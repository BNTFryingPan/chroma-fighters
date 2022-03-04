package match.stage;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class MainGround extends FlxSprite {
   public var groundHeight:Int;

   public function new(groundH:Int) {
      super((250 / 2) * -1, groundH);
      this.groundHeight = groundH;
      this.makeGraphic(250, 50, FlxColor.MAGENTA);
      this.immovable = true;
   }
}

typedef Blastzone = {
   public var topBlastzone:Int; // the distance above `MainGround.groundHeight` the top blastzone is
   public var bottomBlastzone:Int; // the distance below `MainGround.groundHeight` the bottom blastzone is
   public var sideBlastzone:Int; // the distance between the center of the stage and the side blastzones
}

interface IStage extends IMatchObject {

}

class Stage extends MatchObject implements IStage {
   // public var groundType = GroundType.SOLID_GROUND;
   public var mainGround:MainGround;
   public var blastzone:Blastzone;

   public function new() {
      super();
      this.blastzone = {topBlastzone: 500, bottomBlastzone: 200, sideBlastzone: 500};
      this.mainGround = new MainGround(0);
      FlxG.worldBounds.set(this.blastzone.sideBlastzone * -1, this.blastzone.topBlastzone * -1, this.blastzone.sideBlastzone * 2,
         this.blastzone.topBlastzone + this.blastzone.bottomBlastzone);
   }

   public function load(key:NamespacedKey, opts:Map<String, String>) {}

   override public function draw() {
      this.mainGround.draw();
   }
}
