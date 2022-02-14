package match;

/**
   used to get random numbers that can be recreated in a replay
   based off of flixels FlxRandom class, but slightly different

   intended to be created for each object that needs randomness in a match

   next<type> gets a random number and updates the seed
   get<type> gets a random number but does not update the seed
**/
class MatchRandom {
   public var currentSeed(get, set):Int;
   private var _seed:Float = 1;

   function get_currentSeed():Int {
      return Std.int(this._seed);
   }

   function set_currentSeed(seed:Int):Int {
      return Std.int(this._seed = MatchRandom.bound(seed));
   }

   public function new(?seed:Int) {
      this.currentSeed = seed == null ? MatchRandom.getRandomSeed() : seed;
   }

   private function getRand():Float {
      return (this._seed * MatchRandom._mult) % MatchRandom._mod;
   }

   private function nextRand():Float {
      return (this._seed = getRand());
   }

   public function getInt(min:Int = 0, max:Int = FlxMath.MAX_VALUE_INT):Int {
      if (min == 0 && max == FlxMath.MAX_VALUE_INT)
         return Std.int(this.getRand());

      if (min == max)
         return min;

      if (min > max) {
         min += max;
         max = min - max;
         min -= max;
      }

      return Math.floor(min + this.getRand() / MatchRandom._mod * (max - min + 1));
   }

   public function nextInt(min, max):Int {
      var ret = getInt(min, max);
      nextRand();
      return ret;
   }

   public function getFloat(min:Float = 0, max:Float = 1):Float {
      if (min == 0 && max == 1)
         return this.getRand() / MatchRandom._mod;
      
      if (min == max)
         return min;

      if (min > max) {
         min += max;
         max = min - max;
         min -= max;
      }

      return min + (this.getRand() / MatchRandom._mod) * (max - min);
   }

   public function nextFloat(min, max) {
      var ret = getFloat(min, max);
      nextRand();
      return ret;
   }

   public function getBool(chance:Float = 0.5) {
      return getFloat() < chance;
   }

   public function nextBool(chance:Float = 0.5) {
      return nextFloat() < chance;
   }

   // non-deterministic function!
   static public function getRandomSeed():Int {
      return bound(Std.int(Math.random() * FlxMath.MAX_VALUE_INT))
   }

   static function bound(value:Int) {
      return Std.int(FlxMath.bound(value, 1, MatchRandom._mod - 1));
   }

   static inline var _mult:Float = 48271.0;
   static inline var _mod:Int = FlxMath.MAX_VALUE_INT;
}