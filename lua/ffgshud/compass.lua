
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

local DRAWPOS = FFGSHUD:DefinePosition('compass', 0.5, 0.04)
local ipairs = ipairs
local HUDCommons = DLib.HUDCommons
local surface = surface
local ScreenSize = ScreenSize
local render = render
local color_white = Color()
local ScrWL, ScrHL = ScrWL, ScrHL
local ScreenSize = ScreenSize
local TEXT_DISPERSION_SHIFT_DOWN = 0.25
local TEXT_DISPERSION_SHIFT_UP = 0.25

local directions = {
	'S',
	'SE',
	'E',
	'NE',
	'N',
	'NW',
	'W',
	'SW',
}

local TOP_COLOR = Color(204, 134, 23, 200)
local DEFAULT_COLOR = Color()
local BOTTOM_COLOR = Color(55, 229, 202, 200)

local function drawMarkers(x, y, angle, shiftby)
	x, y = x:floor(), y:floor()
	local mult = ScreenSize(1)

	for i, dir in ipairs(directions) do
		local lang = ((i + shiftby - 1) * 45)
		HUDCommons.SimpleTextCentered(dir, nil, (x - (lang - angle) * mult):floor(), y - ScreenSize(TEXT_DISPERSION_SHIFT_UP):max(1):floor(), TOP_COLOR)
		HUDCommons.SimpleTextCentered(dir, nil, (x - (lang - angle) * mult):floor(), y + ScreenSize(TEXT_DISPERSION_SHIFT_DOWN):max(1):floor(), BOTTOM_COLOR)
		HUDCommons.SimpleTextCentered(dir, nil, (x - (lang - angle) * mult):floor(), y, DEFAULT_COLOR)
	end

	y = y + ScreenSize(2)
	local wide, tall = ScreenSize(1):max(1):round(), ScreenSize(4):round()

	for i = 1, (#directions - 2) * 4 do
		local lang = ((i + shiftby - 1) * 15)

		if lang % 45 ~= 0 then
			surface.SetDrawColor(TOP_COLOR)
			surface.DrawRect((x - (lang - angle) * mult - wide / 2):floor(), y - ScreenSize(TEXT_DISPERSION_SHIFT_UP):max(1):floor(), wide, tall)

			surface.SetDrawColor(BOTTOM_COLOR)
			surface.DrawRect((x - (lang - angle) * mult - wide / 2):floor(), y + ScreenSize(TEXT_DISPERSION_SHIFT_DOWN):max(1):floor(), wide, tall)

			surface.SetDrawColor(DEFAULT_COLOR)
			surface.DrawRect((x - (lang - angle) * mult - wide / 2):floor(), y, wide, tall)
		end
	end
end

function FFGSHUD:DrawCompass(ply)
	if not self:GetVarAlive() then return end
	local yaw = ply:EyeAnglesFixed().y
	local angle = yaw

	if angle < 0 then
		angle = 360 + angle
	end

	--local x, y = DRAWPOS()
	local x, y = ScrWL() * 0.5, ScrHL() * 0.04
	surface.SetFont(self.CompassDirections.REGULAR)
	surface.SetTextColor(color_white)

	render.PushScissorRect(x - ScreenSize(135), y, x + ScreenSize(135), y + ScreenSize(40))

	surface.SetDrawColor(170, 225, 150)
	local wide, tall = ScreenSize(2):max(1):round(), ScreenSize(8):round()

	surface.DrawRect(x - wide / 2, y, wide, tall)

	drawMarkers(x, y, angle, 0)

	if angle < 110 then
		drawMarkers(x, y, angle, -#directions)
	end

	if angle > 220 then
		drawMarkers(x, y, angle, #directions)
	end

	render.PopScissorRect()

	self:DrawShadowedTextCentered(self.CompassAngle, angle:floor(), x, y + ScreenSize(10), DEFAULT_COLOR)
end

FFGSHUD:AddPaintHook('DrawCompass')
