
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
	if dmg:GetDamage() == 0 then return false end
	local players = DLib.combat.findPlayers(self)
	if not players then return false end

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

	return true
end

local function damagedealed(ent, dmg)
	if dmg:GetDamage() == 0 then return end
	local self = dmg:GetAttacker()
	-- attacker is not a player
	if ent == self or not IsValid(self) or type(self) ~= 'Player' then return end
	-- entity is not alive
	-- if type(ent) ~= 'Player' and type(ent) ~= 'Vehicle' and type(ent) ~= 'NPC' and type(ent) ~= 'NextBot' then return end
	net.Start('ffgs.damagedealed', true)
	net.WriteUInt64(dmg:GetDamageType() or 0)
	net.WriteFloat(dmg:GetDamage())
	net.Send(self)
end

local function EntityTakeDamage(self, dmg)
	local status = damagereceived(self, dmg)

	if status then
		damagedealed(self, dmg)
	end
end

hook.Add('EntityTakeDamage', 'FFGSHUD', EntityTakeDamage, -4)
