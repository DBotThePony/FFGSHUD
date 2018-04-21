
-- Copyright (C) 2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local RealTimeL = RealTimeL
local DLib = DLib
local FFGSHUD = FFGSHUD
local LerpCubic = LerpCubic
local IsValid = FindMetaTable('Entity').IsValid

FFGSHUD.ammoHUDAnimationTime = 0
FFGSHUD.ammoStoredHUDAnimationTime = 0
FFGSHUD.swipeAnimationTime = 0
FFGSHUD.LastWeaponUpdate = RealTimeL()
FFGSHUD.LastWeaponUpdateFadeIn = RealTimeL()
FFGSHUD.LastWeaponUpdateFadeOutStart = RealTimeL()
FFGSHUD.LastWeaponUpdateFadeOutEnd = RealTimeL()

FFGSHUD.LastWeaponUpdate2 = RealTimeL()
FFGSHUD.LastWeaponUpdateFadeIn2 = RealTimeL()
FFGSHUD.LastWeaponUpdateFadeOutStart2 = RealTimeL()
FFGSHUD.LastWeaponUpdateFadeOutEnd2 = RealTimeL()

FFGSHUD.HealthFadeInStart = 0
FFGSHUD.HealthFadeInEnd = 0
FFGSHUD.HealthFadeOutStart = 0
FFGSHUD.HealthFadeOutEnd = 0

function FFGSHUD:PlayingSwipeAnimation()
	return self.swipeAnimationTime > RealTimeL()
end

function FFGSHUD:SwipeAnimationDuration()
	return RealTimeL():progression(self.swipeAnimationTime - 0.4, self.swipeAnimationTime)
end

local function changes(s, self, lply, old, new)
	self.LastWeaponUpdate = RealTimeL()

	if (not old or old > new) and self.LastWeaponUpdateFadeOutStart < RealTimeL() then
		self.LastWeaponUpdateFadeIn = RealTimeL() + 0.5
	else
		self.LastWeaponUpdateFadeIn = RealTimeL() - 0.5
	end

	self.LastWeaponUpdateFadeOutStart = RealTimeL() + 3
	self.LastWeaponUpdateFadeOutEnd = RealTimeL() + 3.5
end

local function changes2(s, self, lply, old, new)
	self.LastWeaponUpdate2 = RealTimeL()

	if (not old or old > new) and self.LastWeaponUpdateFadeOutStart2 < RealTimeL() then
		self.LastWeaponUpdateFadeIn2 = RealTimeL() + 0.5
	else
		self.LastWeaponUpdateFadeIn2 = RealTimeL() - 0.5
	end

	self.LastWeaponUpdateFadeOutStart2 = RealTimeL() + 1.5
	self.LastWeaponUpdateFadeOutEnd2 = RealTimeL() + 2
end

function FFGSHUD:OnWeaponChanged(old, new)
	if not IsValid(old) or not IsValid(new) then return end

	local ammoReadyText, ammoStoredText, clip2AmmoText, stored2AmmoText = self:GetAmmoDisplayText()

	self.swipeAnimationTime = RealTimeL() + 0.4

	self.oldWeaponName = self:GetVarWeaponName()
	self.oldStoredAmmoString = ammoStoredText
	self.oldStored2AmmoText = stored2AmmoText
	self.oldReadyAmmoString = ammoReadyText
	self.oldReadyAmmoPerc = 1 - self:GetAmmoFillage1()
	self.oldReady2AmmoString = clip2AmmoText
	self.oldReady2AmmoPerc = 1 - self:GetAmmoFillage2()

	self.swipeDirection = old:GetSlot() ~= new:GetSlot() or old:GetSlotPos() < new:GetSlotPos()

	changes(nil, self)
end

local input = input

function FFGSHUD:WatchdogForReload()
	local bind = input.LookupBinding('reload')
	if not bind then self.reloadWatchdog = false return end
	local key = DLib.KeyMap.GetKeyFromString(bind)
	local canHide = self:CanHideAmmoCounter()

	if not canHide then self.reloadWatchdog = false end

	if input.IsKeyDown(key) then
		if self.HealthFadeOutEnd < RealTimeL() then
			self.HealthFadeInStart = RealTimeL()
			self.HealthFadeInEnd = RealTimeL() + 0.5
			self.HealthFadeOutStart = RealTimeL() + 3
			self.HealthFadeOutEnd = RealTimeL() + 3.5
		else
			self.HealthFadeOutStart = RealTimeL() + 3
			self.HealthFadeOutEnd = RealTimeL() + 3.5
		end

		if canHide then
			self.LastWeaponUpdate = RealTimeL()
			self.LastWeaponUpdateFadeOutStart = RealTimeL() + 3
			self.LastWeaponUpdateFadeOutEnd = RealTimeL() + 3.5

			if not self.reloadWatchdog then
				self.reloadWatchdog = true
				self.LastWeaponUpdateFadeIn = RealTimeL() + 0.5
			end
		end
	else
		self.reloadWatchdog = self.LastWeaponUpdateFadeOutStart > RealTimeL()
	end
end

FFGSHUD:SetOnChangeHook('ammoType1', changes)
FFGSHUD:SetOnChangeHook('ammoType2', changes)
FFGSHUD:SetOnChangeHook('clip1', changes)
FFGSHUD:SetOnChangeHook('clip2', changes)
FFGSHUD:SetOnChangeHook('clipMax1', changes)
FFGSHUD:SetOnChangeHook('clipMax2', changes)
FFGSHUD:SetOnChangeHook('ammo1', changes)
FFGSHUD:SetOnChangeHook('ammo2', changes)
FFGSHUD:SetOnChangeHook('weaponName', changes)

FFGSHUD:SetOnChangeHook('ammoType1_Select', changes2)
FFGSHUD:SetOnChangeHook('ammoType2_Select', changes2)
FFGSHUD:SetOnChangeHook('clip1_Select', changes2)
FFGSHUD:SetOnChangeHook('clip2_Select', changes2)
FFGSHUD:SetOnChangeHook('clipMax1_Select', changes2)
FFGSHUD:SetOnChangeHook('clipMax2_Select', changes2)
FFGSHUD:SetOnChangeHook('ammo1_Select', changes2)
FFGSHUD:SetOnChangeHook('ammo2_Select', changes2)
FFGSHUD:SetOnChangeHook('weaponName_Select', changes2)

FFGSHUD:PatchOnChangeHook('alive', function(s, self, ply, old, new)
	if new then
		self.isPlayingDeathAnim = false
	else
		self.isPlayingDeathAnim = true
		self.deathAnimTimeFadeStart = RealTimeL() + 2.5
		self.deathAnimTimeFadeEnd = RealTimeL() + 4.5
	end
end)

FFGSHUD:PatchOnChangeHook('health', function(s, self, ply, old, new)
	if self.HealthFadeOutEnd < RealTimeL() then
		self.HealthFadeInStart = RealTimeL()
		self.HealthFadeInEnd = RealTimeL() + 0.5
		self.HealthFadeOutStart = RealTimeL() + 3
		self.HealthFadeOutEnd = RealTimeL() + 3.5
	else
		self.HealthFadeOutStart = RealTimeL() + 3
		self.HealthFadeOutEnd = RealTimeL() + 3.5
	end
end)

FFGSHUD:PatchOnChangeHook('armor', function(s, self, ply, old, new)
	if self.HealthFadeOutEnd < RealTimeL() then
		self.HealthFadeInStart = RealTimeL()
		self.HealthFadeInEnd = RealTimeL() + 0.5
		self.HealthFadeOutStart = RealTimeL() + 3
		self.HealthFadeOutEnd = RealTimeL() + 3.5
	else
		self.HealthFadeOutStart = RealTimeL() + 3
		self.HealthFadeOutEnd = RealTimeL() + 3.5
	end
end)

FFGSHUD:AddThinkHook('WatchdogForReload')
