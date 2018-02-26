
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

local RealTime = RealTime
local DLib = DLib
local FFGSHUD = FFGSHUD
local LerpCubic = LerpCubic
local IsValid = FindMetaTable('Entity').IsValid

FFGSHUD.ammoHUDAnimationTime = 0
FFGSHUD.ammoStoredHUDAnimationTime = 0
FFGSHUD.LastWeaponUpdate = RealTime()
FFGSHUD.LastWeaponUpdateFadeIn = RealTime()
FFGSHUD.LastWeaponUpdateFadeOutStart = RealTime()
FFGSHUD.LastWeaponUpdateFadeOutEnd = RealTime()

function FFGSHUD:PlayingStoredAmmoAnim()
	return self.ammoStoredHUDAnimationTime > RealTime()
end

function FFGSHUD:StoredAmmoAnim()
	return LerpCosine((self.ammoStoredHUDAnimationTime - RealTime()):progression(0, 0.4), 0, 1)
end

function FFGSHUD:ReadyAmmoAnim()
	return LerpCosine((self.ammoHUDAnimationTime - RealTime()):progression(0, 0.4), 0, 1)
end

function FFGSHUD:PlayingReadyAmmoAnim()
	return self.ammoHUDAnimationTime > RealTime()
end

local function changes(s, self, lply, old, new)
	self.LastWeaponUpdate = RealTime()

	if (not old or old > new) and self.LastWeaponUpdateFadeOutStart < RealTime() then
		self.LastWeaponUpdateFadeIn = RealTime() + 0.5
	else
		self.LastWeaponUpdateFadeIn = RealTime() - 0.5
	end

	self.LastWeaponUpdateFadeOutStart = RealTime() + 3
	self.LastWeaponUpdateFadeOutEnd = RealTime() + 3.5
end

function FFGSHUD:OnWeaponChanged(old, new)
	if not IsValid(old) or not IsValid(new) then return end

	local ammoReadyText, ammoStoredText, clip2AmmoText, stored2AmmoText = self:GetAmmoDisplayText()

	if old:GetPrimaryAmmoType() ~= new:GetPrimaryAmmoType() or old:GetSecondaryAmmoType() ~= new:GetSecondaryAmmoType() then
		self.animateStoredAmmoHUD = true
		self.ammoStoredHUDAnimationTime = RealTime() + 0.4
		self.oldStoredAmmoString = ammoStoredText
		self.oldStored2AmmoText = stored2AmmoText
	end

	self.animateAmmoHUD = true
	self.ammoHUDAnimationTime = RealTime() + 0.4
	self.oldReadyAmmoString = ammoReadyText
	self.oldReady2AmmoString = clip2AmmoText
	changes(nil, self)
end

local input = input

function FFGSHUD:WatchdogForReload()
	if not self:CanHideAmmoCounter() then self.reloadWatchdog = false return end
	local bind = input.LookupBinding('reload')
	if not bind then self.reloadWatchdog = false return end
	local key = DLib.KeyMap.GetKeyFromString(bind)

	if input.IsKeyDown(key) then
		self.LastWeaponUpdate = RealTime()
		self.LastWeaponUpdateFadeOutStart = RealTime() + 3
		self.LastWeaponUpdateFadeOutEnd = RealTime() + 3.5

		if not self.reloadWatchdog then
			self.reloadWatchdog = true
			self.LastWeaponUpdateFadeIn = RealTime() + 0.5
		end
	else
		self.reloadWatchdog = self.LastWeaponUpdateFadeOutStart > RealTime()
	end
end

FFGSHUD:SetOnChangeHook('ammoType1', changes)
FFGSHUD:SetOnChangeHook('ammoType2', changes)
FFGSHUD:SetOnChangeHook('clip1', changes)
FFGSHUD:SetOnChangeHook('clip2', changes)
FFGSHUD:SetOnChangeHook('clipMax1', changes)
FFGSHUD:SetOnChangeHook('clipMax2', changes)
FFGSHUD:SetOnChangeHook('weaponName', changes)
FFGSHUD:AddThinkHook('WatchdogForReload')
