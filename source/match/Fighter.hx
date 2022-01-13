package match;

import AssetHelper;
import PlayerSlot;
import flixel.FlxBasic;

typedef FighterModOption = {
    public var type:String;
    public var defaultValue:Dynamic;
    public var maxValue:Float;
    public var minValue:Float;
    public var step:Float;
}

typedef FighterModJson = {
    public var author:String;
    public var type:String;
    public var version:String;
    public var description:String;
    public var name:String;
    public var id:String;
    public var tags:Array<String>;
    public var options:Map<String, FighterModOption>;
    public var primaryOption:String;
    public var secondaryOption:String;
    public var script:String;
    public var include:Map<String, String>;
    public var isInBaseGame:Bool;
}

typedef Position = {
    public var x:Float;
    public var y:Float;
}

typedef FighterScriptError = {
    public var name:String;
    public var desc:String;
}

// enum abstract FighterScriptsErrors(FighterScriptError) to FighterScriptError {
//    var SCRIPT_NOT_FOUND = {name: "Script Not Found", desc: "A script with the specified key could not be found. Check the fighter's `info.json`!"}
// }

enum FighterAirState {
    GROUNDED; // is literally on the ground
    FULL_CONTROL; // can do any aerial action
    NO_JUMPS; // can do any moves, but cant jump
    PRATFALL; // cant do any actions
    DODGE_PRATFALL; // short pratfall after an air dodge, becomes NO_JUMPS
    SPECIAL_FALL; // like pratfall, but can still do some special moves if the fighter allows it
}

class Fighter {
    public static function getScriptPathForBasegameFighter():String {
        return "";
    }

    public var modData:FighterModJson;
    public var percent:Float;
    public var airState:FighterAirState = GROUNDED;

    public var x:Float;
    public var y:Float;

    private var mainScript:ModScript;
    private var extraScripts:Map<String, ModScript>;
    private var slot:PlayerSlotIdentifier;
    private var recentMoves:Array<String> = ["", "", "", "", "", "", "", "", "", ""];

    public static var recentStaleModifier:Map<Int, Float> = [
        0 => 0.1, 1 => 0.2, 2 => 0.3, 3 => 0.4, 4 => 0.45, 5 => 0.5, 6 => 0.55, 7 => 0.6, 8 => 0.65, 9 => 0.7
    ];

    public function new(data:FighterModJson, slot:PlayerSlotIdentifier, x:Float, y:Float) {
        this.modData = data;
        this.slot = slot;
        this.x = x;
        this.y = y;
    }

    public function loadScripts() {
        this.mainScript = new ModScript(new NamespacedKey(this.modData.name, this.modData.script));
        this.mainScript.shareFunctionMap(["getPercent" => this.getPercent, "getSlot" => this.getSlot]);
    }

    public function callScriptFunction(name:String, ...args:Dynamic):Void {
        this.mainScript.callFunction(name, args.toArray());
    }

    public function update(elapsed:Float) {
        this.callScriptFunction("update", elapsed);
    }

    public function draw() {
        this.callScriptFunction("draw");
    }

    public function render_ui() {
        this.callScriptFunction("draw_ui");
    }

    public function getPercent(a:String):Float {
        return this.percent;
    }

    public function getSlot(a:String):Int {
        return cast this.slot;
    }

    public function stale(id:String) {
        this.recentMoves.pop();
        this.recentMoves.unshift(id);
    }

    public function getHeldItem():Null<HoldableItem> {
        return null;
    }

    public function launch(angle:Float = 50, knockback:Float = 1.0) {}
}
