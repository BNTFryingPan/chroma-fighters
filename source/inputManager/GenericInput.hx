package inputManager;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import inputManager.InputEnums;
import inputManager.InputHelper;
import inputManager.InputTypes;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;

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

    public var slot:PlayerSlotIdentifier;
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

        // Main.log('creating ${this.inputType} input for slot ' + slot);
        this.slot = slot;

        this.coinSprite = new FlxSprite();
        // this.coinSprite.loadGraphic()
        this.cursorSprite = new FlxSprite();
        this.cursorSprite.loadGraphic(this.applySlotColorFilter(AssetHelper.getImageAsset(GenericInput.PointerRightKey)), false, 32, 32);

        this.debugSprite = new FlxSprite();
        this.debugSprite.makeGraphic(3, 3, FlxColor.MAGENTA);

        this.setCursorAngle(RIGHT);

        this.cursor = {x: 0, y: 0};
        // this.inputEnabled = true;

        if (profile == null) {
            this.profile = Profile.getProfile("", true);
        } else {
            this.profile = Profile.getProfile(profile);
        }
    }

    public static var PointerCoinKey:NamespacedKey = NamespacedKey.ofDefaultNamespace("images/cursor/coin");
    public static var PointerLeftKey:NamespacedKey = NamespacedKey.ofDefaultNamespace("images/cursor/pointer_left");
    public static var PointerRightKey:NamespacedKey = NamespacedKey.ofDefaultNamespace("images/cursor/pointer_right");
    public static var PointerUpLeftKey:NamespacedKey = NamespacedKey.ofDefaultNamespace("images/cursor/pointer_up_left");
    public static var PointerUpRightKey:NamespacedKey = NamespacedKey.ofDefaultNamespace("images/cursor/pointer_up_right");
    public static var PointerDownLeftKey:NamespacedKey = NamespacedKey.ofDefaultNamespace("images/cursor/pointer_down_left");
    public static var PointerDownRightKey:NamespacedKey = NamespacedKey.ofDefaultNamespace("images/cursor/pointer_down_right");

    public function setCursorAngle(angle:CursorRotation) {
        if (angle == LEFT) {
            this.cursorSprite.loadGraphic(this.applySlotColorFilter(AssetHelper.getImageAsset(GenericInput.PointerLeftKey)));
        } else if (angle == RIGHT) {
            this.cursorSprite.loadGraphic(this.applySlotColorFilter(AssetHelper.getImageAsset(GenericInput.PointerRightKey)));
        } else if (angle == UP_LEFT) {
            this.cursorSprite.loadGraphic(this.applySlotColorFilter(AssetHelper.getImageAsset(GenericInput.PointerUpLeftKey)));
        } else if (angle == UP_RIGHT) {
            this.cursorSprite.loadGraphic(this.applySlotColorFilter(AssetHelper.getImageAsset(GenericInput.PointerUpRightKey)));
        } else if (angle == DOWN_LEFT) {
            this.cursorSprite.loadGraphic(this.applySlotColorFilter(AssetHelper.getImageAsset(GenericInput.PointerDownLeftKey)));
        } else if (angle == DOWN_RIGHT) {
            this.cursorSprite.loadGraphic(this.applySlotColorFilter(AssetHelper.getImageAsset(GenericInput.PointerDownRightKey)));
        }

        this.spriteOffset = GenericInput.getOffset(angle);
    }

    public function getCursorStick():StickValue {
        return this.getStick();
    }

    public function applySlotColorFilter(bitmap:BitmapData):BitmapData {
        return bitmap;
        var slotColor = PlayerSlot.defaultPlayerColors[this.slot];
        var transform = new ColorTransform(slotColor.red, slotColor.green, slotColor.blue, 1.0, 0, 0, 0, 0);
        bitmap.colorTransform(new Rectangle(0, 0, bitmap.width, bitmap.height), transform);
        return bitmap;
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
            Main.debugDisplay.leftAppend += '\n[P${this.slot + 1}] {${this.inputType}}\nCursor: (${cursorPos.x}, ${cursorPos.y}) from ${this.getCursorStick()}\nStick: ${this.getStick()}\nButtons: con ${this.getConfirm()} can ${this.getCancel()} act ${this.getMenuAction()} left ${this.getMenuLeft()} right ${this.getMenuRight()}\n';
        } else {
            Main.debugDisplay.leftAppend += '\n[P${this.slot + 1}] {${this.inputType}} ----DISABLED----';
        }
    }

    override function draw() {
        if (!this.inputEnabled)
            return;
        super.draw();
        this.cursorSprite.draw();
        // this.coinSprite.draw();

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
