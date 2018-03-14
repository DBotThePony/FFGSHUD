
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

local function onDamage()
	local dmgType = net.ReadUInt64()
	local dmg = net.ReadFloat()
	local reportedPosition

	if net.ReadBool() then
		reportedPosition = net.ReadVector()
	end

	if not reportedPosition then
		reportedPosition = Vector()
	end

	FFGSHUD:ExtendGlitch(dmg:sqrt() / 14)
	FFGSHUD:ClampGlitchTime(1)

	table.insert(history, {
		damage = dmg,
		start = RealTime(),
		endtime = RealTime() + dmg:sqrt() * 0.7,
		pos = reportedPosition,
		arc1 = reportedPosition and 0 or -185,
		arc2 = reportedPosition and 0 or 10,
		arcsize = (dmg * ScreenSize(5)):min(ScreenSize(40)),
		inLen = (dmg:pow(2) * ScreenSize(0.1)):min(ScreenSize(25)),
		shouldDraw = reportedPosition == nil,
		reportedPosition = reportedPosition,
	})
end

net.receive('ffgs.damagereceived', onDamage)

function FFGSHUD:ThinkDamageSense(ply)
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
			local yaw = -180 - pointer:Angle().y:AngleDifference(ang.y) * 0.2
			local dist = entry.reportedPosition:Distance(pos)
			local size = (entry.arcsize / dist:sqrt()):max(s)
			entry.shouldDraw = yaw < -160 and yaw > -200
			entry.arc1 = yaw - size / 2
			entry.arc2 = size
		end
	end

	if toremove then
		table.removeValues(history, toremove)
	end
end

function FFGSHUD:DrawDamageSense(ply)
	local time = RealTime()
	local y = ScrH() * 0.3

	for i, entry in ipairs(history) do
		if entry.shouldDraw then
			local alpha = 1 - time:progression(entry.start, entry.endtime)
			HUDCommons.DrawArcHollow2(ScrW() * -1, y, ScrW() * 3, 120, entry.inLen, entry.arc1, entry.arc2, Color(255, 255, 255, alpha * 200))
			y = y + entry.inLen * 0.54
		end
	end
end

FFGSHUD:AddThinkHook('ThinkDamageSense')
FFGSHUD:AddPaintHook('DrawDamageSense')
