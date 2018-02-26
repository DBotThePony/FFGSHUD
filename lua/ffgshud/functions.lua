
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

function FFGSHUD:GetAmmoDisplayText()
	local ammoReadyText = ''
	local ammoStoredText = ''
	local stored2AmmoText = ''
	local clip2AmmoText = ''

	if self:ShouldDisplayAmmo() then
		if self:ShouldDisplayAmmoStored() then
			ammoStoredText = self:GetVarAmmo1()

			if self:GetVarClipMax1() < self:GetVarClip1() then
				ammoReadyText = ('%i+%i'):format(self:GetVarClipMax1(), self:GetVarClip1() - self:GetVarClipMax1())
			else
				ammoReadyText = ('%i'):format(self:GetVarClip1())
			end

			if self:ShouldDisplaySecondaryAmmo() then
				local ready = self:SelectSecondaryAmmoReady()
				local stored = self:SelectSecondaryAmmoStored()

				if ready ~= -1 then
					clip2AmmoText = '/' .. self:GetVarClip2()
				end

				if stored ~= -1 then
					stored2AmmoText = '/' .. stored
				end
			end
		else
			if not self:ShouldDisplaySecondaryAmmo() then
				ammoReadyText = self:GetVarAmmo1()
			else
				ammoReadyText = ('%i/%i'):format(self:GetVarAmmo1(), self:GetVarClip2())
			end
		end
	else
		ammoReadyText = '-'
	end

	return ammoReadyText, ammoStoredText, clip2AmmoText, stored2AmmoText
end

function FFGSHUD:CanHideAmmoCounter()
	return self:GetVarClipMax1() <= self:GetVarClip1() and self:GetVarClipMax2() <= self:GetVarClip2()
end
