
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
local HUDCommons = DLib.HUDCommons

local POS_VEHICLESTATS = FFGSHUD:DefinePosition('playerstats', 0.07, 0.66)
local color_white = Color()

function FFGSHUD:DrawVehicleInfo()
	if not self:GetVarAlive() then return end
	if self:GetVarVehicleName() == '' then return end

	local x, y = POS_VEHICLESTATS()

	self:DrawShadowedTextUp(self.PlayerName, self:GetVarVehicleName(), x, y, color_white)
end

FFGSHUD:AddPaintHook('DrawVehicleInfo')
