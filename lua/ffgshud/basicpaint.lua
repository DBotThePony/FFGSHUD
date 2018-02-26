
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
			self:DrawShadowedTextPercCustomInv2(self.Health, 0, x, y + self.PlayerName.REGULAR_SIZE_H, color_white, FillageColorHealthShadowStatic, 1, FillageColorHealthStatic)
		elseif self.deathAnimTimeFadeEnd > time then
			local perc = (self.deathAnimTimeFadeEnd - time):progression(0, 2) * 255
			FillageColorHealthShadowStatic.a = perc
			FillageColorHealthStatic.a = perc
			self:DrawShadowedTextPercCustomInv2(self.Health, 0, x, y + self.PlayerName.REGULAR_SIZE_H, color_white, FillageColorHealthShadowStatic, 1, FillageColorHealthStatic)
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
		w, h = self:DrawShadowedTextPercInv2(self.Health, self:GetVarHealth(), x, y, color_white, fillage, FillageColorHealth)
	else
		FillageColorHealthShadow.r = math.sin(RealTimeAnim() * fillage * 30) * 64 + 130
		w, h = self:DrawShadowedTextPercCustomInv2(self.Health, self:GetVarHealth(), x, y, color_white, FillageColorHealthShadow, fillage, FillageColorHealth)
	end

	y = y + h * 0.89

	self:DrawShadowedText(self.Armor, self:GetVarArmor(), x, y, color_white)
end

local color_white = Color()
local FillageColor1 = Color(255, 80, 80, 255)
local FillageColor2 = Color(255, 80, 80, 255)

function FFGSHUD:PaintWeaponStats()
	if not self:HasWeapon() then
		return
	end

	if self:CanHideAmmoCounter() then
		if self.LastWeaponUpdateFadeOutEnd < RealTime() then return end

		if self.LastWeaponUpdateFadeOutStart > RealTime() then
			color_white.a = (1 - (self.LastWeaponUpdateFadeIn - RealTime()):progression(0, 0.5)) * 255
		else
			color_white.a = (self.LastWeaponUpdateFadeOutEnd - RealTime()):progression(0, 0.5) * 255
		end
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
		FillageColor1.r = 0
		FillageColor1.a = 0
	elseif fillage1 == 1 then
		FillageColor1.r = 230
		FillageColor1.a = 230
	else
		FillageColor1.r = 230
		FillageColor1.a = math.sin(RealTimeAnim() * fillage1 * 30) * 64 + 160
	end

	if fillage2 == 0 then
		FillageColor2.r = 0
		FillageColor2.a = 0
	elseif fillage2 == 1 then
		FillageColor2.r = 230
		FillageColor2.a = 230
	else
		FillageColor2.r = 230
		FillageColor2.a = math.sin(RealTimeAnim() * fillage2 * 30) * 64 + 160
	end

	if self:PlayingReadyAmmoAnim() then
		local fraction = 1 - self:ReadyAmmoAnim()
		surface.SetFont(self.AmmoStored.REGULAR)
		local W, H = surface.GetTextSize('W')
		local lineY = (H + ScreenScale(10)) * fraction
		local lineXLen = ScreenScale(120)

		render.SetScissorRect(x - lineXLen, y, x + lineXLen, y + lineY, true)

		w, h = self:DrawShadowedTextAlignedPerc(self.AmmoAmount, ammoReadyText, x, y, color_white, fillage1, FillageColor1)
		self:DrawShadowedTextPerc(self.AmmoAmount2, clip2AmmoText, x, y + self.AmmoAmount.REGULAR_SIZE_H - self.AmmoAmount2.REGULAR_SIZE_H, color_white, fillage2, FillageColor2)

		render.SetScissorRect(x - lineXLen, y + lineY, x + lineXLen, y + 400, true)

		self:DrawShadowedTextAlignedPerc(self.AmmoAmount, self.oldReadyAmmoString, x, y, color_white, fillage1, FillageColor1)
		self:DrawShadowedTextPerc(self.AmmoAmount2, self.oldReady2AmmoString, x, y + self.AmmoAmount.REGULAR_SIZE_H - self.AmmoAmount2.REGULAR_SIZE_H, color_white, fillage2, FillageColor2)

		render.SetScissorRect(0, 0, 0, 0, false)

		surface.SetDrawColor(color_white)
		surface.DrawRect(x - lineXLen, y + lineY, lineXLen * 2, ScreenScale(1):max(1))

		if ammoReadyText ~= '' then
			y = y + h * 0.83
		end
	else
		w, h = self:DrawShadowedTextAlignedPerc(self.AmmoAmount, ammoReadyText, x, y, color_white, fillage1, FillageColor1)
		self:DrawShadowedTextPerc(self.AmmoAmount2, clip2AmmoText, x, y + self.AmmoAmount.REGULAR_SIZE_H - self.AmmoAmount2.REGULAR_SIZE_H, color_white, fillage2, FillageColor2)

		if ammoReadyText ~= '' then
			y = y + h * 0.83
		end
	end

	if self:PlayingStoredAmmoAnim() then
		local fraction = self:StoredAmmoAnim()
		surface.SetFont(self.AmmoStored.REGULAR)
		local W, H = surface.GetTextSize('W')
		local lineY = (H + ScreenScale(10)) * fraction
		local lineXLen = ScreenScale(120)

		render.SetScissorRect(x - lineXLen, y, x + lineXLen, y + lineY, true)

		self:DrawShadowedTextAligned(self.AmmoStored, self.oldStoredAmmoString, x, y, color_white)
		self:DrawShadowedText(self.AmmoStored2, self.oldStored2AmmoText, x, y, color_white)

		render.SetScissorRect(x - lineXLen, y + lineY, x + lineXLen, y + 400, true)

		self:DrawShadowedTextAligned(self.AmmoStored, ammoStoredText, x, y, color_white)
		self:DrawShadowedText(self.AmmoStored2, stored2AmmoText, x, y, color_white)

		render.SetScissorRect(0, 0, 0, 0, false)

		surface.SetDrawColor(color_white)
		surface.DrawRect(x - lineXLen, y + lineY, lineXLen * 2, ScreenScale(1))
	else
		self:DrawShadowedTextAligned(self.AmmoStored, ammoStoredText, x, y, color_white)
		self:DrawShadowedText(self.AmmoStored2, stored2AmmoText, x, y, color_white)
	end
end

FFGSHUD:AddPaintHook('PaintPlayerStats')
FFGSHUD:AddPaintHook('PaintWeaponStats')
