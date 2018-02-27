
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

FFGSHUD.TargetID_Health = FFGSHUD:CreateScalableFont('TargetID_Health', {
	font = 'Exo 2',
	size = 18,
})

FFGSHUD.TargetID_Armor = FFGSHUD:CreateScalableFont('TargetID_Armor', {
	font = 'Exo 2',
	size = 14,
})

local render = render

function FFGSHUD:DrawShadowedText(fontBase, text, x, y, color)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255
	HUDCommons.SimpleText(text, fontBase.REGULAR, x, y, color)
	return surface.GetTextSize(text)
end

function FFGSHUD:DrawShadowedTextCustom(fontBase, text, x, y, color, shadow)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadow)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadow)
	HUDCommons.SimpleText(text, fontBase.REGULAR, x, y, color)
	return surface.GetTextSize(text)
end

function FFGSHUD:DrawShadowedTextPerc(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255

	if perc ~= 1 then
		HUDCommons.SimpleText(text, fontBase.REGULAR, x, y, color)
	end

	local w, h = surface.GetTextSize(text)

	render.PushScissorRect(x - w, y + h * (1 - perc), x + w, y + h)
	HUDCommons.SimpleText(text, fontBase.REGULAR, x, y, colorPerc)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextPerc2(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255

	local w, h = surface.GetTextSize(text)

	render.PushScissorRect(x - w, y, x + w, y + h * (1 - perc))

	if perc ~= 1 then
		HUDCommons.SimpleText(text, fontBase.REGULAR, x, y, color)
	end

	render.PopScissorRect()
	render.PushScissorRect(x - w, y + h * (1 - perc), x + w, y + h)
	HUDCommons.SimpleText(text, fontBase.REGULAR, x, y, colorPerc)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextPercInv(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	color_black.a = color.a
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255

	local w, h = surface.GetTextSize(text)

	render.PushScissorRect(x - w, y, x + w, y + h * perc)
	HUDCommons.SimpleText(text, fontBase.REGULAR, x, y, colorPerc)
	render.PopScissorRect()

	render.PushScissorRect(x - w, y + h * perc, x + w, y + h)
	HUDCommons.SimpleText(text, fontBase.REGULAR, x, y, color)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextPercCustomInv(fontBase, text, x, y, color, shadowColor, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadowColor)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, shadowColor)

	local w, h = surface.GetTextSize(text)

	render.PushScissorRect(x - w, y, x + w, y + h * perc)
	HUDCommons.SimpleText(text, fontBase.REGULAR, x, y, colorPerc)
	render.PopScissorRect()

	render.PushScissorRect(x - w, y + h * perc, x + w, y + h)
	HUDCommons.SimpleText(text, fontBase.REGULAR, x, y, color)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextAligned(fontBase, text, x, y, color)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255
	return HUDCommons.SimpleTextRight(text, fontBase.REGULAR, x, y, color)
end

function FFGSHUD:DrawShadowedTextAlignedCustom(fontBase, text, x, y, color, shadow)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, shadow)
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, shadow)
	return HUDCommons.SimpleTextRight(text, fontBase.REGULAR, x, y, color)
end

function FFGSHUD:DrawShadowedTextAlignedPerc(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255

	local w, h

	if perc ~= 1 then
		w, h = HUDCommons.SimpleTextRight(text, fontBase.REGULAR, x, y, color)
	else
		w, h = surface.GetTextSize(text)
	end

	render.PushScissorRect(x - w, y + h * (1 - perc), x + w, y + h)
	HUDCommons.SimpleTextRight(text, fontBase.REGULAR, x, y, colorPerc)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextAlignedPercInv(fontBase, text, x, y, color, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
	local w, h = HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255

	render.PushScissorRect(x - w, y, x + w, y + h * perc)
	HUDCommons.SimpleTextRight(text, fontBase.REGULAR, x, y, colorPerc)
	render.PopScissorRect()

	render.PushScissorRect(x - w, y + h * perc, x + w, y + h)
	HUDCommons.SimpleTextRight(text, fontBase.REGULAR, x, y, color)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextAlignedPercCustomInv(fontBase, text, x, y, color, shadowColor, perc, colorPerc)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end

	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, shadowColor)
	local w, h = HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, shadowColor)

	render.PushScissorRect(x - w, y, x + w, y + h * perc)
	HUDCommons.SimpleTextRight(text, fontBase.REGULAR, x, y, colorPerc)
	render.PopScissorRect()

	render.PushScissorRect(x - w, y + h * perc, x + w, y + h)
	HUDCommons.SimpleTextRight(text, fontBase.REGULAR, x, y, color)
	render.PopScissorRect()

	return w, h
end

function FFGSHUD:DrawShadowedTextCentered(fontBase, text, x, y, color)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleTextCentered(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleTextCentered(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255
	return HUDCommons.SimpleTextCentered(text, fontBase.REGULAR, x, y, color)
end

function FFGSHUD:HUDShouldDraw(target)
	if
		target == 'CHudAmmo' or
		target == 'CHudBattery' or
		target == 'CHudHealth' or
		target == 'CHudPoisonDamageIndicator' or
		target == 'CHudSecondaryAmmo'
	then
		return false
	end
end

FFGSHUD:AddHook('HUDShouldDraw')

include('vars.lua')
include('basicpaint.lua')
include('functions.lua')
include('targetid.lua')
include('anims.lua')
