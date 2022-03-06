package match.stage;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import match.MatchObject;

typedef Blastzone = {
   public var topBlastzone:Int; // the distance above `MainGround.groundHeight` the top blastzone is
   public var bottomBlastzone:Int; // the distance below `MainGround.groundHeight` the bottom blastzone is
   public var sideBlastzone:Int; // the distance between the center of the stage and the side blastzones
}

interface IStage extends IMatchObject {
   public var mainGround:StageGround;
   public var blastzone:Blastzone;
}

abstract class AbstractStage extends MatchObject implements IStage {
   // public var groundType = GroundType.SOLID_GROUND;
   public var mainGround:StageGround;
   public var blastzone:Blastzone = {topBlastzone: 500, bottomBlastzone: 200, sideBlastzone: 500};

   public final options:Map<String, String>;

   // public static final STAGE_KEYS:M = []

   public function new(?opts:Map<String, String>) {
      super();
      this.options = opts;
   }

   public function afterNew() {
      FlxG.worldBounds.set(this.blastzone.sideBlastzone * -1, this.blastzone.topBlastzone * -1, this.blastzone.sideBlastzone * 2,
         this.blastzone.topBlastzone + this.blastzone.bottomBlastzone);
   }

   public static function load(key:NamespacedKey, ?opts:Map<String, String>):AbstractStage {
      key.parseSpecialNamespaces();
      if (key.namespace == NamespacedKey.DEFAULT_NAMESPACE) {
         return cast switch (key.key) {
            // case 'chroma_fracture':
            default:
               new WebComicStage(opts);
               // default:
               // new DebugStage(opts);
         }
      }
      return new ScriptedStage(key, opts);
   }

   override public function draw() {
      super.draw();
      this.mainGround.draw();
   }

   override public function reloadTextures() {
      this.mainGround.reloadTextures();
   }
}
