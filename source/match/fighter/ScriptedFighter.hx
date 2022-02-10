package match.fighter;

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

class ScriptedFighter extends AbstractFighter {
    public static function getScriptPathForBasegameFighter():String {
        return "";
    }

    public var modData:FighterModJson;
    private var mainScript:ModScript;
    private var extraScripts:Map<String, ModScript>;
    
    public function new(slot:PlayerSlotIdentifier, x:Float, y:Float, data:FighterModJson) {
        super(slot, x, y)
        this.modData = data;
    }

    public function loadScripts() {
        //this.mainScript = new ModScript(new NamespacedKey(this.modData.name, this.modData.script));
        //this.mainScript.shareFunctionMap(["getPercent" => this.getPercent, "getSlot" => this.getSlot]);
    }

    public function callScriptFunction(name:String, ...args:Dynamic):Void {
        //this.mainScript.callFunction(name, args.toArray());
    }

    public override function update(elapsed:Float) {
        //this.callScriptFunction("update", elapsed);
    }

    public override function draw() {
        //this.callScriptFunction("draw");
    }

    public function render_ui() {
        //this.callScriptFunction("draw_ui");
    }
}
