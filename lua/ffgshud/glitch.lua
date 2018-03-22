
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
local math = math

timer.Simple(0, function()
	local textureFlags = 0
	textureFlags = textureFlags + 16 -- anisotropic
	textureFlags = textureFlags + 256 -- no mipmaps
	textureFlags = textureFlags + 2048 -- Texture is procedural
	textureFlags = textureFlags + 32768 -- Texture is a render target
	-- textureFlags = textureFlags + 67108864 -- Usable as a vertex texture

	rt = GetRenderTargetEx('ffgshud_glitch_rt3', ScrW(), ScrH(), RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_ONLY, textureFlags, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGBA8888)
	-- rt = GetRenderTarget('ffgshud_glitch_rt', ScrW(), ScrH(), false)
	local salt = '_6'

	rtmat = CreateMaterial('ffgshud_glitch_rtmat' .. salt, 'UnlitGeneric', {
		['$basetexture'] = 'models/debug/debugwhite',
		['$translucent'] = '1',
		['$halflambert'] = '1',
		['$alpha'] = '1',
	})

	rtmat1 = CreateMaterial('ffgshud_glitch_rtmat1' .. salt, 'UnlitGeneric', {
		['$basetexture'] = 'models/debug/debugwhite',
		['$translucent'] = '1',
		['$halflambert'] = '1',
		['$color'] = '0 0.98 1',
		['$color2'] = '0 0.98 1',
		['$alpha'] = '0.6',
		['$additive'] = '1',
	})

	rtmat2 = CreateMaterial('ffgshud_glitch_rtmat2' .. salt, 'UnlitGeneric', {
		['$basetexture'] = 'models/debug/debugwhite',
		['$translucent'] = '1',
		['$halflambert'] = '1',
		['$color'] = '0.96 0 1',
		['$color2'] = '0.96 0 1',
		['$alpha'] = '0.6',
		['$additive'] = '1',
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
local maxDistort = 4
local minCut = 30
local maxCut = 120

local repeats = 0.04
local rndInt = math.random(1, 1000)

local function generateGlitches(iterations, frameRepeats, strength)
	strength = strength or 1
	frameRepeats = frameRepeats or repeats
	iterations = iterations or 100
	local rTime = RealTime()
	local w, h = ScrW(), ScrH()
	local initial = (rTime / repeats):floor()
	minCut = ScreenScale(7) * strength
	maxCut = ScreenScale(16) * strength
	maxStrength = ScreenScale(24) * strength
	maxDistort = ScreenScale(3.5) * strength

	for i = 1, iterations do
		local data = {
			xStrength = math.random(-maxStrength, maxStrength),
			yStrength = math.random(-maxStrength, maxStrength),
			xDistort = math.random(0, maxDistort),
			yDistort = math.random(0, maxDistort),
			ttl = rTime + i * frameRepeats,
			seed = lookupSeed,
			iterations = {}
		}

		table.insert(glitchPattern, data)

		local ty = -8

		-- generate
		while ty < h do
			local height = math.random(minCut, maxCut)
			local strengthValue = math.random(data.xStrength, data.yStrength + data.xStrength) * 0.4
			local distortValue = math.random(data.xDistort * 0.25, data.xDistort)

			local iteration = {
				ty + 9,
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
			-- iteration[2] = iteration[2] + util.SharedRandom('ffgs_hud_glitch_ycutRand', -minCut, minCut, lookupSeed + g) * 0.65
			if ty >= h then break end
		end

		-- smooth
	end

	return glitchPattern
end

function FFGSHUD:PreDrawGlitch()
	if not self:IsGlitching() and self:GetVarAlive() then return end
	render.PushRenderTarget(rt)

	if math.random() >= 0.5 then
		render.Clear(0, 40, 50, 0, true, true)
	else
		render.Clear(50, 0, 50, 0, true, true)
	end

	cam.Start2D()
end

function FFGSHUD:PostDrawGlitch()
	if not self:IsGlitching() and self:GetVarAlive() then return end
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
		if self:GetVarAlive() then
			generateGlitches()
		else
			generateGlitches(nil, 0.15, 2)
		end

		glitch = glitchPattern[1]
	end

	local w, h = ScrW(), ScrH()

	for i, iteration in ipairs(glitch.iterations) do
		-- center
		surface.SetMaterial(rtmat)
		surface.DrawTexturedRectUV(iteration[3], iteration[1], w, iteration[2], iteration[4], iteration[5], iteration[6], iteration[7])

		surface.SetMaterial(rtmat1)
		surface.DrawTexturedRectUV(iteration[3] - iteration[8], iteration[1], w, iteration[2], iteration[4], iteration[5], iteration[6], iteration[7])

		surface.SetMaterial(rtmat2)
		surface.DrawTexturedRectUV(iteration[3] + iteration[8], iteration[1], w, iteration[2], iteration[4], iteration[5], iteration[6], iteration[7])

		-- left
		surface.SetMaterial(rtmat)
		surface.DrawTexturedRectUV(iteration[3] - w, iteration[1], w, iteration[2], iteration[4], iteration[5], iteration[6], iteration[7])

		surface.SetMaterial(rtmat1)
		surface.DrawTexturedRectUV(iteration[3] - iteration[8] - w, iteration[1], w, iteration[2], iteration[4], iteration[5], iteration[6], iteration[7])

		surface.SetMaterial(rtmat2)
		surface.DrawTexturedRectUV(iteration[3] + iteration[8] - w, iteration[1], w, iteration[2], iteration[4], iteration[5], iteration[6], iteration[7])

		-- right
		surface.SetMaterial(rtmat)
		surface.DrawTexturedRectUV(iteration[3] + w, iteration[1], w, iteration[2], iteration[4], iteration[5], iteration[6], iteration[7])

		surface.SetMaterial(rtmat1)
		surface.DrawTexturedRectUV(iteration[3] - iteration[8] + w, iteration[1], w, iteration[2], iteration[4], iteration[5], iteration[6], iteration[7])

		surface.SetMaterial(rtmat2)
		surface.DrawTexturedRectUV(iteration[3] + iteration[8] + w, iteration[1], w, iteration[2], iteration[4], iteration[5], iteration[6], iteration[7])
	end
end

function FFGSHUD:OnGlitchStart(timeLong)
	generateGlitches(timeLong * repeats + 10)
end

function FFGSHUD:OnGlitchEnd()
	glitchPattern = {}
end

FFGSHUD:AddHookCustom('PreDrawHUD', 'PreDrawGlitch', nil, -7)
FFGSHUD:AddHookCustom('PreDrawHUD', 'PostDrawGlitch', nil, 7)

FFGSHUD:AddHookCustom('PostDrawHUD', 'PreDrawGlitch', nil, -7)
FFGSHUD:AddHookCustom('PostDrawHUD', 'PostDrawGlitch', nil, 7)

FFGSHUD:AddHookCustom('HUDPaint', 'PreDrawGlitch', nil, -7)
FFGSHUD:AddHookCustom('HUDPaint', 'PostDrawGlitch', nil, 7)

--FFGSHUD:AddHookCustom('PreDrawPlayerHands', 'PreDrawGlitch', nil, -7)
--FFGSHUD:AddHookCustom('PostDrawPlayerHands', 'PostDrawGlitch', nil, 7)
