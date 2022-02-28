package match;

import GameManager.ScreenSprite;
import inputManager.Position;
import match.AbstractHitbox.IHitbox;

class SquareHitbox extends AbstractHitbox {
   public var width:Float;
   public var height:Float;

   public function new(x:Float, y:Float, width:Float, height:Float) {
      super(x, y);
      this.width = width;
      this.height = height;
   }

   public function getCenterPosition():Position {
      return {x: this.x + (this.width / 2), y: this.y + (this.height / 2)}
   }

   public function intersectsPoint(pos:Position):Bool {
      if (!(this.x <= pos.x && (this.x + this.width) >= pos.x))
         return false;

      return this.y <= pos.y && (this.y + this.height) >= pos.y;
   }

   public function draw() {
      ScreenSprite.rect({x: this.x, y: this.y}, {x: this.x + this.width, y: this.y + this.height});
   }

   public function intersectsHitbox(box:IHitbox):Bool {
      var close = box.getPointClosestToInside(this.getCenterPosition());
      return this.intersectsPoint(close);
   }

   private function c(min:Float, max:Float, val:Float) {
      return Math.min(Math.max(min, val), max);
   }

   public function getPointClosestToInside(pos:Position):Position {
      ScreenSprite.line({x: c(this.x, this.x + this.width, pos.x), y: c(this.y, this.y + this.height, pos.y)}, pos);
      return {x: c(this.x, this.x + this.width, pos.x), y: c(this.y, this.y + this.height, pos.y)}
   }
}
