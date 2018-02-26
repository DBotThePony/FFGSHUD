
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
	font = 'Exo 2',
	size = 60,
	weight = 600
})

FFGSHUD.AmmoAmount2 = FFGSHUD:CreateScalableFont('AmmoAmount2', {
	font = 'Exo 2',
	size = 38,
	weight = 600
})

FFGSHUD.AmmoStored = FFGSHUD:CreateScalableFont('AmmoStored', {
	font = 'Exo 2',
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
	size = 32,
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

function FFGSHUD:DrawShadowedText(fontBase, text, x, y, color)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleText(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255
	HUDCommons.SimpleText(text, fontBase.REGULAR, x, y, color)
	return surface.GetTextSize(text)
end

function FFGSHUD:DrawShadowedTextAligned(fontBase, text, x, y, color)
	if text == '' then return 0, fontBase.REGULAR_SIZE_H end
	color_black.a = color.a
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
	HUDCommons.SimpleTextRight(text, fontBase.BLURRY, x, y, color_black)
	color_black.a = 255
	return HUDCommons.SimpleTextRight(text, fontBase.REGULAR, x, y, color)
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
