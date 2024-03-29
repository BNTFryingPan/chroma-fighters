package match.hitbox;

import inputManager.Coordinates;
import match.hitbox.AbstractHitbox;

typedef CompoundHitbox = TypedCompoundHitbox<AbstractHitbox>;

class TypedCompoundHitbox<T:AbstractHitbox> extends AbstractHitbox {
   public var limit:Int;
   public final parts:Array<T> = [];

   public function new(x:Float, y:Float, ?limit:Int = -1) {
      super(x, y);
      this.limit = limit;
   }

   public function add(hitbox:T):Bool {
      if (this.limit >= 0 && parts.length >= this.limit)
         return false;
      this.parts.push(hitbox);
      return true;
   }

   public function intersectsPoint(x:Float, y:Float):Bool {
      for (box in this.parts) {
         if (box.intersectsPoint(x, y))
            return true;
      }
      return false;
   }

   override public function intersectsHitbox(box:IHitbox):Bool {
      for (tbox in this.parts) {
         if (tbox.intersectsHitbox(box))
            return true;
      }
      return false;
   }

   public function getPointClosestToInside(x:Float, y:Float, ?use:Coordinates):Coordinates {
      throw new haxe.exceptions.NotImplementedException();
   }

   public function draw() {}
}
