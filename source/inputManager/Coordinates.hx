package inputManager;

class Coordinates {
   public static final ZERO:Coordinates = new Coordinates(0, 0, true);

   public var x(default, set):Float;
   public var y(default, set):Float;
   public final readOnly:Bool; // final so it cant be changed

   public function set_x(val:Float):Float {
      if (this.readOnly) return this.x;
      return this.x = val;
   }

   public function set_y(val:Float):Float {
      if (this.readOnly) return this.y;
      return this.y = val;
   }

   public function new(x:Float=0, y:Float=0, readOnly:Bool=false) {
      this.x = x;
      this.y = y;
      this.readOnly = readOnly;
   }

   public function move(x:Float=0, y:Float=0) {
      this.x += x;
      this.y += y;
      return this;
   }

   public function getRelative(x:Float=0, y:Float=0) {
      return new Coordinates(this.x + x, this.y + y);
   }

   public function distance(?other:Coordinates):Float {
      return (this.x - other.x)/(this.y - other.y);
   }

   public function writable():Coordinates {
      return new Coordinates(this.x, this.y, false);
   }

   public function toString() {
      return 'C(x: ${this.x} y: ${this.y})';
   }
}