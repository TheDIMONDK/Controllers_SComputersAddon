---------------------------------
--        By TheDIMONDK        --
---------------------------------
-- 2024-2025 Copyrighted code. Scrap Mechanic API.

dofile "$CONTENT_DATA/Scripts/Config.lua"
clamp = sm.util.clamp

SmartController = class(nil)
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


function server_onRefresh()
	self:server_onCreate()
end

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

	self.program = {}

	self.programStage = 0
	self.programTimer = 0

	self.interactable.publicData = {
        sc_component = {
            type = SmartController.componentType,
            api = {
				start = function (program)
					if program == nil then error("Please specify the dictionary with the program logic.") end
					self.program = program
					self.operationState = 1
				end,
				stop = function () self.operationState = 2 end,
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
                setSoundType = function (v7)
                    checkArg(1, v7, "number")
                    self.soundtype = v7
                end,
                getSoundType = function ()
                    return self.soundtype
                end
            }
        }
    }



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
			local v11 = v and sm.util.clamp(v, -3.402e+38, 3.402e+38) or 0
			if id > 0 then
				self.bearingsAngle[id] = v11
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

function SmartController.performStage(self, currentStage)


	bearings = currentStage["bearings"]
	if bearings ~= nil then
		for i, bearingData in pairs(bearings) do

			angle = math.rad(self.operationState == 1 and bearingData[2] or bearingData[1])


			if type(i) == "number" then
				self:setBearingAngle(i, angle)


			elseif type(i) == "table" and #i >= 2 and type(i[1]) == "number" and type(i[2]) == "number" then

				for j = i[1], i[2] do
					self:setBearingAngle(j, angle)
				end

			else
				error("Invalid enumeration type. Use [oneIndex] or [{startIndex, endIndex}].")
			end
		end
	end


	pistons = currentStage["pistons"]
	if pistons ~= nil then
		for i, pistonData in pairs(pistons) do

			length = self.operationState == 1 and pistonData[2] or pistonData[1]


			if type(i) == "number" then
				self:setPistonLength(i, length)


			elseif type(i) == "table" and #i >= 2 and type(i[1]) == "number" and type(i[2]) == "number" then

				for j = i[1], i[2] do
					self:setPistonLength(j, length)
				end

			else
				error("Invalid enumeration type. Use [oneIndex] or [{startIndex, endIndex}].")
			end
		end
	end
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
			local v4, v6 = load, rpm
			if self.soundtype == 1 then
				v6 = v4
			end
			self.network:sendToClients("cl_setEffectParams", {
				rpm = v6,
				load = v4,
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

	if v1 and self.program ~= nil and self.operationState ~= 0 then
		self.programTimer = self.programTimer + dt

		stages = self.program


		if self.operationState ~= prevState then
			prevState = self.operationState
			self.programStage = 0
			self.programTimer = 0


			if self.operationState == 1 then
				self:performStage(stages[1])
			elseif self.operationState == 2 then
				self:performStage(stages[#stages])
			end

			self.programStage = 1

			return
		end





		nextStageIndex = clamp(self.programStage, 1, #stages)
		currentStage = self.operationState == 1 and stages[nextStageIndex] or stages[#stages - nextStageIndex + 1]


		if self.programStage >= 1 then
			self.programTimer = self.programTimer + dt
		end


		currentInterval = 1

		StageDelays = currentStage["delays"]
		if StageDelays ~= nil then

			currentInterval = self.operationState == 1 and StageDelays[1] or math.max(0, StageDelays[2] - 1)
		end


		if self.programTimer >= currentInterval then
			self.programTimer = 0
			self.programStage = self.programStage + 1



			if self.programStage <= #stages then
				self:performStage(self.operationState == 1 and stages[self.programStage] or stages[#stages - self.programStage + 1])
			else
				self.programStage = 0

				self.operationState = 0
			end
		end
	end
end

function SmartController:sv_removeItem()
	obj_consumable_battery = sm.uuid.new("910a7f2c-52b0-46eb-8873-ad13255539af")

	for _, parent in ipairs(self.interactable:getParents()) do
        if parent:hasOutputType(sm.interactable.connectionType.electricity) then
			local container = parent:getContainer(0)
			if container:canSpend(obj_consumable_battery, 1) then
				sm.container.beginTransaction()
				sm.container.spend(container, obj_consumable_battery, 1, true)
				if sm.container.endTransaction() then
					self.energy = self.energy + SmartController.chargeAdditions
					break
				end
			end
		end
	end
end

function SmartController:sv_mathCount()
    local v3 = 0
    for _, parent in ipairs(self.interactable:getParents()) do
        if parent:hasOutputType(sm.interactable.connectionType.electricity) then
            local container = parent:getContainer(0)
            for i = 0, container.size - 1 do
                v3 = v3 + (container:getItem(i).quantity)
            end
		end
	end
    return v3
end




function SmartController:client_onCreate()
end

function SmartController:cl_setEffectParams(tbl)
	if tbl then
		if tbl.soundtype ~= self.cl_oldSoundType then
			if self.effect then
				self.effect:setAutoPlay(false)
				self.effect:stop()
				self.effect:destroy()
				self.effect = nil
			end
			self.cl_oldSoundType = tbl.soundtype
		end
		if not self.effect then
			if tbl.soundtype == 1 then
				self.effect = sm.effect.createEffect("ElectricEngine - Level 2", self.interactable)
			elseif tbl.soundtype == 2 then
				self.effect = sm.effect.createEffect("GasEngine - Level 3", self.interactable)
			end

			if self.effect then
				self.effect:setAutoPlay(true)
				self.effect:start()
			end
		end

		if self.effect then
			self.effect:setParameter("rpm", tbl.rpm)
			self.effect:setParameter("load", tbl.load)
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