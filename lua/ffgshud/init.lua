
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
	font = 'Roboto',
	size = 40,
	weight = 600
})

FFGSHUD.PlayerName = FFGSHUD:CreateScalableFont('PlayerName', {
	font = 'Roboto',
	size = 40,
	weight = 600
})

FFGSHUD.AmmoAmount = FFGSHUD:CreateScalableFont('AmmoAmount', {
	font = 'Roboto',
	size = 60,
	weight = 600
})

FFGSHUD.AmmoAmount2 = FFGSHUD:CreateScalableFont('AmmoAmount2', {
	font = 'Roboto',
	size = 38,
	weight = 600
})

FFGSHUD.AmmoStored = FFGSHUD:CreateScalableFont('AmmoStored', {
	font = 'Roboto',
	size = 38,
	weight = 600
})

FFGSHUD.AmmoStored2 = FFGSHUD:CreateScalableFont('AmmoStored2', {
	font = 'Roboto',
	size = 38,
	weight = 600
})

FFGSHUD.Health = FFGSHUD:CreateScalableFont('Health', {
	font = 'Roboto',
	size = 64,
	weight = 600
})

FFGSHUD.VehicleHealth = FFGSHUD:CreateScalableFont('VehicleHealth', {
	font = 'Roboto',
	size = 64,
	weight = 600
})

FFGSHUD.Armor = FFGSHUD:CreateScalableFont('Armor', {
	font = 'Roboto',
	size = 38,
	weight = 600
})

FFGSHUD.TargetID_Name = FFGSHUD:CreateScalableFont('TargetID_Name', {
	font = 'Roboto',
	size = 26,
	weight = 600,
})

FFGSHUD.KillfeedFont = FFGSHUD:CreateScalableFont('KillfeedFont', {
	font = 'Roboto',
	size = 13,
	weight = 600,
})

FFGSHUD.TargetID_Health = FFGSHUD:CreateScalableFont('TargetID_Health', {
	font = 'Roboto',
	size = 18,
})

FFGSHUD.TargetID_Armor = FFGSHUD:CreateScalableFont('TargetID_Armor', {
	font = 'Roboto',
	size = 14,
})

FFGSHUD.BattleStats = FFGSHUD:CreateScalableFont('BattleStats', {
	font = 'Roboto',
	size = 34,
})

FFGSHUD.LastDamageDealt = FFGSHUD:CreateScalableFont('LastDamageDealt', {
	font = 'Roboto',
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
	font = 'Roboto',
	size = 24,
	weight = 600
})

FFGSHUD.PickupHistoryFont = FFGSHUD:CreateScalableFont('PickupHistoryFont', {
	font = 'Roboto',
	size = 18,
	weight = 600
})

FFGSHUD.ICON_FRAGS = '♐'
FFGSHUD.ICON_DEATHS = '☠'
FFGSHUD.ICON_PING = '☍'

FFGSHUD.ENABLE_DISPERSION = FFGSHUD:CreateConVar('dispersion', '1', 'Enable HUD Dispersion (heavily affects FPS)')
FFGSHUD.ENABLE_GLOW = FFGSHUD:CreateConVar('glow', '1', 'Enable HUD text glow (slighty affects FPS)')
FFGSHUD.ENABLE_SHADOWS = FFGSHUD:CreateConVar('shadow', '1', 'Enable HUD text shadow (affects FPS)')

local render = render
local ScreenSize = ScreenSize
local color_black = Color(0, 0, 0)
local TEXT_DISPERSION_SHIFT = 0.0175

local function redraw(self, text, fontBase, x, y, color)
	if self.ENABLE_GLOW:GetBool() then
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, Color(color):SetAlpha(color.a * 0.09))
	end

	if self.ENABLE_DISPERSION:GetBool() then
		local color1 = Color(color.r, 0, 0, color.a)
		local color2 = Color(0, color.g, 0, color.a)
		local color3 = Color(0, 0, color.b, color.a)

		x, y = x:floor(), y:floor()
		color_black.a = color.a
		HUDCommons.SimpleText(text, fontBase.REGULAR, x, y, color_black)
		color_black.a = 255
		HUDCommons.SimpleText(text, fontBase.REGULAR_ADDITIVE, x, y + (fontBase.REGULAR_ADDITIVE_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), color3)
		local a, b, c, d, e, f = HUDCommons.SimpleText(text, fontBase.REGULAR_ADDITIVE, x, y, color2)
		HUDCommons.SimpleText(text, fontBase.REGULAR_ADDITIVE, x, y - (fontBase.REGULAR_ADDITIVE_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), color1)
		return a, b, c, d, e, f
	end

	return HUDCommons.SimpleText(text, fontBase.REGULAR, x, y, color)
end

local function redrawRight(self, text, fontBase, x, y, color)
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, Color(color):SetAlpha(color.a * 0.04))

	if self.ENABLE_DISPERSION:GetBool() then
		local color1 = Color(color.r, 0, 0, color.a)
		local color2 = Color(0, color.g, 0, color.a)
		local color3 = Color(0, 0, color.b, color.a)

		x, y = x:floor(), y:floor()
		color_black.a = color.a
		HUDCommons.SimpleTextRight(text, fontBase.REGULAR, x, y, color_black)
		color_black.a = 255
		HUDCommons.SimpleTextRight(text, fontBase.REGULAR_ADDITIVE, x, y + (fontBase.REGULAR_ADDITIVE_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), color3)
		local a, b, c, d, e, f = HUDCommons.SimpleTextRight(text, fontBase.REGULAR_ADDITIVE, x, y, color2)
		HUDCommons.SimpleTextRight(text, fontBase.REGULAR_ADDITIVE, x, y - (fontBase.REGULAR_ADDITIVE_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), color1)
		return a, b, c, d, e, f
	end

	return HUDCommons.SimpleTextRight(text, fontBase.REGULAR, x, y, color)
end

local function redrawCenter(self, text, fontBase, x, y, color)
	HUDCommons.SimpleTextCentered(text, fontBase.BLURRY, x, y, Color(color):SetAlpha(color.a * 0.04))

	if self.ENABLE_DISPERSION:GetBool() then
		local color1 = Color(color.r, 0, 0, color.a)
		local color2 = Color(0, color.g, 0, color.a)
		local color3 = Color(0, 0, color.b, color.a)

		x, y = x:floor(), y:floor()
		color_black.a = color.a
		HUDCommons.SimpleTextCentered(text, fontBase.REGULAR, x, y, color_black)
		color_black.a = 255
		HUDCommons.SimpleTextCentered(text, fontBase.REGULAR_ADDITIVE, x, y + (fontBase.REGULAR_ADDITIVE_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), color3)
		local a, b, c, d, e, f = HUDCommons.SimpleTextCentered(text, fontBase.REGULAR_ADDITIVE, x, y, color2)
		HUDCommons.SimpleTextCentered(text, fontBase.REGULAR_ADDITIVE, x, y - (fontBase.REGULAR_ADDITIVE_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), color1)
		return a, b, c, d, e, f
	end

	return HUDCommons.SimpleTextCentered(text, fontBase.REGULAR, x, y, color)
end

function FFGSHUD:DrawShadowedText(fontBase, text, x, y, color)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	if self.ENABLE_SHADOWS:GetBool() then
		color_black.a = color.a
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
		color_black.a = 255
	end

	redraw(self, text, fontBase, x, y, color)
	return surface.GetTextSize(text)
end

function FFGSHUD:DrawShadowedTextCustom(fontBase, text, x, y, color, shadow)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	if self.ENABLE_SHADOWS:GetBool() then
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadow)
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadow)
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadow)
	end

	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, Color(color):SetAlpha(color.a * 0.06))

	redraw(self, text, fontBase, x, y, color)
	return surface.GetTextSize(text)
end

function FFGSHUD:DrawShadowedTextPerc(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	if self.ENABLE_SHADOWS:GetBool() then
		color_black.a = color.a
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
		color_black.a = 255
	end

	if perc ~= 1 then
		redraw(self, text, fontBase, x, y, color)
	end

	local w, h = surface.GetTextSize(text)

	render.PushScissorRect(x - w, y + h * (1 - perc) - (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), x + w, y + h + (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor())
	redraw(self, text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextPercH(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	local w, h

	if self.ENABLE_SHADOWS:GetBool() then
		color_black.a = color.a
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
		color_black.a = 255
		w, h = surface.GetTextSize(text)
	else
		surface.SetFont(fontBase.REGULAR)
		w, h = surface.GetTextSize(text)
	end

	render.PushScissorRect(x + w * perc, y, x + w, y + h)
	redraw(self, text, fontBase, x, y, color)
	render.PopScissorRect()

	render.PushScissorRect(x, y - (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), x + w * perc, y + h + (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor())
	redraw(self, text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextPercHCustomShadow(fontBase, text, x, y, color, perc, colorPerc, colorShadow)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	surface.SetFont(fontBase.REGULAR)
	local w, h = surface.GetTextSize(text)

	if self.ENABLE_SHADOWS:GetBool() then
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
	end

	render.PushScissorRect(x + w * perc, y, x + w, y + h)
	redraw(self, text, fontBase, x, y, color)
	render.PopScissorRect()

	render.PushScissorRect(x, y - (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), x + w * perc, y + h + (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor())
	redraw(self, text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextPerc2(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	local w, h

	if self.ENABLE_SHADOWS:GetBool() then
		color_black.a = color.a
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
		color_black.a = 255
		w, h = surface.GetTextSize(text)
	else
		surface.SetFont(fontBase.REGULAR)
		w, h = surface.GetTextSize(text)
	end

	render.PushScissorRect(x - w, y, x + w, y + h * (1 - perc))

	if perc ~= 1 then
		redraw(self, text, fontBase, x, y, color)
	end

	render.PopScissorRect()
	render.PushScissorRect(x - w, y + h * (1 - perc) - (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), x + w, y + h + (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor())
	redraw(self, text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextPercInv(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	local w, h

	if self.ENABLE_SHADOWS:GetBool() then
		color_black.a = color.a
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
		color_black.a = 255
		w, h = surface.GetTextSize(text)
	else
		surface.SetFont(fontBase.REGULAR)
		w, h = surface.GetTextSize(text)
	end

	render.PushScissorRect(x - w, y - (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), x + w, y + h * perc + (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor())
	redraw(self, text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	render.PushScissorRect(x - w, y + h * perc, x + w, y + h)
	redraw(self, text, fontBase, x, y, color)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextPercCustomInv(fontBase, text, x, y, color, shadowColor, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	local w, h

	if self.ENABLE_SHADOWS:GetBool() then
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadowColor)
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadowColor)
		HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadowColor)
		w, h = surface.GetTextSize(text)
	else
		surface.SetFont(fontBase.REGULAR)
		w, h = surface.GetTextSize(text)
	end

	render.PushScissorRect(x - w, y - (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), x + w, y + h * perc + (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor())
	redraw(self, text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	render.PushScissorRect(x - w, y + h * perc, x + w, y + h)
	redraw(self, text, fontBase, x, y, color)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextAligned(fontBase, text, x, y, color)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	if self.ENABLE_SHADOWS:GetBool() then
		color_black.a = color.a
		HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
		HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
		HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
		color_black.a = 255
	end

	return redrawRight(self, text, fontBase, x, y, color)
end

function FFGSHUD:DrawShadowedTextAlignedCustom(fontBase, text, x, y, color, shadow)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	if self.ENABLE_SHADOWS:GetBool() then
		HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, shadow)
		HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, shadow)
	end

	return redrawRight(self, text, fontBase, x, y, color)
end

function FFGSHUD:DrawShadowedTextAlignedPerc(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	if self.ENABLE_SHADOWS:GetBool() then
		color_black.a = color.a
		HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
		HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
		color_black.a = 255
	end

	local w, h

	if perc ~= 1 then
		w, h = redrawRight(self, text, fontBase, x, y, color)
	else
		w, h = surface.GetTextSize(text)
	end

	render.PushScissorRect(x - w, y + h * (1 - perc) - (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), x + w, y + h + (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor())
	redrawRight(self, text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextAlignedPercInv(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	local w, h

	if self.ENABLE_SHADOWS:GetBool() then
		color_black.a = color.a
		HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
		w, h = HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
		color_black.a = 255
	else
		surface.SetFont(fontBase.REGULAR)
		w, h = surface.GetTextSize(text)
	end

	render.PushScissorRect(x - w, y - (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), x + w, y + h * perc + (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor())
	redrawRight(self, text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	render.PushScissorRect(x - w, y + h * perc, x + w, y + h)
	redrawRight(self, text, fontBase, x, y, color)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextAlignedPercCustomInv(fontBase, text, x, y, color, shadowColor, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	local w, h

	if self.ENABLE_SHADOWS:GetBool() then
		HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, shadowColor)
		w, h = HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, shadowColor)
	else
		surface.SetFont(fontBase.REGULAR)
		w, h = surface.GetTextSize(text)
	end

	render.PushScissorRect(x - w, y - (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), x + w, y + h * perc + (fontBase.REGULAR_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor())
	redrawRight(self, text, fontBase, x, y, colorPerc)
	render.PopScissorRect()

	render.PushScissorRect(x - w, y + h * perc, x + w, y + h)
	redrawRight(self, text, fontBase, x, y, color)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextCentered(fontBase, text, x, y, color)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	if self.ENABLE_SHADOWS:GetBool() then
		color_black.a = color.a
		HUDCommons.SimpleTextCentered(text, fontBase.BLURRY, x, y, color_black)
		color_black.a = 255
	end

	return redrawCenter(self, text, fontBase, x, y, color)
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
include('crosshairs.lua')
include('tfacompat.lua')
