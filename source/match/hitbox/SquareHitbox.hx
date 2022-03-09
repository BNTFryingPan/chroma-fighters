package match.hitbox;

import GameManager.ScreenSprite;
import inputManager.Coordinates;
import match.hitbox.AbstractHitbox;

class SquareHitbox extends AbstractHitbox {
   public var width:Float;
   public var height:Float;

   public function new(x:Float, y:Float, width:Float, height:Float) {
      super(x, y);
      this.width = width;
      this.height = height;
   }

   public function getCenterPosition(?use:Coordinates):Coordinates {
      if (use == null)
         use = Coordinates.get();
      return use.set(this.x + (this.width / 2), this.y + (this.height / 2));
   }

   public function intersectsPoint(x:Float, y:Float):Bool {
      if (!(this.x <= x && (this.x + this.width) >= x))
         return false;

      return this.y <= y && (this.y + this.height) >= y;
   }

   public function draw() {
      ScreenSprite.rect(Coordinates.weak(this.x, this.y), Coordinates.weak(this.x + this.width, this.y + this.height));
   }

   override public function intersectsHitbox(box:IHitbox):Bool {
      var center = this.getCenterPosition();
      var close = box.getPointClosestToInside(center.x, center.y, center);
      var ret = this.intersectsPoint(close.x, close.y);
      close.put();
      return ret;
   }

   private function c(min:Float, max:Float, val:Float) {
      return Math.min(Math.max(min, val), max);
   }

   public function getPointClosestToInside(x:Float, y:Float, ?use:Coordinates):Coordinates {
      if (use == null)
         use = Coordinates.get();
      // ScreenSprite.line({x: c(this.x, this.x + this.width, pos.x), y: c(this.y, this.y + this.height, pos.y)}, pos);
      return use.set(c(this.x, this.x + this.width, x), c(this.y, this.y + this.height, y));
   }
}
