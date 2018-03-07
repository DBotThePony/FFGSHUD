
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
local IsValid = FindMetaTable('Entity').IsValid

local function EntityTakeDamage(self, dmg)
	local players = DLib.combat.findPlayers(self)
	if not players then return end

	local attacker = dmg:GetAttacker()
	local reportedPos = dmg:GetReportedPosition()
	local validReportedPos = false

	if not dmg:IsFallDamage() then
		if reportedPos:IsZero() then
			if IsValid(attacker) then
				reportedPos = attacker:GetPos()
				validReportedPos = true
			end
		else
			validReportedPos = true
		end
	end

	net.Start('ffgs.damagereceived')
	net.WriteUInt64(dmg:GetDamageType() or 0)
	net.WriteFloat(dmg:GetDamage())

	net.WriteBool(validReportedPos)

	if validReportedPos then
		net.WriteVector(reportedPos)
	end

	net.Send(players)
end

hook.Add('EntityTakeDamage', 'FFGSHUD', EntityTakeDamage)
