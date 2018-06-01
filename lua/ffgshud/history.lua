
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
local DEFAULT_TTL = 3
local MAXIMAL_SLOTS = 3
local DISPLAY_PAUSE = 1
local GIVE_CHANCE_TIME = 0.2

FFGSHUD.PickupsHistory = {}
FFGSHUD.ENABLE_PICKUP_HISTORY = FFGSHUD:CreateConVar('pickups', '1', 'Enable HUD pickups history')
local glitchPattern = {}

--[[

for i = 11, 30 do
	table.insert(glitchPattern, string.char(i))
end

for i = 34, 150 do
	table.insert(glitchPattern, string.char(i))
end
]]

local _glitchPattern = '________/\\!@#$%&*'

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

		if i % 4 == 0 and freeSlots > 0 then
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

		if i % 2 == 0 and freeSlotsGlitch > 0 then
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

local function grabSlotTime(self)
	if #self.PickupsHistory == 0 then
		local bucket = {
			start = RealTimeL() + GIVE_CHANCE_TIME,
			ttl = RealTimeL() + GIVE_CHANCE_TIME + DEFAULT_TTL,
			ttlo = RealTimeL() + GIVE_CHANCE_TIME + DEFAULT_TTL,
			list = {}
		}

		table.insert(self.PickupsHistory, bucket)
		return bucket, bucket.start
	end

	local time = RealTimeL()

	for i, bucket in ipairs(self.PickupsHistory) do
		if bucket.start > time and #bucket.list < MAXIMAL_SLOTS then
			bucket.ttl = bucket.ttlo + DEFAULT_TTL * 0.9

			for i2, data in ipairs(bucket.list) do
				data.sequencesEnd = generateSequencesOut(data.localized, bucket.ttl - 1, 1)
				data.startGlitchOut = bucket.ttl - 1
			end

			return bucket, bucket.start + (DISPLAY_PAUSE * #bucket.list)
		end
	end

	local last = self.PickupsHistory[#self.PickupsHistory]

	local bucket = {
		start = last.ttl,
		ttl = last.ttl + DEFAULT_TTL,
		ttlo = last.ttl + DEFAULT_TTL,
		list = {}
	}

	table.insert(self.PickupsHistory, bucket)
	return bucket, bucket.start
end

local language = language

function FFGSHUD:HUDAmmoPickedUp(ammoid, ammocount)
	if not self.ENABLE_PICKUP_HISTORY:GetBool() then return end
	if ammocount == 0 then return end -- ???

	for i, bucket in ipairs(self.PickupsHistory) do
		if bucket.start > RealTimeL() then
			for i2, data in ipairs(bucket.list) do
				if data.type == 'ammo' and data.ammoid == ammoid then
					data.amount = data.amount + ammocount
					data.localized = data.localized2 .. ' ' .. data.amount
					data.sequencesStart = generateSequences(data.localized, data.start + 0.9, 1)
					data.sequencesEnd = generateSequencesOut(data.localized, bucket.ttl - 1, 1)
					return
				end
			end
		end
	end

	local localized2 = language.GetPhrase(('#%s_Ammo'):format(ammoid))
	local localized = localized2 .. ' ' .. ammocount
	surface.SetFont(self.PickupHistoryFont.REGULAR)
	local w, h = surface.GetTextSize(localized)
	local bucket, startTime = grabSlotTime(self)

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
		slideIn = 0,
		slideOut = 0,
		drawText = localized,

		sequencesStart = generateSequences(localized, startTime + 0.3, 0.4),
		sequencesEnd = generateSequencesOut(localized, bucket.ttl - 1, 0.2),

		-- white slider
		slideInStart = startTime,
		slideInEnd = startTime + 0.2,

		-- white slider out in start
		slideOutStart = startTime + 0.2,
		slideOutEnd = startTime + 0.4,

		startGlitchOut = bucket.ttl - 1,
	}

	table.insert(bucket.list, newData)
	return true
end

function FFGSHUD:HUDItemPickedUp(printname)
	if not self.ENABLE_PICKUP_HISTORY:GetBool() then return end

	for i, bucket in ipairs(self.PickupsHistory) do
		if bucket.start > RealTimeL() then
			for i2, data in ipairs(bucket.list) do
				if data.type == 'entity' and data.oprintname == printname then
					data.amount = data.amount + 1
					data.localized = data.localized2 .. ' x' .. data.amount
					data.sequencesStart = generateSequences(data.localized, data.start + 0.4, 1)
					data.sequencesEnd = generateSequencesOut(data.localized, bucket.ttl - 1, 1)
					return
				end
			end
		end
	end

	local oprintname = printname

	if printname[1] == '#' then
		printname = language.GetPhrase(printname:sub(2))
	else
		printname = language.GetPhrase(printname)
	end

	local localized = printname
	surface.SetFont(self.PickupHistoryFont.REGULAR)
	local w, h = surface.GetTextSize(localized)
	local bucket, startTime = grabSlotTime(self)

	local newData = {
		type = 'entity',
		oprintname = oprintname,
		localized = localized,
		localized2 = localized,
		ow = w,
		oh = h,
		amount = 1,
		w = w * 1.6,
		h = h * 1.2,
		wPadding = w * 0.1,
		hPadding = h * 0.1,
		start = startTime,
		slideIn = 0,
		slideOut = 0,
		drawText = localized,

		sequencesStart = generateSequences(localized, startTime + 0.3, 0.4),
		sequencesEnd = generateSequencesOut(localized, bucket.ttl - 1, 0.2),

		-- white slider
		slideInStart = startTime,
		slideInEnd = startTime + 0.2,

		-- white slider out in start
		slideOutStart = startTime + 0.2,
		slideOutEnd = startTime + 0.4,

		startGlitchOut = bucket.ttl - 1,
	}

	table.insert(bucket.list, newData)
	return true
end

function FFGSHUD:HUDWeaponPickedUp(ent)
	if not self.ENABLE_PICKUP_HISTORY:GetBool() then return end

	local localized = ent:GetPrintName()

	if localized[1] == '#' then
		localized = language.GetPhrase(localized:sub(2))
	end

	surface.SetFont(self.PickupHistoryFont.REGULAR)
	local w, h = surface.GetTextSize(localized)
	local bucket, startTime = grabSlotTime(self)

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
		slideIn = 0,
		slideOut = 0,
		drawText = localized,

		sequencesStart = generateSequences(localized, startTime + 0.3, 0.4),
		sequencesEnd = generateSequencesOut(localized, bucket.ttl - 1, 0.2),

		-- white slider
		slideInStart = startTime,
		slideInEnd = startTime + 0.2,

		-- white slider out in start
		slideOutStart = startTime + 0.2,
		slideOutEnd = startTime + 0.4,

		startGlitchOut = bucket.ttl - 1,
	}

	table.insert(bucket.list, newData)
	return true
end

local DRAWPOS, DRAWSIDE = FFGSHUD:DefinePosition('history', 0.04, 0.4, false)
local Cosine = Cosine
local Quintic = Quintic
local HUDCommons = DLib.HUDCommons
local color_white = Color()
local ScreenSize = ScreenSize
local ScrWL, ScrHL = ScrWL, ScrHL
local TEXT_DISPERSION_SHIFT = 0.0175

local function redrawBox(self, x, y, w, h, color)
	if self.ENABLE_DISPERSION:GetBool() then
		local color2 = Color(0, color.g * 0.3, color.b * 0.8, color.a)
		local color3 = Color(color.r * 0.95, color.g * 0.35, color.b * 0.1, color.a)
		HUDCommons.DrawBox(x, y - (self.PickupHistoryFont.REGULAR_ADDITIVE_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), w, h, color3)
		HUDCommons.DrawBox(x, y + (self.PickupHistoryFont.REGULAR_ADDITIVE_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), w, h, color2)
	end

	HUDCommons.DrawBox(x, y, w, h, color)
end

local function redrawBoxCenter(self, x, y, w, h, color)
	w = w * 1.2

	if self.ENABLE_DISPERSION:GetBool() then
		local color2 = Color(0, color.g * 0.3, color.b * 0.8, color.a)
		local color3 = Color(color.r * 0.95, color.g * 0.35, color.b * 0.1, color.a)
		HUDCommons.DrawBox(x - w / 2, y - (self.PickupHistoryFont.REGULAR_ADDITIVE_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), w, h, color3)
		HUDCommons.DrawBox(x - w / 2, y + (self.PickupHistoryFont.REGULAR_ADDITIVE_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), w, h, color2)
	end

	HUDCommons.DrawBox(x - w / 2, y, w, h, color)
end

local function redrawBoxRight(self, x, y, w, h, color)
	if self.ENABLE_DISPERSION:GetBool() then
		local color2 = Color(0, color.g * 0.3, color.b * 0.8, color.a)
		local color3 = Color(color.r * 0.95, color.g * 0.35, color.b * 0.1, color.a)
		HUDCommons.DrawBox(x - w, y - (self.PickupHistoryFont.REGULAR_ADDITIVE_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), w, h, color3)
		HUDCommons.DrawBox(x - w, y + (self.PickupHistoryFont.REGULAR_ADDITIVE_SIZE_H * TEXT_DISPERSION_SHIFT):max(1):floor(), w, h, color2)
	end

	HUDCommons.DrawBox(x - w, y, w, h, color)
end

function FFGSHUD:HUDDrawPickupHistoryLeftTest()
	local x, y = DRAWPOS()
	local drawcolor = Color()
	local w, h = self:DrawShadowedText(self.PickupHistoryFont, 'Sample text', x + ScreenSize(9), y, drawcolor)
	redrawBox(self, x, y + h * 0.84, ScreenSize(48), ScreenSize(6), drawcolor)
	redrawBox(self, x, y + h * 0.84 + ScreenSize(7), ScreenSize(24), ScreenSize(6), drawcolor)
end

function FFGSHUD:HUDDrawPickupHistoryRightTest()
	local x, y = DRAWPOS()
	local drawcolor = Color()
	local w, h = self:DrawShadowedTextAligned(self.PickupHistoryFont, 'Sample text', x - ScreenSize(9), y, drawcolor)
	redrawBoxRight(self, x, y + h * 0.84, ScreenSize(48), ScreenSize(6), drawcolor)
	redrawBoxRight(self, x, y + h * 0.84 + ScreenSize(7), ScreenSize(24), ScreenSize(6), drawcolor)
end

function FFGSHUD:HUDDrawPickupHistoryCenterTest()
	local x, y = DRAWPOS()
	local drawcolor = Color()
	local w, h = self:DrawShadowedTextCentered(self.PickupHistoryFont, 'Sample text', x, y, drawcolor)
	redrawBoxCenter(self, x, y + h * 0.84, ScreenSize(48), ScreenSize(6), drawcolor)
	redrawBoxCenter(self, x, y + h * 0.84 + ScreenSize(7), ScreenSize(24), ScreenSize(6), drawcolor)
end

function FFGSHUD:HUDDrawPickupHistoryLeft()
	local time = RealTimeL()
	local x, y = DRAWPOS()

	for i, bucket in ipairs(self.PickupsHistory) do
		if bucket.start > time then
			goto CONTINUE
		end

		for i2, data in ipairs(bucket.list) do
			if data.type == 'empty' then
				if data.death then
					local drawcolor = Color(data.red, data.green, data.blue, data.alpha)

					if data.slideIn < 1 then
						redrawBox(self, x, y, data.w * data.slideIn, data.h, drawcolor)
					elseif data.slideOut < 1 and data.slideOut ~= 0 then
						redrawBox(self, x, y, data.w * (1 - data.slideOut), data.h, drawcolor)
					end
				else
					if data.slideIn < 1 then
						redrawBox(self, x, y, data.w * data.slideIn, data.h, color_white)
					elseif data.slideOut < 1 and data.slideOut ~= 0 then
						redrawBox(self, x, y, data.w * (1 - data.slideOut), data.h, color_white)
					end
				end
			else
				if data.death then
					local drawcolor = Color(data.red, data.green, data.blue, data.alpha)

					if data.slideIn < 1 then
						redrawBox(self, x, y, data.w * data.slideIn, data.h, drawcolor)
					else
						self:DrawShadowedText(self.PickupHistoryFont, data.drawText, x + ScreenSize(9), y + data.hPadding, drawcolor)
					end

					if data.slideOut < 1 and data.slideOut ~= 0 then
						redrawBox(self, x, y, data.w * (1 - data.slideOut), data.h, drawcolor)
					end
				else
					if data.slideIn < 1 then
						redrawBox(self, x, y, data.w * data.slideIn, data.h, color_white)
					else
						self:DrawShadowedText(self.PickupHistoryFont, data.drawText, x + ScreenSize(9), y + data.hPadding, color_white)
					end

					if data.slideOut < 1 and data.slideOut ~= 0 then
						redrawBox(self, x, y, data.w * (1 - data.slideOut), data.h, color_white)
					end
				end
			end

			y = y + data.h
		end

		::CONTINUE::
	end
end

function FFGSHUD:HUDDrawPickupHistoryRight()
	local time = RealTimeL()
	local x, y = DRAWPOS()

	for i, bucket in ipairs(self.PickupsHistory) do
		if bucket.start > time then
			goto CONTINUE
		end

		for i2, data in ipairs(bucket.list) do
			if data.type == 'empty' then
				if data.death then
					local drawcolor = Color(data.red, data.green, data.blue, data.alpha)

					if data.slideIn < 1 then
						redrawBoxRight(self, x, y, data.w * data.slideIn, data.h, drawcolor)
					elseif data.slideOut < 1 and data.slideOut ~= 0 then
						redrawBoxRight(self, x, y, data.w * (1 - data.slideOut), data.h, drawcolor)
					end
				else
					if data.slideIn < 1 then
						redrawBoxRight(self, x, y, data.w * data.slideIn, data.h, color_white)
					elseif data.slideOut < 1 and data.slideOut ~= 0 then
						redrawBoxRight(self, x, y, data.w * (1 - data.slideOut), data.h, color_white)
					end
				end
			else
				if data.death then
					local drawcolor = Color(data.red, data.green, data.blue, data.alpha)

					if data.slideIn < 1 then
						redrawBoxRight(self, x, y, data.w * data.slideIn, data.h, drawcolor)
					else
						self:DrawShadowedTextAligned(self.PickupHistoryFont, data.drawText, x - ScreenSize(9), y + data.hPadding, drawcolor)
					end

					if data.slideOut < 1 and data.slideOut ~= 0 then
						redrawBoxRight(self, x, y, data.w * (1 - data.slideOut), data.h, drawcolor)
					end
				else
					if data.slideIn < 1 then
						redrawBoxRight(self, x, y, data.w * data.slideIn, data.h, color_white)
					else
						self:DrawShadowedTextAligned(self.PickupHistoryFont, data.drawText, x - ScreenSize(9), y + data.hPadding, color_white)
					end

					if data.slideOut < 1 and data.slideOut ~= 0 then
						redrawBoxRight(self, x, y, data.w * (1 - data.slideOut), data.h, color_white)
					end
				end
			end

			y = y + data.h
		end

		::CONTINUE::
	end
end

function FFGSHUD:HUDDrawPickupHistoryCenter()
	local time = RealTimeL()
	local x, y = DRAWPOS()

	for i, bucket in ipairs(self.PickupsHistory) do
		if bucket.start > time then
			goto CONTINUE
		end

		for i2, data in ipairs(bucket.list) do
			if data.type == 'empty' then
				if data.death then
					local drawcolor = Color(data.red, data.green, data.blue, data.alpha)

					if data.slideIn < 1 then
						redrawBoxCenter(self, x, y, data.w * data.slideIn, data.h, drawcolor)
					elseif data.slideOut < 1 and data.slideOut ~= 0 then
						redrawBoxCenter(self, x, y, data.w * (1 - data.slideOut), data.h, drawcolor)
					end
				else
					if data.slideIn < 1 then
						redrawBoxCenter(self, x, y, data.w * data.slideIn, data.h, color_white)
					elseif data.slideOut < 1 and data.slideOut ~= 0 then
						redrawBoxCenter(self, x, y, data.w * (1 - data.slideOut), data.h, color_white)
					end
				end
			else
				if data.death then
					local drawcolor = Color(data.red, data.green, data.blue, data.alpha)

					if data.slideIn < 1 then
						redrawBoxCenter(self, x, y, data.w * data.slideIn, data.h, drawcolor)
					else
						self:DrawShadowedTextCentered(self.PickupHistoryFont, data.drawText, x, y + data.hPadding, drawcolor)
					end

					if data.slideOut < 1 and data.slideOut ~= 0 then
						redrawBoxCenter(self, x, y, data.w * (1 - data.slideOut), data.h, drawcolor)
					end
				else
					if data.slideIn < 1 then
						redrawBoxCenter(self, x, y, data.w * data.slideIn, data.h, color_white)
					else
						self:DrawShadowedTextCentered(self.PickupHistoryFont, data.drawText, x, y + data.hPadding, color_white)
					end

					if data.slideOut < 1 and data.slideOut ~= 0 then
						redrawBoxCenter(self, x, y, data.w * (1 - data.slideOut), data.h, color_white)
					end
				end
			end

			y = y + data.h
		end

		::CONTINUE::
	end
end

function FFGSHUD:HUDDrawPickupHistory()
	if not self.ENABLE_PICKUP_HISTORY:GetBool() then return end

	local side = DRAWSIDE()

	if HUDCommons.IsInEditMode() then
		if side == 'LEFT' then
			self:HUDDrawPickupHistoryLeftTest()
		elseif side == 'RIGHT' then
			self:HUDDrawPickupHistoryRightTest()
		else
			self:HUDDrawPickupHistoryCenterTest()
		end

		return
	end

	if side == 'LEFT' then
		self:HUDDrawPickupHistoryLeft()
	elseif side == 'RIGHT' then
		self:HUDDrawPickupHistoryRight()
	else
		self:HUDDrawPickupHistoryCenter()
	end

	return true
end

local Sinusine = Sinusine
local Cosine = Cosine

function FFGSHUD:ThinkPickupHistory()
	if not self.ENABLE_PICKUP_HISTORY:GetBool() then return end

	local toRemove
	local time = RealTimeL()

	for i, bucket in ipairs(self.PickupsHistory) do
		if bucket.ttl < time then
			toRemove = toRemove or {}
			table.insert(toRemove, i)
			goto CONTINUE
		end

		if bucket.start > time then
			goto CONTINUE
		end

		if not bucket.tick then
			bucket.tick = true

			for i = 1, MAXIMAL_SLOTS - #bucket.list do
				local startTime = bucket.start + (DISPLAY_PAUSE * #bucket.list)
				bucket.ttl = bucket.ttl + DEFAULT_TTL * 0.2

				for i2, data in ipairs(bucket.list) do
					if data.sequencesEnd and data.localized then
						data.sequencesEnd = generateSequencesOut(data.localized, bucket.ttl - 1, 1)
						data.startGlitchOut = bucket.ttl - 1
					end
				end

				local newData = {
					type = 'empty',
					w = ScreenSize(64),
					h = ScreenSize(7),
					start = startTime,
					slideIn = 0,
					slideOut = 0,

					-- white slider
					slideInStart = startTime,
					slideInEnd = startTime + 0.3,

					-- white slider out in start
					slideOutStart = startTime + 0.3,
					slideOutEnd = startTime + 0.75,
				}

				table.insert(bucket.list, newData)
			end
		end

		for i, data in ipairs(bucket.list) do
			if data.death then
				data.alpha = (1 - time:progression(data.deathStart, data.deathEnds)) * 255
				data.red = 255 - time:progression(data.deathStart, data.deathEnds) * 50
				data.green = 255 - time:progression(data.deathStart, data.deathEnds) * 200
				data.blue = 255 - time:progression(data.deathStart, data.deathEnds) * 220
			elseif data.type ~= 'empty' then
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
			else
				data.slideIn = Cosine(time:progression(data.slideInStart, data.slideInEnd))
				data.slideOut = Cubic(time:progression(data.slideOutStart, data.slideOutEnd))
			end
		end

		::CONTINUE::
	end

	if toRemove then
		table.removeValues(self.PickupsHistory, toRemove)
	end
end

function FFGSHUD:HUDShouldDrawHistory(element)
	if not self.ENABLE_PICKUP_HISTORY:GetBool() then return end

	if element == 'CHudHistoryResource' then
		return false
	end
end

FFGSHUD:AddHookCustom('HUDShouldDraw', 'HUDShouldDrawHistory')
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
