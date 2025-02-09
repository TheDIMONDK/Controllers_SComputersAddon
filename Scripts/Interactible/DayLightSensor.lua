---------------------------------
--        By TheDIMONDK        --
---------------------------------
-- 2024-2025 Copyrighted code. Scrap Mechanic API.

DayLightSensor = class(nil)
DayLightSensor.maxParentCount = 1
DayLightSensor.maxChildCount = 0
DayLightSensor.connectionInput = sm.interactable.connectionType.composite + sm.interactable.connectionType.electricity
DayLightSensor.colorNormal = sm.color.new(0x5230ffff)
DayLightSensor.colorHighlight = sm.color.new(0x2100caff)
DayLightSensor.componentType = "dayLightSensor"

DayLightSensor.dayBegin = 4
DayLightSensor.dayEnd = 19.5


function DayLightSensor.IsSkyFree(self)
    if (self.data and self.data.survival) then
        local v2, data = sm.physics.raycast(self.shape.worldPosition, self.shape.worldPosition + sm.vec3.new(0, 0, 10000), sm.shape.body)
        if v2 and data.type ~= "limiter" then
            return false
        else
            return true
        end
    else
        return true
    end
end




function DayLightSensor.server_createData(self)

end


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