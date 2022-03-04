package match;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import match.AbstractHitbox;
import match.MatchObject;

class StageGround extends FlxSprite implements IMatchObjectWithHitbox {
   public var floorHeight:Int;
   public var groundHeight:Int;
   public var groundWidth:Int;

   public var hitbox:AbstractHitbox;

   public function new(floorHeight:Int, groundHeight:Int, groundWidth:Int) {
      this.floorHeight = floorHeight;
      this.groundHeight = groundHeight;
      this.groundWidth = groundWidth;

      var spriteX = (this.groundWidth / 2) * -1;

      this.hitbox = new SquareHitbox(spriteX, this.floorHeight, this.groundWidth, this.groundHeight);
      super(spriteX, this.floorHeight);

      this.makeGraphic(this.groundWidth, this.groundHeight, FlxColor.MAGENTA);
      this.immovable = true;
   }

   public function reloadTextures() {}
}
