package inputManager;

class StickVector {
   public var x(get, default):Float;
   public var y(get, default):Float;

   public function new(x:Float = 0.0, y:Float = 0.0) {
      #if memtraces
      trace('new stick vector');
      #end
      // Main.log("new stick vector");
      this.x = x;
      this.y = y;
   }

   function get_x():Float {
      return Math.max(Math.min(this.x, 1), -1);
   }

   function get_y():Float {
      return Math.max(Math.min(this.y, 1), -1);
   }

   /**
      updates the x and y values of this StickVector and returns it for chaining
    */
   public function update(?x:Float, ?y:Float):StickVector {
      if (x != null) {
         this.x = x;
      }
      if (y != null) {
         this.y = y;
      }
      return this;
   }

   /**
      updates the x and y values of the given StickVector and returns that StickVector for chaining
    */
   public function clone(to:StickVector):StickVector {
      return to.update(this.x, this.y);
   }

   public function withX(x:Float):StickVector {
      return new StickVector(x, this.y);
   }

   public function withY(y:Float):StickVector {
      return new StickVector(this.x, y);
   }

   public function toString():String {
      return 'StickVector(${this.x}, ${this.y}, ${this.length})';
   }

   public var length(get, null):Float;

   function get_length():Float {
      var xs = this.x * this.x;
      var ys = this.y * this.y;
      return Math.sqrt(xs + ys);
   }

   public function normalize():StickVector {
      if (this.length != 0)
         return this.divide(this.length);
      return this;
   }

   public function add(other:StickVector):StickVector {
      return this.update(this.x + other.x, this.y + other.y);
   }

   public function subtract(other:StickVector):StickVector {
      return this.update(this.x - other.x, this.y - other.y);
   }

   public function multiply(value:Float):StickVector {
      return this.update(this.x * value, this.y * value);
   }

   public function divide(value:Float):StickVector {
      return this.update(this.x / value, this.y / value);
   }
}
