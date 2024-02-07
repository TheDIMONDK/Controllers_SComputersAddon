ScriptableController = class(nil)
ScriptableController.maxParentCount = -1
ScriptableController.maxChildCount = 16
ScriptableController.connectionInput = sm.interactable.connectionType.composite + sm.interactable.connectionType.electricity
ScriptableController.connectionOutput = sm.interactable.connectionType.bearing + sm.interactable.connectionType.piston
ScriptableController.colorNormal = sm.color.new(0x00b3a4ff)
ScriptableController.colorHighlight = sm.color.new(0x1bdeceff)
ScriptableController.componentType = "scriptableController"

ScriptableController.nonActiveImpulse = 0
ScriptableController.chargeAdditions = 50000

-- COPIED FROM SCOMPUTERS FORK, NEED PUBLIC API OF THIS METHOD
function checkArg(n, have, ...)
	have = type(have)
	local tbl = {...}
	for _, t in ipairs(tbl) do
		if have == t then
			return
		end
	end
	error(string_format("bad argument #%d (%s expected, got %s)", n, table_concat(tbl, " or "), have), 3)
end


-- SERVER --

function ScriptableController.server_createData(self)

end

function ScriptableController.server_onCreate(self)
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
	
	self.interactable.publicData = {
        sc_component = {
            type = ScriptableController.componentType,
            api = {
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

                getAllBearingsAngle = function () return self.bearingsAngle end,
                getBearingAngle = function (id) return self.bearingsAngle[id] end,
                setBearingAngle = function (id, v)
                    if type(id) == "number" then
                        if type(v) == "number" or type(v) == "nil" then
                            local val = v and sm.util.clamp(v, -3.402e+38, 3.402e+38) or nil
                            if id <= self.bearingsCount then
								if self.bearingsAngle[id] == nil then
									table.insert(self.bearingsAngle, val)
								else
									self.bearingsAngle[id] = val
								end
							else
								error(id .. " - Value of index must be less than or equal to the number of connected bearings")
							end
                        else
                            error("Value of angle must be number or nil")
                        end

                    else
                        error("Value of index must be number")
                    end
                end,

                getAllPistonsLength = function () return self.pistonsLength end,
                getPistonLength = function (id) return self.pistonsLength[id] end,
                setPistonLength = function (id, v)
                    if type(id) == "number" then
                        if type(v) == "number" then
                            if v >= 0 then
								if id <= self.pistonsCount then
									if self.pistonsLength[id] == nil then
										table.insert(self.pistonsLength, v)
									else
										self.pistonsLength[id] = val
									end
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
        
                -- maxStrength = function ()
                --     return self.mImpulse
                -- end,
                -- maxVelocity = function ()
                --     return self.maxMasterVelocity
                -- end,
                getChargeAdditions = function ()
                    return ScriptableController.chargeAdditions
                end,
                setSoundType = function (num)
                    checkArg(1, num, "number")
                    self.soundtype = num
                end,
                getSoundType = function ()
                    return self.soundtype
                end
            }
        }
    }

	--sc.motorsDatas[self.interactable:getId()] = self:server_createData()

	sm.sc.creativeCheck(self, self.energy == math.huge)
end

function ScriptableController.server_onDestroy(self)
	--sc.motorsDatas[self.interactable:getId()] = nil
end

function ScriptableController.server_onFixedUpdate(self, dt)
	self.bearingsCount = #self.interactable:getBearings()
	self.pistonsCount = #self.interactable:getPistons()

	-- -- Disconnected bearings
	-- if self.bearingsCount < #self.bearingsAngle then
	-- 	for i = self.bearingsCount, #self.bearingsAngle do
	-- 		self.bearingsAngle[i] = nil
	-- 	end
	-- end
	-- -- Disconnected pistons
	-- if self.pistonsCount < #self.pistonsLength then
	-- 	for i = self.pistonsCount, #self.pistonsLength do
	-- 		self.pistonsLength[i] = nil
	-- 	end
	-- end

	--------------------------------------------------------

	local container
	for _, parent in ipairs(self.interactable:getParents()) do
		if parent:hasOutputType(sm.interactable.connectionType.electricity) then
			container = parent:getContainer(0)
			break
		end
	end

	self.batteries = self:sv_mathCount()
	self.chargeDelta = 0

	--------------------------------------------------------

	local active = self.isActive
	if active and self.energy <= 0 then
		self:sv_removeItem()
		if self.energy <= 0 then
			active = nil
		end
	end

	if active then
        -- Bearings
		if #self.bearingsAngle == 0 then
			for k, v in pairs(self.interactable:getBearings()) do
				v:setMotorVelocity(self.masterVelocity, self.maxImpulse)
			end
		else
			for k, v in pairs(self.interactable:getBearings()) do
				if self.bearingsAngle[k] == nil then
					self.bearingsAngle[k] = 0
				end

				v:setTargetAngle(self.bearingsAngle[k], self.masterVelocity, self.maxImpulse)
			end
		end

        -- Pistons
        if #self.pistonsLength ~= 0 then
			for k, v in pairs(self.interactable:getPistons()) do
                v:setTargetLength(math.max(self.pistonsLength[k]-1, 0), self.masterVelocity, 100000)
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
			v:setMotorVelocity(0, ScriptableController.nonActiveImpulse)
		end
	end
	self.wasActive = active

	if self.energy < 0 then
		self.energy = 0
	end

	local rpm = self.masterVelocity / self.maxMasterVelocity
	local load = (self.chargeDelta / self.maxImpulse) / ((self.bearingsCount + self.pistonsCount) or self.bearingsCount or 0)
	if self.old_active ~= active or
	rpm ~= self.old_rpm or
	load ~= self.old_load or
	self.soundtype ~= self.old_type then
		if active and self.soundtype ~= 0 then
			local lload, lrpm = load, rpm
			if self.soundtype == 1 then
				lrpm = lload
			end
			self.network:sendToClients("cl_setEffectParams", {
				rpm = lrpm,
				load = lload,
				soundtype = self.soundtype
			})
		else
			self.network:sendToClients("cl_setEffectParams")
		end
	end
	self.old_active = active
	self.old_rpm = rpm
	self.old_load = load
	self.old_type = self.soundtype

	sm.sc.creativeCheck(self, self.energy == math.huge)
end

function ScriptableController:sv_removeItem()
	obj_consumable_battery = sm.uuid.new("910a7f2c-52b0-46eb-8873-ad13255539af")
	
	for _, parent in ipairs(self.interactable:getParents()) do
        if parent:hasOutputType(sm.interactable.connectionType.electricity) then
			local container = parent:getContainer(0)
			if container:canSpend(obj_consumable_battery, 1) then
				sm.container.beginTransaction()
				sm.container.spend(container, obj_consumable_battery, 1, true)
				if sm.container.endTransaction() then
					self.energy = self.energy + ScriptableController.chargeAdditions
					break
				end
			end
		end
	end
end

function ScriptableController:sv_mathCount()
    local count = 0
    for _, parent in ipairs(self.interactable:getParents()) do
        if parent:hasOutputType(sm.interactable.connectionType.electricity) then
            local container = parent:getContainer(0)
            for i = 0, container.size - 1 do
                count = count + (container:getItem(i).quantity)
            end
		end
	end
    return count
end


-- CLIENT --

function ScriptableController:client_onCreate()
end

function ScriptableController:cl_setEffectParams(tbl)
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