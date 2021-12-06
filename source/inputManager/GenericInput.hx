package inputManager;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

typedef Position = {
    var x:Int;
    var y:Int;
}

enum INPUT_STATE {
    JUST_PRESSED;
    JUST_RELEASED;
    PRESSED;
    NOT_PRESSED;
}

typedef StickValue = {
    public var x:Float;
    public var y:Float;
}

class InputHelper {
    static public function isPressed(state:INPUT_STATE) {
        if (state == JUST_PRESSED) {
            return true;
        }
        return state == PRESSED;
    }

    static public function isNotPressed(state:INPUT_STATE) {
        if (state == JUST_RELEASED) {
            return true;
        }
        return state == NOT_PRESSED;
    }

    static public function justChanged(state:INPUT_STATE) {
        if (state == JUST_PRESSED) {
            return true;
        }
        return state == JUST_RELEASED;
    }

    static public function notChanged(state:INPUT_STATE) {
        if (state == PRESSED) {
            return true;
        }
        return state == NOT_PRESSED;
    }

    static public function getFromFlixel(justPressed:Bool, justReleased:Bool, pressed:Bool) {
        if (justPressed)
            return JUST_PRESSED;
        if (justReleased)
            return JUST_RELEASED;
        if (pressed)
            return PRESSED;
        return NOT_PRESSED;
    }

    static public function getFromFlxInput(input:FlxInput<Int>) {
        if (input.justPressed)
            return JUST_PRESSED;
        if (input.justReleased)
            return JUST_RELEASED;
        if (input.pressed)
            return PRESSED;
        return NOT_PRESSED;
    }

    @:access(flixel.input.FlxKeyManager)
    static public function getFromFlxKey(key:FlxKey) {
        return InputHelper.getFromFlxInput(FlxG.keys.getKey(key));
    }

    static public function or(...inputs:INPUT_STATE) {
        if (inputs.length == 0) {
            return NOT_PRESSED;
        }

        var asArray = inputs.toArray();

        if (asArray.contains(PRESSED))
            return PRESSED;

        if (asArray.contains(JUST_PRESSED)) {
            if (asArray.contains(JUST_RELEASED))
                return PRESSED;
            return JUST_PRESSED;
        }

        if (asArray.contains(JUST_RELEASED))
            return JUST_RELEASED;

        return NOT_PRESSED;
    }

    static public function asInt(state:INPUT_STATE):Int {
        return InputHelper.isPressed(state) ? 1 : 0;
    }
    /*
        static public function badUnitTest():Bool {
            Main.log('NOT_PRESSED   + NOT_PRESSED  : ${or(NOT_PRESSED, NOT_PRESSED)}');
            Main.log('NOT_PRESSED   + JUST_PRESSED : ${or(NOT_PRESSED, JUST_PRESSED)}');
            Main.log('NOT_PRESSED   + PRESSED      : ${or(NOT_PRESSED, PRESSED)}');
            Main.log('NOT_PRESSED   + JUST_RELEASED: ${or(NOT_PRESSED, JUST_RELEASED)}');
            Main.log('JUST_PRESSED  + NOT_PRESSED  : ${or(JUST_PRESSED, NOT_PRESSED)}');
            Main.log('JUST_PRESSED  + JUST_PRESSED : ${or(JUST_PRESSED, JUST_PRESSED)}');
            Main.log('JUST_PRESSED  + PRESSED      : ${or(JUST_PRESSED, PRESSED)}');
            Main.log('JUST_PRESSED  + JUST_RELEASED: ${or(JUST_PRESSED, JUST_RELEASED)}');
            Main.log('PRESSED       + NOT_PRESSED  : ${or(PRESSED, NOT_PRESSED)}');
            Main.log('PRESSED       + JUST_PRESSED :  ${or(PRESSED, JUST_PRESSED)}');
            Main.log('PRESSED       + PRESSED      : ${or(PRESSED, PRESSED)}');
            Main.log('PRESSED       + JUST_RELEASED: ${or(PRESSED, JUST_RELEASED)}');
            Main.log('JUST_RELEASED + NOT_PRESSED  : ${or(JUST_RELEASED, NOT_PRESSED)}');
            Main.log('JUST_RELEASED + JUST_PRESSED : ${or(JUST_RELEASED, JUST_PRESSED)}');
            Main.log('JUST_RELEASED + PRESSED      : ${or(JUST_RELEASED, PRESSED)}');
            Main.log('JUST_RELEASED + JUST_RELEASED: ${or(JUST_RELEASED, JUST_RELEASED)}');
            return true;
        }

        static public var a = badUnitTest();
     */
}

enum CursorRotation {
    LEFT;
    RIGHT;
    UP_LEFT;
    UP_RIGHT;
    DOWN_LEFT;
    DOWN_RIGHT;
}

/**
    A basic input handler, used as a base for all other input types.

    this handler always returns false for any input checks, and reports the cursor position as (0, 0)
**/
class GenericInput extends FlxBasic {
    public var cursorSprite:FlxSprite;
    public var coinSprite:FlxSprite;
    public var debugSprite:FlxSprite;
    public var cursor:Position = {x: Math.round(FlxG.width / 2), y: Math.round(FlxG.height / 2)};
    public var cursorAngle:CursorRotation = RIGHT;
    public var spriteOffset:Position = {x: 0, y: 0};
    public var isvisible:Bool = true;

    public var inputEnabled(get, default):Bool = false;

    public var inputType(get, never):String;

    public function get_inputEnabled() {
        return false;
    }

    public function get_inputType() {
        return "Generic";
    }

    public final slot:PlayerSlotIdentifier;
    public var profile:Profile;

    public static function getOffset(angle:CursorRotation):Position {
        if (angle == LEFT) {
            return {x: 30, y: 15};
        } else if (angle == RIGHT) {
            return {x: 30, y: 15};
        } else if (angle == UP_LEFT) {
            return {x: 30, y: 15};
        } else if (angle == UP_RIGHT) {
            return {x: 27, y: 0};
        } else if (angle == DOWN_LEFT) {
            return {x: 30, y: 15};
        } else if (angle == DOWN_RIGHT) {
            return {x: 30, y: 15};
        }

        return {x: 30, y: 15};
    }

    public function new(slot:PlayerSlotIdentifier, ?profile:String) {
        super();

        Main.log('creating ${this.inputType} input for slot ' + slot);

        this.coinSprite = new FlxSprite();
        Main.log('loading graphic');
        this.coinSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/coin")));
        Main.log('loaded graphic');
        this.cursorSprite = new FlxSprite();

        this.debugSprite = new FlxSprite();
        this.debugSprite.makeGraphic(3, 3, FlxColor.MAGENTA);

        this.setCursorAngle(RIGHT);

        this.cursor = {x: 0, y: 0};
        // this.inputEnabled = true;

        this.slot = slot;

        if (profile == null) {
            this.profile = Profile.getProfile("", true);
        } else {
            this.profile = Profile.getProfile(profile);
        }
    }

    public function setCursorAngle(angle:CursorRotation) {
        if (angle == LEFT) {
            this.cursorSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_left")));
        } else if (angle == RIGHT) {
            this.cursorSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_right")));
        } else if (angle == UP_LEFT) {
            this.cursorSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_up_left")));
        } else if (angle == UP_RIGHT) {
            this.cursorSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_up_right")));
        } else if (angle == DOWN_LEFT) {
            this.cursorSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_down_left")));
        } else if (angle == DOWN_RIGHT) {
            this.cursorSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_down_right")));
        }

        this.spriteOffset = GenericInput.getOffset(angle);
    }

    public function getCursorStick():StickValue {
        return this.getStick();
    }

    function updateCursorPos(elapsed:Float) {
        var stick = getCursorStick();

        this.cursor.x += Math.round(stick.x * 500 * elapsed);
        this.cursor.y += Math.round(stick.y * 500 * elapsed);

        this.cursor.x = Std.int(Math.min(this.cursor.x, FlxG.width));
        this.cursor.x = Std.int(Math.max(this.cursor.x, 0));
        this.cursor.y = Std.int(Math.min(this.cursor.y, FlxG.height));
        this.cursor.y = Std.int(Math.max(this.cursor.y, 0));
    }

    override function update(elapsed:Float) {
        this.updateCursorPos(elapsed);
        var cursorPos = this.getCursorPosition();

        this.cursorSprite.x = cursorPos.x - this.spriteOffset.x;
        this.cursorSprite.y = cursorPos.y - this.spriteOffset.y;

        this.debugSprite.x = cursorPos.x;
        this.debugSprite.y = cursorPos.y;

        super.update(elapsed);

        if (this.inputEnabled) {
            for (mem in FlxG.state.members) {
                if (Std.isOfType(mem, CustomButton)) {
                    var button:CustomButton = cast mem;
                    if (button.overlapsPoint(FlxPoint.get(cursorPos.x, cursorPos.y))) {
                        button.overHandler(this.slot);
                        if (InputHelper.isPressed(this.getConfirm()))
                            button.downHandler(this.slot);
                        else
                            button.upHandler(this.slot);
                    } else
                        button.outHandler(this.slot);
                }
            }
        }

        // if (this.isvisible)
        if (this.inputEnabled)
            Main.debugDisplay.leftAppend += '\n[P${this.slot + 1}] {${this.inputType}}\nCursor: (${this.cursor.x}, ${this.cursor.y}) from ${this.getCursorStick()}\nStick: ${this.getStick()}\nButtons: con ${this.getConfirm()} can ${this.getCancel()} act ${this.getMenuAction()} left ${this.getMenuLeft()} right ${this.getMenuRight()}\n';
        else
            Main.debugDisplay.leftAppend += '\n[P${this.slot + 1}] {${this.inputType}} ----DISABLED----';
    }

    override function draw() {
        if (!this.inputEnabled)
            return;
        super.draw();
        this.cursorSprite.draw();

        this.debugSprite.draw();
    }

    /**
        returns the screen position where the cursor should be drawn and the "click point"
    **/
    public function getCursorPosition():Position {
        return this.cursor;
    }

    public function getConfirm():INPUT_STATE {
        return NOT_PRESSED;
    }

    public function getCancel():INPUT_STATE {
        return NOT_PRESSED;
    }

    public function getMenuAction():INPUT_STATE {
        return NOT_PRESSED;
    }

    public function getMenuLeft():INPUT_STATE {
        return NOT_PRESSED;
    }

    public function getMenuRight():INPUT_STATE {
        return NOT_PRESSED;
    }

    public function getAttack():INPUT_STATE {
        return NOT_PRESSED;
    }

    public function getJump():INPUT_STATE {
        return NOT_PRESSED;
    }

    public function getSpecial():INPUT_STATE {
        return NOT_PRESSED;
    }

    public function getStrong():INPUT_STATE {
        return NOT_PRESSED;
    }

    public function getShield():INPUT_STATE {
        return NOT_PRESSED;
    }

    public function getDodge():INPUT_STATE {
        return NOT_PRESSED;
    }

    public function getWalk():INPUT_STATE {
        return NOT_PRESSED;
    }

    public function getTaunt():INPUT_STATE {
        return NOT_PRESSED;
    }

    public function getQuit():INPUT_STATE {
        return NOT_PRESSED;
    }

    public function getPause():INPUT_STATE {
        return NOT_PRESSED;
    }

    public function getUp():Float {
        return 0;
    }

    public function getDown():Float {
        return 0;
    }

    public function getLeft():Float {
        return 0;
    }

    public function getRight():Float {
        return 0;
    }

    /*
        public function getStick():StickVector {
            return new StickVector(0, 0);
        }

        public function getDirection():StickVector {
            return new StickVector(0, 0);
        }

        public function getRawDirection():StickVector {
            return new StickVector(0, 0);
    }*/
    public function getStick():StickValue {
        return {x: 0, y: 0};
    }

    public function getDirection():StickValue {
        return {x: 0, y: 0};
    }

    public function getRawDirection():StickValue {
        return {x: 0, y: 0};
    }
}
