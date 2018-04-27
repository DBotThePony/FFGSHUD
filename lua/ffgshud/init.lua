
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

_G.FFGSHUD = DLib.ConsturctClass('HUDCommonsBase', 'ffgs_hud', 'FFGS HUD')
local FFGSHUD = FFGSHUD
local DLib = DLib
local surface = surface
local HUDCommons = DLib.HUDCommons

FFGSHUD.WeaponName = FFGSHUD:CreateScalableFont('WeaponName', {
	font = 'PT Sans',
	size = 40,
	weight = 600
})

FFGSHUD.PlayerName = FFGSHUD:CreateScalableFont('PlayerName', {
	font = 'PT Sans',
	size = 40,
	weight = 600
})

FFGSHUD.AmmoAmount = FFGSHUD:CreateScalableFont('AmmoAmount', {
	font = 'PT Mono',
	size = 60,
	weight = 600
})

FFGSHUD.AmmoAmount2 = FFGSHUD:CreateScalableFont('AmmoAmount2', {
	font = 'PT Mono',
	size = 38,
	weight = 600
})

FFGSHUD.AmmoStored = FFGSHUD:CreateScalableFont('AmmoStored', {
	font = 'PT Mono',
	size = 38,
	weight = 600
})

FFGSHUD.AmmoStored2 = FFGSHUD:CreateScalableFont('AmmoStored2', {
	font = 'PT Mono',
	size = 38,
	weight = 600
})

FFGSHUD.Health = FFGSHUD:CreateScalableFont('Health', {
	font = 'Exo 2',
	size = 64,
	weight = 600
})

FFGSHUD.VehicleHealth = FFGSHUD:CreateScalableFont('VehicleHealth', {
	font = 'PT Mono',
	size = 64,
	weight = 600
})

FFGSHUD.Armor = FFGSHUD:CreateScalableFont('Armor', {
	font = 'Exo 2',
	size = 38,
	weight = 600
})

FFGSHUD.TargetID_Name = FFGSHUD:CreateScalableFont('TargetID_Name', {
	font = 'PT Sans',
	size = 26,
	weight = 600,
})

FFGSHUD.KillfeedFont = FFGSHUD:CreateScalableFont('KillfeedFont', {
	font = 'Roboto',
	size = 13,
	weight = 600,
})

FFGSHUD.TargetID_Health = FFGSHUD:CreateScalableFont('TargetID_Health', {
	font = 'Exo 2',
	size = 18,
})

FFGSHUD.TargetID_Armor = FFGSHUD:CreateScalableFont('TargetID_Armor', {
	font = 'Exo 2',
	size = 14,
})

FFGSHUD.BattleStats = FFGSHUD:CreateScalableFont('BattleStats', {
	font = 'Roboto',
	size = 34,
})

FFGSHUD.LastDamageDealed = FFGSHUD:CreateScalableFont('LastDamageDealed', {
	font = 'PT Mono',
	size = 64,
	weight = 600
})

FFGSHUD.CompassDirections = FFGSHUD:CreateScalableFont('CompassDirections', {
	font = 'Roboto',
	size = 13,
	weight = 600
})

FFGSHUD.CompassAngle = FFGSHUD:CreateScalableFont('CompassAngle', {
	font = 'Roboto',
	size = 16,
	weight = 600
})

FFGSHUD.SelectionNumber = FFGSHUD:CreateScalableFont('SelectionNumber', {
	font = 'Roboto',
	size = 20,
	weight = 600
})

FFGSHUD.SelectionNumberActive = FFGSHUD:CreateScalableFont('SelectionNumberActive', {
	font = 'Roboto',
	size = 28,
	weight = 600
})

FFGSHUD.SelectionText = FFGSHUD:CreateScalableFont('SelectionText', {
	font = 'PT Sans',
	size = 24,
	weight = 600
})

FFGSHUD.PickupHistoryFont = FFGSHUD:CreateScalableFont('PickupHistoryFont', {
	font = 'PT Mono',
	size = 18,
	weight = 600
})

FFGSHUD.ICON_FRAGS = '♐'
FFGSHUD.ICON_DEATHS = '☠'
FFGSHUD.ICON_PING = '☍'

local render = render
local ScreenSize = ScreenSize
local color_black = Color(0, 0, 0)
local TEXT_DISPERSION_SHIFT_DOWN = 0.4
local TEXT_DISPERSION_SHIFT_UP = 0.4
local DISPERSION_ALPHA_1 = 1
local DISPERSION_ALPHA_2 = 1
local DISPERSION_ALPHA_3 = 1

local function redraw(text, fontBase, x, y, color)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, Color(color):SetAlpha(color.a * 0.04))

	local color1 = Color(color.r, 0, 0, color.a * DISPERSION_ALPHA_1)
	local color2 = Color(0, color.g, 0, color.a * DISPERSION_ALPHA_2)
	local color3 = Color(0, 0, color.b, color.a * DISPERSION_ALPHA_3)

	x, y = x:floor(), y:floor()
	color_black.a = color.a
	HUDCommons.SimpleText(text, fontBase.REGULAR, x, y, color_black)
	color_black.a = 255
	HUDCommons.SimpleText(text, fontBase.REGULAR_ADDITIVE, x, y - ScreenSize(TEXT_DISPERSION_SHIFT_UP):max(1):floor(), color3)
	local a, b, c, d, e, f = HUDCommons.SimpleText(text, fontBase.REGULAR_ADDITIVE, x, y, color2)
	HUDCommons.SimpleText(text, fontBase.REGULAR_ADDITIVE, x, y + ScreenSize(TEXT_DISPERSION_SHIFT_DOWN):max(1):floor(), color1)
	return a, b, c, d, e, f
end

local function redrawRight(text, fontBase, x, y, color)
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, Color(color):SetAlpha(color.a * 0.04))

	local color1 = Color(color.r, 0, 0, color.a * DISPERSION_ALPHA_1)
	local color2 = Color(0, color.g, 0, color.a * DISPERSION_ALPHA_2)
	local color3 = Color(0, 0, color.b, color.a * DISPERSION_ALPHA_3)

	x, y = x:floor(), y:floor()
	color_black.a = color.a
	HUDCommons.SimpleTextRight(text, fontBase.REGULAR, x, y, color_black)
	color_black.a = 255
	HUDCommons.SimpleTextRight(text, fontBase.REGULAR_ADDITIVE, x, y + ScreenSize(TEXT_DISPERSION_SHIFT_DOWN):max(1):floor(), color3)
	local a, b, c, d, e, f = HUDCommons.SimpleTextRight(text, fontBase.REGULAR_ADDITIVE, x, y, color2)
	HUDCommons.SimpleTextRight(text, fontBase.REGULAR_ADDITIVE, x, y - ScreenSize(TEXT_DISPERSION_SHIFT_UP):max(1):floor(), color1)
	return a, b, c, d, e, f
end

local function redrawCenter(text, fontBase, x, y, color)
	HUDCommons.SimpleTextCentered(text, fontBase.BLURRY, x, y, Color(color):SetAlpha(color.a * 0.04))

	local color1 = Color(color.r, 0, 0, color.a * DISPERSION_ALPHA_1)
	local color2 = Color(0, color.g, 0, color.a * DISPERSION_ALPHA_2)
	local color3 = Color(0, 0, color.b, color.a * DISPERSION_ALPHA_3)

	x, y = x:floor(), y:floor()
	color_black.a = color.a
	HUDCommons.SimpleTextCentered(text, fontBase.REGULAR, x, y, color_black)
	color_black.a = 255
	HUDCommons.SimpleTextCentered(text, fontBase.REGULAR_ADDITIVE, x, y + ScreenSize(TEXT_DISPERSION_SHIFT_DOWN):max(1):floor(), color3)
	local a, b, c, d, e, f = HUDCommons.SimpleTextCentered(text, fontBase.REGULAR_ADDITIVE, x, y, color2)
	HUDCommons.SimpleTextCentered(text, fontBase.REGULAR_ADDITIVE, x, y - ScreenSize(TEXT_DISPERSION_SHIFT_UP):max(1):floor(), color1)
	return a, b, c, d, e, f
end

function FFGSHUD:DrawShadowedText(fontBase, text, x, y, color)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255
	redraw(text, fontBase, x, y, color)
	return surface.GetTextSize(text)
end

function FFGSHUD:DrawShadowedTextCustom(fontBase, text, x, y, color, shadow)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadow)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadow)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadow)

	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, Color(color):SetAlpha(color.a * 0.06))

	redraw(text, fontBase, x, y, color)
	return surface.GetTextSize(text)
end

function FFGSHUD:DrawShadowedTextPerc(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255

	if perc ~= 1 then
		redraw(text, fontBase, x, y, color)
	end

	local w, h = surface.GetTextSize(text)

	render.PushScissorRect(x - w, y + h * (1 - perc) - TEXT_DISPERSION_SHIFT_UP, x + w, y + h + TEXT_DISPERSION_SHIFT_DOWN)
	redraw(text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextPercH(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255

	local w, h = surface.GetTextSize(text)

	render.PushScissorRect(x + w * perc, y, x + w, y + h)
	redraw(text, fontBase, x, y, color)
	render.PopScissorRect()

	render.PushScissorRect(x, y - TEXT_DISPERSION_SHIFT_UP, x + w * perc, y + h + TEXT_DISPERSION_SHIFT_DOWN)
	redraw(text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextPercHCustomShadow(fontBase, text, x, y, color, perc, colorPerc, colorShadow)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	surface.SetFont(fontBase.REGULAR)
	local w, h = surface.GetTextSize(text)

	render.PushScissorRect(x + w * perc, y, x + w, y + h)
	color_black.a = color.a
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255
	render.PopScissorRect()

	render.PushScissorRect(x, y, x + w * perc, y + h)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, colorShadow)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, colorShadow)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, colorShadow)
	render.PopScissorRect()

	render.PushScissorRect(x + w * perc, y, x + w, y + h)
	redraw(text, fontBase, x, y, color)
	render.PopScissorRect()

	render.PushScissorRect(x, y - TEXT_DISPERSION_SHIFT_UP, x + w * perc, y + h + TEXT_DISPERSION_SHIFT_DOWN)
	redraw(text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextPerc2(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255

	local w, h = surface.GetTextSize(text)

	render.PushScissorRect(x - w, y, x + w, y + h * (1 - perc))

	if perc ~= 1 then
		redraw(text, fontBase, x, y, color)
	end

	render.PopScissorRect()
	render.PushScissorRect(x - w, y + h * (1 - perc) - TEXT_DISPERSION_SHIFT_UP, x + w, y + h + TEXT_DISPERSION_SHIFT_DOWN)
	redraw(text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextPercInv(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	color_black.a = color.a
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255

	local w, h = surface.GetTextSize(text)

	render.PushScissorRect(x - w, y - TEXT_DISPERSION_SHIFT_UP, x + w, y + h * perc + TEXT_DISPERSION_SHIFT_DOWN)
	redraw(text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	render.PushScissorRect(x - w, y + h * perc, x + w, y + h)
	redraw(text, fontBase, x, y, color)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextPercCustomInv(fontBase, text, x, y, color, shadowColor, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadowColor)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadowColor)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadowColor)

	local w, h = surface.GetTextSize(text)

	render.PushScissorRect(x - w, y - TEXT_DISPERSION_SHIFT_UP, x + w, y + h * perc + TEXT_DISPERSION_SHIFT_DOWN)
	redraw(text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	render.PushScissorRect(x - w, y + h * perc, x + w, y + h)
	redraw(text, fontBase, x, y, color)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextAligned(fontBase, text, x, y, color)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255
	return redrawRight(text, fontBase, x, y, color)
end

function FFGSHUD:DrawShadowedTextAlignedCustom(fontBase, text, x, y, color, shadow)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, shadow)
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, shadow)
	return redrawRight(text, fontBase, x, y, color)
end

function FFGSHUD:DrawShadowedTextAlignedPerc(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255

	local w, h

	if perc ~= 1 then
		w, h = redrawRight(text, fontBase, x, y, color)
	else
		w, h = surface.GetTextSize(text)
	end

	render.PushScissorRect(x - w, y + h * (1 - perc) - TEXT_DISPERSION_SHIFT_UP, x + w, y + h + TEXT_DISPERSION_SHIFT_DOWN)
	redrawRight(text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextAlignedPercInv(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
	local w, h = HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255

	render.PushScissorRect(x - w, y - TEXT_DISPERSION_SHIFT_UP, x + w, y + h * perc + TEXT_DISPERSION_SHIFT_DOWN)
	redrawRight(text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	render.PushScissorRect(x - w, y + h * perc, x + w, y + h)
	redrawRight(text, fontBase, x, y, color)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextAlignedPercCustomInv(fontBase, text, x, y, color, shadowColor, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, shadowColor)
	local w, h = HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, shadowColor)

	render.PushScissorRect(x - w, y - TEXT_DISPERSION_SHIFT_UP, x + w, y + h * perc + TEXT_DISPERSION_SHIFT_DOWN)
	redrawRight(text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	render.PushScissorRect(x - w, y + h * perc, x + w, y + h)
	redrawRight(text, fontBase, x, y, color)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextCentered(fontBase, text, x, y, color)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleTextCentered(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255
	return redrawCenter(text, fontBase, x, y, color)
end

for k, v in pairs(FFGSHUD) do
	if type(k) == 'string' and k:startsWith('DrawShadowedText') then
		FFGSHUD[k .. 'Up'] = function(self, fontBase, text, x, y, ...)
			y = y - fontBase.REGULAR_SIZE_H
			return v(self, fontBase, text, x, y, ...)
		end
	end
end

function FFGSHUD:HUDShouldDraw(target)
	if
		target == 'CHudAmmo' or
		target == 'CHudBattery' or
		target == 'CHudHealth' or
		target == 'CHudPoisonDamageIndicator' or
		target == 'CHudDamageIndicator' or
		target == 'CHudSecondaryAmmo'
	then
		return false
	end
end

FFGSHUD:AddHook('HUDShouldDraw')

include('vars.lua')
include('basicpaint.lua')
include('vehicle.lua')
include('functions.lua')
include('targetid.lua')
include('anims.lua')
include('binfo.lua')
include('dmgtrack.lua')
include('glitch.lua')
include('killfeed.lua')
include('compass.lua')
include('wepselect.lua')
include('history.lua')
