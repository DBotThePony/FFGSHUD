
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

function FFGSHUD:PaintPlayerStats()
	if not self:GetVarAlive() then
		return
	end

	local x, y = POS_PLAYERSTATS()
	local w, h = self:DrawShadowedText(self.PlayerName, self:GetVarNick(), x, y, color_white)
	y = y + h * 0.83

	w, h = self:DrawShadowedText(self.Health, self:GetVarHealth(), x, y, color_white)
	y = y + h * 0.89

	self:DrawShadowedText(self.Armor, ('%i / %i'):format(self:GetVarArmor(), self:GetVarMaxArmor()), x, y, color_white)
end

function FFGSHUD:PaintWeaponStats()
	if not self:HasWeapon() then
		return
	end

	local x, y = POS_WEAPONSTATS()

	local w, h = self:DrawShadowedTextAligned(self.WeaponName, self:GetVarWeaponName(), x, y, color_white)
	y = y + h * 0.83

	local ammoReadyText, ammoStoredText = self:GetAmmoDisplayText()

	if ammoReadyText ~= '' then
		w, h = self:DrawShadowedTextAligned(self.AmmoAmount, ammoReadyText, x, y, color_white)
		y = y + h * 0.83
	end

	if self:PlayingStoredAmmoAnim() then
		local fraction = self:StoredAmmoAnim()
		surface.SetFont(self.AmmoStored.REGULAR)
		local W, H = surface.GetTextSize('W')
		local lineY = (H + ScreenScale(10)) * fraction
		local lineXLen = ScreenScale(80)

		render.SetScissorRect(x - lineXLen, y, x, y + lineY, true)

		self:DrawShadowedTextAligned(self.AmmoStored, self.oldStoredAmmoString, x, y, color_white)

		render.SetScissorRect(x - lineXLen, y + lineY, x, y + 400, true)

		if ammoStoredText ~= '' then
			self:DrawShadowedTextAligned(self.AmmoStored, ammoStoredText, x, y, color_white)
		end

		render.SetScissorRect(0, 0, 0, 0, false)

		surface.SetDrawColor(color_white)
		surface.DrawRect(x - lineXLen, y + lineY, lineXLen, ScreenScale(1))
	else
		self:DrawShadowedTextAligned(self.AmmoStored, ammoStoredText, x, y, color_white)
	end
end

FFGSHUD:AddPaintHook('PaintPlayerStats')
FFGSHUD:AddPaintHook('PaintWeaponStats')
