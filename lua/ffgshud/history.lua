
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

local RealTimeL = RealTimeL
local DLib = DLib
local FFGSHUD = FFGSHUD
local ipairs = ipairs
local surface = surface
local string = string
local table = table
local IsValid = FindMetaTable('Entity').IsValid
local DEFAULT_TTL = 5

FFGSHUD.PickupsHistory = {}

local glitchPattern = {}

for i = 11, 30 do
	table.insert(glitchPattern, string.char(i))
end

for i = 34, 150 do
	table.insert(glitchPattern, string.char(i))
end

local function generateSequences(finalText, startTime, maxTime)
	maxTime = maxTime or 0.5
	local output = {}
	local iterations = #finalText * 8
	local perFrame = maxTime / iterations
	local len = #finalText
	local visible = {}

	for i = 1, len do
		visible[i] = false
	end

	local freeSlots = len

	for i = 1, iterations do
		local build = {}

		for i = 1, len do
			if visible[i] then
				table.insert(build, finalText[i])
			else
				table.insert(build, table.frandom(glitchPattern))
			end
		end

		local outputString = table.concat(build)

		table.insert(output, {
			str = outputString,
			ttl = startTime + i * perFrame
		})

		if i % 8 == 0 then
			if freeSlots <= 0 then break end -- ???

			while freeSlots > 0 do
				local rnd = math.random(1, len)

				if not visible[rnd] then
					visible[rnd] = true
					freeSlots = freeSlots - 1
					break
				end
			end
		end
	end

	-- so we can pop from top of array
	return table.flip(output)
end

local function generateSequencesOut(finalText, startTime, maxTime)
	maxTime = maxTime or 0.5
	local output = {}
	local iterations = #finalText * 8
	local perFrame = maxTime / iterations
	local len = #finalText
	local visible = {}

	for i = 1, len do
		visible[i] = 0
	end

	local freeSlots = len
	local freeSlotsGlitch = len

	for i = 1, iterations do
		local build = {}

		for i = 1, len do
			if visible[i] == 0 then
				table.insert(build, finalText[i])
			elseif visible[i] == 2 then
				table.insert(build, table.frandom(glitchPattern))
			end
		end

		local outputString = table.concat(build)

		table.insert(output, {
			str = outputString,
			ttl = startTime + i * perFrame
		})

		if i % 3 == 0 and freeSlots > 0 then
			local rnd = math.random(1, freeSlots)
			freeSlots = freeSlots - 1
			local pos = 0

			for i = 1, #visible do
				if visible[i] ~= 1 then
					pos = pos + 1

					if pos == rnd then
						if visible[i] == 0 then
							freeSlotsGlitch = freeSlotsGlitch - 1
						end

						visible[i] = 1
						break
					end
				end
			end
		end

		if i % 8 == 0 and freeSlotsGlitch > 0 then
			local rnd = math.random(1, freeSlotsGlitch)
			freeSlotsGlitch = freeSlotsGlitch - 1
			local pos = 0

			for i = 1, #visible do
				if visible[i] == 0 then
					pos = pos + 1

					if pos == rnd then
						visible[i] = 2
						break
					end
				end
			end
		end
	end

	-- so we can pop from top of array
	return table.flip(output)
end

local function checkForFreeSlots()
	return #self.PickupsHistory < 3
end

local function refreshActivity(self, startPos)
	startPos = startPos or 1
	local stamp = RealTimeL()

	for i = startPos, math.min(startPos + 2, #self.PickupsHistory) do
		local data = self.PickupsHistory[i]
		data.ttl = stamp + DEFAULT_TTL
		data.sequencesEnd = generateSequencesOut(data.localized, stamp + DEFAULT_TTL - 2, 2)
	end
end

local function refreshActivityIfPossible(self)
	if #self.PickupsHistory == 0 then return end

	if #self.PickupsHistory < 3 then
		refreshActivity(self, 1)
	elseif #self.PickupsHistory % 3 ~= 0 then
		refreshActivity(self, #self.PickupsHistory - #self.PickupsHistor % 3 + 1)
	end
end

local function grabSlotTime(self)
	local amount = #self.PickupsHistory
	if amount == 0 then return RealTimeL(), RealTimeL() + DEFAULT_TTL, false end
	if amount < 3 then return self.PickupsHistory[1].start, self.PickupsHistory[1].ttl, true end

	if amount % 3 == 0 then
		return self.PickupsHistory[amount].ttl, self.PickupsHistory[amount].ttl + DEFAULT_TTL, false
	else
		local i = amount - amount % 3 + 1
		return self.PickupsHistory[i].start, self.PickupsHistory[i].ttl, true
	end
end

local language = language

function FFGSHUD:HUDAmmoPickedUp(ammoid, ammocount)
	if ammocount == 0 then return end -- ???

	for i, data in ipairs(self.PickupsHistory) do
		if data.type == 'ammo' and data.ammoid == ammoid then
			data.amount = data.amount + ammocount
			return
		end
	end

	local localized = language.GetPhrase(('#%s_Ammo'):format(ammoid))
	surface.SetFont(self.PickupHistoryFont.REGULAR)
	local w, h = surface.GetTextSize(localized)
	refreshActivityIfPossible(self)
	local startTime, ttlTime, isContinuing = grabSlotTime(self)
	local animStartTime = not isContinuing and startTime or RealTimeL()
	local slideOut = ttlTime - 2

	local newData = {
		type = 'ammo',
		ammoid = ammoid,
		amount = ammocount,
		localized = localized,
		ow = w,
		oh = h,
		w = w * 1.6,
		h = h * 1.2,
		wPadding = w * 0.1,
		hPadding = h * 0.1,
		start = startTime,
		ttl = ttlTime,
		slideIn = 0,
		slideOut = 0,
		drawText = localized,

		sequencesStart = generateSequences(localized, animStartTime + 0.75, 1),
		sequencesEnd = generateSequencesOut(localized, slideOut, 2),

		-- white slider
		slideInStart = animStartTime,
		slideInEnd = animStartTime + 0.6,

		-- white slider out in start
		slideOutStart = animStartTime + 0.6,
		slideOutEnd = animStartTime + 1.5,

		startGlitchOut = slideOut,
	}

	print(ammoid, ttlTime, slideOut, newData.sequencesEnd[#newData.sequencesEnd].ttl, newData.sequencesEnd[1].ttl)

	table.insert(self.PickupsHistory, newData)

	return true
end

function FFGSHUD:HUDItemPickedUp(printname)
	return true
end

function FFGSHUD:HUDWeaponPickedUp(ent)
	return true
end

local DRAWPOS = FFGSHUD:DefinePosition('history', 0.04, 0.4)
local Cosine = Cosine
local Quintic = Quintic
local HUDCommons = DLib.HUDCommons
local color_white = Color()
local ScreenSize = ScreenSize

function FFGSHUD:HUDDrawPickupHistory()
	local x, y = DRAWPOS()
	local time = RealTimeL()

	for i, data in ipairs(self.PickupsHistory) do
		if data.slideIn < 1 then
			HUDCommons.DrawBox(x, y, data.w * data.slideIn, data.h, color_white)
		else
			self:DrawShadowedText(self.PickupHistoryFont, data.drawText, x + ScreenSize(9), y + data.hPadding, color_white)
		end

		if data.slideOut < 1 and data.slideOut ~= 0 then
			HUDCommons.DrawBox(x, y, data.w * (1 - data.slideOut), data.h, color_white)
		end

		y = y + data.h
	end

	return true
end

function FFGSHUD:ThinkPickupHistory()
	local toRemove
	local time = RealTimeL()

	for i, data in ipairs(self.PickupsHistory) do
		if data.ttl < time then
			toRemove = toRemove or {}
			table.insert(toRemove, i)
			goto CONTINUE
		end

		if data.start > time then
			goto CONTINUE
		end

		data.slideIn = Cubic(time:progression(data.slideInStart, data.slideInEnd))
		data.slideOut = Quintic(time:progression(data.slideOutStart, data.slideOutEnd))

		if #data.sequencesStart > 1 then
			while #data.sequencesStart > 1 do
				local seq = data.sequencesStart[#data.sequencesStart]

				if seq.ttl > time then
					data.drawText = seq.str
					break
				else
					table.remove(data.sequencesStart)
				end
			end
		elseif data.startGlitchOut <= time then
			while #data.sequencesEnd > 1 do
				local seq = data.sequencesEnd[#data.sequencesEnd]
				-- print(data.localized, seq.ttl, time, seq.ttl > time)

				if seq.ttl > time then
					data.drawText = seq.str
					break
				else
					table.remove(data.sequencesEnd)
				end
			end
		else
			data.drawText = data.localized
		end

		::CONTINUE::
	end

	if toRemove then
		table.removeValues(self.PickupsHistory, toRemove)
	end
end

FFGSHUD:AddHook('HUDDrawPickupHistory')
FFGSHUD:AddHook('HUDAmmoPickedUp')
FFGSHUD:AddHook('HUDItemPickedUp')
FFGSHUD:AddHook('HUDWeaponPickedUp')
FFGSHUD:AddThinkHook('ThinkPickupHistory')
