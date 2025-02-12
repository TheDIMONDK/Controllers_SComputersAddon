---------------------------------
--        By TheDIMONDK        --
---------------------------------
-- 2024-2025 Copyrighted code. Scrap Mechanic API.

dofile "$CONTENT_DATA/Scripts/Config.lua"

local clamp = sm.util.clamp
local max = math.max


SmartController = class()
SmartController.maxParentCount = -1
SmartController.maxChildCount = -1
SmartController.connectionInput = sm.interactable.connectionType.composite + sm.interactable.connectionType.electricity
SmartController.connectionOutput = sm.interactable.connectionType.bearing + sm.interactable.connectionType.piston
SmartController.colorNormal = sm.color.new(0x2b7abfff)
SmartController.colorHighlight = sm.color.new(0x3e9bedff)
SmartController.componentType = "smartController"

SmartController.nonActiveImpulse = 0
SmartController.chargeAdditions = 50000



function SmartController.server_createData(self)

end









local function _tableColored(v41, v14, color)
    v14 = v14 or 0
    color = color or "reset"

    local v33 = string.rep("  ", v14)
    local v31 = "<Таблица> \n"


	if #v41 == 0 then
		return TextColored("{}", color)
	end


    v31 = v31 .. TextColored(v33 .. "{\n", color)

    for k, v in pairs(v41) do
        if type(v) == "table" then

            v31 = v31 .. TextColored(v33 .. "  " .. tostring(k) .. ": {\n", color)
            v31 = v31 .. _tableColored(v, v14 + 1, color)
            v31 = v31 .. TextColored(v33 .. "  }\n", color)
        else

            v31 = v31 .. TextColored(v33 .. "  " .. tostring(k) .. ": " .. tostring(v) .. "\n", color)
        end
    end


    v31 = v31 .. TextColored(v33 .. "}\n", color)

    return v31
end




function TextColored(v42, color)
    local v6 = {

		black = "\27[30m",
		red = "\27[31m",
		green = "\27[32m",
		yellow = "\27[33m",
		blue = "\27[34m",
		magenta = "\27[35m",
		cyan = "\27[36m",
		white = "\27[37m",


		bright_black = "\27[90m",
		bright_red = "\27[91m",
		bright_green = "\27[92m",
		bright_yellow = "\27[93m",
		bright_blue = "\27[94m",
		bright_magenta = "\27[95m",
		bright_cyan = "\27[96m",
		bright_white = "\27[97m",


		bg_black = "\27[40m",
		bg_red = "\27[41m",
		bg_green = "\27[42m",
		bg_yellow = "\27[43m",
		bg_blue = "\27[44m",
		bg_magenta = "\27[45m",
		bg_cyan = "\27[46m",
		bg_white = "\27[47m",


		gray = "\27[38;2;153;153;153m",
		dark_gray = "\27[38;2;100;100;100m",


		orange = "\27[38;5;208m",
		pink = "\27[38;5;205m",
		purple = "\27[38;5;93m",
		brown = "\27[38;5;130m",


		reset = "\27[0m"
    }


	if type(v42) == "table" then
		return _tableColored(v42, 0, color)
	end


	local v5 = v6[color] or v6.reset
	return v5 .. tostring(v42) .. v6.reset
end

local d = ""



























function SmartController.server_onCreate(self)
	self.chargeDelta = 0

	self.soundtype = 1
	self.maxMasterVelocity = 10000
	self.mImpulse = 10000
	self.energy = math.huge
	if self.data and self.data.survival then
		self.maxMasterVelocity = self.data.v or 500
		self.mImpulse = self.data.i or 1000
		self.energy = 0
	end

	self.masterVelocity = 0
	self.maxImpulse = 0
	self.bearingsAngle = {}
	self.pistonsLength = {}
	self.isActive = false
	self.wasActive = false
	self.bearingsCount = #self.interactable:getBearings()
    self.pistonsCount = #self.interactable:getPistons()

	self.operationState = 0

	self.lastProgramLength = -1
	self.program = {}

	self.prevOperationState = -1
	self.pendingOperation = nil
	self.programStage = 0
	self.programTimer = 0


	self.debug = {
		startPrints = false,
		stopPrints = false,
		onTickPrints = false,
		positionsReset = false
	}
	d = TextColored("[SmartController " .. string.sub(tostring(self.shape.uuid), 1, 5) .. "]", "dark_gray")


	self.interactable.publicData = {
        sc_component = {
            type = SmartController.componentType,
            api = {
				start = function (program)

					local v24 = self.operationState


					if program == nil or #program == 0 then error("Please specify the table (dictionary) with the program logic.") end


					if self.operationState ~= 0 then

						self.pendingOperation = 1

					else
						self.operationState = 1
						self.programTimer = 0
					end


					if program ~= "old" then
						self.program = program
						self.lastProgramLength = #program
					end


					if self.debug.startPrints then
						print(
							d .. TextColored("[startPrints]", "gray"), "#self.program", TextColored(#self.program, "bright_cyan"),
							"	self.lastProgramLength", TextColored(self.lastProgramLength, "bright_cyan"),
							"	self.operationState (old)", TextColored(v24, "bright_cyan"), "	self.operationState (new)", TextColored(self.operationState, "bright_cyan"),
							"	self.pendingOperation", TextColored(self.pendingOperation, "bright_cyan")
						)
					end

				end,
				stop = function ()

					local v24 = self.operationState



					if self.operationState ~= 0 then

						self.pendingOperation = 2

					else
						if self.program ~= nil then
							self.operationState = 2
						end
					end


					if self.debug.stopPrints then
						print(
							d .. TextColored("[stopPrints]", "gray"), "#self.program", TextColored(#self.program, "bright_cyan"),
							"self.lastProgramLength", TextColored(self.lastProgramLength, "bright_cyan"),
							"	self.operationState (old)", TextColored(v24, "bright_cyan"), "	self.operationState (new)", TextColored(self.operationState, "bright_cyan"),
							"	self.pendingOperation", TextColored(self.pendingOperation, "bright_cyan")
						)
					end

				end,
                getVelocity = function () return self.masterVelocity end,
                setVelocity = function (v)
                    if type(v) == "number" then
                        self.masterVelocity = sm.util.clamp(v, -self.maxMasterVelocity, self.maxMasterVelocity)
                    else
                        error("Value must be number")
                    end
                end,
                getStrength = function () return self.maxImpulse end,
                setStrength = function (v)
                    if type(v) == "number" then
                        self.maxImpulse = sm.util.clamp(v, 0, self.mImpulse)
                    else
                        error("Value must be number")
                    end
                end,

                isActive = function () return self.isActive end,
                setActive = function (v)
                    if type(v) == "boolean" then
                        self.isActive = v
                    elseif type(v) == "number" then
                        self.isActive = v > 0
                    else
                        error("Type must be boolean or number")
                    end
                end,

                getAvailableBatteries = function ()
                    return (self.data and self.data.survival) and (self.batteries or 0) or math.huge
                end,
                getCharge = function ()
                    return self.energy
                end,
                getChargeDelta = function ()
                    return self.chargeDelta
                end,
                isWorkAvailable = function ()
                    if self.data and self.data.survival then
                        if self.energy > 0 then
                            return true
                        end

                        if self.batteries and self.batteries > 0 then
                            return true
                        end

                        return false
                    end
                    return true
                end,
                getBearingsCount = function ()
                    return self.bearingsCount or 0
                end,
                getPistonsCount = function ()
                    return self.pistonsCount or 0
                end,

                getChargeAdditions = function ()
                    return SmartController.chargeAdditions
                end,
                setSoundType = function (v22)
                    checkArg(1, v22, "number")
                    self.soundtype = v22
                end,
                getSoundType = function ()
                    return self.soundtype
                end,

				debug = function (v12, startPrints, stopPrints, onTickPrints, positionsReset)

					if v12 == 1 then
						for i, v in pairs(self.debug) do
							v = true
						end

					else
						self.debug.startPrints = startPrints == 1
						self.debug.stopPrints = startPrints == 1
						self.debug.onTickPrints = onTickPrints == 1
						self.debug.positionsReset = positionsReset == 1
					end
				end

            }
        }
    }


	self:resetAll()

	sm.sc.creativeCheck(self, self.energy == math.huge)
end

function SmartController.server_onDestroy(self)

end

function SmartController.resetAllBearingsAngle(self)
	for k, v in pairs(self.bearingsAngle) do
		self.bearingsAngle[k] = 0
	end
end
function SmartController.getAllBearingsAngle(self) return self.bearingsAngle end
function SmartController.getBearingAngle(self, id) return self.bearingsAngle[id] end
function SmartController.setBearingAngle(self, id, v)
	if type(id) == "number" then
		if type(v) == "number" or type(v) == "nil" then
			local v44 = v and sm.util.clamp(v, -3.402e+38, 3.402e+38) or 0
			if id > 0 then
				self.bearingsAngle[id] = v44
			else
				error(id .. " - Value of index must be less than or equal to the number of connected bearings")
			end
		else
			error("Value of angle must be number or nil")
		end

	else
		error("Value of index must be number")
	end
end

function SmartController.resetAllPistonsLength(self)
	for k, v in pairs(self.pistonsLength) do
		self.pistonsLength[k] = 0
	end
end
function SmartController.getAllPistonsLength(self) return self.pistonsLength end
function SmartController.getPistonLength(self, id) return self.pistonsLength[id] end
function SmartController.setPistonLength(self, id, v)
	if type(id) == "number" then
		if type(v) == "number" then
			if v >= 0 then
				if id <= self.pistonsCount and id > 0 then
					self.pistonsLength[id] = v
				else
					error(id .. " - Value of index must be less than or equal to the number of connected pistons")
				end

			else
				error("Value of length must be non-negative")
			end
		else
			error("Value of length must be number")
		end

	else
		error("Value of index must be number")
	end
end

function SmartController.setPistonLengthByIndex(self, i, length)
	length = max(length - 1, 0)

	if type(i) == "number" then

		if i <= self.pistonsCount then
			self:setPistonLength(i, length)
		end


	elseif type(i) == "table" and #i >= 2 and type(i[1]) == "number" and type(i[2]) == "number" then

		if i[1] <= self.pistonsCount and i[2] <= self.pistonsCount then

			for v15 = i[1], i[2] do
				self:setPistonLength(v15, length)
			end
		end

	else
		error("Invalid enumeration type. Use [oneIndex] or [{startIndex, endIndex}].")
	end
end

function SmartController.setBearingAngleByIndex(self, i, angle)

	if type(i) == "number" then

		if i <= self.bearingsCount then
			self:setBearingAngle(i, angle)
		end


	elseif type(i) == "table" and #i >= 2 and type(i[1]) == "number" and type(i[2]) == "number" then

		if i[1] <= self.bearingsCount and i[2] <= self.bearingsCount then

			for v15 = i[1], i[2] do
				self:setBearingAngle(v15, angle)
			end
		end

	else
		error("Invalid enumeration type. Use [oneIndex] or [{startIndex, endIndex}].")
	end
end

function SmartController.resetAll(self)

	if self.debug.positionsReset then
		print(d .. TextColored("[positionsReset]", "gray"), TextColored("Сброс всех подвижных деталей:", "bright_blue"))
	end




	if (self.pistonsCount or 0) > 0 then

		if self.program ~= nil and #self.program > 0 and self.program[1]["pistons"] then
			for i, pistonData in pairs(self.program[1]["pistons"]) do

				if self.debug.positionsReset then
					local v15 = i
					if type(v15) == "table" then v15 = _tableColored(v15, 0, "bright_cyan") end
					print(d .. TextColored("[positionsReset]", "gray"), "	Поршень", TextColored("По программе", "bright_cyan"), "	Индекс", TextColored(v15, "bright_cyan"), "	Длина", TextColored(pistonData[1], "bright_cyan"))
				end



				self:setPistonLengthByIndex(i, pistonData[1])
			end

		else
			for i = 1, self.pistonsCount do

				if self.debug.positionsReset then
					print(d .. TextColored("[positionsReset]", "gray"), "	Поршень", TextColored("По нулям", "bright_cyan"), "	Индекс", TextColored(i, "bright_cyan"), "	Длина", TextColored("0", "bright_cyan"))
				end



				self:setPistonLength(i, 0)
			end
		end
	end

	if (self.bearingsCount or 0) > 0 then

		if self.program ~= nil and #self.program > 0 and self.program[1]["bearings"] ~= nil then
			for i, bearingData in pairs(self.program[1]["bearings"]) do

				if self.debug.positionsReset then
					local v15 = i
					if type(v15) == "table" then v15 = _tableColored(v15, 0, "bright_cyan") end
					print(d .. TextColored("[positionsReset]", "gray"), "	Подшипник", TextColored("По программе", "bright_cyan"), "	Индекс", TextColored(v15, "bright_cyan"), "	Угол", TextColored(bearingData[1], "bright_cyan"))
				end



				self:setBearingAngleByIndex(i, bearingData[1])
			end

		else
			for i = 1, self.bearingsCount do

				if self.debug.positionsReset then
					print(d .. TextColored("[positionsReset]", "gray"), "	Подшипник", TextColored("По нулям", "bright_cyan"), "	Индекс", TextColored(i, "bright_cyan"), "	Угол", TextColored("0", "bright_cyan"))
				end



				self:setBearingAngle(i, 0)
			end
		end
	end


	self:refreshAll()
end

function SmartController.refreshAll(self)

	if #self.bearingsAngle == 0 then
		for k, v in pairs(self.interactable:getBearings()) do
			v:setMotorVelocity(self.masterVelocity, self.maxImpulse)
		end
	else
		for k, v in pairs(self.interactable:getBearings()) do
			mv = self.masterVelocity
			mi = self.maxImpulse
			if self.bearingsAngle[k] == nil then
				self.bearingsAngle[k] = 0
				mv = 0
				mi = 0
			end

			v:setTargetAngle(self.bearingsAngle[k], mv, mi)
		end
	end


	if #self.pistonsLength ~= 0 then
		for k, v in pairs(self.interactable:getPistons()) do
			if self.pistonsLength[k] ~= nil then
				v:setTargetLength(math.max(self.pistonsLength[k] - 1, 0), self.masterVelocity, 500000)
			else
				v:setTargetLength(0, self.masterVelocity, 500000)
			end
		end
	end
end

function SmartController.performStage(self, v10)


	local bearings = v10["bearings"]
	if bearings ~= nil then
		for i, bearingData in pairs(bearings) do

			angle = math.rad(self.operationState == 1 and bearingData[2] or bearingData[1])

			self:setBearingAngleByIndex(i, angle)
		end
	end


	local pistons = v10["pistons"]
	if pistons ~= nil then
		for i, pistonData in pairs(pistons) do

			length = self.operationState == 1 and pistonData[2] or pistonData[1]

			self:setPistonLengthByIndex(i, length)
		end
	end


	self:refreshAll()
end

function SmartController.server_onFixedUpdate(self, dt)
	self.bearingsCount = #self.interactable:getBearings()
	self.pistonsCount = #self.interactable:getPistons()



	local container
	for _, parent in ipairs(self.interactable:getParents()) do
		if parent:hasOutputType(sm.interactable.connectionType.electricity) then
			container = parent:getContainer(0)
			break
		end
	end

	self.batteries = self:sv_mathCount()
	self.chargeDelta = 0



	local v1 = self.isActive
	if v1 and self.energy <= 0 then
		self:sv_removeItem()
		if self.energy <= 0 then
			v1 = nil
		end
	end

	if v1 then
		if self.maxImpulse > 0 then
			for k, v in pairs(self.interactable:getBearings()) do
				self.chargeDelta = self.chargeDelta + math.abs(v:getAppliedImpulse())
			end
			for k, v in pairs(self.interactable:getPistons()) do
				self.chargeDelta = self.chargeDelta + math.abs(v:getLength() * self.maxImpulse)
			end
			self.energy = self.energy - self.chargeDelta
		end
	elseif self.wasActive then
		for k, v in pairs(self.interactable:getBearings()) do
			v:setMotorVelocity(0, SmartController.nonActiveImpulse)
		end
	end
	self.wasActive = v1

	if self.energy < 0 then
		self.energy = 0
	end

	local rpm = self.masterVelocity / self.maxMasterVelocity
	local load = (self.chargeDelta / self.maxImpulse) / ((self.bearingsCount + self.pistonsCount) or self.bearingsCount or 0)
	if self.old_active ~= v1 or
	rpm ~= self.old_rpm or
	load ~= self.old_load or
	self.soundtype ~= self.old_type then
		if v1 and self.soundtype ~= 0 then
			local v16, v18 = load, rpm
			if self.soundtype == 1 then
				v18 = v16
			end
			self.network:sendToClients("cl_setEffectParams", {
				rpm = v18,
				load = v16,
				soundtype = self.soundtype
			})
		else
			self.network:sendToClients("cl_setEffectParams")
		end
	end
	self.old_active = v1
	self.old_rpm = rpm
	self.old_load = load
	self.old_type = self.soundtype

	sm.sc.creativeCheck(self, self.energy == math.huge)

	local v36 = self.program

	local operationState = self.operationState




	local v37 = #v36


	if self.debug.onTickPrints then
		print(
			d .. TextColored("[onTickPrints]", "gray"), "v1", TextColored(v1, "bright_cyan"),
			"	self.program ~= nil", TextColored(self.program ~= nil, "bright_cyan"), "	operationState", TextColored(operationState, "bright_cyan"),
			"	self.prevOperationState", TextColored(self.prevOperationState, "bright_cyan"), "	self.programStage", TextColored(self.programStage, "bright_cyan"),
			"	self.pendingOperation", TextColored(self.pendingOperation, "bright_cyan"), "	#v36", TextColored(v37, "bright_cyan")
		)
	end



	if self.operationState == 0 and self.pendingOperation then
		if self.pendingOperation ~= self.prevOperationState then
			if self.pendingOperation == 1 then
				self.interactable.publicData.sc_component.api.start("old")
			else
				self.interactable.publicData.sc_component.api.stop()
			end
		end
		self.pendingOperation = nil
	end

	if v1 and operationState ~= 0 then
		if not self.program or v37 == 0 then

			return
		end




		local v21 = operationState == 1
		local programStage = self.programStage


		self.programTimer = self.programTimer + dt


		if operationState ~= self.prevOperationState then
			self.prevOperationState = operationState
			self.programStage = 0
			self.programTimer = 0


			local v13 = v21 and v36[1] or v36[v37]


			self:performStage(v13)

			self.programStage = 1

			return
		end






		local v35 = v21 and programStage or (v37 - programStage + 1)
		v35 = clamp(v35, 1, v37)

		local v10 = v36[v35]
		local v34 = v10.delays


		local v9 = 1
		if v34 then
			v9 = v21 and v34[2] or max(0, v34[1] - 1)
		end


		if self.programTimer >= v9 then
			self.programTimer = 0
			self.programStage = programStage + 1

			if programStage + 1 <= v37 then
				local v20 = v21 and (programStage + 1) or (v37 - (programStage + 1) + 1)
				self:performStage(v36[v20])
			else

				local v24 = self.operationState
				self.operationState = 0
				self.programStage = 0
				self.prevOperationState = v24


				if self.pendingOperation and self.pendingOperation ~= self.prevOperationState then
					if self.pendingOperation == 1 then

						self.interactable.publicData.sc_component.api.start("old")
					else
						self.interactable.publicData.sc_component.api.stop()
					end

					self.pendingOperation = nil
				end
			end
		end











































	end
end

function SmartController:sv_removeItem()
	local v23 = sm.uuid.new("910a7f2c-52b0-46eb-8873-ad13255539af")

	for _, parent in ipairs(self.interactable:getParents()) do
        if parent:hasOutputType(sm.interactable.connectionType.electricity) then
			local container = parent:getContainer(0)
			if container:canSpend(v23, 1) then
				sm.container.beginTransaction()
				sm.container.spend(container, v23, 1, true)
				if sm.container.endTransaction() then
					self.energy = self.energy + SmartController.chargeAdditions
					break
				end
			end
		end
	end
end

function SmartController:sv_mathCount()
    local v8 = 0
    for _, parent in ipairs(self.interactable:getParents()) do
        if parent:hasOutputType(sm.interactable.connectionType.electricity) then
            local container = parent:getContainer(0)
            for i = 0, container.size - 1 do
                v8 = v8 + (container:getItem(i).quantity)
            end
		end
	end
    return v8
end




function SmartController:client_onCreate()
end

function SmartController:cl_setEffectParams(v41)
	if v41 then
		if v41.soundtype ~= self.cl_oldSoundType then
			if self.effect then
				self.effect:setAutoPlay(false)
				self.effect:stop()
				self.effect:destroy()
				self.effect = nil
			end
			self.cl_oldSoundType = v41.soundtype
		end
		if not self.effect then
			if v41.soundtype == 1 then
				self.effect = sm.effect.createEffect("ElectricEngine - Level 2", self.interactable)
			elseif v41.soundtype == 2 then
				self.effect = sm.effect.createEffect("GasEngine - Level 3", self.interactable)
			end

			if self.effect then
				self.effect:setAutoPlay(true)
				self.effect:start()
			end
		end

		if self.effect then
			self.effect:setParameter("rpm", v41.rpm)
			self.effect:setParameter("load", v41.load)
		end
	else
		if self.effect then
			self.effect:setAutoPlay(false)
			self.effect:stop()
			self.effect:destroy()
			self.effect = nil
		end
	end
end