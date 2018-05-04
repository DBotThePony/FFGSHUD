
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
FFGSHUD.ENABLE_CROSSHAIRS = FFGSHUD:CreateConVar('crosshair', '1', 'Enable custom crosshair')

local CrosshairColor = FFGSHUD:CreateColorN('crosshair', 'Crosshair Outline Color', Color(0, 0, 0))
local CrosshairColorInner = FFGSHUD:CreateColorN('crosshair_inner', 'Crosshair Color', Color())

local IsValid = IsValid
local ScreenSize = ScreenSize
local surface = surface
local hook = hook
local math = math
local DRAW_STATUS = false

local RealFrameTime = RealFrameTime
local CROSSHAIR_FADE = 1

local function catch(err)
	print(debug.traceback('[4Hud] Catching - ' .. err, 2))
end

function FFGSHUD:DrawCrosshair(ply)
	if not self.ENABLE_CROSSHAIRS:GetBool() then return end
	if not self:GetVarAlive() then return end

	if self:GetVarInVehicle() and not self:GetVarWeaponsInVehicle() then return end

	local wep = self:GetWeapon()
	local drawing = true

	if IsValid(wep) then
		if wep.DrawCrosshair == false or wep.HUDShouldDraw and wep:HUDShouldDraw('CHudCrosshair') == false then
			drawing = false
		end
	end

	if drawing then
		DRAW_STATUS = true
		drawing = hook.Run('HUDShouldDraw', 'CHudCrosshair') ~= false
		DRAW_STATUS = false
	end

	local tr, d, x, y

	if drawing then
		tr = ply:GetEyeTrace()
		d = tr.HitPos:ToScreen()
		x, y = math.ceil(d.x / 1.3) * 1.3, math.ceil(d.y / 1.3) * 1.3

		if IsValid(wep) and wep.DoDrawCrosshair then
			--local execStatus, status = xpcall(wep.DoDrawCrosshair, catch, wep, x, y)
			local status = wep:DoDrawCrosshair(x, y)
			drawing = status ~= true
		end
	end

	if drawing then
		CROSSHAIR_FADE = (CROSSHAIR_FADE + RealFrameTime() * 6):min(1)
	else
		if CROSSHAIR_FADE == 0 then return end
		CROSSHAIR_FADE = (CROSSHAIR_FADE - RealFrameTime() * 6):max(0)
	end

	local size = ScreenSize(2)
	local CrosshairColor = CrosshairColor(63 * CROSSHAIR_FADE)

	for gapSize = 1, 3 do
		local gap = size + ScreenSize(gapSize)

		surface.SetDrawColor(CrosshairColor)
		HUDCommons.DrawCircle(x - (gap / 2):floor(), y - (gap / 2):floor(), gap, 20)
	end

	surface.SetDrawColor(CrosshairColorInner(255 * CROSSHAIR_FADE))
	HUDCommons.DrawCircle(x - (size / 2):floor(), y - (size / 2):floor(), size, 20)
end

function FFGSHUD:CrosshairShouldDraw(element)
	if element == 'CHudCrosshair' and not DRAW_STATUS and self.ENABLE_CROSSHAIRS:GetBool() then
		return false
	end
end

FFGSHUD:AddHookCustom('HUDShouldDraw', 'CrosshairShouldDraw')
FFGSHUD:AddPaintHook('DrawCrosshair')
