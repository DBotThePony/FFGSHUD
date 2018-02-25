
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

	if self:ShouldDisplayAmmo() then
		if self:ShouldDisplayAmmoStored() then
			local ammoReadyText = ''
			local ammoStoredText = self:GetVarAmmo1()

			if self:GetVarClipMax1() ~= 1 then
				if self:GetVarClipMax1() < self:GetVarClip1() then
					ammoReadyText = ('%i + %i / %i'):format(self:GetVarClipMax1(), self:GetVarClip1() - self:GetVarClipMax1(), self:GetVarClipMax1())
				else
					ammoReadyText = ('%i / %i'):format(self:GetVarClip1(), self:GetVarClipMax1())
				end
			else
				ammoReadyText = self:GetVarClip1()
			end

			if self:ShouldDisplaySecondaryAmmo() then
				local ready = self:SelectSecondaryAmmoReady()
				local stored = self:SelectSecondaryAmmoStored()

				if ready ~= -1 then
					ammoReadyText = ammoReadyText .. (' (%i / %i)'):format(self:GetVarClip2(), self:GetVarClipMax2())
				end

				if stored ~= -1 then
					ammoStoredText = ammoStoredText .. (' / %i'):format(stored)
				end
			end

			w, h = self:DrawShadowedTextAligned(self.AmmoAmount, ammoReadyText, x, y, color_white)
			y = y + h * 0.83

			self:DrawShadowedTextAligned(self.AmmoStored, ammoStoredText, x, y, color_white)
		else
			if not self:ShouldDisplaySecondaryAmmo() then
				self:DrawShadowedTextAligned(self.AmmoAmount, self:GetVarAmmo1(), x, y, color_white)
			else
				self:DrawShadowedTextAligned(self.AmmoAmount, ('%i / %i'):format(self:GetVarAmmo1(), self:GetVarClip2()), x, y, color_white)
			end
		end
	else
		self:DrawShadowedTextAligned(self.AmmoAmount, '-', x, y, color_white)
	end
end

FFGSHUD:AddPaintHook('PaintPlayerStats')
FFGSHUD:AddPaintHook('PaintWeaponStats')
