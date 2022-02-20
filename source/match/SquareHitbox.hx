package match;

import inputManager.Position;

// class SquareAttackHitbox extends AttackHitbox
class SquareHitbox extends AbstractHitbox {
   public var width:Float;
   public var height:Float;

   public function new(x:Float, y:Float, width:Float, height:Float) {
      super(x, y);
      this.width = width;
      this.height = height;
   }

   public function intersectsPoint(pos:Position):Bool {
      if (!(this.x <= pos.x && (this.x + this.width) >= pos.x))
         return false;

      return this.y <= pos.y && (this.y + this.height) >= pos.y;
   }
}
