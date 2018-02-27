
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
local RealTime = RealTime
local math = math

local FillageColorHealth = Color(80, 80, 80)
local FillageColorHealthStatic = Color(80, 80, 80)
local FillageColorHealthShadow = Color(230, 0, 0)
local FillageColorHealthShadowStatic = Color(230, 0, 0)
local pi = math.pi * 16
local function RealTimeAnim()
	return RealTime() % pi
end

function FFGSHUD:PaintPlayerStats()
	if self.isPlayingDeathAnim then
		local x, y = POS_PLAYERSTATS()
		local time = RealTime()

		if self.deathAnimTimeFadeStart > time then
			FillageColorHealthShadowStatic.a = 255
			FillageColorHealthStatic.a = 255
			self:DrawShadowedTextPercCustomInv(self.Health, 0, x, y + self.PlayerName.REGULAR_SIZE_H, color_white, FillageColorHealthShadowStatic, 1, FillageColorHealthStatic)
		elseif self.deathAnimTimeFadeEnd > time then
			local perc = (self.deathAnimTimeFadeEnd - time):progression(0, 2) * 255
			FillageColorHealthShadowStatic.a = perc
			FillageColorHealthStatic.a = perc
			self:DrawShadowedTextPercCustomInv(self.Health, 0, x, y + self.PlayerName.REGULAR_SIZE_H, color_white, FillageColorHealthShadowStatic, 1, FillageColorHealthStatic)
		else
			return
		end
	end

	if not self:GetVarAlive() then
		return
	end

	local x, y = POS_PLAYERSTATS()
	local w, h = self:DrawShadowedText(self.PlayerName, self:GetVarNick(), x, y, color_white)
	y = y + h * 0.83

	local mhp = self:GetVarMaxHealth()
	if mhp == 0 then mhp = 1 end
	local fillage = 1 - math.min(1, self:GetVarHealth() / mhp)

	if fillage == 0 then
		FillageColorHealth.a = 0
	elseif fillage == 1 then
		FillageColorHealth.a = 255
	else
		FillageColorHealth.a = 255
	end

	if fillage < 0.5 then
		w, h = self:DrawShadowedTextPercInv(self.Health, self:GetVarHealth(), x, y, color_white, fillage, FillageColorHealth)
	else
		FillageColorHealthShadow.r = math.sin(RealTimeAnim() * fillage * 30) * 64 + 130
		w, h = self:DrawShadowedTextPercCustomInv(self.Health, self:GetVarHealth(), x, y, color_white, FillageColorHealthShadow, fillage, FillageColorHealth)
	end

	y = y + h * 0.89

	self:DrawShadowedText(self.Armor, self:GetVarArmor(), x, y, color_white)
end

local color_white = Color()

local FillageColorAmmo = Color(80, 80, 80)
local FillageColorAmmoShadow1 = Color(200, 0, 0)
local FillageColorAmmoShadow2 = Color(FillageColorAmmoShadow1)
local ShadowEmpty = Color(FillageColorAmmoShadow1)

function FFGSHUD:PaintWeaponStatsSelect()

end

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
	if self.LastWeaponUpdateFadeOutEnd < time then return 0 end

	if self.LastWeaponUpdateFadeOutStart > time then
		return (1 - (self.LastWeaponUpdateFadeIn - time):progression(0, 0.5)) * 255
	else
		return (self.LastWeaponUpdateFadeOutEnd - time):progression(0, 0.5) * 255
	end

	return 0
end

function FFGSHUD:PaintWeaponStats()
	if not self:HasWeapon() then
		return
	end

	local time = RealTime()
	local hide = self:CanHideAmmoCounter()

	if self:CanDisplayWeaponSelect() and hide then
		color_white.a = calculateSelectAlpha(self, time):max(calculateHideAlpha(self, time))
	elseif hide then
		color_white.a = calculateHideAlpha(self, time)
	else
		color_white.a = 255
	end

	local x, y = POS_WEAPONSTATS()

	local w, h = self:DrawShadowedTextAligned(self.WeaponName, self:GetVarWeaponName(), x, y, color_white)
	y = y + h * 0.83

	local ammoReadyText, ammoStoredText, clip2AmmoText, stored2AmmoText = self:GetAmmoDisplayText()
	local fillage1 = 1 - self:GetAmmoFillage1()
	local fillage2 = 1 - self:GetAmmoFillage2()

	if fillage1 == 0 then
		FillageColorAmmoShadow1.r = 0
	elseif fillage1 == 1 then
		FillageColorAmmoShadow1.r = 200
	else
		FillageColorAmmoShadow1.r = math.sin(RealTimeAnim() * fillage1 * 30) * 64 + 130
	end

	if fillage2 == 0 then
		FillageColorAmmoShadow2.r = 0
	elseif fillage2 == 1 then
		FillageColorAmmoShadow2.r = 200
	else
		FillageColorAmmoShadow2.r = math.sin(RealTimeAnim() * fillage2 * 30) * 64 + 130
	end

	if self:PlayingReadyAmmoAnim() then
		local fraction = 1 - self:ReadyAmmoAnim()
		surface.SetFont(self.AmmoStored.REGULAR)
		local W, H = surface.GetTextSize('W')
		local lineY = (H + ScreenScale(10)) * fraction
		local lineXLen = ScreenScale(120)

		render.PushScissorRect(x - lineXLen, y, x + lineXLen, y + lineY)

		if fillage1 < 0.5 then
			w, h = self:DrawShadowedTextAlignedPerc(self.AmmoAmount, ammoReadyText, x, y, color_white, fillage1, FillageColorAmmo)
		else
			w, h = self:DrawShadowedTextAlignedPercCustomInv(self.AmmoAmount, ammoReadyText, x, y, color_white, FillageColorAmmoShadow1, fillage1, FillageColorAmmo)
		end

		if fillage2 < 0.5 then
			self:DrawShadowedTextPerc(self.AmmoAmount2, clip2AmmoText, x, y + self.AmmoAmount.REGULAR_SIZE_H - self.AmmoAmount2.REGULAR_SIZE_H, color_white, fillage2, FillageColorAmmo)
		else
			self:DrawShadowedTextPercCustomInv(self.AmmoAmount2, clip2AmmoText, x, y + self.AmmoAmount.REGULAR_SIZE_H - self.AmmoAmount2.REGULAR_SIZE_H, color_white, FillageColorAmmoShadow2, fillage2, FillageColorAmmo)
		end

		render.PopScissorRect()
		render.PushScissorRect(x - lineXLen, y + lineY, x + lineXLen, y + 400)

		if self.oldReadyAmmoPerc < 0.5 then
			self:DrawShadowedTextAlignedPerc(self.AmmoAmount, self.oldReadyAmmoString, x, y, color_white, self.oldReadyAmmoPerc, FillageColorAmmo)
		else
			FillageColorAmmoShadow1.r = math.sin(RealTimeAnim() * self.oldReadyAmmoPerc * 30) * 64 + 130
			self:DrawShadowedTextAlignedPercCustomInv(self.AmmoAmount, self.oldReadyAmmoString, x, y, color_white, FillageColorAmmoShadow1, self.oldReadyAmmoPerc, FillageColorAmmo)
		end

		if self.oldReady2AmmoPerc < 0.5 then
			self:DrawShadowedTextPerc(self.AmmoAmount2, self.oldReady2AmmoString, x, y + self.AmmoAmount.REGULAR_SIZE_H - self.AmmoAmount2.REGULAR_SIZE_H, color_white, self.oldReady2AmmoPerc, FillageColorAmmo)
		else
			FillageColorAmmoShadow2.r = math.sin(RealTimeAnim() * self.oldReady2AmmoPerc * 30) * 64 + 130
			self:DrawShadowedTextPercCustomInv(self.AmmoAmount2, self.oldReady2AmmoString, x, y + self.AmmoAmount.REGULAR_SIZE_H - self.AmmoAmount2.REGULAR_SIZE_H, color_white, FillageColorAmmoShadow2, self.oldReady2AmmoPerc, FillageColorAmmo)
		end

		render.PopScissorRect()

		surface.SetDrawColor(color_white)
		surface.DrawRect(x - lineXLen, y + lineY, lineXLen * 2, ScreenScale(1):max(1))

		y = y + h * 0.83
	else
		if fillage1 < 0.5 then
			w, h = self:DrawShadowedTextAlignedPercInv(self.AmmoAmount, ammoReadyText, x, y, color_white, fillage1, FillageColorAmmo)
		else
			w, h = self:DrawShadowedTextAlignedPercCustomInv(self.AmmoAmount, ammoReadyText, x, y, color_white, FillageColorAmmoShadow1, fillage1, FillageColorAmmo)
		end

		if fillage2 < 0.5 then
			self:DrawShadowedTextPercInv(self.AmmoAmount2, clip2AmmoText, x, y + self.AmmoAmount.REGULAR_SIZE_H - self.AmmoAmount2.REGULAR_SIZE_H, color_white, fillage1, FillageColorAmmo)
		else
			self:DrawShadowedTextPercCustomInv(self.AmmoAmount2, clip2AmmoText, x, y + self.AmmoAmount.REGULAR_SIZE_H - self.AmmoAmount2.REGULAR_SIZE_H, color_white, FillageColorAmmoShadow2, fillage2, FillageColorAmmo)
		end

		y = y + h * 0.83
	end

	if self:PlayingStoredAmmoAnim() then
		local fraction = self:StoredAmmoAnim()
		surface.SetFont(self.AmmoStored.REGULAR)
		local W, H = surface.GetTextSize('W')
		local lineY = (H + ScreenScale(10)) * fraction
		local lineXLen = ScreenScale(120)

		render.PushScissorRect(x - lineXLen, y, x + lineXLen, y + lineY)

		if self.oldStoredAmmoString == 0 or self.oldStoredAmmoString == '0' then
			self:DrawShadowedTextAlignedCustom(self.AmmoStored, self.oldStoredAmmoString, x, y, FillageColorAmmo, ShadowEmpty)
		else
			self:DrawShadowedTextAligned(self.AmmoStored, self.oldStoredAmmoString, x, y, color_white)
		end

		if self.oldStored2AmmoText == 0 or self.oldStored2AmmoText == '0' then
			self:DrawShadowedTextCustom(self.AmmoStored2, self.oldStored2AmmoText, x, y, FillageColorAmmo, ShadowEmpty)
		else
			self:DrawShadowedText(self.AmmoStored2, self.oldStored2AmmoText, x, y, color_white)
		end

		render.PopScissorRect()
		render.PushScissorRect(x - lineXLen, y + lineY, x + lineXLen, y + 400)

		if ammoStoredText == 0 or ammoStoredText == '0' then
			self:DrawShadowedTextAlignedCustom(self.AmmoStored, ammoStoredText, x, y, FillageColorAmmo, ShadowEmpty)
		else
			self:DrawShadowedTextAligned(self.AmmoStored, ammoStoredText, x, y, color_white)
		end

		if stored2AmmoText == 0 or stored2AmmoText == '/0' then
			self:DrawShadowedTextCustom(self.AmmoStored2, stored2AmmoText, x, y, FillageColorAmmo, ShadowEmpty)
		else
			self:DrawShadowedText(self.AmmoStored2, stored2AmmoText, x, y, color_white)
		end

		render.PopScissorRect()

		surface.SetDrawColor(color_white)
		surface.DrawRect(x - lineXLen, y + lineY, lineXLen * 2, ScreenScale(1))
		y = y + self.AmmoStored.REGULAR_SIZE_H
	else
		if ammoStoredText == 0 or ammoStoredText == '0' then
			self:DrawShadowedTextAlignedCustom(self.AmmoStored, ammoStoredText, x, y, FillageColorAmmo, ShadowEmpty)
		else
			self:DrawShadowedTextAligned(self.AmmoStored, ammoStoredText, x, y, color_white)
		end

		if stored2AmmoText == 0 or stored2AmmoText == '/0' then
			self:DrawShadowedTextCustom(self.AmmoStored2, stored2AmmoText, x, y, FillageColorAmmo, ShadowEmpty)
		else
			self:DrawShadowedText(self.AmmoStored2, stored2AmmoText, x, y, color_white)
		end

		y = y + self.AmmoStored.REGULAR_SIZE_H
	end

	local oX, oY = POS_WEAPONSTATS()
	local diffX, diffY = oX - x, oY - y
	x, y = x, oY - diffY

	ammoReadyText, ammoStoredText, clip2AmmoText, stored2AmmoText = self:GetAmmoDisplayText2()
end

FFGSHUD:AddPaintHook('PaintPlayerStats')
FFGSHUD:AddPaintHook('PaintWeaponStats')
