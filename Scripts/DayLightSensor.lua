---------------------------------
--   By TheDIMONDK             --
---------------------------------

DayLightSensor = class(nil)
DayLightSensor.maxParentCount = 1
DayLightSensor.maxChildCount = 0
DayLightSensor.connectionInput = sm.interactable.connectionType.composite + sm.interactable.connectionType.electricity
DayLightSensor.colorNormal = sm.color.new(0x5230ffff)
DayLightSensor.colorHighlight = sm.color.new(0x2100caff)
DayLightSensor.componentType = "dayLightSensor"

DayLightSensor.dayBegin = 4
DayLightSensor.dayEnd = 19.5

-- LOCAL --
function DayLightSensor.IsSkyFree(self)
    if (self.data and self.data.survival) then
        local ok, data = sm.physics.raycast(self.shape.worldPosition, self.shape.worldPosition + sm.vec3.new(0, 0, 10000), sm.shape.body)
        if ok and data.type ~= "limiter" then
            return false -- is sky blocked
        else
            return true -- is sky free
        end
    else
        return true -- is creative
    end
end


-- SERVER --

function DayLightSensor.server_createData(self)

end

-- for script refresh
function server_onRefresh()
	self:server_onCreate()
end

function DayLightSensor.server_onCreate(self)
    self.interactable.publicData = {
        sc_component = {
            type = DayLightSensor.componentType,
            api = {
                isSkyNotObstructed = function ()
                    return self:IsSkyFree()
                end,
                isDay = function ()
                    if self:IsSkyFree() then
                        return self.currentTime > self.dayBegin and self.currentTime < self.dayEnd
                    else
                        error("The sky is blocked, the sensor cannot continue to work. Use IsSkyObstructed() for check, and Eliminate the obstacle and try again!")
                    end
                end,
                isNight = function ()
                    if self:IsSkyFree() then
                        return not (self.currentTime > self.dayBegin and self.currentTime < self.dayEnd)
                    else
                        error("The sky is blocked, the sensor cannot continue to work. Use IsSkyObstructed() for check, Eliminate the obstacle and try again!")
                    end
                end
            }
        }
    }

    sm.sc.creativeCheck(self, self.data == nil)
end

function DayLightSensor.server_onFixedUpdate(self, dt)
    self.currentTime = sm.game.getTimeOfDay() * 24

    sm.sc.creativeCheck(self, self.data == nil)
end