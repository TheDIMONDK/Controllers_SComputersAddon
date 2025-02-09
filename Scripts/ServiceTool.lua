ServiceTool = class()

function ServiceTool:client_onFixedUpdate()
    if sm.scomputers and not _G_EXAMPLES_BINDED then
        sm.scomputers.addExample("Smart Controller - Simple", [[controller = getComponents("smartController")[1]
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

_enableCallbacks = true]])

    sm.scomputers.addExample("Smart Controller - Various", [[controller = getComponents("smartController")[1]
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

_enableCallbacks = true]])
        _G_EXAMPLES_BINDED = true
    end
end