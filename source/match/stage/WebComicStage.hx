package match.stage;

import match.stage.AbstractStage;
import match.StageGround;

class WebComicStage extends AbstractStage {
   private var background:FlxSprite;

   public function new(?opts:Map<String, String>) {
      super(opts);
      this.mainGround = new StageGround(-50);
      this.mainGround.loadGraphic(AssetHelper.getImageAsset(new NamespacedKey('cf_chroma_fracture_stage', 'platform')));
      this.background = new FlxSprite();
      this.background.loadGraphic(AssetHelper.getImageAsset(new NamespacedKey('cf_chroma_fracture_stage', 'background')));
      this.background.scrollFactor = FlxPoint.get(0.1, 0.1);
      this.afterNew();
   }
}