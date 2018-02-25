
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
			if not self:ShouldDisplaySecondaryAmmo() then
				if self:GetVarClipMax1() ~= 1 then
					w, h = self:DrawShadowedTextAligned(self.AmmoAmount, ('%i / %i'):format(self:GetVarClip1(), self:GetVarClipMax1()), x, y, color_white)
				else
					w, h = self:DrawShadowedTextAligned(self.AmmoAmount, self:GetVarClip1(), x, y, color_white)
				end

				y = y + h * 0.83

				self:DrawShadowedTextAligned(self.AmmoStored, self:GetVarAmmo1(), x, y, color_white)
			else
				local ready = self:SelectSecondaryAmmoReady()
				local stored = self:SelectSecondaryAmmoStored()

				if self:GetVarClipMax1() ~= 1 then
					if ready ~= -1 then
						w, h = self:DrawShadowedTextAligned(self.AmmoAmount, ('%i / %i (%i / %i)'):format(self:GetVarClip1(), self:GetVarClipMax1(), self:GetVarClip2(), self:GetVarClipMax2()), x, y, color_white)
					else
						w, h = self:DrawShadowedTextAligned(self.AmmoAmount, ('%i / %i'):format(self:GetVarClip1(), self:GetVarClipMax1()), x, y, color_white)
					end
				else
					if ready ~= 1 then
						w, h = self:DrawShadowedTextAligned(self.AmmoAmount, ('%i (%i / %i)'):format(self:GetVarClip1(), self:GetVarClip2(), self:GetVarClipMax2()), x, y, color_white)
					else
						w, h = self:DrawShadowedTextAligned(self.AmmoAmount, ('%i'):format(self:GetVarClip1()), x, y, color_white)
					end
				end

				y = y + h * 0.83

				if stored == -1 then
					self:DrawShadowedTextAligned(self.AmmoStored, self:GetVarAmmo1(), x, y, color_white)
				else
					self:DrawShadowedTextAligned(self.AmmoStored, ('%i / %i'):format(self:GetVarAmmo1(), stored), x, y, color_white)
				end
			end
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
