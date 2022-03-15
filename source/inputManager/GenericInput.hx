package inputManager;

import PlayerSlot.PlayerSlotIdentifier;
import inputManager.InputState;

/**
   A basic input handler, used as a base for all other input types.

   this handler always returns false for any input checks, and reports the cursor position as (0, 0)
**/
class GenericInput {
   public var inputEnabled(get, default):Bool = false;

   public var inputType(get, never):String;

   public var stick:StickVector = new StickVector();
   public var cursorStick:StickVector = new StickVector();
   public var directionStick:StickVector = new StickVector();
   public var rawDirectionStick:StickVector = new StickVector();

   private final cursorPosition:Coordinates = new Coordinates(0, 0);

   public function get_inputEnabled() {
      return false;
   }

   public function get_inputType() {
      return "Generic";
   }

   public var slot:PlayerSlotIdentifier;
   public var profile:Profile;

   public final trackers:Map<Action, InputTracker> = [];

   private static final _TRACKED_ACTIONS:Array<Action> = [
      MENU_CONFIRM, MENU_CANCEL, MENU_ACTION, MENU_LEFT, MENU_RIGHT, MENU_BUTTON, JUMP, SHORT_JUMP, ATTACK, SPECIAL, STRONG, TAUNT, SHIELD, DODGE, WALK,
   ];

   public function new(slot:PlayerSlotIdentifier, ?profile:String = null) {
      Main.log('creating ${this.inputType} input for slot ' + slot);
      this.slot = slot;

      if (profile == null) {
         this.profile = Profile.getProfile("", true);
      } else {
         this.profile = Profile.getProfile(profile);
      }

      for (act in _TRACKED_ACTIONS) {
         this.trackers.set(act, new InputTracker(act, this));
      }
   }

   /**
      can be used to override the cursor position. mainly so mouse input works, but could theoretically be used for wii remote pointer or touchscreen inputs too
   **/
   public function getCursorPosition():Null<Coordinates> {
      return null;
   }

   public function getCursorStick():StickVector {
      return this.getStick().clone(this.cursorStick);
   }

   public function get(action:Action):Null<InputTracker> {
      if (this.trackers.exists(action))
         return this.trackers.get(action);
      return null;
   }

   public function getConfirm():InputState {
      return NOT_PRESSED;
   }

   public function getCancel():InputState {
      return NOT_PRESSED;
   }

   public function getMenuAction():InputState {
      return NOT_PRESSED;
   }

   public function getMenuLeft():InputState {
      return NOT_PRESSED;
   }

   public function getMenuRight():InputState {
      return NOT_PRESSED;
   }

   public function getMenuButton():InputState {
      return NOT_PRESSED;
   }

   public function getAttack():InputState {
      return NOT_PRESSED;
   }

   public function getJump():InputState {
      return NOT_PRESSED;
   }

   public function getShortJump():InputState {
      return NOT_PRESSED;
   }

   public function getSpecial():InputState {
      return NOT_PRESSED;
   }

   public function getStrong():InputState {
      return NOT_PRESSED;
   }

   public function getShield():InputState {
      return NOT_PRESSED;
   }

   public function getDodge():InputState {
      return NOT_PRESSED;
   }

   public function getWalk():InputState {
      return NOT_PRESSED;
   }

   public function getTaunt():InputState {
      return NOT_PRESSED;
   }

   public function getQuit():InputState {
      return NOT_PRESSED;
   }

   public function getPause():InputState {
      return NOT_PRESSED;
   }

   public function getUp():Float {
      return 0;
   }

   public function getDown():Float {
      return 0;
   }

   public function getLeft():Float {
      return 0;
   }

   public function getRight():Float {
      return 0;
   }

   public function getStick():StickVector {
      var x:Float = 0;
      var y:Float = 0;

      x += this.getRight();
      x -= this.getLeft();
      y += this.getDown();
      y -= this.getUp();

      return this.stick.update(x, y);
   }

   public function getDirection():StickVector {
      return this.directionStick.update(0, 0);
   }

   public function getRawDirection():StickVector {
      return this.rawDirectionStick.update(0, 0);
   }

   public function update(elapsed:Float) {
      for (tracker in this.trackers) {
         tracker.tick(elapsed);
      }
   }

   public function getAction(action:Action):InputState {
      return switch (action) {
         case NULL: // never true
            NOT_PRESSED;
         case MENU_CONFIRM:
            this.getConfirm();
         case MENU_CANCEL:
            this.getCancel();
         case MENU_ACTION:
            this.getMenuAction();
         case MENU_LEFT:
            this.getMenuLeft();
         case MENU_RIGHT:
            this.getMenuRight();
         case MENU_BUTTON:
            this.getMenuButton();
         case JUMP:
            this.getJump();
         case SHORT_JUMP:
            this.getShortJump();
         case ATTACK:
            this.getAttack();
         case SPECIAL:
            this.getSpecial();
         case STRONG:
            this.getStrong();
         case TAUNT:
            this.getTaunt();
         case SHIELD:
            this.getShield(); // might only do parries, not sure yet
         case DODGE:
            this.getDodge();
         case WALK:
            this.getWalk();
         case DIRECTION_X:
            NOT_PRESSED;
         case DIRECTION_Y:
            NOT_PRESSED;
         case MOVE_X:
            NOT_PRESSED;
         case MOVE_Y:
            NOT_PRESSED;

         case MODIFIER_X:
            NOT_PRESSED;
         case MODIFIER_Y:
            NOT_PRESSED;
      }
   }
}
