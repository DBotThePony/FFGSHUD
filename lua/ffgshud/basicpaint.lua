
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

local POS_PLAYERSTATS = FFGSHUD:DefinePosition('playerstats', 0.07, 0.68)
local POS_WEAPONSTATS = FFGSHUD:DefinePosition('weaponstats', 0.93, 0.68)
local color_white = color_white
local render = render
local surface = surface
local ScreenScale = ScreenScale
local RealTimeL = RealTimeL
local math = math

local FillageColorHealth = FFGSHUD:CreateColorN('fillage_hp', 'Fillage Color for HP', Color(80, 80, 80))
local FillageColorHealthStatic = FFGSHUD:CreateColorN('fillage_hp_s', 'Fillage Color for HP (Static)', Color(80, 80, 80))
local FillageColorHealthShadow = FFGSHUD:CreateColorN('fillage_hp_sh', 'Fillage Color for HP Shadow', Color(230, 0, 0))
local FillageColorHealthShadowStatic = FFGSHUD:CreateColorN('fillage_hp_shs', 'Fillage Color for HP Shadow (Static)', Color(230, 0, 0))
local FillageShield = FFGSHUD:CreateColorN('fillage_shield', 'Fillage Color for Armor', Color(177, 255, 252))
local FillageShieldShadow = FFGSHUD:CreateColorN('fillage_shield_s', 'Fillage Color for Armor Shadow', Color(39, 225, 247, 200))

local PlayerName = FFGSHUD:CreateColorN('plyname', 'Player Name', Color())
local HPColor = FFGSHUD:CreateColorN('plyhp', 'Player Health', Color())
local ArmorColor = FFGSHUD:CreateColorN('armorcolor', 'Player Armor', Color())

local pi = math.pi * 16
local function RealTimeLAnim()
	return RealTimeL() % pi
end

function FFGSHUD:PaintPlayerStats()
	if self.isPlayingDeathAnim then
		local x, y = POS_PLAYERSTATS()
		local time = RealTimeL()

		if self.deathAnimTimeFadeStart > time then
			FillageColorHealthShadowStatic(255)
			FillageColorHealthStatic(255)
			self:DrawShadowedTextPercCustomInv(self.Health, 0, x, y + self.PlayerName.REGULAR_SIZE_H, HPColor(), FillageColorHealthShadowStatic(), 1, FillageColorHealthStatic())
		elseif self.deathAnimTimeFadeEnd > time then
			local perc = (self.deathAnimTimeFadeEnd - time):progression(0, 2) * 255
			FillageColorHealthShadowStatic(perc)
			FillageColorHealthStatic(perc)
			self:DrawShadowedTextPercCustomInv(self.Health, 0, x, y + self.PlayerName.REGULAR_SIZE_H, HPColor(), FillageColorHealthShadowStatic(), 1, FillageColorHealthStatic())
		else
			return
		end
	end

	if not self:GetVarAlive() then
		return
	end

	local x, y = POS_PLAYERSTATS()
	local fillageArmor = self:GetVarArmor() / self:GetVarMaxArmor()
	local w, h = self:DrawShadowedTextPercHCustomShadow(self.PlayerName, self:GetVarNick(), x, y, PlayerName(), fillageArmor:min(1), FillageShield(), FillageShieldShadow())
	y = y + h * 0.83

	local mhp = self:GetVarMaxHealth()
	if mhp == 0 then mhp = 1 end
	local fillage = 1 - math.min(1, self:GetVarHealth() / mhp)

	if fillage == 0 then
		FillageColorHealth(0)
	elseif fillage == 1 then
		FillageColorHealth(255)
	else
		FillageColorHealth(255)
	end

	if fillage < 0.5 then
		w, h = self:DrawShadowedTextPercInv(self.Health, self:GetVarHealth(), x, y, HPColor(), fillage, FillageColorHealth())
	else
		w, h = self:DrawShadowedTextPercCustomInv(self.Health, self:GetVarHealth(), x, y, HPColor(), FillageColorHealthShadow():SetRed(math.sin(RealTimeLAnim() * fillage * 30) * 64 + 130), fillage, FillageColorHealth())
	end

	y = y + h * 0.89

	if self:GetVarArmor() > 0 then
		if self:GetVarMaxArmor() ~= 100 then
			self:DrawShadowedText(self.Armor, ('%i/%i'):format(self:GetVarArmor(), self:GetVarMaxArmor()), x, y, ArmorColor())
		else
			self:DrawShadowedText(self.Armor, self:GetVarArmor(), x, y, ArmorColor())
		end
	end
end

local color_white = Color()

local FillageColorAmmo = 				FFGSHUD:CreateColorN2('fillage_ammo', 'Fillage Color for Ammo', Color(80, 80, 80))
local FillageColorAmmoShadow1 = 		FFGSHUD:CreateColorN2('fillage_ammo_s', 'Fillage Color for Ammo Shadow', Color(200, 0, 0))

local FillageColorAmmo_Select = 		FFGSHUD:CreateColorN2('fillage_ammo_se', 'Fillage Color for Ammo Select', FillageColorAmmo)
local FillageColorAmmoShadow1_Select = 	FFGSHUD:CreateColorN2('fillage_ammo_s1se', 'Fillage Color for Ammo Shadow 1 Select', FillageColorAmmoShadow1)
local FillageColorAmmoShadow2 = 		FFGSHUD:CreateColorN2('fillage_ammo_s2', 'Fillage Color for Ammo Shadow 2', FillageColorAmmoShadow1)
local FillageColorAmmoShadow2_Select = 	FFGSHUD:CreateColorN2('fillage_ammo_s2se', 'Fillage Color for Ammo Shadow 2 Select', FillageColorAmmoShadow1)
local ShadowEmpty = 					FFGSHUD:CreateColorN2('fillage_ammo_sempty', 'Fillage Color for Ammo Shadow Empty', FillageColorAmmoShadow1)
local ShadowEmpty_Select = 				FFGSHUD:CreateColorN2('fillage_ammo_sempty', 'Fillage Color for Ammo Shadow Empty Select', FillageColorAmmoShadow1)

local function calculateSelectAlpha(self, time)
	if self.tryToSelectWeaponFadeIn > time then
		return (1 - (self.tryToSelectWeaponFadeIn - time)):progression(0, 0.5) * 100
	elseif self.tryToSelectWeaponLast > time then
		return 100
	elseif self.tryToSelectWeaponLastEnd > time then
		return (self.tryToSelectWeaponLastEnd - time):progression(0, 0.5) * 100
	else
		return 0
	end

	return 0
end

local function calculateHideAlpha(self, time)
	if self.LastWeaponUpdateFadeOutEnd < time then return false end

	if self.LastWeaponUpdateFadeOutStart > time then
		return (1 - (self.LastWeaponUpdateFadeIn - time):progression(0, 0.5)) * 255
	else
		return (self.LastWeaponUpdateFadeOutEnd - time):progression(0, 0.5) * 255
	end

	return false
end

local WeaponNameColor = FFGSHUD:CreateColorN('weaponname', 'Player Armor', Color())
local AmmoReadyColor = FFGSHUD:CreateColorN('ammoready', 'Player Armor', Color())
local AmmoReady2Color = FFGSHUD:CreateColorN('ammoready2', 'Player Armor', Color())
local AmmoStoredColor = FFGSHUD:CreateColorN('ammostored', 'Player Armor', Color())
local AmmoStored2Color = FFGSHUD:CreateColorN('ammostored2', 'Player Armor', Color())

local WeaponNameColor_Select = FFGSHUD:CreateColorN('weaponname_s', 'Player Armor', Color())
local AmmoReadyColor_Select = FFGSHUD:CreateColorN('ammoready_s', 'Player Armor', Color())
local AmmoReady2Color_Select = FFGSHUD:CreateColorN('ammoready2_s', 'Player Armor', Color())
local AmmoStoredColor_Select = FFGSHUD:CreateColorN('ammostored_s', 'Player Armor', Color())
local AmmoStored2Color_Select = FFGSHUD:CreateColorN('ammostored2_s', 'Player Armor', Color())

function FFGSHUD:PaintWeaponStats()
	if not self:HasWeapon() then
		return
	end

	local time = RealTimeL()
	local hide = self:CanHideAmmoCounter()

	if self:CanDisplayWeaponSelect2() and hide then
		color_white.a = calculateSelectAlpha(self, time):max(calculateHideAlpha(self, time) or 0)
	elseif hide then
		local getValue = calculateHideAlpha(self, time)
		if getValue == false then return end
		color_white.a = getValue
	else
		color_white.a = 255
	end

	local WeaponNameColor = WeaponNameColor():ModifyAlpha(color_white.a)
	local AmmoReadyColor = AmmoReadyColor():ModifyAlpha(color_white.a)
	local AmmoReady2Color = AmmoReady2Color():ModifyAlpha(color_white.a)
	local AmmoStoredColor = AmmoStoredColor():ModifyAlpha(color_white.a)
	local AmmoStored2Color = AmmoStored2Color():ModifyAlpha(color_white.a)

	local x, y = POS_WEAPONSTATS()
	local swipe = self:PlayingSwipeAnimation()

	if swipe then
		render.PushScissorRect(x - 800, y, x + 800, y + self.WeaponName.REGULAR_SIZE_H * 0.83 + self.AmmoAmount.REGULAR_SIZE_H * 0.83 + self.AmmoStored.REGULAR_SIZE_H)
		local fraction = self:SwipeAnimationDuration()

		if self.swipeDirection then
			y = y - (self.WeaponName.REGULAR_SIZE_H * 0.83 + self.AmmoAmount.REGULAR_SIZE_H * 0.83 + self.AmmoStored.REGULAR_SIZE_H) * fraction
		else
			y = y + (self.WeaponName.REGULAR_SIZE_H * 0.83 + self.AmmoAmount.REGULAR_SIZE_H * 0.83 + self.AmmoStored.REGULAR_SIZE_H) * fraction
		end

		local w, h = self:DrawShadowedTextAligned(self.WeaponName, self.oldWeaponName, x, y, WeaponNameColor)
		y = y + self.WeaponName.REGULAR_SIZE_H * 0.83

		local fillage1 = self.oldReadyAmmoPerc
		local fillage2 = self.oldReady2AmmoPerc

		if fillage1 == 0 then
			FillageColorAmmoShadow1.r = 0
		elseif fillage1 == 1 then
			FillageColorAmmoShadow1.r = 200
		else
			FillageColorAmmoShadow1.r = math.sin(RealTimeLAnim() * fillage1 * 30) * 64 + 130
		end

		if fillage2 == 0 then
			FillageColorAmmoShadow2.r = 0
		elseif fillage2 == 1 then
			FillageColorAmmoShadow2.r = 200
		else
			FillageColorAmmoShadow2.r = math.sin(RealTimeLAnim() * fillage2 * 30) * 64 + 130
		end

		if fillage1 < 0.5 then
			w, h = self:DrawShadowedTextAlignedPercInv(self.AmmoAmount, self.oldReadyAmmoString, x, y, AmmoReadyColor, fillage1, FillageColorAmmo)
		else
			w, h = self:DrawShadowedTextAlignedPercCustomInv(self.AmmoAmount, self.oldReadyAmmoString, x, y, AmmoReadyColor, FillageColorAmmoShadow1, fillage1, FillageColorAmmo)
		end

		if fillage2 < 0.5 then
			self:DrawShadowedTextPercInv(self.AmmoAmount2, self.oldReady2AmmoString, x, y + self.AmmoAmount.REGULAR_SIZE_H - self.AmmoAmount2.REGULAR_SIZE_H, AmmoReady2Color, fillage2, FillageColorAmmo)
		else
			self:DrawShadowedTextPercCustomInv(self.AmmoAmount2, self.oldReady2AmmoString, x, y + self.AmmoAmount.REGULAR_SIZE_H - self.AmmoAmount2.REGULAR_SIZE_H, AmmoReady2Color, FillageColorAmmoShadow2, fillage2, FillageColorAmmo)
		end

		y = y + self.AmmoAmount.REGULAR_SIZE_H * 0.83

		if self.oldStoredAmmoString == 0 or self.oldStoredAmmoString == '0' then
			self:DrawShadowedTextAlignedCustom(self.AmmoStored, self.oldStoredAmmoString, x, y, FillageColorAmmo, ShadowEmpty)
		else
			self:DrawShadowedTextAligned(self.AmmoStored, self.oldStoredAmmoString, x, y, AmmoStoredColor)
		end

		if self.oldStored2AmmoText == 0 or self.oldStored2AmmoText == '/0' then
			self:DrawShadowedTextCustom(self.AmmoStored2, self.oldStored2AmmoText, x, y, FillageColorAmmo, ShadowEmpty)
		else
			self:DrawShadowedText(self.AmmoStored2, self.oldStored2AmmoText, x, y, AmmoStored2Color)
		end

		y = y + self.AmmoStored.REGULAR_SIZE_H

		if not self.swipeDirection then
			y = y - (self.WeaponName.REGULAR_SIZE_H * 0.83 + self.AmmoAmount.REGULAR_SIZE_H * 0.83 + self.AmmoStored.REGULAR_SIZE_H) * 2
		end
	end

	local w, h = self:DrawShadowedTextAligned(self.WeaponName, self:GetVarWeaponName(), x, y, WeaponNameColor)
	y = y + h * 0.83

	local ammoReadyText, ammoStoredText, clip2AmmoText, stored2AmmoText = self:GetAmmoDisplayText()
	local fillage1 = 1 - self:GetAmmoFillage1()
	local fillage2 = 1 - self:GetAmmoFillage2()

	if fillage1 == 0 then
		FillageColorAmmoShadow1.r = 0
	elseif fillage1 == 1 then
		FillageColorAmmoShadow1.r = 200
	else
		FillageColorAmmoShadow1.r = math.sin(RealTimeLAnim() * fillage1 * 30) * 64 + 130
	end

	if fillage2 == 0 then
		FillageColorAmmoShadow2.r = 0
	elseif fillage2 == 1 then
		FillageColorAmmoShadow2.r = 200
	else
		FillageColorAmmoShadow2.r = math.sin(RealTimeLAnim() * fillage2 * 30) * 64 + 130
	end

	if fillage1 < 0.5 then
		w, h = self:DrawShadowedTextAlignedPercInv(self.AmmoAmount, ammoReadyText, x, y, AmmoReadyColor, fillage1, FillageColorAmmo)
	else
		w, h = self:DrawShadowedTextAlignedPercCustomInv(self.AmmoAmount, ammoReadyText, x, y, AmmoReadyColor, FillageColorAmmoShadow1, fillage1, FillageColorAmmo)
	end

	if fillage2 < 0.5 then
		self:DrawShadowedTextPercInv(self.AmmoAmount2, clip2AmmoText, x, y + self.AmmoAmount.REGULAR_SIZE_H - self.AmmoAmount2.REGULAR_SIZE_H, AmmoReady2Color, fillage2, FillageColorAmmo)
	else
		self:DrawShadowedTextPercCustomInv(self.AmmoAmount2, clip2AmmoText, x, y + self.AmmoAmount.REGULAR_SIZE_H - self.AmmoAmount2.REGULAR_SIZE_H, AmmoReady2Color, FillageColorAmmoShadow2, fillage2, FillageColorAmmo)
	end

	y = y + h * 0.83

	if ammoStoredText == 0 or ammoStoredText == '0' then
		self:DrawShadowedTextAlignedCustom(self.AmmoStored, ammoStoredText, x, y, FillageColorAmmo, ShadowEmpty)
	else
		self:DrawShadowedTextAligned(self.AmmoStored, ammoStoredText, x, y, AmmoStoredColor)
	end

	if stored2AmmoText == 0 or stored2AmmoText == '/0' then
		self:DrawShadowedTextCustom(self.AmmoStored2, stored2AmmoText, x, y, FillageColorAmmo, ShadowEmpty)
	else
		self:DrawShadowedText(self.AmmoStored2, stored2AmmoText, x, y, AmmoStored2Color)
	end

	y = y + self.AmmoStored.REGULAR_SIZE_H

	if swipe then
		render.PopScissorRect()
	end

	if not self:CanDisplayWeaponSelect() then return end

	if not hide then
		color_white.a = 100
	else
		color_white.a = color_white.a:min(100)
	end

	local WeaponNameColor_Select = WeaponNameColor_Select():ModifyAlpha(color_white.a)
	local AmmoReadyColor_Select = AmmoReadyColor_Select():ModifyAlpha(color_white.a)
	local AmmoReady2Color_Select = AmmoReady2Color_Select():ModifyAlpha(color_white.a)
	local AmmoStoredColor_Select = AmmoStoredColor_Select():ModifyAlpha(color_white.a)
	local AmmoStored2Color_Select = AmmoStored2Color_Select():ModifyAlpha(color_white.a)

	x, y = POS_WEAPONSTATS()
	y = y - (self.WeaponName.REGULAR_SIZE_H * 0.83 + self.AmmoAmount.REGULAR_SIZE_H * 0.83 + self.AmmoStored.REGULAR_SIZE_H)

	ammoReadyText, ammoStoredText, clip2AmmoText, stored2AmmoText = self:GetAmmoDisplayText2()

	fillage1 = 1 - self:GetAmmoFillage1_Select()
	fillage2 = 1 - self:GetAmmoFillage2_Select()

	ShadowEmpty_Select.a = color_white.a
	FillageColorAmmo_Select.a = color_white.a
	local multAlpha = math.Clamp(color_white.a / 100, 0, 1)

	if fillage1 == 0 then
		FillageColorAmmoShadow1_Select.r = 0
	elseif fillage1 == 1 then
		FillageColorAmmoShadow1_Select.r = 200
	else
		FillageColorAmmoShadow1_Select.r = (math.sin(RealTimeLAnim() * fillage1 * 30) * 64 + 130) * multAlpha
	end

	FillageColorAmmoShadow1_Select.a = color_white.a
	FillageColorAmmoShadow2_Select.a = color_white.a

	if fillage2 == 0 then
		FillageColorAmmoShadow2_Select.r = 0
	elseif fillage2 == 1 then
		FillageColorAmmoShadow2_Select.r = 200
	else
		FillageColorAmmoShadow2_Select.r = (math.sin(RealTimeLAnim() * fillage2 * 30) * 64 + 130) * multAlpha
	end

	w, h = self:DrawShadowedTextAligned(self.WeaponName, self:GetVarWeaponName_Select(), x, y, WeaponNameColor_Select)
	y = y + h * 0.83

	if fillage1 < 0.5 then
		w, h = self:DrawShadowedTextAlignedPercInv(self.AmmoAmount, ammoReadyText, x, y, AmmoReadyColor_Select, fillage1, FillageColorAmmo_Select)
	else
		w, h = self:DrawShadowedTextAlignedPercCustomInv(self.AmmoAmount, ammoReadyText, x, y, AmmoReadyColor_Select, FillageColorAmmoShadow1_Select, fillage1, FillageColorAmmo_Select)
	end

	if fillage2 < 0.5 then
		self:DrawShadowedTextPercInv(self.AmmoAmount2, clip2AmmoText, x, y + self.AmmoAmount.REGULAR_SIZE_H - self.AmmoAmount2.REGULAR_SIZE_H, AmmoReady2Color_Select, fillage2, FillageColorAmmo_Select)
	else
		self:DrawShadowedTextPercCustomInv(self.AmmoAmount2, clip2AmmoText, x, y + self.AmmoAmount.REGULAR_SIZE_H - self.AmmoAmount2.REGULAR_SIZE_H, AmmoReady2Color_Select, FillageColorAmmoShadow2_Select, fillage2, FillageColorAmmo_Select)
	end

	y = y + h * 0.83

	if ammoStoredText == 0 or ammoStoredText == '0' then
		self:DrawShadowedTextAlignedCustom(self.AmmoStored, ammoStoredText, x, y, FillageColorAmmo_Select, ShadowEmpty_Select)
	else
		self:DrawShadowedTextAligned(self.AmmoStored, ammoStoredText, x, y, AmmoStoredColor_Select)
	end

	if stored2AmmoText == 0 or stored2AmmoText == '/0' then
		self:DrawShadowedTextCustom(self.AmmoStored2, stored2AmmoText, x, y, FillageColorAmmo_Select, ShadowEmpty_Select)
	else
		self:DrawShadowedText(self.AmmoStored2, stored2AmmoText, x, y, AmmoStored2Color_Select)
	end
end

FFGSHUD:AddPaintHook('PaintPlayerStats')
FFGSHUD:AddPaintHook('PaintWeaponStats')
