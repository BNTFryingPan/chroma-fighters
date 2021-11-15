package inputManager;

import inputManager.InputManager.Action;
import inputManager.GenericInput.INPUT_STATE;
import flixel.input.gamepad.FlxGamepad;

typedef ProfileAction = OneOfTwo<FlxKey, GenericButton>;

class Profile {
    public static function getProfile(name:String) {
        // TODO : load and create the players profile
        return new Profile();
    }

    public var name:String;
    public var fileName:String;

    public var bindings:Map<Action, Array<ProfileAction> = [
        MENU_CONFIRM => [Z, FACE_A],
        MENU_CANCEL => [X, FACE_B],
        MENU_ACTION => [C, FACE_X, FACE_Y],
        MENU_LEFT => [A, LEFT_TRIGGER, LEFT_BUMPER],
        MENU_RIGHT => [S, RIGHT_TRIGGER, RIGHT_BUMPER],
        JUMP => [X, FACE_X, FACE_Y],
        SHORT_JUMP => [V, RIGHT_BUMPER],
        ATTACK => [Z, FACE_A],
        SPECIAL => [C, FACE_B],
        STRONG => [D],
        TAUNT => [F, DPAD_UP, DPAD_DOWN, DPAD_LEFT, DPAD_RIGHT],
        SHIELD => [S, LEFT_BUMPER, LEFT_TRIGGER, RIGHT_TRIGGER],
        WALK => [A]
    ];

    public function new() {

    }

    private var input:Null<GenericInput>;
    private function getOwningPlayerFromInputManager():Null<GenericInput> {
        if (this.input != null)
            return this.input;

        var owner = InputManager.getPlayerByProfileName();
        if (owner == null)
            return null;

        this.input = owner;
        return this.input;
    } 

    public function checkActionArray(list:Array<ProfileAction>):INPUT_STATE {
        if (this.getOwningPlayerFromInputManager() == null)
            return NOT_PRESSED;

        var pressed:Array<INPUT_STATE>;

        if (Std.isOfType(this.input, KeyboardHandler))
            pressed = list.map(action -> {
                if (Std.isOfType(action, GenericButton))
                    return NOT_PRESSED;
                
                var key:FlxKey = cast action;
                return InputHelper.getFromFlixel(FlxG.keys.justPressed[key], FlxG.keys.justReleased[key], FlxG.keys.pressed[key]);
            })
        else if (Std.isOfType(this.input, GenericControler))
            pressed = list.map(action -> {
                if (Std.isOfType(action, FlxKey))
                    return NOT_PRESSED;

                var button:GenericButton = cast action;
                return this.input.getButtonState(button);
            })
    }

    public function getAction(action:Action, gamepad:FlxGamepad):INPUT_STATE {
        return switch (action) {
            case MENU_CONFIRM
        }
    }
}