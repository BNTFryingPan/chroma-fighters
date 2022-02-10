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
class GenericInput {
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

    public function new(slot:PlayerSlotIdentifier, ?profile:String = null) {
        Main.log('creating ${this.inputType} input for slot ' + slot);
        this.slot = slot;

        if (profile == null) {
            this.profile = Profile.getProfile("", true);
        } else {
            this.profile = Profile.getProfile(profile);
        }
    }

    /**
        can be used to override the cursor position. mainly so mouse input works, but could theoretically be used for wii remote pointer or touchscreen inputs too
    **/
    public function getCursorPosition():Null<Position> {
        return null;
    }

    public function getCursorStick():StickValue {
        return this.getStick();
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

    public function getMenuButton():INPUT_STATE {
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
