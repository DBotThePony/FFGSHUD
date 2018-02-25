
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

function FFGSHUD:StoredAmmoAnim()
	return LerpCubic((self.ammoStoredHUDAnimationTime - RealTime()):progression(0, 0.4), 0, 1)
end

function FFGSHUD:ReadyAmmoAnim()
	return LerpCubic((self.ammoHUDAnimationTime - RealTime()):progression(0, 0.4), 0, 1)
end

function FFGSHUD:OnWeaponChanged(old, new)
	if not IsValid(old) or not IsValid(new) then return end

	if old:GetPrimaryAmmoType() ~= new:GetPrimaryAmmoType() or old:GetSecondaryAmmoType() ~= new:GetSecondaryAmmoType() then
		self.animateStoredAmmoHUD = true
		self.ammoStoredHUDAnimationTime = RealTime() + 0.4
	end

	self.animateAmmoHUD = true
	self.ammoHUDAnimationTime = RealTime() + 0.4
end
