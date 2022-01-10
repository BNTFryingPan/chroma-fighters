package;

import flixel.FlxBasic;
import flixel.FlxG;
import inputManager.InputEnums;
import inputManager.InputHelper;
import inputManager.InputManager;
import inputManager.MouseHandler;

class GameManager {
    public static function update(elapsed:Float) {
        PlayerSlot.updateAll(elapsed);

        // var pads = FlxG.gamepads.getActiveGamepads().map(p -> p.name);
        // Main.debugDisplay.rightAppend += '${pads}';

        if (InputManager.enabled) {
            var emptySlot = PlayerSlot.getFirstOpenPlayerSlot();

            if (emptySlot != null) {
                if (FlxG.keys.pressed.A && FlxG.keys.pressed.S && FlxG.keys.anyJustPressed([A, S])) {
                    if (PlayerSlot.getPlayerSlotByInput(KeyboardInput) == null) {
                        PlayerSlot.getPlayer(emptySlot).setNewInput(KeyboardInput, Keyboard);
                    } else if (!Main.skipKeyboardModeToggleCheckNextUpdate) {
                        var keyboardPlayer = PlayerSlot.getPlayerByInput(KeyboardInput);
                        if (Std.isOfType(keyboardPlayer.input, MouseHandler)) {
                            keyboardPlayer.setNewInput(KeyboardInput, Keyboard, keyboardPlayer.input.profile.name);
                        } else {
                            keyboardPlayer.setNewInput(KeyboardAndMouseInput, Keyboard, keyboardPlayer.input.profile.name);
                        }
                    }
                }
                FlxG.gamepads.getActiveGamepads().filter(p -> {
                    if (InputHelper.isPressingConnectCombo(p)) {
                        PlayerSlot.tryToAddPlayerFromInputDevice(p);
                    }
                    return true;
                });

                Main.skipKeyboardModeToggleCheckNextUpdate = false;
            }
        }

        Main.debugDisplay.update(elapsed);
    }

    public static function draw() {
        PlayerSlot.drawAll();
        Main.debugDisplay.draw();
    }

    public static function getAllObjects():Array<FlxBasic> {
        var ret = [];

        for (fb in FlxG.state.members) {
            ret.push(fb);
        }

        for (player in PlayerSlot.getPlayerArray()) {
            ret.push(player.playerBox.background);
            ret.push(player.playerBox.labelText);
            ret.push(player.playerBox.inputTypeText);
            ret.push(player.playerBox.swapButton);
            ret.push(player.playerBox.disconnectButton);
        }

        return ret;
    }
}
