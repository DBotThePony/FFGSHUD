
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
local CurTimeL = CurTimeL
local table = table
local ipairs = ipairs
local ScreenSize = ScreenSize
local HUDCommons = DLib.HUDCommons
local ScrHL = ScrHL

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
		start = CurTimeL(),
		endtime = CurTimeL() + (dmg:sqrt() * 0.7):clamp(1, 10),
		pos = reportedPosition,
		shiftOutStart = CurTimeL(),
		shiftOutMiddle = CurTimeL() + 0.1,
		shiftOutEnd = CurTimeL() + 0.12,
		arc1 = 0,
		arc2 = 0,
		arcsize = (dmg * ScreenSize(40)):min(ScreenSize(40)),
		inLen = (dmg:pow(2) * ScreenSize(0.1)):clamp(ScreenSize(3), ScreenSize(50)),
		reportedPosition = reportedPosition,
		colors = colors,
		alpha = 1,
	})
end

net.receive('ffgs.damagereceived', onDamage)

function FFGSHUD:ThinkDamageSense(ply)
	local toremove
	local time = CurTimeL()
	local pos = ply:EyePos()
	local ang = ply:EyeAnglesFixed()
	local s = ScreenSize(1)
	local s2 = ScreenSize(12)
	local vehicle = ply:InVehicle()

	for i, entry in ipairs(history) do
		if entry.endtime < time then
			toremove = toremove or {}
			table.insert(toremove, i)
		elseif entry.reportedPosition then
			local pointer = entry.reportedPosition - pos
			local yaw = -180 - pointer:Angle().y:AngleDifference(ang.y)
			local dist = entry.reportedPosition:Distance(pos)

			if vehicle then
				dist = dist:sqrt():sqrt()
			end

			local size = (entry.arcsize / dist:sqrt():sqrt()):max(s)
			entry.arc1 = yaw - size
			entry.arc2 = size
		end

		entry.alpha = 1 - time:progression(entry.start, entry.endtime)
	end

	if toremove then
		table.removeValues(history, toremove)
	end
end

local cam = cam
local Vector = Vector
local CAMANG = Angle(0, 0, 0)

function FFGSHUD:DrawDamageSense(ply)
	local sw, sh = ScrWL(), ScrHL()
	local vehicle = ply:InVehicle()
	local x = (sw - sh * 0.6) / 2
	local y = sh * 0.2
	local shiftByValue = ScreenSize(64)
	local time = CurTimeL()

	if vehicle then
		x = (sw - sh * 0.8) / 2
		y = sh * 0.1
		sh = sh * 0.8

		local ang = ply:EyeAngles()
		ang.p = -ang.p:clamp(-45, 40)
		ang.y = 0
		-- ang.r = 0
		local campos = Vector(0, -ScreenSize(400) * ang.p:progression(-35, 0), ScreenSize(300) * ang.p:progression(-140, 90))

		local sceneAng = (Vector(ScreenSize(1200) * ang.p:progression(-15, 0)) - campos):Angle()
		sceneAng.y = 90

		cam.Start3D(campos, sceneAng)
		cam.Start3D2D(Vector(-ScrWL() / 2, ScrHL() / 2, 0), CAMANG, 1)
	else
		sh = sh * 0.6
	end

	for i, entry in ipairs(history) do
		if entry.reportedPosition then
			local m = #entry.colors
			local slice = entry.arc2 / m
			local doshift = (1 - time:progression(entry.shiftOutStart, entry.shiftOutEnd)) * shiftByValue

			for i2, color in ipairs(entry.colors) do
				HUDCommons.DrawArcHollow2(x + doshift / 2, y + doshift / 2, sh - doshift, 120, entry.inLen, entry.arc1 + slice * i2 - 3, slice, color:SetAlpha(entry.alpha * 200))
			end
			--surface.DrawRect(0, 0, ScrWL(), ScrHL())
			--HUDCommons.DrawArcHollow2(x, y, sh, 120, entry.inLen, 180, 180, Color())
			--HUDCommons.DrawArcHollow2(x, y, sh, 120, entry.inLen, 0, 180, Color())

			y = y + entry.inLen * 0.5
			sh = sh - entry.inLen
			x = x + entry.inLen * 0.5
		end
	end

	sw, sh = ScrWL(), ScrHL()

	if vehicle then
		x = (sw - sh * 0.8) / 2
		y = sh * 0.1
		sh = sh * 0.8
	else
		x = (sw - sh * 0.6) / 2
		y = sh * 0.2
		sh = sh * 0.6
	end

	for i, entry in ipairs(history) do
		if not entry.reportedPosition then
			local m = #entry.colors
			local slice = 120 / m
			local doshift = time:progression(entry.shiftOutStart, entry.shiftOutEnd, entry.shiftOutMiddle) * shiftByValue * 2

			y = y - entry.inLen * 0.5
			sh = sh + entry.inLen
			x = x - entry.inLen * 0.5

			for i2, color in ipairs(entry.colors) do
				local i = i2 - 1
				HUDCommons.DrawArcHollow2(x - doshift / 2, y - doshift / 2, sh + doshift, 120, entry.inLen, -150 + slice * i, slice, color:SetAlpha(entry.alpha * 200))
				HUDCommons.DrawArcHollow2(x - doshift / 2, y - doshift / 2, sh + doshift, 120, entry.inLen, 30 + slice * i, slice, color)
			end

			--HUDCommons.DrawArcHollow2(x, y, sh, 120, entry.inLen, 180, 180, Color())
			--HUDCommons.DrawArcHollow2(x, y, sh, 120, entry.inLen, 0, 180, Color())
		end
	end

	if vehicle then
		cam.End3D2D()
		cam.End3D()
		cam.Start3D()
		cam.End3D()
	end
end

FFGSHUD:AddThinkHook('ThinkDamageSense')
FFGSHUD:AddPaintHook('DrawDamageSense')

local lastDamage = {}
local colorsDraw = {}
local textToDisplay = ''
local hideAtStart = 0
local hideAtEnd = 0
local hideInStart = 0
local hideInEnd = 0

local function updateColor(dmgtype, color, newvalue)
	local data

	for i, entry in ipairs(colorsDraw) do
		if entry.dmgtype == dmgtype then
			data = entry
			break
		end
	end

	local time = CurTimeL()

	if not data then
		data = {
			color = color,
			slideInStart = time,
			slideInEnd = time + 0.65,
			slideOutStart = newvalue - 0.65,
			slideOutEnd = newvalue,
			dmgtype = dmgtype,
		}

		if hideAtEnd < time then
			hideInStart = hideInStart:max(data.slideInStart)
			hideInEnd = hideInEnd:max(data.slideInEnd)
		end

		hideAtStart = hideAtStart:max(data.slideOutStart)
		hideAtEnd = hideAtEnd:max(data.slideOutEnd)

		table.insert(colorsDraw, data)
		return
	end

	data.color = color

	if data.slideOutStart < time then
		data.slideInStart = data.slideOutStart
		data.slideInEnd = data.slideOutEnd
	end

	data.slideOutEnd = data.slideOutEnd:max(newvalue)
	data.slideOutStart = data.slideOutEnd - 0.65

	if hideAtEnd < time then
		hideInStart = hideInStart:max(data.slideInStart)
		hideInEnd = hideInEnd:max(data.slideInEnd)
	end

	hideAtStart = hideAtStart:max(data.slideOutStart)
	hideAtEnd = hideAtEnd:max(data.slideOutEnd)
end

local function rebuild()
	local amount = 0

	for i, entry in ipairs(lastDamage) do
		amount = amount - entry.dmg
		local dmgtype = entry.dmgtype

		if dmgtype == DMG_GENERIC then -- stopid addons
			updateColor(dmgtype, Color(), entry.endtime)
		else
			for i, clr in ipairs(dmgColors) do
				if clr[1]:band(dmgtype) == clr[1] then
					updateColor(clr[1], clr[2]:Copy(), entry.endtime)
				end
			end
		end
	end

	textToDisplay = tostring(amount:floor())
end

local function damageDealed()
	local dmgtype = net.ReadUInt64()
	local dmg = net.ReadFloat()

	table.insert(lastDamage, {
		start = CurTimeL(),
		endtime = CurTimeL() + dmg:sqrt():clamp(2, 8),
		dmgtype = dmgtype,
		dmg = dmg,
	})

	rebuild()
end

net.receive('ffgs.damagedealed', damageDealed)

local surface = surface
local DRAWPOS = FFGSHUD:DefinePosition('lastdealed', 0.5, 0.85)
local render = render

function FFGSHUD:DrawLastDamageDealed(ply)
	local time = CurTimeL()
	if hideAtEnd < time then return end
	local x, y = ScrW() * 0.5, ScrH() * 0.85
	surface.SetFont(self.LastDamageDealed.BLURRY)
	local w, h = surface.GetTextSize(textToDisplay)

	local alpha = 255 * (time < hideAtStart and time:progression(hideInStart, hideInEnd) or (1 - time:progression(hideAtStart, hideAtEnd)))
	local color_black = Color(0, 0, 0, alpha)

	HUDCommons.SimpleText(textToDisplay, self.LastDamageDealed.BLURRY, x - w / 2, y, color_black)
	HUDCommons.SimpleText(textToDisplay, self.LastDamageDealed.BLURRY, x - w / 2, y, color_black)
	local amount = #colorsDraw

	surface.SetFont(self.LastDamageDealed.REGULAR)
	w, h = surface.GetTextSize(textToDisplay)
	local step = w / amount

	for i, entry in ipairs(colorsDraw) do
		-- performance
		render.SetScissorRect(x - w / 2 + step * (i - 1), y, x - w / 2 + step * i, y + h, true)
		HUDCommons.SimpleText(textToDisplay, self.LastDamageDealed.REGULAR, x - w / 2, y, entry.color:SetAlpha(alpha))
	end

	render.SetScissorRect(0, 0, 0, 0, false)
end

function FFGSHUD:ThinkLastDamageDealed(ply)
	local time = CurTimeL()
	local toRemoveDamage, toRemoveColor

	for i, entry in ipairs(lastDamage) do
		if entry.endtime < time then
			toRemoveDamage = toRemoveDamage or {}
			table.insert(toRemoveDamage, i)
		end
	end

	for i, entry in ipairs(colorsDraw) do
		if entry.slideOutEnd < time then
			toRemoveColor = toRemoveColor or {}
			table.insert(toRemoveColor, i)
		end
	end

	if toRemoveDamage or toRemoveColor then
		if toRemoveDamage then
			table.removeValues(lastDamage, toRemoveDamage)
		end

		if toRemoveColor then
			table.removeValues(colorsDraw, toRemoveColor)
		end

		rebuild()
	end
end

FFGSHUD:AddThinkHook('ThinkLastDamageDealed')
FFGSHUD:AddPaintHook('DrawLastDamageDealed')
