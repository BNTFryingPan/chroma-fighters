package inputManager;

import flixel.FlxCamera;
import flixel.math.FlxAngle;
import flixel.util.FlxPool;

class Coordinates implements IFlxPooled {
   public static var pool(get, never):IFlxPool<Coordinates>;

   public static function get_pool():IFlxPool<Coordinates> {
      return Coordinates._pool;
   }

   private static var _pool:FlxPool<Coordinates> = new FlxPool<Coordinates>(Coordinates);

   public static final ZERO:Coordinates = new Coordinates(0, 0, true);

   // a is a reusable coordinates object that should be used instead of making a new one when you only need it for like one thing
   // if it needs to be stored, make a new one instead
   // public static final a:Coordinates = new Coordinates(0, 0, false);

   public static function get(?x:Float, ?y:Float) {
      var ret = _pool.get().set(x, y);
      ret._inPool = false;
      return ret;
   }

   public static function weak(x:Float, y:Float) {
      var ret = Coordinates.get(x, y);
      ret._weak = true;
      return ret;
   }

   public function destroy():Void {}

   public var x(default, set):Float;
   public var y(default, set):Float;
   public var sx(get, never):Float;
   public var sy(get, never):Float;
   public final readOnly:Bool; // final so it cant be changed

   var _inPool:Bool = false;
   var _weak:Bool = false;

   public function set_x(val:Float):Float {
      if (this.readOnly)
         return this.x;
      return this.x = val;
   }

   public function set_y(val:Float):Float {
      if (this.readOnly)
         return this.y;
      return this.y = val;
   }

   public function new(x:Float = 0, y:Float = 0, readOnly:Bool = false) {
      this.set(x, y);
      this.readOnly = readOnly;
   }

   public function put():Void {
      if (this.readOnly)
         return;
      if (!this._inPool) {
         this._inPool = true;
         this._weak = false;
         Coordinates._pool.putUnsafe(this);
      }
   }

   public function putWeak():Void {
      if (this._weak)
         this.put();
   }

   public function move(x:Float = 0, y:Float = 0):Coordinates {
      this.x += x;
      this.y += y;
      return this;
   }

   public function move2(coords:Coordinates):Coordinates {
      this.move(coords.x, coords.y);
      coords.putWeak();
      return this;
   }

   public function clone(from:Coordinates):Coordinates {
      this.set(from.x, from.y);
      from.putWeak();
      return this;
   }

   public function set(?x:Float = 0, ?y:Float = 0):Coordinates {
      if (x != null)
         this.x = x;
      if (y != null)
         this.y = y;
      return this;
   }

   private static inline var EPSILON:Float = 0.0000001;

   public function equals(x:Float, y:Float, ?ep:Float = null):Bool {
      if (ep == null)
         ep = Coordinates.EPSILON;
      return (Math.abs(x - this.x) <= ep) && (Math.abs(y - this.y) <= ep);
   }

   public function equalsOther(other:Coordinates):Bool {
      var ret = this.equals(other.x, other.y);
      other.putWeak();
      return ret;
   }

   public function getRelative(x:Float = 0, y:Float = 0):Coordinates {
      return Coordinates.get(this.getRelX(x), this.getRelY(y));
   }

   public function getRelX(x:Float = 0):Float {
      return this.x + x;
   }

   public function getRelY(y:Float = 0):Float {
      return this.y + y;
   }

   public static function xInScreenSpace(x:Float = 0, ?camera:FlxCamera):Float {
      if (camera == null)
         camera = Main.screenSprite.camera;
      return camera.scroll.x - x;
   }

   public static function yInScreenSpace(y:Float = 0, ?camera:FlxCamera):Float {
      if (camera == null)
         camera = Main.screenSprite.camera;
      return camera.scroll.y - y;
   }

   public function get_sx():Float {
      return Coordinates.xInScreenSpace(this.x);
   }

   public function get_sy():Float {
      return Coordinates.xInScreenSpace(this.y);
   }

   public function ceil():Coordinates {
      this.x = Math.ceil(this.x);
      this.y = Math.ceil(this.y);
      return this;
   }

   public function angleBetweenOther(other:Coordinates):Float {
      var ret = this.angleBetween(other.x, other.y);
      other.putWeak();
      return ret;
   }

   public function angleBetween(x:Float, y:Float):Float {
      var angle = Math.atan2(x - this.x, y - this.y);
      return angle * FlxAngle.TO_DEG;
   }

   // TODO : to screenspace coords?

   public function distanceFromOther(other:Coordinates):Float {
      var ret = this.distanceFrom(other.x, other.y);
      other.putWeak();
      return ret;
   }

   public function distanceFrom(x:Float, y:Float):Float {
      var dx = this.x - x;
      var dy = this.y - y;
      return dx / dy;
   }

   public function writable():Coordinates {
      return new Coordinates(this.x, this.y, false);
   }

   public function toString() {
      return 'C(x: ${this.x} y: ${this.y})';
   }
}
