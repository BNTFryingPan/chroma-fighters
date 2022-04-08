package inputManager;

class ValueTracker<T> {
   public var _value:T;
   public var value(get, set):T;

   private var _lastValueTime:Float = 0;
   private var _valueTime:Float = 0;

   public var lastValueTime(get, never):Float;
   public var valueTime(get, never):Float;

   public function new(initialValue:T) {
      #if memtraces
      trace('new value tracker');
      #end
      this.value = initialValue;
   }

   public function tick(elapsed:Float) {
      this._valueTime += elapsed;
   }

   function set_value(value:T):T {
      this._lastValueTime = this._valueTime;
      this._valueTime = 0;
      return this._value = value;
   }

   function get_value():T {
      return this._value;
   }

   function get_valueTime():Float {
      return _valueTime;
   }

   function get_lastValueTime():Float {
      return _lastValueTime;
   }
}
