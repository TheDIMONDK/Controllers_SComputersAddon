---
title: dayLightSensor
---

The DayLightSensor can be used to automate energy-saving systems and enhance security measures in structures. For instance, it enables the construction of buildings that only consume energy during daylight hours, optimizing the use of resources. Additionally, it can be integrated into automated lighting systems, ensuring lights are only activated when necessary.

### DayLightSensor component
* type - dayLightSensor;

##### Primary
* **DayLightSensor.isSkyNotObstructed():boolean** - checks if the sky is not obstructed for the sensor. Returns true if the sensor has a clear view of the sky, false otherwise. This method is crucial for outdoor applications where the sensor's performance might be affected by physical obstructions like buildings or trees.

* **DayLightSensor.isDay():boolean** - determines if the sensor perceives the current time as day. Returns true during daylight hours, based on the game world's day-night cycle. This can be used to activate or deactivate machines and systems during the day.

* **DayLightSensor.isNight():boolean** - determines if the sensor perceives the current time as night. Returns true during nighttime hours, according to the game world's day-night cycle. This function can be particularly useful for activating lighting systems or triggering events that should only occur at night.

##### Config
* There are no configurable settings for the DayLightSensor component as its functionality is solely based on environmental conditions. However, users can combine its outputs with other logic components to create complex behaviors in their creations.

**Note: The effectiveness of the DayLightSensor depends on its placement in the game world. Ensure it is placed in an area where its view of the sky is unobstructed for accurate readings.**


#### Code

Simple example (2 connected bearings, and 2 connected pistons)
```lua
sensor = getComponents("dayLightSensor")[1]
if controller == nil then return end

-- Checking
if sensor.isSkyNotObstructed() then
	print(sensor.isNight())
else
	print("Sky is obstructed!")
end
```