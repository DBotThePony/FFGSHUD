
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
local ANG_WIDE = 270
local ipairs = ipairs
local HUDCommons = DLib.HUDCommons
local surface = surface
local ScreenSize = ScreenSize
local render = render
local color_white = Color()
local ScrWL, ScrHL = ScrWL, ScrHL

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

local function drawMarkers(x, y, angle, shiftby)
	local mult = ScreenSize(1)
	for i, dir in ipairs(directions) do
		local lang = (i + shiftby - 1) * 45
		HUDCommons.SimpleTextCentered(dir, nil, x - (lang - angle) * mult, y)
	end

	surface.SetDrawColor(225, 225, 225)
	y = y + ScreenSize(2)
	local wide, tall = ScreenSize(1):max(1), ScreenSize(4)

	for i = 1, #directions * 4 do
		local lang = (i + shiftby - 1) * 15

		if lang % 45 ~= 0 then
			surface.DrawRect(x - (lang - angle) * mult - wide / 2, y, wide, tall)
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

	render.PushScissorRect(x - ANG_WIDE / 2 * ScreenSize(1), y, x + ANG_WIDE / 2 * ScreenSize(1), y + ScreenSize(40))

	surface.SetDrawColor(170, 225, 150)
	local wide, tall = ScreenSize(2):max(1), ScreenSize(8)

	surface.DrawRect(x - wide / 2, y, wide, tall)

	drawMarkers(x, y, angle, 0)

	if angle < ANG_WIDE / 3 then
		drawMarkers(x, y, angle, -#directions)
	end

	if angle > ANG_WIDE / 2 then
		drawMarkers(x, y, angle, #directions)
	end

	render.PopScissorRect()

	HUDCommons.SimpleTextCentered(angle:floor(), self.CompassAngle.REGULAR, x, y + ScreenSize(10))
end

FFGSHUD:AddPaintHook('DrawCompass')
