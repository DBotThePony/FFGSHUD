
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

FFGSHUD.BATTLE_STATS_WIDE = 0
local POS_STATS = FFGSHUD:DefinePosition('battlestats', 0.87, 0.12)
local color_white = Color()
local ScreenScale = ScreenScale
local hook = hook
local amount = amount

local toDraw = {}
local toDraw2 = {}

local function addLines(...)
	local amount = select('#', ...)

	for i = 1, amount do
		table.insert(toDraw, select(i, ...))
	end
end

local function addLines2(...)
	local amount = select('#', ...)

	for i = 1, amount do
		table.insert(toDraw2, select(i, ...))
	end
end

local function doDrawLines(self, x, y)
	local drawn = toDraw
	local drawn2 = toDraw2
	toDraw = {}
	toDraw2 = {}

	for i = 1, #drawn do
		local w, h = self:DrawShadowedText(self.BattleStats, drawn[i], x + spacing, y, color_white)
		y = y + h * 0.83
	end

	for i = 1, #drawn2 do
		local w, h = self:DrawShadowedTextAligned(self.BattleStats, drawn2[i], x + spacing, y, color_white)
		FFGSHUD.BATTLE_STATS_WIDE = FFGSHUD.BATTLE_STATS_WIDE:max(w)
		y = y + h * 0.83
	end

	return x, y
end

function FFGSHUD:DrawBattleStats()
	if not self:GetVarAlive() then
		return
	end

	local spacing = ScreenScale(4)
	local x, y = POS_STATS()
	local w, h
	FFGSHUD.BATTLE_STATS_WIDE = 0

	hook.Run('FFGSHUD_AddStatsLines_Pre', addLines, addLines2, self)
	x, y = doDrawLines(self, x, y)

	w, h = self:DrawShadowedTextAligned(self.BattleStats, self:GetVarFrags(), x, y, color_white)
	FFGSHUD.BATTLE_STATS_WIDE = FFGSHUD.BATTLE_STATS_WIDE:max(w)
	self:DrawShadowedText(self.BattleStats, self.ICON_FRAGS, x + spacing, y, color_white)
	y = y + h * 0.83
	w, h = self:DrawShadowedTextAligned(self.BattleStats, self:GetVarDeaths(), x, y, color_white)
	FFGSHUD.BATTLE_STATS_WIDE = FFGSHUD.BATTLE_STATS_WIDE:max(w)
	self:DrawShadowedText(self.BattleStats, self.ICON_DEATHS, x + spacing, y, color_white)
	y = y + h * 0.83
	w, h = self:DrawShadowedTextAligned(self.BattleStats, self:GetVarPing(), x, y, color_white)
	FFGSHUD.BATTLE_STATS_WIDE = FFGSHUD.BATTLE_STATS_WIDE:max(w)
	self:DrawShadowedText(self.BattleStats, self.ICON_PING, x + spacing, y, color_white)
	y = y + h * 0.83

	hook.Run('FFGSHUD_AddStatsLines_Post', addLines, addLines2, self)
	x, y = doDrawLines(self, x, y)
end

FFGSHUD:AddPaintHook('DrawBattleStats')
