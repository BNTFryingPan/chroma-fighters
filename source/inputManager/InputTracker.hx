package inputManager;

class InputTracker extends ValueTracker<InputState> {
   public var pressed(get, never):Bool;
   public var notPressed(get, never):Bool;
   public var changed(get, never):Bool;
   public var justPressed(get, never):Bool;
   public var justReleased(get, never):Bool;

   public final action:Action;
   public final input:GenericInput;

   public function new(action:Action, input:GenericInput) {
      this.action = action;
      this.input = input;
      super(NOT_PRESSED);
   }

   function get_pressed():Bool {
      return InputHelper.isPressed(this.value);
   }

   function get_notPressed():Bool {
      return InputHelper.isNotPressed(this.value);
   }

   function get_changed():Bool {
      return InputHelper.justChanged(this.value);
   }

   function get_justPressed():Bool {
      return this.value == JUST_PRESSED;
   }

   function get_justReleased():Bool {
      return this.value == JUST_RELEASED;
   }

   override public function tick(elapsed:Float) {
      this.get_value();
      super.tick(elapsed);
   }

   override function get_value():InputState {
      var value = this.input.getAction(this.action);
      if (this._value == null || value != this._value) {
         this.value = value;
      }
      return value;
   }

   override function set_value(value:InputState):InputState {
      if (!((this._value == JUST_PRESSED && value == PRESSED) || (this._value == JUST_RELEASED && value == NOT_PRESSED)))
         return super.set_value(value);
      return this._value = value;
   }
}
