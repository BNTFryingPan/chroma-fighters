package match;

typedef FighterModJson = {
    public var author:String;
    public var type:String;
    public var version:String;
    public var description:String;
    public var name:String;
    public var id:String;
    public var tags:Array<String>;
    public var options:Map<String, Dynamic>;
    public var primaryOption:String;
    public var secondaryOption:String;
    public var altRenderer:String;
    public var scripts:Map<String, String>;
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

enum abstract FighterScripts(FighterScriptError) to FighterScriptError {
    var SCRIPT_NOT_FOUND = {name: "Script Not Found", desc: "A script with the specified key could not be found. Check the fighter's `info.json`!"}
}

class Fighter extends FlxBasic {
    public static function getScriptPathForBasegameFighter()

    public var modData:FighterModJson;

    public function new(data:FighterModJson, slot:PlayerSlotIdentifier, x:Float, y:Float) {
        super();
        this.modData = data;
    }

    public function callScript(key:String, data:Map<String, Dynamic>):Dynamic {
        if (!this.modData.scripts.exists(key)) {
            return SCRIPT_NOT_FOUND;
        }

        
    }

    public function tick(elasped:Float, input:GenericInput) {

    }
}