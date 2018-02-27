
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

local POS_STATS = FFGSHUD:DefinePosition('battlestats', 0.87, 0.12)
local color_white = Color()
local ScreenScale = ScreenScale

function FFGSHUD:DrawBattleStats()
	if not self:GetVarAlive() then
		return
	end

	local spacing = ScreenScale(4)
	local x, y = POS_STATS()
	local w, h = self:DrawShadowedTextAligned(self.BattleStats, self:GetVarFrags(), x, y, color_white)
	self:DrawShadowedText(self.BattleStats, self.ICON_FRAGS, x + spacing, y, color_white)
	y = y + h * 0.83
	w, h = self:DrawShadowedTextAligned(self.BattleStats, self:GetVarDeaths(), x, y, color_white)
	self:DrawShadowedText(self.BattleStats, self.ICON_DEATHS, x + spacing, y, color_white)
	y = y + h * 0.83
	w, h = self:DrawShadowedTextAligned(self.BattleStats, self:GetVarPing(), x, y, color_white)
	self:DrawShadowedText(self.BattleStats, self.ICON_PING, x + spacing, y, color_white)
	y = y + h * 0.83
end

FFGSHUD:AddPaintHook('DrawBattleStats')
