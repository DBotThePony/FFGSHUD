
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

local FFGSHUD = FFGSHUD
local IsValid = IsValid
local meta = FindMetaTable('Weapon')

local function GetWeaponName(s, self, ply, weaponName, wep, ...)
	if not meta.IsTFA or not IsValid(wep) or not meta.IsTFA(wep) then return weaponName, wep, ... end
	if not wep.SelectiveFire and not wep.FireModeName and not wep:IsSafety() then return weaponName, wep, ... end

	return ('(%s) %s'):format(wep:GetFireModeName(), weaponName), wep, ...
end

FFGSHUD:SoftPatchTickHook('weaponName', GetWeaponName)
FFGSHUD:SoftPatchTickHook('weaponName_Select', GetWeaponName)
