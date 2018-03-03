
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
local RealTime = RealTime

local function onDamge()
	local dmgType = net.ReadUInt64()
	local dmg = net.ReadFloat()

	FFGSHUD:ExtendGlitch(dmg / 12.5)
	FFGSHUD:ClampGlitchTime(8)
end

net.receive('ffgs.damagereceived', onDamge)

-- TODO: Damage Sense
