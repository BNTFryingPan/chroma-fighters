package match;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.util.FlxColor;

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

class MainGround extends FlxSprite {
   public var groundHeight:Int;

   public function new(groundH:Int) {
      super(100, groundH);
      this.groundHeight = groundH;
      this.makeGraphic(50, 25, FlxColor.MAGENTA);
   }
}

typedef Blastzone = {
   public var topBlastzone:Int; // the distance above `MainGround.groundHeight` the top blastzone is
   public var bottomBlastzone:Int; // the distance below `MainGround.groundHeight` the bottom blastzone is
   public var sideBlastzone:Int; // the distance between the center of the stage and the side blastzones
}

class Stage extends MatchObject {
   // public var groundType = GroundType.SOLID_GROUND;
   public var mainGround:MainGround;
   public var blastzone:Blastzone;

   public function new() {
      super();
      this.blastzone = {topBlastzone: 500, bottomBlastzone: 200, sideBlastzone: 500};
      this.mainGround = new MainGround(100);
   }

   public function load(key:NamespacedKey, opts:Map<String, String>) {}

   override public function draw() {
      this.mainGround.draw();
   }
}
