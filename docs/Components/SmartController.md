---
title: SmartController
---

The **SmartController** is an advanced control unit in Scrap Mechanic designed for creating intricate movement sequences for pistons and bearings. By defining a program inside it, users can orchestrate precise mechanical actions, making it ideal for automated robotic constructs, complex doors, and synchronized mechanical systems.

### SmartController component
* type - SmartController;

##### Primary
* **SmartController.start(program:table)** - Initiates the execution of a predefined movement sequence. The `program` parameter must be a dictionary defining the logic of movement. If a stage in the program does not include a delays field, the default delay of {1, 1} is applied.

* **SmartController.stop()** - Reverses the current operation of the controller, causing all active movements to run in the opposite direction. To completely stop the controller, use `SmartController.setActive(false)`.

* **SmartController.isActive():boolean** - Returns whether the controller is currently active, allowing for checks in automated systems.

* **SmartController.setActive(state:boolean|number)** - Enables or disables the controller. Accepts either a boolean value or a number (where non-zero values are interpreted as `true`).

* **SmartController.isWorkAvailable():boolean** - Checks whether the controller has the necessary power (e.g., energy or batteries) to function.

* **SmartController.getAvailableBatteries():number** - Returns the number of available batteries. In creative mode, this always returns an infinite value.

* **SmartController.getCharge():number** - Retrieves the current charge level of the controller.

* **SmartController.getChargeDelta():number** - Returns the rate at which the charge is changing.

* **SmartController.getChargeAdditions():number** - Fetches additional charge-related parameters relevant to the controller.

##### Config
* **SmartController.getVelocity():number** - Retrieves the master velocity at which the controller operates.

* **SmartController.setVelocity(value:number)** - Sets the master velocity. The value is clamped between `-maxMasterVelocity` and `maxMasterVelocity` to ensure controlled speed regulation.

* **SmartController.getStrength():number** - Returns the maximum impulse force exerted by the controller.

* **SmartController.setStrength(value:number)** - Adjusts the impulse strength, ensuring movements are executed with the appropriate force. Values are clamped between `0` and `mImpulse`.

##### Bearings
* **SmartController.getBearingsCount():number** - Returns the number of bearings currently controlled by the SmartController.

##### Pistons
* **SmartController.getPistonsCount():number** - Returns the number of pistons currently connected to the controller.

##### Sound
* **SmartController.getSoundType():number** - Retrieves the type of sound effect associated with the controller.

* **SmartController.setSoundType(value:number)** - Sets the sound type for the controller, influencing the audio feedback of mechanical actions.

#### Code Examples

### Example 1: Smart Controller - Simple Program
Below is a example demonstrating how to configure and start a simple movement sequence using SmartController:
### Good practice:
```lua
controller = getComponents("smartController")[1]
if controller == nil then return end

-- Configuring
controller.setVelocity(20)
controller.setStrength(1000)
controller.setSoundType(0)
controller.setActive(true)

function onStart()
    -- Execute the program (direct order)
    controller.start({
		-- Stages (step-by-step)
		[1] = { -- Synchronized actions
			["pistons"] = {
                -- [pistonIndex] = {lengthBefore, lengthAfter}
				[{1,25}] = {1, 4}  -- Short notation (1-25 indexes pistons)
			},
			["bearings"] = {
                -- [bearingIndex] = {degreeBefore, degreeAfter}
				[1] = {0, 90}
			}
		},
		[2] = {
			["pistons"] = {
				[{1,25}] = {4, 1}
			},
			["bearings"] = {
				[1] = {90, 0},
			},

			-- Delays when [onDirectDelay, onReverseDelay] (start/stop delays)
			-- If a stage in the program does not include a ["delays"] field, the default delay of {1, 1} is applied.
			["delays"] = {2, 2}
		}
    })
end

function onStop()
	-- Execute the program (reversed order)
    controller.stop()
end

_enableCallbacks = true
```

### BAD practice:
```lua
controller = getComponents("smartController")[1]

controller.setVelocity(20)
controller.setStrength(10000)
controller.setSoundType(0)
controller.setActive(true)

function onStart()
    controller.start({
		[1] = {
			["pistons"] = {
				[1] = {1, 4}, -- Very long and not optimized!
				[2] = {1, 4},
				[3] = {1, 4},
				[4] = {1, 4},
				[5] = {1, 4},
				[6] = {1, 4},
				[7] = {1, 4},
				[8] = {1, 4},
				[9] = {1, 4},
				[10] = {1, 4},
				[11] = {1, 4},
				[12] = {1, 4},
				[13] = {1, 4},
				[14] = {1, 4},
				[15] = {1, 4},
				[16] = {1, 4},
				[17] = {1, 4},
				[18] = {1, 4},
				[19] = {1, 4},
				[20] = {1, 4},
				[21] = {1, 4},
				[22] = {1, 4},
				[23] = {1, 4},
				[24] = {1, 4}
				[25] = {1, 4}
			},
			["bearings"] = {
				[1] = {0, 90}
			}
		},
		[2] = {
			["pistons"] = {
				[1] = {4, 1},
				[2] = {4, 1},
				[3] = {4, 1},
				[4] = {4, 1},
				[5] = {4, 1},
				[6] = {4, 1},
				[7] = {4, 1},
				[8] = {4, 1},
				[9] = {4, 1},
				[10] = {4, 1},
				[11] = {4, 1},
				[12] = {4, 1},
				[13] = {4, 1},
				[14] = {4, 1},
				[15] = {4, 1},
				[16] = {4, 1},
				[17] = {4, 1},
				[18] = {4, 1},
				[19] = {4, 1},
				[20] = {4, 1},
				[21] = {4, 1},
				[22] = {4, 1},
				[23] = {4, 1},
				[24] = {4, 1}
				[25] = {4, 1}
			},
			["bearings"] = {
				[1] = {90, 0},
			},

			["delays"] = {2, 2}
		}
})
end

function onStop()
    controller.stop()
end

_enableCallbacks = true
```

### Example 2: Smart Controller - Various Program Configurations
A code example showcasing various possible program configurations:

```lua
controller = getComponents("smartController")[1]
if controller == nil then return end

-- Configuring
controller.setVelocity(20)
controller.setStrength(1000)
controller.setSoundType(0)
controller.setActive(true)

function onStart()
	-- Execute the program (direct order)
    controller.start({
		-- Stages (step-by-step)
		[1] = { -- Synchronized actions
			["pistons"] = {
				-- [pistonIndex] = {lengthBefore, lengthAfter}
				[3] = {1, 7}, -- Maybe we should change it to a short notation? The example is below :D
				[4] = {1, 7}
			},
			["bearings"] = {
				-- [bearingIndex] = {degreeBefore, degreeAfter}
				[{1,2}] = {90, 90} -- Short notation (1-2 indexes bearings)
				-- [1] = {90, 90}, -- Long notation
				-- [2] = {90, 90} -- Loooong
			}
		},
		[2] = {
			["pistons"] = {
				[{1,2}] = {1, 4}
			},
			["bearings"] = {
				[{1,2}] = {180, 180}
			},

			-- Delays when [onDirectDelay, onReverseDelay] (start/stop delays)
			-- If a stage in the program does not include a ["delays"] field, the default delay of {1, 1} is applied.
			["delays"] = {2, 2}
		},
		[3] = {
			-- Pistons are not affected (saved state from stage 2)
			["bearings"] = {
				[1] = {45, 45},
				[2] = {45, 45}
			},

			["delays"] = {2, 2}
		}
	})
end

function onStop()
	-- Execute the program (reversed order)
    controller.stop()
end

_enableCallbacks = true
```

