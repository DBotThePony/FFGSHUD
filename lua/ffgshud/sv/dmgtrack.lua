
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

local net = net
local DLib = DLib

net.pool('ffgs.damagereceived')
net.pool('ffgs.damagedealed')
local IsValid = FindMetaTable('Entity').IsValid

local function damagereceived(self, dmg)
local players = DLib.combat.findPlayers(self)
	if not players then return end

	local attacker = dmg:GetAttacker()
	local inflictor = dmg:GetInflictor()
	local reportedPos = dmg:GetReportedPosition()
	local validReportedPos = false
	local validAttacker = attacker:IsValid()
	local attackerClass = validAttacker and attacker:GetClass() or ''
	local cond = not dmg:IsFallDamage() and
		not attackerClass:startsWith('trigger_') and
		not attackerClass:startsWith('func_') and
		attackerClass ~= 'env_fire' and
		(not validAttacker or attacker:GetParent() ~= self) and
		attacker ~= self

	if cond then
		if reportedPos:IsZero() then
			if IsValid(inflictor) and not inflictor:IsWeapon() then
				reportedPos = inflictor:GetPos()
				validReportedPos = true
			elseif IsValid(attacker) then
				reportedPos = attacker:GetPos()
				validReportedPos = true
			end
		else
			validReportedPos = true
		end
	end

	net.Start('ffgs.damagereceived', true)
	net.WriteUInt64(dmg:GetDamageType() or 0)
	net.WriteFloat(dmg:GetDamage())

	net.WriteBool(validReportedPos)

	if validReportedPos then
		net.WriteVector(reportedPos)
	end

	net.Send(players)
end

local function EntityTakeDamage(self, dmg)
	damagereceived(self, dmg)
end

hook.Add('EntityTakeDamage', 'FFGSHUD', EntityTakeDamage)
