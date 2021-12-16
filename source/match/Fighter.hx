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

//enum abstract FighterScriptsErrors(FighterScriptError) to FighterScriptError {
//    var SCRIPT_NOT_FOUND = {name: "Script Not Found", desc: "A script with the specified key could not be found. Check the fighter's `info.json`!"}
//}

enum FighterAirState {
    GROUNDED; // is literally on the ground
    FULL_CONTROL; // can do any aerial action
    NO_JUMPS; // can do any moves, but cant jump
    PRATFALL; // cant do any actions
    DODGE_PRATFALL; // short pratfall after an air dodge, becomes NO_JUMPS
    SPECIAL_FALL; // like pratfall, but can still do some special moves if the fighter allows it
}

class Fighter extends FlxBasic {
    public static function getScriptPathForBasegameFighter():String {
        return "";
    }

    public var modData:FighterModJson;
    public var percent:Float;
    public var airState:FighterAirState = GROUNDED;
    public var scriptVariables:Map<String, Dynamic>;

    private var mainScript:Expr;
    private var extraScripts:Array<Expr>;

    public function new(data:FighterModJson, slot:PlayerSlotIdentifier, x:Float, y:Float) {
        super();
        this.modData = data;
    }

    public function loadScripts() {
        this.mainScript = AssetHelper.getScriptAsset(this.modData.script);
    }

    public function tick(elasped:Float, input:GenericInput) {
        super.update(elapsed);

        this.callScript("update", ["input" => input])
    }

    public function render(input:GenericInput) {
        super.draw();

        this.callScript("draw", ["input" => input])
    }

    public function render_ui(input:GenericInput) {
        this.callScript("draw_ui", ["input" => input])
    }
}