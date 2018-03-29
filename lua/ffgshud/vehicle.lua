
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

local POS_VEHICLESTATS = FFGSHUD:DefinePosition('vehiclestats', 0.07, 0.63)
local color_white = Color()

local FillageColorHealth = FFGSHUD:CreateColorN('fillage_hp', 'Fillage Color for HP', Color(80, 80, 80))
local FillageColorHealthShadow = FFGSHUD:CreateColorN('fillage_hp_sh', 'Fillage Color for HP Shadow', Color(230, 0, 0))
local VehicleName = FFGSHUD:CreateColorN('vehname', 'Vehicle Name', Color())
local HPColor = FFGSHUD:CreateColorN('vehcolor', 'Vehicle Health', Color())

local math = math
local RealTimeL = RealTimeL
local pi = math.pi * 16
local function RealTimeLAnim()
	return RealTimeL() % pi
end

function FFGSHUD:DrawVehicleInfo()
	if not self:GetVarAlive() then return end
	if self:GetVarVehicleName() == '' then return end

	local x, y = POS_VEHICLESTATS()

	local w, h = self:DrawShadowedTextUp(self.PlayerName, self:GetVarVehicleName(), x, y, VehicleName())
	y = y - h * 0.83

	local fillage = 1 - self:GetVehicleHealthFillage()

	if self:GetVarVehicleMaxHealth() > 1 then
		if fillage < 0.5 then
			self:DrawShadowedTextPercInvUp(self.VehicleHealth, self:GetVarVehicleHealth(), x, y, HPColor(), fillage, FillageColorHealth())
		else
			self:DrawShadowedTextPercCustomInvUp(self.VehicleHealth, self:GetVarVehicleHealth(), x, y, HPColor(), FillageColorHealthShadow(math.sin(RealTimeLAnim() * fillage * 30) * 64 + 130), fillage, FillageColorHealth())
		end
	elseif self:GetVarVehicleHealth() > 0 then
		self:DrawShadowedTextUp(self.VehicleHealth, self:GetVarVehicleHealth(), x, y, HPColor())
	end
end

FFGSHUD:AddPaintHook('DrawVehicleInfo')
