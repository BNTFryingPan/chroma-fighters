package states;

import CustomButton;
import PlayerSlot.PlayerSlotIdentifier;
import flixel.FlxG;
import flixel.FlxState;
import flixel.input.gamepad.FlxGamepad;
import inputManager.InputEnums;
import inputManager.InputManager;
import inputManager.InputTypes;
import inputManager.MouseHandler;

/**
    a base for other states in the game

    contains core functionality that allows the input manager to work
**/
class BaseState extends FlxState {
    override public function create() {
        super.create();

        FlxG.autoPause = false;

        // add(new MonospaceText(100, 200, 0, "HI"));

        /*if (FlxG.gamepads.lastActive != null) { // if there is a controller connected, make the last active (arbitrary?) controller the P1 input
                InputManager.setInputType(P1, ControllerInput);
                InputManager.setInputDevice(P1, FlxG.gamepads.lastActive);
            } else { // otherwise default to keyboard input
                InputManager.setInputType(P1, KeyboardInput);
        }*/
    }

    override public function draw() {
        super.draw();
        GameManager.draw();
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        GameManager.update(elapsed);
    }
}
