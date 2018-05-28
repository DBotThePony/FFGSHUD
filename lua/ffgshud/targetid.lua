
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
local hook = hook
local MousePos = gui.MousePos
local team = team
local ScreenSize = ScreenScale
local color_white = color_white
local math = math
local RealTimeL = RealTimeL
local IsValid = FindMetaTable('Entity').IsValid

FFGSHUD.ENABLE_TARGETID = FFGSHUD:CreateConVar('targetid', '1', 'Enable HUD targetid replacement')

local function unassignedColor(id)
	local crc = tonumber(util.CRC(id))
	local r = crc % 255
	crc = crc - r
	local g = (crc / 255) % 255
	crc = crc / 255 - g
	local b = (crc / 255) % 255
	return Color(r:abs(), g:abs(), b:abs())
end

function FFGSHUD:HUDDrawTargetID()
	if not self.ENABLE_TARGETID:GetBool() then return end

	return false
end

local POS = FFGSHUD:DefinePosition('targetid', 0.5, 0.52)

FFGSHUD.targetID_Fade = 0

function FFGSHUD:ThinkTargetID(ply)
	if not self.ENABLE_TARGETID:GetBool() then return end
	if not self:GetVarAlive() then return end

	local tr = ply:GetEyeTrace()
	local ent = tr.Entity

	if not IsValid(ent) or not ent:IsPlayer()then
		self.drawTargetID = RealTimeL() < self.targetID_Fade and IsValid(self.targetID_Ply)
		return
	end

	self.drawTargetID = true
	self.targetID_Ply = ent
	self.targetID_Fade = RealTimeL() + 0.4
end

function FFGSHUD:PaintTargetID(ply)
	if not self.ENABLE_TARGETID:GetBool() then return end
	local edit = HUDCommons.IsInEditMode() and not IsValid(self.targetID_Ply)

	if not self.drawTargetID and not edit then return end
	local ent = self.targetID_Ply
	if not IsValid(self.targetID_Ply) and not HUDCommons.IsInEditMode() then return end

	local name, health, maxHealth, armor, maxArmor, pteam, color
	local x, y = MousePos()

	if edit then
		name = 'Nickname'
		health = 45
		maxHealth = 125
		armor = 50
		maxArmor = 100
		pteam = -1
		self.targetID_Fade = RealTimeL() + 0.4
		x, y = POS()
	else
		name = ent:Nick()
		health = ent:GetHealth()
		maxHealth = ent:GetMaxHealth()
		armor = ent:GetArmor()
		maxArmor = ent:GetMaxArmor()
		pteam = ent:Team() or 0
	end

	if pteam > 0 and pteam ~= TEAM_UNASSIGNED then
		color = Color(team.GetColor(pteam or 0) or color_white)
	elseif IsValid(ent) then
		--ent.__ffgshud_targetidcolor = ent.__ffgshud_targetidcolor or unassignedColor(ent:SteamID())
		ent.__ffgshud_targetidcolor = ent.__ffgshud_targetidcolor or unassignedColor(name)
		color = Color(ent.__ffgshud_targetidcolor)
	else
		color = unassignedColor(name)
	end

	color.a = math.max((self.targetID_Fade - RealTimeL()) / 0.4 * 255, 0)

	if not edit then
		if x == 0 and y == 0 then
			x, y = POS()
		else
			y = y + ScreenScale(8)
		end
	end

	local w, h = self:DrawShadowedTextCentered(self.TargetID_Name, name, x, y, color)
	y = y + h * 0.89

	w, h = self:DrawShadowedTextCentered(self.TargetID_Health, ('%i / %i'):format(health, maxHealth), x, y, color)
	y = y + h * 0.95

	if armor ~= 0 then
		w, h = self:DrawShadowedTextCentered(self.TargetID_Armor, ('%i / %i'):format(armor, maxArmor), x, y, color)
		y = y + h * 0.95
	end
end

FFGSHUD:AddPaintHook('PaintTargetID')
FFGSHUD:AddThinkHook('ThinkTargetID')
FFGSHUD:AddHook('HUDDrawTargetID')
