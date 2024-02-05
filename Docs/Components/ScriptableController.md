---
title: scriptableController
---

The ScriptableController can be used to create automatic machinery and huge robots. \nIt also makes it possible to rotate the specified bearings and change the length of the specified connected pistons. In other words, it allows the bearings of the specified index to be rotated at any angle, and a similar situation is with the pistons - their length can also be changed individually, which allows for the creation of various asynchronous transforming structures.

### scriptableController component
* type - scriptableController;
##### Primary
* scriptableController.setActive(state:boolean) - starts or stops the controller. returns true even if there are no resources to work with in order to find out the true state use: scriptableController.isActive() and scriptableController.isWorkAvailable();
* scriptableController.isActive():boolean - outputs the state set via setActive;
* scriptableController.isWorkAvailable():boolean - outputs true if the engine can work at the moment (there is enough fuel and batteries);
* scriptableController.getAvailableBatteries():number - returns the number of batteries available to the engine;
* scriptableController.getCharge():number;
* scriptableController.getChargeDelta():number;
* scriptableController.getChargeAdditions():number;
* scriptableController.getSoundType():number;
* scriptableController.setSoundType(number);

##### Config
* scriptableController.getVelocity():number - returns the velocity of the controller's action on the bearings;
* scriptableController.setVelocity(number) - set the velocity of the controller's on the bearings;
* scriptableController.getStrength():number - returns the strength of the controller's on the bearings;
* scriptableController.setStrength(number) - set the strength of the controller's action on the bearings;

##### Bearings
* scriptableController.getBearingsCount():number - returns the count of bearings connected to the controller;
* scriptableController.getAllBearingsAngle():table - returns a table with the current angles of rotation (in radians) of all bearings (note that the index in the table is equal to the bearing index);
* scriptableController.getBearingAngle(id:number) - returns the current angle of rotation of the bearing at the specified index (in radians);
* scriptableController.setBearingAngle(id:number, angle:number) - set the angle of rotation of the bearing at the specified index (in radians);

##### Pistons
* scriptableController.getPistonsCount():number - returns the count of pistons connected to the controller;
* scriptableController.getAllPistonsLength():table - returns a table with the current lengths of all pistons (note that the index in the table is equal to the piston index);
* scriptableController.getPistonLength(id:number) - returns the current length of the piston at the specified index;
* scriptableController.setBearingAngle(id:number, length:number) - set the length of the piston at the specified index;


#### Code

Simple example (2 connected bearings, and 2 connected pistons)
```lua
controller = getComponents("scriptableController")[1]
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