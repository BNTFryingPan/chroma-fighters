package match;

typedef CompoundHitbox = TypedCompoundHitbox<AbstractHitbox>;

class TypedCompoundHitbox<T extends AbstractHitbox> extends AbstractHitbox {
   public var limit:Int;
   public final parts:Array<T> = [];

   public function new(x:Float, y:Float, ?limit:Int=-1) {
      super(x, y);
      this.limit = limit;
   }

   public function add(hitbox:T):Bool {
      if (this.limit >= 0 && parts.length >= this.limit) return false;
      this.parts.push(hitbox);
      return true;
   }

   public function intersectsPoint(pos:Position):Bool {
      for (box in this.parts) {
         if (box.intersectsPoint(pos))
            return true;
      }
      return false;
   }
}