
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
local language = language
local Color = Color
local RealTimeL = RealTimeL
local table = table
local math = math
local Vector = Vector

local notices = {}
local function npcColor(npc)
	local crc = tonumber(util.CRC(npc))
	local r = crc % 255
	crc = crc - r
	local g = (crc / 255) % 255
	crc = crc / 255 - g
	local b = (crc / 255) % 255
	return Color(r:abs(), g:abs(), b:abs())
end

function FFGSHUD:AddDeathNotice(attacker, attackerTeam, inflictor, victim, victimTeam)
	local validWeapon = inflictor ~= nil and inflictor ~= 'suicide'
	local validAttacker = attacker ~= nil and attacker ~= victim
	local worldspawn = attacker == '#world'

	local isSuicide = not validWeapon and not validAttacker or attacker == victim
	local weapon = worldspawn and 'fall damage'
		or isSuicide and language.GetPhrase('suicide') or
		(inflictor and (inflictor ~= 'worldspawn' and language.GetPhrase(inflictor) or language.GetPhrase(attacker))) or
		'???'

	weapon = weapon:upper()

	local gravity = math.random() < 0.1
	local entry = {}

	entry.weaponColor = Color(255, 255, 255)
	entry.isFallDamage = worldspawn
	entry.isSuicide = isSuicide
	entry.weapon = '[' .. weapon .. ']'
	entry.validAttacker = validAttacker

	local displayTime = ((not isSuicide and (attacker and #attacker / 4 or 0) or 0) + (#weapon / 4) + (#victim / 2)):clamp(4, 8)
	local animtime = displayTime * 0.1

	entry.ttl = RealTimeL() + displayTime
	entry.fadeInStart = RealTimeL()
	entry.fadeInEnd = RealTimeL() + animtime

	entry.fadeOutStart = RealTimeL() + displayTime - animtime
	entry.fadeOutEnd = RealTimeL() + displayTime

	entry.victim = victim
	entry.attacker = attacker

	if validAttacker then
		if attackerTeam and attackerTeam > 0 and attackerTeam ~= TEAM_UNASSIGNED then
			entry.attackerColor = team.GetColor(attackerTeam)
		else
			entry.attackerColor = npcColor(attacker)
		end
	else
		entry.attackerColor = Color(67, 158, 184)
	end

	if victimTeam and victimTeam > 0 and victimTeam ~= TEAM_UNASSIGNED then
		entry.victimColor = team.GetColor(victimTeam)
	else
		entry.victimColor = npcColor(victim)
	end

	entry.gravity = gravity

	if gravity then
		entry.velocityAttacker = {math.random(-100, 25) / 25, math.random(-15, 5)}
		entry.velocityWeapon = {math.random(-25, 25) / 25, math.random(-25, 5)}
		entry.velocityVictim = {math.random(-25, 100) / 25, math.random(-17, 5)}
		entry.posAttacker = {0, 0}
		entry.posWeapon = {0, 0}
		entry.posVictim = {0, 0}

		entry.ttl = RealTimeL() + displayTime * 2
	end

	table.insert(notices, entry)

	return true
end

local DRAW_POS = FFGSHUD:DefinePosition('killfeed', 0.85, 0.12)
local surface = surface
local ScreenSize = ScreenSize
local render = render

function FFGSHUD:DrawDeathNotice()
	local x, y = DRAW_POS()
	x = x - self.BATTLE_STATS_WIDE
	local space = ScreenSize(3)
	local time = RealTimeL()
	local H = self.KillfeedFont.REGULAR_SIZE_H

	for i, entry in ipairs(notices) do
		local x = x
		local mult = 1
		local cut = false
		local gravity = entry.gravity

		if entry.fadeInEnd > time then
			cut = true
			mult = time:progression(entry.fadeInStart, entry.fadeInEnd)
			render.PushScissorRect(0, y, x, y + H * mult)
		elseif entry.fadeOutStart < time then
			mult = 1 - time:progression(entry.fadeOutStart, entry.fadeOutEnd)

			if not gravity then
				cut = true
				render.PushScissorRect(0, y, x, y + H * mult)
			end
		end

		local addx, addy = gravity and entry.posVictim[1] or 0, gravity and entry.posVictim[2] or 0
		local w, h = self:DrawShadowedTextAligned(self.KillfeedFont, entry.victim, x + addx, y + addy, entry.victimColor)
		x = x - w - ScreenSize(5)

		local addx, addy = gravity and entry.posWeapon[1] or 0, gravity and entry.posWeapon[2] or 0
		w, h = self:DrawShadowedTextAligned(self.KillfeedFont, entry.weapon, x + addx, y + addy, entry.weaponColor)

		if entry.validAttacker then
			x = x - w - ScreenSize(5)
			local addx, addy = gravity and entry.posAttacker[1] or 0, gravity and entry.posAttacker[2] or 0
			self:DrawShadowedTextAligned(self.KillfeedFont, entry.attacker, x + addx, y + addy, entry.attackerColor)
		end

		y = y + (h + space) * mult

		if cut then
			render.PopScissorRect()
		end
	end
end

function FFGSHUD:ThinkDeathNotice()
	local toRemove
	local time = RealTimeL()
	local ftime = RealFrameTime() * 11

	for i, entry in ipairs(notices) do
		if entry.ttl < time then
			toRemove = toRemove or {}
			table.insert(toRemove, i)
		elseif entry.gravity and entry.fadeOutStart < time then
			local velx, vely = entry.velocityAttacker[1], entry.velocityAttacker[2]
			velx = velx * 0.98
			vely = vely + ftime
			entry.posAttacker[1] = entry.posAttacker[1] + velx
			entry.posAttacker[2] = entry.posAttacker[2] + vely
			entry.velocityAttacker[1], entry.velocityAttacker[2] = velx, vely

			velx, vely = entry.velocityWeapon[1], entry.velocityWeapon[2]
			velx = velx * 0.98
			vely = vely + ftime
			entry.posWeapon[1] = entry.posWeapon[1] + velx
			entry.posWeapon[2] = entry.posWeapon[2] + vely
			entry.velocityWeapon[1], entry.velocityWeapon[2] = velx, vely

			velx, vely = entry.velocityVictim[1], entry.velocityVictim[2]
			velx = velx * 0.98
			vely = vely + ftime
			entry.posVictim[1] = entry.posVictim[1] + velx
			entry.posVictim[2] = entry.posVictim[2] + vely
			entry.velocityVictim[1], entry.velocityVictim[2] = velx, vely
		end
	end

	if toRemove then
		table.removeValues(notices, toRemove)
	end
end

FFGSHUD:AddHookCustom('AddDeathNotice', 'AddDeathNotice')
FFGSHUD:AddPaintHook('DrawDeathNotice')
FFGSHUD:AddThinkHook('ThinkDeathNotice')
