package match;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import inputManager.Coordinates;
import match.AbstractHitbox;
import match.Match.GroundType;
import match.MatchObject;
import openfl.display.BitmapData;

class StageGround extends FlxSprite implements IGroundObject {
   public var floorHeight:Int;
   public var groundHeight:Int;
   public var groundWidth:Int;

   public var groundType:GroundType = GroundType.SOLID_GROUND;
   public final groundAsset:Null<NamespacedKey>;

   public var hitbox:AbstractHitbox;

   public function new(floorHeight:Int, ?asset:NamespacedKey, ?groundWidth:Int, ?groundHeight:Int) {
      this.floorHeight = floorHeight;

      if (asset == null && (groundWidth == null || groundHeight == null))
         throw "No size provided";

      var bitmap:BitmapData = null;

      if (asset != null) {
         this.groundAsset = asset;
         bitmap = AssetHelper.getImageAsset(asset);
         this.groundHeight = bitmap.height;
         this.groundWidth = bitmap.width;
      } else
         this.groundAsset = null;

      if (groundWidth != null)
         this.groundWidth = groundWidth;
      if (groundHeight != null)
         this.groundHeight = groundHeight;

      var spriteX = (this.groundWidth / 2) * -1;

      this.hitbox = new SquareHitbox(spriteX, this.floorHeight, this.groundWidth, this.groundHeight);
      super(spriteX, this.floorHeight);

      if (asset != null && bitmap != null)
         this.loadGraphic(bitmap, false, bitmap.width, bitmap.height, true, asset.toString());
      else
         this.makeGraphic(this.groundWidth, this.groundHeight, FlxColor.MAGENTA);
      this.immovable = true;
   }

   public function reloadTextures() {
      if (this.groundAsset == null)
         return;
      this.loadGraphic(AssetHelper.getImageAsset(this.groundAsset));
   }
}
