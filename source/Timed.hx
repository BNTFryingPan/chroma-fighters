package;

/*
   A class to keep track of durations in frames or seconds. useful for checking buffered inputs
*/
class Timed /*implements IFlxPooled*/ {
   /*private static var _pool:FlxPool<Timed> = new FlxPool<Timed>;
   public static var pool(get, never):IFlxPool<Timed>;

   public static function get_pool():IFlxPool<Timed> {
      return Timed._pool;
   }

   public static function get()

   private var _inPool = false;

   public function put():Void {

   }*/

   private var _frames:Int = 0;
   private var _seconds:Float = 0;
   private var _invalid:Bool = false;

   public function new(frames:Int=0, seconds:Float=0) {
      this.setFrames(frames);
      this.setSeconds(seconds);
   }

   public function inFrames(frames:Int):Bool {
      if (this._invalid) return false;
      return this._frames <= frames;
   }

   public function inSeconds(seconds:Float):Bool {
      if (this._invalid) return false;
      return this._seconds <= seconds;
   }

   public function frames():Int {
      return this._frames;
   }

   public function seconds():Float {
      return this._seconds;
   }

   public function valid():Bool {
      return this._invalid;
   }

   public function invalidate(state:Bool):Bool {
      return this._invalid = state;
   }

   public function tick(elapsed:Float, reset:Bool):Void {
      if (reset) {
         this.reset();
         return;
      }
      this._seconds += elapsed;
      this._frames++;
   }

   public function reset():Void {
      this._frames = 0;
      this._seconds = 0;
   }

   public function setFrames(frames:Int) {
      return this._frames = frames;
   }

   public function setSeconds(seconds:Float) {
      return this._seconds = seconds;
   }
}