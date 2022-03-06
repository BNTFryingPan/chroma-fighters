package match.stage;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import match.StageGround;
import match.stage.AbstractStage;

// class WebComicStageGround extends StageGround {}
class WebComicStage extends AbstractStage {
   private var background:FlxSprite;

   public function new(?opts:Map<String, String>) {
      super(opts);
      var asset_background = AssetHelper.getImageAsset(new NamespacedKey('cf_chroma_fracture_stage', 'background'));
      this.mainGround = new StageGround(50, new NamespacedKey('cf_chroma_fracture_stage', 'ground'));
      // this.mainGround.loadGraphic(asset_ground);
      this.background = new FlxSprite();
      this.background.loadGraphic(asset_background);
      this.background.scrollFactor = FlxPoint.get(0.1, 0.1);
      this.afterNew();
   }

   override public function draw() {
      this.background.draw();
      super.draw();
   }
}
