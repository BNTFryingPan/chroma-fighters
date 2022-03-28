package;

class Fuse {
   private var blown:Bool = false;

   public function new() {}

   /**
      sets the state of this fuse to true and returns true
   **/
   public function blow():Bool {
      return this.blown = true;
   }

   public function isBlown():Bool {
      return this.blown;
   }
}
