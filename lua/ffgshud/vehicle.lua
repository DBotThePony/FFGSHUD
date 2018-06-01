
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

FFGSHUD.ENABLE_VEHICLE = FFGSHUD:CreateConVar('vehicle', '1', 'Enable Vehicle HUD')
local color_white = Color()

local FillageColorHealth = FFGSHUD:CreateColorN('fillage_hp', 'Fillage Color for HP', Color(80, 80, 80))
local FillageColorHealthShadow = FFGSHUD:CreateColorN('fillage_hp_sh', 'Fillage Color for HP Shadow', Color(230, 0, 0))
local VehicleName = FFGSHUD:CreateColorN('vehname', 'Vehicle Name', Color())
local HPColor = FFGSHUD:CreateColorN('vehcolor', 'Vehicle Health', Color())

local math = math
local RealTimeL = RealTimeL
local pi = math.pi * 16
local Lerp = Lerp
local lastDrawnHeight = 0
local ScreenSize = ScreenSize
local Quintic = Quintic

local function RealTimeLAnim()
	return RealTimeL() % pi
end

function FFGSHUD:DrawVehicleInfo()
	if not self.ENABLE_VEHICLE:GetBool() then return end
	if not self:GetVarAlive() then return end
	if self:GetVarVehicleName() == '' and not HUDCommons.IsInEditMode() then return end
	local time = RealTimeL()

	local x, y = self.POS_PLAYERSTATS()
	y = y - ScreenSize(10)
	local fullyVisible = self.HPBAR_VISIBLE and self.HealthFadeInEnd < time and self.HealthFadeOutStart > time

	if not fullyVisible then
		if not self.HPBAR_VISIBLE then
			y = y + lastDrawnHeight
		elseif self.HealthFadeInEnd > time then
			local fadeIn = Quintic(1 - time:progression(self.HealthFadeInStart, self.HealthFadeInEnd))
			y = y + lastDrawnHeight * fadeIn
		elseif self.HealthFadeOutStart < time then
			local fadeIn = Quintic(time:progression(self.HealthFadeOutStart, self.HealthFadeOutEnd))
			y = y + lastDrawnHeight * fadeIn
		end
	end

	lastDrawnHeight = ScreenSize(32)

	local w, h = self:DrawShadowedTextUp(self.PlayerName, self:GetVarVehicleName() ~= '' and self:GetVarVehicleName() or 'put vehicle name here', x, y, VehicleName())
	y = y - h * 0.83
	lastDrawnHeight = lastDrawnHeight + h * 0.83

	if HUDCommons.IsInEditMode() and self:GetVarVehicleName() == '' then
		self:DrawShadowedTextPercInvUp(self.VehicleHealth, 255, x, y, HPColor(), 0.4, FillageColorHealth())
		lastDrawnHeight = lastDrawnHeight + h * 0.83
	else
		local fillage = 1 - self:GetVehicleHealthFillage()

		if self:GetVarVehicleMaxHealth() > 1 then
			if fillage < 0.5 then
				w, h = self:DrawShadowedTextPercInvUp(self.VehicleHealth, self:GetVarVehicleHealth(), x, y, HPColor(), fillage, FillageColorHealth())
				lastDrawnHeight = lastDrawnHeight + h * 0.83
			else
				w, h = self:DrawShadowedTextPercCustomInvUp(self.VehicleHealth, self:GetVarVehicleHealth(), x, y, HPColor(), FillageColorHealthShadow(math.sin(RealTimeLAnim() * fillage * 30) * 64 + 130), fillage, FillageColorHealth())
				lastDrawnHeight = lastDrawnHeight + h * 0.83
			end
		elseif self:GetVarVehicleHealth() > 0 then
			w, h = self:DrawShadowedTextUp(self.VehicleHealth, self:GetVarVehicleHealth(), x, y, HPColor())
			lastDrawnHeight = lastDrawnHeight + h * 0.83
		end
	end
end

FFGSHUD:AddPaintHook('DrawVehicleInfo')
