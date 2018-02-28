
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
local render = render
local surface = surface
local cam = cam
local rt, rtmat, rtmat1, rtmat2
local util = util
local table = table
local RealTime = RealTime
local ScrW, ScrH = ScrW, ScrH
local LerpCubic = LerpCubic
local ScreenScale = ScreenScale

timer.Simple(0, function()
	rt = GetRenderTarget('ffgshud_glitch_rt', ScrW(), ScrH(), false)

	rtmat = CreateMaterial('ffgshud_glitch_rtmat', 'UnlitGeneric', {
		['$basetexture'] = 'models/debug/debugwhite',
		['$translucent'] = '1',
		['$halflambert'] = '1',
	})

	rtmat1 = CreateMaterial('ffgshud_glitch_rtmat1', 'UnlitGeneric', {
		['$basetexture'] = 'models/debug/debugwhite',
		['$translucent'] = '1',
		['$halflambert'] = '1',
		['$color'] = '0 0.98 1',
		['$color2'] = '0 0.98 1',
	})

	rtmat2 = CreateMaterial('ffgshud_glitch_rtmat2', 'UnlitGeneric', {
		['$basetexture'] = 'models/debug/debugwhite',
		['$translucent'] = '1',
		['$halflambert'] = '1',
		['$color'] = '0.96 0 1',
		['$color2'] = '0.96 0 1',
	})

	rtmat:SetTexture('$basetexture', rt)
	rtmat1:SetTexture('$basetexture', rt)
	rtmat2:SetTexture('$basetexture', rt)

	rtmat1:SetVector('$color', Color(0, 222, 255):ToVector())
	rtmat1:SetVector('$color2', Color(0, 222, 255):ToVector())
	rtmat2:SetVector('$color', Color(255, 0, 225):ToVector())
	rtmat2:SetVector('$color2', Color(255, 0, 225):ToVector())
end)

local glitchPattern = {}

local maxStrength = 20
local maxDistort = 6
local minCut = 30
local maxCut = 120

local repeats = 0.1
local rndInt = math.random(1, 1000)

local function generateGlitches(iterations)
	iterations = iterations or 100
	local rTime = RealTime()
	local w, h = ScrW(), ScrH()
	local initial = (rTime / repeats):floor()
	minCut = ScreenScale(20)
	maxCut = ScreenScale(40)
	maxStrength = ScreenScale(15)
	maxDistort = ScreenScale(6)

	for i = 1, iterations do
		local id = initial + i
		local lookupSeed = rndInt + id

		local data = {
			xStrength = util.SharedRandom('ffgs_hud_glitch_xStrength', -maxStrength, maxStrength, lookupSeed),
			yStrength = util.SharedRandom('ffgs_hud_glitch_yStrength', -maxStrength, maxStrength, lookupSeed),
			xDistort = util.SharedRandom('ffgs_hud_glitch_xDistort', 0, maxDistort, lookupSeed),
			yDistort = util.SharedRandom('ffgs_hud_glitch_yDistort', 0, maxDistort, lookupSeed),
			ttl = rTime + i * repeats,
			id = id,
			seed = lookupSeed,
			iterations = {}
		}

		table.insert(glitchPattern, data)

		local ty = 0
		local lastStrength
		local g = 0

		while ty < h do
			g = g + 1
			if g > 200 then break end -- wtf
			local height = util.SharedRandom('ffgs_hud_glitch_ycut', minCut, maxCut, lookupSeed + g)
			local strengthValue = util.SharedRandom('ffgs_hud_glitch_xcut', data.xStrength, data.yStrength + data.xStrength, lookupSeed + g)
			local distortValue = util.SharedRandom('ffgs_hud_glitch_xcut', data.xDistort, data.yDistort + data.xDistort, lookupSeed + g)
			lastStrength = lastStrength or strengthValue
			strengthValue = LerpCubic(height / h, strengthValue, lastStrength)
			lastStrength = strengthValue

			local iteration = {
				ty,
				height,
				strengthValue
			}

			iteration[4] = 0
			iteration[5] = ty / h
			iteration[6] = 1
			iteration[7] = (ty + height) / h

			iteration[8] = distortValue

			table.insert(data.iterations, iteration)

			ty = ty + height
			if ty >= h then break end
		end
	end

	return glitchPattern
end

function FFGSHUD:PreDrawGlitch()
	if not self:IsGlitching() then return end
	render.PushRenderTarget(rt)
	render.Clear(0, 0, 0, 0)
	cam.Start2D()
end

function FFGSHUD:PostDrawGlitch()
	if not self:IsGlitching() then return end
	cam.End2D()
	render.PopRenderTarget()

	--render.SetMaterial(rtmat)
	--render.DrawScreenQuad()

	local rTime = RealTime()
	local glitch = glitchPattern[1]

	while glitch and glitch.ttl < rTime do
		table.remove(glitchPattern, 1)
		glitch = glitchPattern[1]
	end

	if not glitch then
		generateGlitches()
		glitch = glitchPattern[1]
	end

	local w, h = ScrW(), ScrH()

	surface.SetDrawColor(255, 255, 255)

	for i, iteration in ipairs(glitch.iterations) do
		surface.SetMaterial(rtmat1)
		surface.DrawTexturedRectUV(iteration[3] - iteration[8], iteration[1], w, iteration[2], iteration[4], iteration[5], iteration[6], iteration[7])

		surface.SetMaterial(rtmat2)
		surface.DrawTexturedRectUV(iteration[3] + iteration[8], iteration[1], w, iteration[2], iteration[4], iteration[5], iteration[6], iteration[7])

		surface.SetMaterial(rtmat)
		surface.DrawTexturedRectUV(iteration[3], iteration[1], w, iteration[2], iteration[4], iteration[5], iteration[6], iteration[7])
	end
end

function FFGSHUD:OnGlitchStart(timeLong)
	generateGlitches(timeLong * repeats + 10)
end

function FFGSHUD:OnGlitchEnd()
	glitchPattern = {}
end

FFGSHUD:AddHookCustom('HUDPaint', 'PreDrawGlitch', nil, -7)
FFGSHUD:AddHookCustom('HUDPaint', 'PostDrawGlitch', nil, 7)
