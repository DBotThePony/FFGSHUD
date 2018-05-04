
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
local CrosshairColorInner = FFGSHUD:CreateColorN('crosshair_inner', 'Crosshair Color', Color(200, 200, 200))

local IsValid = IsValid
local ScreenSize = ScreenSize
local surface = surface
local hook = hook
local math = math
local DRAW_STATUS = false

local function DrawRect(x, y, w, h)
	return surface.DrawRect(x:floor(), y:floor(), w:floor(), h:floor())
end

local function catch(err)
	print(debug.traceback('[4Hud] Catching - ' .. err, 2))
end

function FFGSHUD:DrawCrosshair(ply)
	if not self.ENABLE_CROSSHAIRS:GetBool() then return end

	if self:GetVarInVehicle() and not self:GetVarWeaponsInVehicle() then return end

	local wep = self:GetWeapon()

	if IsValid(wep) then
		if wep.HUDShouldDraw and wep:HUDShouldDraw('CHudCrosshair') == false then return end
		if wep.DrawCrosshair == false then return end
	end

	DRAW_STATUS = true
	local can = hook.Run('HUDShouldDraw', 'CHudCrosshair')
	DRAW_STATUS = false

	if can == false then return end

	local tr = ply:GetEyeTrace()
	local d = tr.HitPos:ToScreen()
	local x, y = math.ceil(d.x / 1.1) * 1.1, math.ceil(d.y / 1.1) * 1.1

	if IsValid(wep) and wep.DoDrawCrosshair then
		--local execStatus, status = xpcall(wep.DoDrawCrosshair, catch, wep, x, y)
		local status = wep:DoDrawCrosshair(x, y)
		if status == true then return end
	end

	local size = ScreenSize(2):floor()
	local CrosshairColor = CrosshairColor(35)

	for gapSize = 0.5, 3, 0.5 do
		local gap = size + ScreenSize(gapSize):floor()

		surface.SetDrawColor(CrosshairColor)
		HUDCommons.DrawCircle(x - gap / 2, y - gap / 2, gap, 20)
	end

	surface.SetDrawColor(CrosshairColorInner())
	HUDCommons.DrawCircle(x - size / 2, y - size / 2, size, 20)
end

function FFGSHUD:CrosshairShouldDraw(element)
	if element == 'CHudCrosshair' and not DRAW_STATUS and self.ENABLE_CROSSHAIRS:GetBool() then
		return false
	end
end

FFGSHUD:AddHookCustom('HUDShouldDraw', 'CrosshairShouldDraw')
FFGSHUD:AddPaintHook('DrawCrosshair')
