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

    private static function isPressingConnectCombo(gp:FlxGamepad):Bool {
        if (gp.pressed.LEFT_SHOULDER && gp.pressed.RIGHT_SHOULDER) {
            return gp.anyJustPressed([LEFT_SHOULDER, RIGHT_SHOULDER]);
        } else if (gp.pressed.LEFT_TRIGGER && gp.pressed.RIGHT_TRIGGER) {
            return gp.anyJustPressed([LEFT_TRIGGER, RIGHT_TRIGGER]);
        }
        return false;
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        InputManager.update(elapsed);

        var pads = FlxG.gamepads.getActiveGamepads().map(p -> p.name);
        Main.debugDisplay.rightAppend += '${pads}';

        if (!InputManager.enabled)
            return;

        var emptySlot = PlayerSlot.getFirstOpenPlayerSlot();

        if (emptySlot != null) {
            if (FlxG.keys.pressed.A && FlxG.keys.pressed.S && FlxG.keys.anyJustPressed([A, S])) {
                if (PlayerSlot.getPlayerSlotByInput(KeyboardInput) == null) {
                    PlayerSlot.setInputType(emptySlot, KeyboardInput);
                } else {
                    var keyboardPlayer = PlayerSlor.getPlayerByInput(KeyboardInput);
                    if (Std.isOfType(keyboardPlayer, MouseHandler)) {
                        keyboardPlayer.setNewInput(KeyboardInput, Keyboard, keyboardPlayer.input.profile.name);
                    } else {
                        keyboardPlayer.setNewInput(KeyboardAndMouseInput, Keyboard, keyboardPlayer.input.profile.name);
                    }
                }
                return;
            }
            FlxG.gamepads.getActiveGamepads().filter(p -> {
                if (BaseState.isPressingConnectCombo(p)) {
                    InputManager.tryToAddPlayerFromInputDevice(p);
                }
                return true;
            });
        }
    }
}
