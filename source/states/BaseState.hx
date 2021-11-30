package states;

import CustomButton;
import PlayerSlot.PlayerSlotIdentifier;
import flixel.FlxG;
import flixel.FlxState;
import inputManager.InputManager;
import inputManager.MouseHandler;

/**
    a base for other states in the game

    contains core functionality that allows the input manager to work
**/
class BaseState extends FlxState {
    override public function create() {
        super.create();

        FlxG.autoPause = false;

        FlxG.gamepads.deviceConnected.add(gamepad -> {
            Main.log('${gamepad.name}.${gamepad.id} connected');
        });

        FlxG.gamepads.deviceDisconnected.add(gamepad -> {
            Main.log('${gamepad.name}.${gamepad.id} disconnected');
            if (InputManager.getUsedGamepads().contains(gamepad)) {
                var slot = InputManager.getPlayerSlotByInput(gamepad);
                if (slot != null) {
                    InputManager.setInputType(slot, NoInput);
                }
            }
        });

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
        InputManager.draw();
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        InputManager.update(elapsed);

        var pads = FlxG.gamepads.getActiveGamepads().map(p -> p.name);
        Main.debugDisplay.rightAppend += '${pads}';

        if (!InputManager.enabled)
            return;

        var emptySlot = InputManager.getFirstOpenPlayerSlot();

        if (emptySlot != null) {
            if (FlxG.keys.pressed.A && FlxG.keys.pressed.S && FlxG.keys.anyJustPressed([A, S]))
                if (InputManager.getPlayerSlotByInput(KeyboardInput) == null)
                    InputManager.setInputType(emptySlot, KeyboardInput);
                else {
                    var keyboardSlot = InputManager.getPlayerSlotByInput(KeyboardInput);
                    var keyboardInput = InputManager.getPlayer(keyboardSlot);
                    if (Std.isOfType(keyboardInput, MouseHandler))
                        InputManager.setInputType(keyboardSlot, KeyboardInput);
                    else
                        InputManager.setInputType(keyboardSlot, KeyboardAndMouseInput);
                }
            FlxG.gamepads.getActiveGamepads().filter(p -> {
                if (!p.anyJustPressed([A]))
                    return false;
                InputManager.tryToAddPlayerFromInputDevice(p);
                return true;
            });
        }
    }
}
