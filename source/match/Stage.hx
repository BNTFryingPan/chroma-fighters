package match;

import flixel.FlxBasic;

typedef StageModOption = {
    public var type:String;
    public var defaultValue:Dynamic;
    public var maxValue:Float;
    public var minValue:Float;
    public var step:Float;
}

typedef StageModJson = {
    public var author:String;
    public var type:String;
    public var version:String;
    public var description:String;
    public var name:String;
    public var id:String;
    public var tags:Array<String>;
    public var options:Map<String, StageModOption>;
    public var script:String;
    public var include:Map<String, String>;
    public var isInBaseGame:Bool;
}

class MainGround {
    public var sprite:FlxSprite;
    public var groundHeight:Int;
}

typedef Blastzone = {
    public var topBlastzone:Int; // the distance above `MainGround.groundHeight` the top blastzone is
    public var bottomBlastzone:Int; // the distance below `MainGround.groundHeight` the bottom blastzone is
    public var sideBlastzone:Int; // the distance between the center of the stage and the side blastzones 
}

class Stage extends MatchObject {
    public override var groundType = GroundType.SOLID_GROUND;
    public var mainGround:MainGround;
    public var blastzone:Blastzone

    public function new() {
        this.blastzone = {topBlastzone: 500, bottomBlastzone: 200, sideBlastzone: 500};
        this.mainGround = new MainGround(100)
    }

    public function load(key:NamespacedKey, opts:Map<String, String>) {
        
    }
}
