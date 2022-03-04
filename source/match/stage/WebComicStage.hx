package match.stage;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import match.StageGround;
import match.stage.AbstractStage;

class WebComicStage extends AbstractStage {
   private var background:FlxSprite;

   public function new(?opts:Map<String, String>) {
      super(opts);
      this.mainGround = new StageGround(50, 112, 528);
      this.mainGround.loadGraphic(AssetHelper.getImageAsset(new NamespacedKey('cf_chroma_fracture_stage', 'ground')));
      this.background = new FlxSprite();
      this.background.loadGraphic(AssetHelper.getImageAsset(new NamespacedKey('cf_chroma_fracture_stage', 'background')));
      this.background.scrollFactor = FlxPoint.get(0.1, 0.1);
      this.afterNew();
   }

   override public function draw() {
      this.background.draw();
      super.draw();
   }
}
