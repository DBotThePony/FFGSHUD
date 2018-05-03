
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

FFGSHUD.ENABLE_BATTLESTATS = FFGSHUD:CreateConVar('stats', '1', 'Enable battle stats')
FFGSHUD.ENABLE_BATTLESTATS_KILLS = FFGSHUD:CreateConVar('stats_frags', '1', 'Enable frags stat')
FFGSHUD.ENABLE_BATTLESTATS_DEATHS = FFGSHUD:CreateConVar('stats_deaths', '1', 'Enable deaths stat')
FFGSHUD.ENABLE_BATTLESTATS_PING = FFGSHUD:CreateConVar('stats_ping', '1', 'Enable ping stat')

FFGSHUD.BATTLE_STATS_WIDE = 0
FFGSHUD.BATTLE_STATS_HIGH = 0

local POS_STATS = FFGSHUD:DefinePosition('battlestats', 0.87, 0.12)
FFGSHUD.POS_BATTLESTATS = POS_STATS

local color_white = FFGSHUD:CreateColorN('stats', 'Battle Stats Color', Color())
local ScreenScale = ScreenScale
local hook = hook
local amount = amount
local game = game

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
	local spacing = ScreenScale(4)
	local drawn = toDraw
	local drawn2 = toDraw2
	toDraw = {}
	toDraw2 = {}
	local color_white = color_white()

	for i = 1, math.max(#drawn, #drawn2) do
		if drawn[i] then
			self:DrawShadowedText(self.BattleStats, drawn[i], x + spacing, y, color_white)
		end

		if drawn2[i] then
			local w, h = self:DrawShadowedTextAligned(self.BattleStats, drawn2[i], x, y, color_white)
			FFGSHUD.BATTLE_STATS_WIDE = FFGSHUD.BATTLE_STATS_WIDE:max(w)
			FFGSHUD.BATTLE_STATS_HIGH = FFGSHUD.BATTLE_STATS_HIGH + h * 0.83
		end

		y = y + self.BattleStats.REGULAR_SIZE_H * 0.83
	end

	return x, y
end

local ipLookup

function FFGSHUD:DrawBattleStats()
	if not self:GetVarAlive() or not self.ENABLE_BATTLESTATS:GetBool() then
		return
	end

	local color_white = color_white()
	local spacing = ScreenScale(4)
	local x, y = POS_STATS()
	local w, h
	FFGSHUD.BATTLE_STATS_WIDE = 0
	FFGSHUD.BATTLE_STATS_HIGH = 0

	hook.Run('FFGSHUD_AddStatsLines_Pre', addLines, addLines2, self)
	x, y = doDrawLines(self, x, y)

	if self.ENABLE_BATTLESTATS_KILLS:GetBool() then
		w, h = self:DrawShadowedTextAligned(self.BattleStats, self:GetVarFrags(), x, y, color_white)
		FFGSHUD.BATTLE_STATS_WIDE = FFGSHUD.BATTLE_STATS_WIDE:max(w)
		FFGSHUD.BATTLE_STATS_HIGH = FFGSHUD.BATTLE_STATS_HIGH + h * 0.83
		self:DrawShadowedText(self.BattleStats, self.ICON_FRAGS, x + spacing, y, color_white)
		y = y + h * 0.83
	end

	if self.ENABLE_BATTLESTATS_DEATHS:GetBool() then
		w, h = self:DrawShadowedTextAligned(self.BattleStats, self:GetVarDeaths(), x, y, color_white)
		FFGSHUD.BATTLE_STATS_WIDE = FFGSHUD.BATTLE_STATS_WIDE:max(w)
		FFGSHUD.BATTLE_STATS_HIGH = FFGSHUD.BATTLE_STATS_HIGH + h * 0.83
		self:DrawShadowedText(self.BattleStats, self.ICON_DEATHS, x + spacing, y, color_white)
		y = y + h * 0.83
	end

	if ipLookup == nil then
		local ip = game.GetIPAddress()
		ipLookup = ip:startsWith('192.168.') or
			ip:startsWith('10.') or
			ip:startsWith('127.') or
			ip == '0.0.0.0' or
			ip:startsWith('172.16')
	end

	if not ipLookup and not game.SinglePlayer() and self.ENABLE_BATTLESTATS_PING:GetBool() then
		w, h = self:DrawShadowedTextAligned(self.BattleStats, self:GetVarPing(), x, y, color_white)
		FFGSHUD.BATTLE_STATS_WIDE = FFGSHUD.BATTLE_STATS_WIDE:max(w)
		FFGSHUD.BATTLE_STATS_HIGH = FFGSHUD.BATTLE_STATS_HIGH + h * 0.83
		self:DrawShadowedText(self.BattleStats, self.ICON_PING, x + spacing, y, color_white)
		y = y + h * 0.83
	end

	hook.Run('FFGSHUD_AddStatsLines_Post', addLines, addLines2, self)
	x, y = doDrawLines(self, x, y)
end

FFGSHUD:AddPaintHook('DrawBattleStats')
