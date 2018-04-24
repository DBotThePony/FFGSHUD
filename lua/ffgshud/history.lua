
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
local MAXIMAL_SLOTS = 4

FFGSHUD.PickupsHistory = {}
local glitchPattern = {}

--[[

for i = 11, 30 do
	table.insert(glitchPattern, string.char(i))
end

for i = 34, 150 do
	table.insert(glitchPattern, string.char(i))
end
]]

local _glitchPattern = 'QWERTYUIOPASDFGHJKLZXCVBNM,.[];/\\!@#$%^&*()'

for char in _glitchPattern:gmatch('.') do
	table.insert(glitchPattern, char)
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

		if i % 5 == 0 and freeSlots > 0 then
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

		if i % 3 == 0 and freeSlotsGlitch > 0 then
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
	return #self.PickupsHistory < MAXIMAL_SLOTS
end

local function refreshActivity(self, startPos)
	startPos = startPos or 1
	local stamp = RealTimeL()

	for i = startPos, math.min(startPos + 2, #self.PickupsHistory) do
		local data = self.PickupsHistory[i]
		data.ttl = data.ttl:max(stamp + DEFAULT_TTL)
		data.sequencesEnd = generateSequencesOut(data.localized, data.ttl - 1, 1)
		data.startGlitchOut = data.ttl - 1
	end
end

local function refreshActivityIfPossible(self)
	if #self.PickupsHistory == 0 then return end

	if #self.PickupsHistory < MAXIMAL_SLOTS then
		refreshActivity(self, 1)
	elseif #self.PickupsHistory % MAXIMAL_SLOTS ~= 0 then
		refreshActivity(self, #self.PickupsHistory - #self.PickupsHistory % MAXIMAL_SLOTS + 1)
	end
end

local function grabSlotTime(self)
	local amount = #self.PickupsHistory
	if amount == 0 then return RealTimeL(), RealTimeL() + DEFAULT_TTL, false end
	if amount < MAXIMAL_SLOTS then return self.PickupsHistory[1].start, self.PickupsHistory[1].ttl, true end

	if amount % MAXIMAL_SLOTS == 0 then
		return self.PickupsHistory[amount].ttl, self.PickupsHistory[amount].ttl + DEFAULT_TTL, false
	else
		local i = amount - amount % MAXIMAL_SLOTS + 1
		return self.PickupsHistory[i].start, self.PickupsHistory[i].ttl, true
	end
end

local language = language

function FFGSHUD:HUDAmmoPickedUp(ammoid, ammocount)
	if ammocount == 0 then return end -- ???

	for i, data in ipairs(self.PickupsHistory) do
		if data.type == 'ammo' and data.ammoid == ammoid then
			data.amount = data.amount + ammocount
			data.localized = data.localized2 .. ' ' .. data.amount
			data.sequencesStart = generateSequences(data.localized, data.start + 0.9, 1)
			data.sequencesEnd = generateSequencesOut(data.localized, data.startGlitchOut, 1)
			return
		end
	end

	local localized2 = language.GetPhrase(('#%s_Ammo'):format(ammoid))
	local localized = localized2 .. ' ' .. ammocount
	surface.SetFont(self.PickupHistoryFont.REGULAR)
	local w, h = surface.GetTextSize(localized)
	refreshActivityIfPossible(self)
	local startTime, ttlTime, isContinuing = grabSlotTime(self)
	local slideOut = ttlTime - 1

	local newData = {
		type = 'ammo',
		ammoid = ammoid,
		amount = ammocount,
		localized = localized,
		localized2 = localized2,
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

		sequencesStart = generateSequences(localized, startTime + 0.9, 1),
		sequencesEnd = generateSequencesOut(localized, slideOut, 1),

		-- white slider
		slideInStart = startTime,
		slideInEnd = startTime + 0.6,

		-- white slider out in start
		slideOutStart = startTime + 0.6,
		slideOutEnd = startTime + 1.5,

		startGlitchOut = slideOut,
	}

	table.insert(self.PickupsHistory, newData)

	return true
end

function FFGSHUD:HUDItemPickedUp(printname)
	if printname[1] == '#' then
		printname = language.GetPhrase(printname:sub(2))
	else
		printname = language.GetPhrase(printname)
	end

	local localized = printname
	surface.SetFont(self.PickupHistoryFont.REGULAR)
	local w, h = surface.GetTextSize(localized)
	refreshActivityIfPossible(self)
	local startTime, ttlTime, isContinuing = grabSlotTime(self)
	local slideOut = ttlTime - 1

	local newData = {
		type = 'entity',
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

		sequencesStart = generateSequences(localized, startTime + 0.9, 1),
		sequencesEnd = generateSequencesOut(localized, slideOut, 1),

		-- white slider
		slideInStart = startTime,
		slideInEnd = startTime + 0.6,

		-- white slider out in start
		slideOutStart = startTime + 0.6,
		slideOutEnd = startTime + 1.5,

		startGlitchOut = slideOut,
	}

	table.insert(self.PickupsHistory, newData)

	return true
end

function FFGSHUD:HUDWeaponPickedUp(ent)
	local localized = ent:GetPrintName()

	if localized[1] == '#' then
		localized = language.GetPhrase(localized:sub(2))
	end

	surface.SetFont(self.PickupHistoryFont.REGULAR)
	local w, h = surface.GetTextSize(localized)
	refreshActivityIfPossible(self)
	local startTime, ttlTime, isContinuing = grabSlotTime(self)
	local slideOut = ttlTime - 1

	local newData = {
		type = 'weapon',
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

		sequencesStart = generateSequences(localized, startTime + 0.9, 1),
		sequencesEnd = generateSequencesOut(localized, slideOut, 1),

		-- white slider
		slideInStart = startTime,
		slideInEnd = startTime + 0.6,

		-- white slider out in start
		slideOutStart = startTime + 0.6,
		slideOutEnd = startTime + 1.5,

		startGlitchOut = slideOut,
	}

	table.insert(self.PickupsHistory, newData)

	return true
end

local DRAWPOS = FFGSHUD:DefinePosition('history', 0.04, 0.4)
local Cosine = Cosine
local Quintic = Quintic
local HUDCommons = DLib.HUDCommons
local color_white = Color()
local ScreenSize = ScreenSize
local ScrWL, ScrHL = ScrWL, ScrHL

function FFGSHUD:HUDDrawPickupHistory()
	--local x, y = DRAWPOS()
	local x, y = ScrWL() * 0.04, ScrHL() * 0.4
	local time = RealTimeL()

	for i, data in ipairs(self.PickupsHistory) do
		if data.start > time then
			goto CONTINUE
		end

		if data.death then
			local drawcolor = Color(data.red, data.green, data.blue, data.alpha)

			if data.slideIn < 1 then
				HUDCommons.DrawBox(x, y, data.w * data.slideIn, data.h, drawcolor)
			else
				self:DrawShadowedText(self.PickupHistoryFont, data.drawText, x + ScreenSize(9), y + data.hPadding, drawcolor)
			end

			if data.slideOut < 1 and data.slideOut ~= 0 then
				HUDCommons.DrawBox(x, y, data.w * (1 - data.slideOut), data.h, drawcolor)
			end
		else
			if data.slideIn < 1 then
				HUDCommons.DrawBox(x, y, data.w * data.slideIn, data.h, color_white)
			else
				self:DrawShadowedText(self.PickupHistoryFont, data.drawText, x + ScreenSize(9), y + data.hPadding, color_white)
			end

			if data.slideOut < 1 and data.slideOut ~= 0 then
				HUDCommons.DrawBox(x, y, data.w * (1 - data.slideOut), data.h, color_white)
			end
		end

		y = y + data.h
		::CONTINUE::
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

		if data.death then
			data.alpha = (1 - time:progression(data.deathStart, data.deathEnds)) * 255
			data.red = 255 - time:progression(data.deathStart, data.deathEnds) * 50
			data.green = 255 - time:progression(data.deathStart, data.deathEnds) * 200
			data.blue = 255 - time:progression(data.deathStart, data.deathEnds) * 220
		else
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

FFGSHUD:PatchOnChangeHook('alive', function(s, self, ply, old, new)
	-- self.PickupsHistory = {}

	if not new then
		local time = RealTimeL()

		for i, data in ipairs(self.PickupsHistory) do
			data.death = true
			data.deathStart = time
			data.deathEnds = time + 3
			data.alpha = 255
			data.red = 255
			data.green = 255
			data.blue = 255
			data.ttl = time + 3
		end
	else
		self.PickupsHistory = {}
	end
end)
