
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
local net = net
local RealTime = RealTime
local table = table
local ipairs = ipairs
local ScreenSize = ScreenSize
local HUDCommons = DLib.HUDCommons
local ScrH = ScrH

local history = {}

-- DHUD/2 Color palette
local dmgColorsPalette = {
	-- [DMG_GENERIC] = color_white,
	[DMG_CRUSH] = Color(255, 210, 60),
	[DMG_CLUB] = Color(255, 210, 60),
	[DMG_BULLET] = Color(154, 199, 245),
	[DMG_SLASH] = Color(255, 165, 165),
	[DMG_BURN] = Color(255, 64, 64),
	[DMG_SLOWBURN] = Color(255, 64, 64),
	[DMG_VEHICLE] = Color(255, 210, 60),
	[DMG_FALL] = Color(250, 55, 255),
	[DMG_BLAST] = Color(255, 170, 64),
	[DMG_SHOCK] = Color(64, 198, 255),
	[DMG_SONIC] = Color(64, 198, 255),
	[DMG_ENERGYBEAM] = Color(255, 255, 60),
	[DMG_DROWN] = Color(64, 128, 255),
	[DMG_PARALYZE] = Color(115, 255, 60),
	[DMG_NERVEGAS] = Color(115, 255, 60),
	[DMG_POISON] = Color(115, 255, 60),
	[DMG_ACID] = Color(0, 200, 50),
	[DMG_RADIATION] = Color(0, 200, 50),
	[DMG_AIRBOAT] = Color(192, 220, 216),
	[DMG_BLAST_SURFACE] = Color(255, 170, 64),
	[DMG_DIRECT] = Color(0, 0, 0),
	[DMG_DISSOLVE] = Color(175, 36, 255),
	[DMG_DROWNRECOVER] = Color(64, 128, 255),
	[DMG_PHYSGUN] = Color(255, 210, 60),
	[DMG_PLASMA] = Color(131, 155, 255),
}

local dmgColors = {}

for k, v in pairs(dmgColorsPalette) do
	table.insert(dmgColors, {k, v})
end

local function onDamage()
	local dmgType = net.ReadUInt64()
	local dmg = net.ReadFloat()
	local reportedPosition
	local colors = {}

	if net.ReadBool() then
		reportedPosition = net.ReadVector()
	end

	if dmgType == DMG_GENERIC then -- stopid addons
		table.insert(colors, Color())
	else
		for i, clr in ipairs(dmgColors) do
			if clr[1]:band(dmgType) == clr[1] then
				table.insert(colors, clr[2]:Copy())
			end
		end
	end

	FFGSHUD:ExtendGlitch(dmg:sqrt() / 14)
	FFGSHUD:ClampGlitchTime(1)

	if #colors == 0 then
		table.insert(colors, Color())
	end

	table.insert(history, {
		damage = dmg,
		start = RealTime(),
		endtime = RealTime() + dmg:sqrt() * 0.7,
		pos = reportedPosition,
		arc1 = reportedPosition and 0 or -192,
		arc2 = reportedPosition and 0 or 10,
		arcsize = (dmg * ScreenSize(10)):min(ScreenSize(40)),
		inLen = (dmg:pow(2) * ScreenSize(0.1)):min(ScreenSize(50)),
		reportedPosition = reportedPosition,
		colors = colors,
		alpha = 1,
	})
end

net.receive('ffgs.damagereceived', onDamage)

function FFGSHUD:ThinkDamageSense(ply)
	if not self:GetVarAlive() then return end
	local toremove
	local time = RealTime()
	local pos = ply:EyePos()
	local ang = ply:EyeAngles()
	local s = ScreenSize(1)
	local s2 = ScreenSize(12)

	for i, entry in ipairs(history) do
		if entry.endtime < time then
			toremove = toremove or {}
			table.insert(toremove, i)
		elseif entry.reportedPosition then
			local pointer = entry.reportedPosition - pos
			local yaw = -180 - pointer:Angle().y:AngleDifference(ang.y)
			local dist = entry.reportedPosition:Distance(pos)
			local size = (entry.arcsize / dist:sqrt()):max(s)
			entry.arc1 = yaw - size
			entry.arc2 = size
		end

		entry.alpha = 1 - time:progression(entry.start, entry.endtime)
	end

	if toremove then
		table.removeValues(history, toremove)
	end
end

function FFGSHUD:DrawDamageSense(ply)
	if not self:GetVarAlive() then return end
	local sw, sh = ScrW(), ScrH()
	local x = (sw - sh * 0.6) / 2
	local y = sh * 0.2
	sh = sh * 0.6

	for i, entry in ipairs(history) do
		local m = #entry.colors
		local slice = entry.arc2 / m

		for i2, color in ipairs(entry.colors) do
			HUDCommons.DrawArcHollow2(x, y, sh, 120, entry.inLen, entry.arc1 + slice * i2 - 3, slice, color:SetAlpha(entry.alpha * 200))
		end

		--HUDCommons.DrawArcHollow2(x, y, sh, 120, entry.inLen, 180, 180, Color())
		--HUDCommons.DrawArcHollow2(x, y, sh, 120, entry.inLen, 0, 180, Color())

		y = y + entry.inLen * 0.5
		sh = sh - entry.inLen
		x = x + entry.inLen * 0.5
	end
end

FFGSHUD:AddThinkHook('ThinkDamageSense')
FFGSHUD:AddPaintHook('DrawDamageSense')
