
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
local NULL = NULL

FFGSHUD.DrawWepSelectionFadeOutStart = 0
FFGSHUD.DrawWepSelectionFadeOutEnd = 0
FFGSHUD.DrawWepSelectionFadeOutEnd2 = 0
FFGSHUD.DrawWepSelection = false
FFGSHUD.HoldKeyTrap = false
FFGSHUD.PrevSelectWeapon = NULL
FFGSHUD.SelectWeapon = NULL
FFGSHUD.SelectWeaponForce = NULL
FFGSHUD.SelectWeaponForceTime = 0
FFGSHUD.SelectWeaponPos = -1
FFGSHUD.LastSelectSlot = -1
FFGSHUD.WeaponListInSlot = {}
FFGSHUD.WeaponListInSlots = {}

local RealTimeL = RealTimeL
local ipairs = ipairs
local table = table
local HUDCommons = DLib.HUDCommons
local ScreenSize = ScreenSize
local LocalWeapon = LocalWeapon
local surface = surface
local LocalPlayer = LocalPlayer
local ScrWL, ScrHL = ScrWL, ScrHL
local language = language
local lastFrameAttack = false
local hud_fastswitch = GetConVar('hud_fastswitch')
local cam = cam
local Matrix = Matrix

FFGSHUD.ENABLE_WEAPON_SELECT = FFGSHUD:CreateConVar('wepselect', '1', 'Enable HUD weapon selection')

local function sortTab(a, b)
	return a:GetSlotPos() < b:GetSlotPos()
end

local function getPrintName(self)
	local class = self:GetClass()
	local phrase = language.GetPhrase(class)
	return phrase ~= class and phrase or self:GetPrintName()
end

local function updateWeaponList(weapons)
	FFGSHUD.WeaponListInSlots[1] = {}
	FFGSHUD.WeaponListInSlots[2] = {}
	FFGSHUD.WeaponListInSlots[3] = {}
	FFGSHUD.WeaponListInSlots[4] = {}
	FFGSHUD.WeaponListInSlots[5] = {}
	FFGSHUD.WeaponListInSlots[6] = {}

	if #weapons == 0 then return end

	for i, weapon in pairs(weapons) do
		local slot = weapon:GetSlot() + 1

		if FFGSHUD.WeaponListInSlots[slot] then
			table.insert(FFGSHUD.WeaponListInSlots[slot], weapon)
		end
	end

	for i = 1, 6 do
		table.sort(FFGSHUD.WeaponListInSlots[i], sortTab)
	end
end

local function getWeaponsInSlot(self, slotIn)
	for i, weapon in ipairs(self.WeaponListInSlots[slotIn]) do
		if not IsValid(weapon) then
			updateWeaponList(LocalPlayer():GetWeapons())
			break
		end
	end

	return self.WeaponListInSlots[slotIn]
end

function FFGSHUD:ShouldDrawWeaponSelection(element)
	if not self.ENABLE_WEAPON_SELECT:GetBool() then return end

	if element == 'CHudWeaponSelection' then
		return false
	end
end

local DRAWPOS = FFGSHUD:DefinePosition('wepselect', 0.2, 0.08)
local SLOT_ACTIVE = FFGSHUD:CreateColorN('wepselect_a', '', Color())
local SLOT_INACTIVE = FFGSHUD:CreateColorN('wepselect_i', '', Color(137, 137, 137))
local SLOT_INACTIVE_BOX = FFGSHUD:CreateColorN('wepselect_i', '', Color(80, 80, 80))
local WEAPON_SELECTED = FFGSHUD:CreateColorN('wepselect_s', '', Color(242, 210, 101))
local WEAPON_READY = FFGSHUD:CreateColorN('wepselect_r', '', Color(237, 89, 152))
local WEAPON_FOCUSED = FFGSHUD:CreateColorN('wepselect_f', '', Color())
local SLOT_BG = FFGSHUD:CreateColorN('wepselect_bg', '', Color(40, 40, 40))

local TILT_MATRIX = Matrix()
TILT_MATRIX:SetAngles(Angle(0, -1.5, 0))
local render = render
local TEXFILTER = TEXFILTER

function FFGSHUD:DrawWeaponSelection()
	if not self.ENABLE_WEAPON_SELECT:GetBool() then return end

	if not FFGSHUD.DrawWepSelection then return end
	--local x, y = DRAWPOS()
	local x, y = ScrWL() * 0.12, ScrHL() * 0.11
	local spacing = ScreenSize(1.5)
	local alpha = (1 - RealTimeL():progression(FFGSHUD.DrawWepSelectionFadeOutStart, FFGSHUD.DrawWepSelectionFadeOutEnd)) * 255
	local inactive, bg, bgb = SLOT_INACTIVE(alpha), SLOT_BG(alpha * 0.75), SLOT_INACTIVE_BOX(alpha * 0.7)
	local activeWeapon = LocalWeapon()
	local boxSpacing = ScreenSize(8)
	local boxSpacing2 = boxSpacing * 3
	local unshift = ScreenSize(1.5)

	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	cam.PushModelMatrix(TILT_MATRIX)

	for i = 1, 6 do
		if i ~= FFGSHUD.LastSelectSlot then
			local w, h = HUDCommons.WordBox(i, self.SelectionNumber.REGULAR, x, y, inactive, bg)

			for i = 1, #FFGSHUD.WeaponListInSlots[i] do
				HUDCommons.DrawBox(x - unshift, y + (i - 1) * (spacing + h * 0.35) + h, w, h * 0.35, bgb)
			end

			x = x + w + spacing
		else
			local w, h = HUDCommons.WordBox(i, self.SelectionNumberActive.REGULAR, x, y, SLOT_ACTIVE(alpha), bg)
			local Y = y + h + spacing
			local maxW = ScreenSize(90)

			if #FFGSHUD.WeaponListInSlot ~= 0 then
				surface.SetFont(self.SelectionText.REGULAR)

				for i, weapon in ipairs(FFGSHUD.WeaponListInSlot) do
					if weapon:IsValid() then
						local name = getPrintName(weapon)
						local W, H = surface.GetTextSize(name)

						if weapon == FFGSHUD.SelectWeapon then
							if weapon ~= activeWeapon then
								maxW = maxW:max(W + boxSpacing2)
							else
								maxW = maxW:max(W + ScreenSize(4) + boxSpacing2)
							end
						elseif weapon == activeWeapon then
							maxW = maxW:max(W + ScreenSize(4) + boxSpacing2)
						else
							maxW = maxW:max(W + boxSpacing2)
						end
					end
				end

				for i, weapon in ipairs(FFGSHUD.WeaponListInSlot) do
					if weapon:IsValid() then
						local name = getPrintName(weapon)
						local W, H = surface.GetTextSize(name)
						local X = x - unshift

						if weapon == FFGSHUD.SelectWeapon then
							if weapon ~= activeWeapon then
								HUDCommons.DrawBox(X, Y, maxW, H, WEAPON_READY(alpha))
								HUDCommons.SimpleText(name, nil, X + boxSpacing, Y, WEAPON_FOCUSED(alpha))
							else
								W = W + ScreenSize(4)
								HUDCommons.DrawBox(X, Y, maxW, H, WEAPON_READY(alpha))
								local col = WEAPON_SELECTED(alpha)
								HUDCommons.DrawBox(X, Y, ScreenSize(4), H, col)
								HUDCommons.SimpleText(name, nil, X + ScreenSize(7), Y, col)
							end
						elseif weapon == activeWeapon then
							W = W + ScreenSize(4)
							HUDCommons.DrawBox(X, Y,maxW, H, bg)
							local col = WEAPON_SELECTED(alpha)
							HUDCommons.DrawBox(X, Y, ScreenSize(4), H, col)
							HUDCommons.SimpleText(name, nil, X + ScreenSize(7), Y, col)
						else
							HUDCommons.DrawBox(X, Y, maxW, H, bg)
							HUDCommons.SimpleText(name, nil, X + boxSpacing, Y, WEAPON_READY(alpha))
						end

						Y = Y + H + spacing
					end
				end

				x = x + w + maxW - ScreenSize(6)
			else
				x = x + w + spacing
			end
		end
	end

	cam.PopModelMatrix()
	render.PopFilterMin()
	render.PopFilterMag()
end

function FFGSHUD:ThinkWeaponSelection()
	if not self.ENABLE_WEAPON_SELECT:GetBool() then return end

	local time = RealTimeL()

	if FFGSHUD.DrawWepSelectionFadeOutEnd < time then
		FFGSHUD.DrawWepSelection = false

		if FFGSHUD.LastSelectSlot ~= -1 and not hud_fastswitch:GetBool() then
			FFGSHUD.LastSelectSlot = -1
		end
	end

	if FFGSHUD.DrawWepSelectionFadeOutEnd2 < time then
		FFGSHUD.SelectWeapon = NULL
	end
end

function FFGSHUD:LookupSelectWeapon()
	return self.SelectWeapon, FFGSHUD.DrawWepSelectionFadeOutStart > RealTimeL()
end

local function BindSlot(self, ply, bind, pressed, weapons)
	if not self.ENABLE_WEAPON_SELECT:GetBool() then return end

	if not bind:startsWith('slot') then return end
	local newslot = bind:sub(5):tonumber()
	if newslot < 1 or newslot > 6 then return end
	local getweapons = getWeaponsInSlot(self, newslot)

	if #getweapons == 0 then
		LocalPlayer():EmitSound('Player.DenyWeaponSelection')
		FFGSHUD.DrawWepSelectionFadeOutStart = RealTimeL() + 0.5
		FFGSHUD.DrawWepSelectionFadeOutEnd = RealTimeL() + 1
		FFGSHUD.DrawWepSelection = true
		FFGSHUD.SelectWeapon = NULL
		FFGSHUD.LastSelectSlot = newslot
		FFGSHUD.WeaponListInSlot = {}
		return
	end

	if newslot ~= FFGSHUD.LastSelectSlot then
		FFGSHUD.LastSelectSlot = newslot
		FFGSHUD.SelectWeapon = getweapons[1]
		FFGSHUD.SelectWeaponPos = 1
	else
		FFGSHUD.SelectWeaponPos = FFGSHUD.SelectWeaponPos + 1

		if FFGSHUD.SelectWeaponPos > #getweapons then
			FFGSHUD.SelectWeaponPos = 1
		end

		FFGSHUD.SelectWeapon = getweapons[FFGSHUD.SelectWeaponPos]
	end

	if not hud_fastswitch:GetBool() then
		if not FFGSHUD.DrawWepSelection then
			FFGSHUD.DrawWepSelection = true
			LocalPlayer():EmitSound('Player.WeaponSelectionOpen')
		else
			LocalPlayer():EmitSound('Player.WeaponSelectionMoveSlot')
		end

		FFGSHUD.DrawWepSelectionFadeOutStart = RealTimeL() + 2
		FFGSHUD.DrawWepSelectionFadeOutEnd = RealTimeL() + 2.5
		FFGSHUD.DrawWepSelectionFadeOutEnd2 = RealTimeL() + 3.5
	end

	FFGSHUD.WeaponListInSlot = getweapons

	if hud_fastswitch:GetBool() then
		FFGSHUD.SelectWeaponForce = FFGSHUD.SelectWeapon
		FFGSHUD.SelectWeaponForceTime = RealTimeL() + 2
		LocalPlayer():EmitSound('Player.WeaponSelected')
	else
		FFGSHUD.SelectWeaponForce = NULL
		FFGSHUD.SelectWeaponForceTime = 0
	end

	return true
end

local function WheelBind(self, ply, bind, pressed, weapons)
	if not self.ENABLE_WEAPON_SELECT:GetBool() then return end

	if bind ~= 'invprev' and bind ~= 'invnext' then return end

	local weapon = LocalWeapon()
	local slot

	if not FFGSHUD.DrawWepSelection then
		if weapon:IsValid() then
			slot = weapon:GetSlot() + 1
		else
			slot = 1
		end
	else
		slot = FFGSHUD.LastSelectSlot
	end

	local getweapons = getWeaponsInSlot(self, slot)

	if #getweapons == 0 then
		for i = 1, 6 do
			getweapons = getWeaponsInSlot(self, i)

			if #getweapons ~= 0 then
				slot = i
				break
			end
		end

		if #getweapons == 0 then return end
	end

	if not FFGSHUD.DrawWepSelection then
		local hit = false

		for i, wep in ipairs(getweapons) do
			if wep == weapon then
				FFGSHUD.SelectWeaponPos = i
				hit = true
				break
			end
		end

		if not hit then
			FFGSHUD.SelectWeaponPos = 0
		end
	end

	FFGSHUD.SelectWeaponPos = FFGSHUD.SelectWeaponPos + (bind == 'invnext' and 1 or -1)

	if FFGSHUD.SelectWeaponPos < 1 then
		for i = 1, 6 do
			slot = slot - 1

			if slot < 1 then
				slot = 6
			end

			getweapons = getWeaponsInSlot(self, slot)
			if #getweapons ~= 0 then break end
		end

		FFGSHUD.SelectWeaponPos = #getweapons
	elseif FFGSHUD.SelectWeaponPos > #getweapons then
		FFGSHUD.SelectWeaponPos = 1

		for i = 1, 6 do
			slot = slot + 1

			if slot > 6 then
				slot = 1
			end

			getweapons = getWeaponsInSlot(self, slot)
			if #getweapons ~= 0 then break end
		end
	end

	if #getweapons == 0 then
		-- might be annoying
		-- LocalPlayer():EmitSound('Player.DenyWeaponSelection')
		return
	end

	FFGSHUD.SelectWeapon = getweapons[FFGSHUD.SelectWeaponPos]

	if slot ~= FFGSHUD.LastSelectSlot or not FFGSHUD.SelectWeapon:IsValid() then
		FFGSHUD.LastSelectSlot = slot
	end

	if not hud_fastswitch:GetBool() then
		if not FFGSHUD.DrawWepSelection then
			FFGSHUD.DrawWepSelection = true
			LocalPlayer():EmitSound('Player.WeaponSelectionOpen')
		else
			LocalPlayer():EmitSound('Player.WeaponSelectionMoveSlot')
		end

		FFGSHUD.DrawWepSelectionFadeOutStart = RealTimeL() + 2
		FFGSHUD.DrawWepSelectionFadeOutEnd = RealTimeL() + 2.5
		FFGSHUD.DrawWepSelectionFadeOutEnd2 = RealTimeL() + 3.5
	end

	FFGSHUD.WeaponListInSlot = getweapons
	FFGSHUD.DrawWepSelection = true

	if hud_fastswitch:GetBool() then
		FFGSHUD.SelectWeaponForce = FFGSHUD.SelectWeapon
		FFGSHUD.SelectWeaponForceTime = RealTimeL() + 2
		LocalPlayer():EmitSound('Player.WeaponSelected')
	else
		FFGSHUD.SelectWeaponForce = NULL
		FFGSHUD.SelectWeaponForceTime = 0
	end

	return true
end

function FFGSHUD:WeaponSelectionBind(ply, bind, pressed)
	if not self.ENABLE_WEAPON_SELECT:GetBool() then return end

	if lastFrameAttack then return end
	if not pressed then return end
	if not self:GetVarAlive() then return end
	if ply:InVehicle() and not ply:GetAllowWeaponsInVehicle() then return end
	local weapons = ply:GetWeapons()
	if #weapons == 0 then return end

	updateWeaponList(weapons)
	local status = BindSlot(self, ply, bind, pressed, weapons)
	if status then return status end
	status = WheelBind(self, ply, bind, pressed, weapons)
	if status then return status end

	if bind == 'lastinv' and FFGSHUD.PrevSelectWeapon:IsValid() then
		local next = FFGSHUD.PrevSelectWeapon
		local prev = LocalWeapon()

		FFGSHUD.PrevSelectWeapon = prev
		FFGSHUD.SelectWeaponForce = next
		FFGSHUD.SelectWeaponForceTime = RealTimeL() + 2
		LocalPlayer():EmitSound('Player.WeaponSelected')
		return true
	end
end

local IN_ATTACK = IN_ATTACK
local IN_ATTACK2 = IN_ATTACK2

function FFGSHUD:TrapWeaponSelect(cmd)
	if not self.ENABLE_WEAPON_SELECT:GetBool() then return end

	if FFGSHUD.SelectWeaponForce:IsValid() and FFGSHUD.SelectWeaponForceTime > RealTimeL() then
		cmd:SelectWeapon(FFGSHUD.SelectWeaponForce)

		if LocalWeapon() == FFGSHUD.SelectWeaponForce then
			FFGSHUD.SelectWeaponForce = NULL
			FFGSHUD.SelectWeaponForceTime = 0
		end
	end

	if not FFGSHUD.DrawWepSelection and not FFGSHUD.HoldKeyTrap then
		lastFrameAttack = cmd:KeyDown(IN_ATTACK)
		return
	end

	if not lastFrameAttack and cmd:KeyDown(IN_ATTACK) then
		cmd:SetButtons(cmd:GetButtons() - IN_ATTACK)

		if not FFGSHUD.HoldKeyTrap then
			FFGSHUD.DrawWepSelection = false
			FFGSHUD.HoldKeyTrap = true

			if FFGSHUD.SelectWeapon:IsValid() then
				if FFGSHUD.SelectWeapon ~= LocalWeapon() then
					FFGSHUD.PrevSelectWeapon = LocalWeapon()
				end

				cmd:SelectWeapon(FFGSHUD.SelectWeapon)
				FFGSHUD.SelectWeaponForce = FFGSHUD.SelectWeapon
				FFGSHUD.SelectWeaponForceTime = RealTimeL() + 2
				LocalPlayer():EmitSound('Player.WeaponSelected')
			end
		end
	elseif cmd:KeyDown(IN_ATTACK2) then
		cmd:SetButtons(cmd:GetButtons() - IN_ATTACK2)

		if not FFGSHUD.HoldKeyTrap then
			LocalPlayer():EmitSound('Player.WeaponSelectionClose')
			FFGSHUD.DrawWepSelection = false
			FFGSHUD.HoldKeyTrap = true
			FFGSHUD.DrawWepSelectionFadeOutStart = RealTimeL()
		end
	else
		FFGSHUD.HoldKeyTrap = false
	end

	if lastFrameAttack and not cmd:KeyDown(IN_ATTACK) then
		lastFrameAttack = false
	end
end

FFGSHUD:AddHookCustom('HUDShouldDraw', 'ShouldDrawWeaponSelection', nil, 2)
FFGSHUD:AddHookCustom('CreateMove', 'TrapWeaponSelect', nil, 2)
FFGSHUD:AddHookCustom('PlayerBindPress', 'WeaponSelectionBind', nil, 2)
FFGSHUD:AddPostPaintHook('DrawWeaponSelection')
FFGSHUD:AddThinkHook('ThinkWeaponSelection')
