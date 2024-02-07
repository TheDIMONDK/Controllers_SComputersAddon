```
---
title: scriptableController
---

The ScriptableController is a versatile component in Scrap Mechanic that enables the automation and dynamic control of machinery and robotic constructs. It can precisely manipulate the rotation of bearings and the extension of pistons, allowing for the creation of complex, articulated structures and mechanisms. From simple automated doors to intricate transforming robots, the ScriptableController serves as the brain behind many inventive creations within the game.

### scriptableController component
* type - scriptableController;

##### Primary
* **scriptableController.setActive(state:boolean)** - Initiates or halts the operation of the controller. It returns true irrespective of the controller's current resource availability. To accurately determine the controller's operational state or resource availability, use: `scriptableController.isActive()` and `scriptableController.isWorkAvailable()`.

* **scriptableController.isActive():boolean** - Reveals whether the controller is currently activated. This status check is crucial for troubleshooting and synchronizing multiple controllers within larger systems, ensuring coordinated operations.

* **scriptableController.isWorkAvailable():boolean** - Indicates the presence of necessary resources (e.g., fuel, batteries) for the controller to function. This method is vital for managing energy-efficient designs and ensuring machines operate only when they have adequate resources.

* **scriptableController.getAvailableBatteries():number** - Reports the quantity of batteries available for the controller's operations. This information is key for power management and planning the deployment of battery-dependent devices.

* **scriptableController.getCharge():number;**
* **scriptableController.getChargeDelta():number;**
* **scriptableController.getChargeAdditions():number;**
* **scriptableController.getSoundType():number;**
* **scriptableController.setSoundType(number);**

##### Config
* **scriptableController.getVelocity():number** - Retrieves the current velocity at which the controller manipulates bearings. This is critical for tuning the speed of mechanical movements to match the desired pace of actions in machines and robots.

* **scriptableController.setVelocity(number)** - Adjusts the velocity of bearing rotations. By fine-tuning this setting, creators can achieve precise control over the speed of mechanical parts, enhancing the performance of their constructs.

* **scriptableController.getStrength():number** - Returns the force applied by the controller on the bearings. This parameter is essential for ensuring that mechanical movements have sufficient power.

* **scriptableController.setStrength(number)** - Sets the strength of the controller's actions on bearings, allowing for the adjustment of force to match the requirements of various mechanical applications.

##### Bearings
* **scriptableController.getBearingsCount():number** - Counts the bearings linked to the controller, aiding in the management and debugging of complex constructs by providing a quick inventory of controlled bearings.

* **scriptableController.getAllBearingsAngle():table** - Produces a table detailing the current angular positions of all bearings. This is invaluable for diagnostics and synchronization tasks, offering a comprehensive overview of the mechanical state.

* **scriptableController.getBearingAngle(id:number)** - Retrieves the angle of a specific bearing, allowing for precise monitoring and adjustments to individual components within a mechanism.

* **scriptableController.setBearingAngle(id:number, angle:number)** - Sets a particular bearing's rotation angle. This method is fundamental for creating dynamic and responsive movements within mechanical constructs.

* **scriptableController.resetAllBearingsAngle()** - Reverts all bearings to their original angular positions. This function is useful for resetting mechanisms to a known state before initiating a sequence of operations.

##### Pistons
* **scriptableController.getPistonsCount():number** - Determines the number of pistons connected to the controller. This aids in the configuration and troubleshooting of piston-operated elements within creations.

* **scriptableController.getAllPistonsLength():table** - Provides a table with the current extension lengths of all pistons. This feature is crucial for assessing and coordinating the movements of multiple pistons in complex systems.

* **scriptableController.getPistonLength(id:number)** - Returns the extension length of a specific piston, offering precise control over individual piston adjustments for tailored mechanical actions.

* **scriptableController.setPistonLength(id:number, length:number)** - Adjusts the length of a piston, enabling the customization of piston-driven movements to suit various engineering and design needs.

* **scriptableController.resetAllPistonsLength()** - Resets all pistons to their initial lengths. This function is useful for ensuring that mechanical systems start from a consistent baseline for each operation cycle.

#### Code

Below is a simple example showcasing the setup and basic operation of two connected bearings and pistons using the scriptableController:

```lua
controller = getComponents("scriptableController")[1

]
if controller == nil then return end

-- Configuring
controller.setVelocity(30)
controller.setStrength(30)
controller.setActive(true)

-- Bearings
controller.setBearingAngle(1, math.rad(math.random(140, 160)))
controller.setBearingAngle(2, math.rad(220))

-- Pistons
controller.setPistonLength(1, 4)
controller.setPistonLength(2, 10)

print()
print("Bearing index 1 angle in degrees: " .. math.deg(controller.getBearingAngle(1)))
print("Bearings count: " .. controller.getBearingsCount() .. "; Pistons count: " .. controller.getPistonsCount())
```