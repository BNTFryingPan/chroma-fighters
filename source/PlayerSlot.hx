package;

import GameManager;
import cpuController.CpuController;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.typeLimit.OneOfTwo;
import inputManager.CursorRotation;
import inputManager.GenericInput;
import inputManager.InputDevice;
import inputManager.InputHelper;
import inputManager.InputManager;
import inputManager.InputType;
import inputManager.KeyboardHandler;
import inputManager.MouseHandler;
import inputManager.Position;
import inputManager.controllers.GenericController;
import inputManager.controllers.SwitchProController;
import match.Match;
import match.fighter.AbstractFighter;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

enum abstract PlayerSlotIdentifier(Int) to Int {
   var P1;
   var P2;
   var P3;
   var P4;
   var P5;
   var P6;
   var P7;
   var P8;
}

typedef PlayerColor = {
   var red:Float;
   var green:Float;
   var blue:Float;
}

enum PlayerType {
   NONE;
   CPU;
   PLAYER;
}

/*enum PlayerBoxState {
   HIDDEN;
   CHARACTER_SEL;
   STAGE_SEL;
   MATCH;
}*/
class PlayerBox extends FlxSpriteGroup {
   public static var STATE(default, set):PlayerBoxState = PlayerBoxState.HIDDEN;

   public static function set_STATE(state:PlayerBoxState) {
      switch (state) {
         case PlayerBoxState.HIDDEN:
         case PlayerBoxState.FIGHTER_SELECT:
            for (player in PlayerSlot.getPlayerArray()) {
               player.playerBox.configureCSS();
            }
         case PlayerBoxState.IN_GAME:
            for (player in PlayerSlot.getPlayerArray()) {
               player.playerBox.configureInGame();
            }
         default:
      }
      PlayerBox.STATE = state;
      return state;
   }

   public var text:FlxText;
   public var background:FlxSprite;
   public var swapButton:CustomButton;
   public var disconnectButton:CustomButton;
   public var slot:PlayerSlotIdentifier;

   public function new(slot:PlayerSlotIdentifier) {
      super(0, FlxG.height - 80);
      this.background = new FlxSprite();
      this.text = new FlxText(0, 0, 0, "0/8\nInput");
      this.swapButton = new CustomButton(0, 0, "swap", (targetslot) -> {
         PlayerSlot.getPlayer(targetslot).moveToSlot(this.slot);
      });
      this.disconnectButton = new CustomButton(0, 0, "disconnect", (targetslot) -> {
         PlayerSlot.getPlayer(this.slot).setNewInput(NoInput);
      });
      this.background.makeGraphic(64, 64, FlxColor.MAGENTA);

      this.add(this.background);
      this.add(this.text);
      this.add(this.swapButton);
      this.add(this.disconnectButton);

      this.scrollFactor.x = 0;
      this.scrollFactor.y = 0;

      this.slot = slot;
   }

   public function setPercentText(value:String) {
      this.text.text = '${slot + 1}/8\nInput\n${value}';
   }

   public function configureCSS() {
      // this.xPos = Math.floor((FlxG.width * 0.9) / max + 1) * (Math.floor((FlxG.width * 0.9) / max) * (cast this.slot));
      this.x = ((cast this.slot) * 100) + 20;
      this.text.text = '${slot + 1}/8\nInput';
      this.text.y = this.y + 2;
      this.swapButton.y = this.y + 20;
      this.disconnectButton.y = this.y + 40;
   }

   public function configureInGame() {
      this.x = ((cast this.slot) * 100) + 20;
      this.swapButton.visible = false;
      this.disconnectButton.visible = false;
   }

   override public function update(elapsed:Float) {
      super.update(elapsed);
      if (PlayerBox.STATE == PlayerBoxState.IN_GAME) {}
   }
}

class PlayerSlot {
   public static var PointerCoinBitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/coin"));
   public static var PointerP1Bitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/coins/p1"));
   public static var PointerP2Bitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/coins/p2"));
   public static var PointerP3Bitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/coins/p3"));
   public static var PointerP4Bitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/coins/p4"));
   public static var PointerP5Bitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/coins/p5"));
   public static var PointerP6Bitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/coins/p6"));
   public static var PointerP7Bitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/coins/p7"));
   public static var PointerP8Bitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/coins/p8"));
   public static var PointerCPUBitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/coins/cpu"));
   public static var PointerLeftBitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_left"));
   public static var PointerRightBitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_right"));
   public static var PointerUpLeftBitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_up_left"));
   public static var PointerUpRightBitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_up_right"));
   public static var PointerDownLeftBitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_down_left"));
   public static var PointerDownRightBitmap(get, default) = AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_down_right"));

   public static final artificalPlayerLimit = false; // if true, caps at 4 players instead of 8 at runtime. might break stuff, idk
   public static final defaultPlayerColors:Map<PlayerSlotIdentifier, PlayerColor> = [
      P1 => {red: 1.0, green: 0.2, blue: 0.2}, // red
      // P1 => {red: 1.0, green: 0.9, blue: 0.3},
      P2 => {red: 0.2, green: 0.2, blue: 1.0}, // blue
      P3 => {red: 0.2, green: 1.0, blue: 0.2}, // green
      P4 => {red: 1.0, green: 1.0, blue: 0.2}, // yellow
      P5 => {red: 1.0, green: 0.2, blue: 1.0}, // magenta
      P6 => {red: 0.2, green: 1.0, blue: 1.0}, // teal
      P7 => {red: 1.0, green: 0.5, blue: 0.0}, // orange
      P8 => {red: 0.5, green: 0.5, blue: 0.5}, // gray
   ];
   public static final cpuPlayerColor:PlayerColor = {red: 0.4, green: 0.4, blue: 0.4};

   public static var players:Map<PlayerSlotIdentifier, Null<PlayerSlot>> = [
      P1 => new PlayerSlot(P1),
      P2 => new PlayerSlot(P2),
      P3 => new PlayerSlot(P3),
      P4 => new PlayerSlot(P4),
      P5 => new PlayerSlot(P5),
      P6 => new PlayerSlot(P6),
      P7 => new PlayerSlot(P7),
      P8 => new PlayerSlot(P8),
   ];

   public static function getPlayer(slot:PlayerSlotIdentifier) {
      return PlayerSlot.players[slot];
   }

   public static function getNumberOfPlayerSlotsToDraw():Int {
      if (!PlayerSlot.artificalPlayerLimit) {
         if (PlayerSlot.players[P8].type != NONE)
            return 8;
         if (PlayerSlot.players[P7].type != NONE)
            return 7;
         if (PlayerSlot.players[P6].type != NONE)
            return 6;
         if (PlayerSlot.players[P5].type != NONE)
            return 5;
      }
      if (PlayerSlot.players[P4].type != NONE)
         return 4;
      if (PlayerSlot.players[P3].type != NONE)
         return 3;
      return 2;
   }

   public static function getPlayerArray(?skipEmpty:Bool):Array<PlayerSlot> {
      var array = [];
      for (player in PlayerSlot.players) {
         if ((!skipEmpty) || (player.type != NONE)) {
            array.push(player);
         }
      }
      return array;
   }

   public static function getPlayerInputArray(?skipEmpty:Bool):Array<GenericInput> {
      return PlayerSlot.getPlayerArray(skipEmpty).map(player -> player.input);
   }

   public static function getPlayerSlotByInput(input:OneOfTwo<FlxGamepad, InputType>):Null<PlayerSlotIdentifier> {
      // if (!Std.isOfType(input, FlxGamepad)) {
      if (!(input is FlxGamepad)) {
         var type:InputType = cast input;
         if (type == KeyboardInput || type == KeyboardAndMouseInput) {
            var matchingInputs = PlayerSlot.getPlayerInputArray().filter(thisInput -> {
               // return Std.isOfType(thisInput, KeyboardHandler);
               return (thisInput is KeyboardHandler);
            });
            if (matchingInputs.length > 0) {
               return matchingInputs[0].slot;
            }
         }
         return null;
      }

      var gamepad:FlxGamepad = cast input;
      for (slot => player in PlayerSlot.players) {
         // if (Std.isOfType(player.input, GenericController)) {
         if ((player.input is GenericController)) {
            var c:GenericController = cast player.input;
            if (c._flixelGamepad == gamepad) {
               return cast slot;
            }
         }
      }

      return null;
   }

   public static function getPlayerByInput(input:OneOfTwo<FlxGamepad, InputType>):Null<PlayerSlot> {
      return getPlayer(getPlayerSlotByInput(input));
   }

   public static function getFirstOpenPlayerSlot():Null<PlayerSlotIdentifier> {
      if (PlayerSlot.getPlayer(P1).type == NONE)
         return P1;
      if (PlayerSlot.getPlayer(P2).type == NONE)
         return P2;
      if (PlayerSlot.getPlayer(P3).type == NONE)
         return P3;
      if (PlayerSlot.getPlayer(P4).type == NONE)
         return P4;
      if (PlayerSlot.artificalPlayerLimit)
         return null;
      if (PlayerSlot.getPlayer(P5).type == NONE)
         return P5;
      if (PlayerSlot.getPlayer(P6).type == NONE)
         return P6;
      if (PlayerSlot.getPlayer(P7).type == NONE)
         return P7;
      if (PlayerSlot.getPlayer(P8).type == NONE)
         return P8;
      return null;
   }

   public static function getFirstEmptyPlayer():Null<PlayerSlot> {
      return PlayerSlot.getPlayer(getFirstOpenPlayerSlot());
   }

   public static function getPlayerByProfileName(profile:String):Null<PlayerSlot> {
      var matched = PlayerSlot.getPlayerArray().filter(player -> player.input.profile.name == profile);
      if (matched.length > 0)
         return matched[0];
      return null;
   }

   public static function tryToAddPlayerFromInputDevice(inputDevice:FlxGamepad):Null<PlayerSlot> {
      if (PlayerSlot.getPlayerSlotByInput(inputDevice) != null) {
         return null;
      }

      var player = PlayerSlot.getFirstEmptyPlayer();

      if (player == null)
         return null;

      player.setNewInput(ControllerInput, inputDevice);
      return player;
   }

   public static function initAll() {
      PlayerSlot.getPlayer(P1).init();
      PlayerSlot.getPlayer(P2).init();
      PlayerSlot.getPlayer(P3).init();
      PlayerSlot.getPlayer(P4).init();
      PlayerSlot.getPlayer(P5).init();
      PlayerSlot.getPlayer(P6).init();
      PlayerSlot.getPlayer(P7).init();
      PlayerSlot.getPlayer(P8).init();
   }

   public static function updateAll(elapsed:Float) {
      PlayerSlot.getPlayer(P1).update(elapsed);
      PlayerSlot.getPlayer(P2).update(elapsed);
      PlayerSlot.getPlayer(P3).update(elapsed);
      PlayerSlot.getPlayer(P4).update(elapsed);
      PlayerSlot.getPlayer(P5).update(elapsed);
      PlayerSlot.getPlayer(P6).update(elapsed);
      PlayerSlot.getPlayer(P7).update(elapsed);
      PlayerSlot.getPlayer(P8).update(elapsed);
   }

   public static function drawAll() {
      PlayerSlot.getPlayer(P8).drawBox();
      PlayerSlot.getPlayer(P7).drawBox();
      PlayerSlot.getPlayer(P6).drawBox();
      PlayerSlot.getPlayer(P5).drawBox();
      PlayerSlot.getPlayer(P4).drawBox();
      PlayerSlot.getPlayer(P3).drawBox();
      PlayerSlot.getPlayer(P2).drawBox();
      PlayerSlot.getPlayer(P1).drawBox();

      PlayerSlot.getPlayer(P8).draw();
      PlayerSlot.getPlayer(P7).draw();
      PlayerSlot.getPlayer(P6).draw();
      PlayerSlot.getPlayer(P5).draw();
      PlayerSlot.getPlayer(P4).draw();
      PlayerSlot.getPlayer(P3).draw();
      PlayerSlot.getPlayer(P2).draw();
      PlayerSlot.getPlayer(P1).draw();

      /*PlayerSlot.getPlayerArray().filter(player -> {
         player.draw();
         return false;
      });*/
   }

   public static function getOffset(angle:CursorRotation):Position {
      if (angle == LEFT) {
         return {x: 0, y: 15};
      } else if (angle == RIGHT) {
         return {x: 30, y: 15};
      } else if (angle == UP_LEFT) {
         return {x: 3, y: 0};
      } else if (angle == UP_RIGHT) {
         return {x: 27, y: 0};
      } else if (angle == DOWN_LEFT) {
         return {x: 3, y: 30};
      } else if (angle == DOWN_RIGHT) {
         return {x: 27, y: 30};
      }

      return {x: 30, y: 15};
   }

   public static function getCoinOffset(angle:CursorRotation):Position {
      if (angle == LEFT) {
         return {x: -30, y: 15};
      } else if (angle == RIGHT) {
         return {x: 60, y: 15};
      } else if (angle == UP_LEFT) {
         return {x: -7, y: -23};
      } else if (angle == UP_RIGHT) {
         return {x: 38, y: -23};
      } else if (angle == DOWN_LEFT) {
         return {x: -7, y: 50};
      } else if (angle == DOWN_RIGHT) {
         return {x: 36, y: 50};
      }

      return {x: 16, y: 16};
   }

   public var type:PlayerType = NONE;
   public var color:PlayerColor;
   public var slot(default, set):PlayerSlotIdentifier;
   public var fighterSelection:FighterSelection;
   public var fighter:AbstractFighter;
   public var input:GenericInput;
   public var debugSprite:FlxSprite;
   public var cursorSprite:FlxSprite;
   public var cursorPosition:Position = {x: Math.round(FlxG.width / 2), y: Math.round(FlxG.height / 2)};
   public var cursorAngle:CursorRotation = RIGHT;
   public var coinSprite:FlxSprite;
   public var cursorSpriteOffset:Position = {x: 30, y: 15};
   public var coinSpriteOffset:Position = {x: 16, y: 16};
   public var visible(get, default):Bool = false;

   private function set_slot(v:PlayerSlotIdentifier) {
      if (this.playerBox != null)
         this.playerBox.slot = v;
      if (this.input != null)
         this.input.slot = v;

      this.slot = v;

      if (this.coinSprite != null)
         this.coinSprite.loadGraphic(this.applySlotColorFilter(PlayerSlot.getCoinBitmap(v)));

      if (this.cursorSprite != null)
         this.setCursorAngle(SAME);

      return v;
   }

   private function get_visible() {
      if (!this.input.inputEnabled)
         return false;
      return true;
   }

   private function setControllerObjectFromInputDevice(?inputDevice:FlxGamepad, ?profile:String) {
      if (inputDevice == null)
         return;

      this.input = switch (inputDevice.model) {
         case SWITCH_PRO:
            new SwitchProController(this.slot, profile);
         default:
            new GenericController(this.slot, profile);
      };

      var inp:GenericController = cast this.input;
      inp._flixelGamepad = cast inputDevice;
   }

   public function setNewInput(type:InputType, ?inputDevice:OneOfTwo<FlxGamepad, InputDevice>, ?profile:String) {
      if (this.input.getCursorPosition() != null) {
         this.cursorPosition = this.input.getCursorPosition();
      }
      if (type == KeyboardInput || (inputDevice == Keyboard && type != KeyboardAndMouseInput)) {
         this.setType(PLAYER);
         this.input = new KeyboardHandler(slot, profile);
      } else if (type == KeyboardAndMouseInput) {
         this.setType(PLAYER);
         this.input = new MouseHandler(slot, profile);
      } else if (type == ControllerInput) {
         this.setType(PLAYER);
         this.setControllerObjectFromInputDevice(cast inputDevice, profile);
      } else if (type == CPUInput) {
         this.setType(CPU);
         this.input = new CpuController(slot, profile);
      } else {
         this.setType(NONE);
         this.input = new GenericInput(slot, profile);
      }
   }

   public function applySlotColorFilter(bitmap:BitmapData):BitmapData {
      // return bitmap;
      var slotColor = PlayerSlot.defaultPlayerColors[this.slot];
      var transform = new ColorTransform(slotColor.red, slotColor.green, slotColor.blue, 1.0, 0, 0, 0, 0);
      bitmap.colorTransform(new Rectangle(0, 0, bitmap.width, bitmap.height), transform);
      return bitmap;
   }

   function updateCursorPos(elapsed:Float) {
      if (this.input.getCursorPosition() != null)
         return;
      var stick = this.input.getCursorStick();

      this.cursorPosition.x += Math.round(stick.x * 500 * elapsed);
      this.cursorPosition.y += Math.round(stick.y * 500 * elapsed);

      this.cursorPosition.x = Std.int(Math.min(this.cursorPosition.x, FlxG.width));
      this.cursorPosition.x = Std.int(Math.max(this.cursorPosition.x, 0));
      this.cursorPosition.y = Std.int(Math.min(this.cursorPosition.y, FlxG.height));
      this.cursorPosition.y = Std.int(Math.max(this.cursorPosition.y, 0));
   }

   public static function getCoinBitmap(slot:PlayerSlotIdentifier):BitmapData {
      var baseCoin = PlayerSlot.PointerCoinBitmap;
      var icon = switch (slot) {
         case P1: PointerP1Bitmap;
         case P2: PointerP2Bitmap;
         case P3: PointerP3Bitmap;
         case P4: PointerP4Bitmap;
         case P5: PointerP5Bitmap;
         case P6: PointerP6Bitmap;
         case P7: PointerP7Bitmap;
         case P8: PointerP8Bitmap;
      }

      baseCoin.copyPixels(icon, new Rectangle(0, 0, 32, 32), new Point(0, 0), null, null, true);
      return baseCoin;
   }

   public static function get_PointerCoinBitmap():BitmapData {
      return PointerCoinBitmap.clone();
   }

   public static function get_PointerP1Bitmap():BitmapData {
      return PointerP1Bitmap.clone();
   }

   public static function get_PointerP2Bitmap():BitmapData {
      return PointerP2Bitmap.clone();
   }

   public static function get_PointerP3Bitmap():BitmapData {
      return PointerP3Bitmap.clone();
   }

   public static function get_PointerP4Bitmap():BitmapData {
      return PointerP4Bitmap.clone();
   }

   public static function get_PointerP5Bitmap():BitmapData {
      return PointerP5Bitmap.clone();
   }

   public static function get_PointerP6Bitmap():BitmapData {
      return PointerP6Bitmap.clone();
   }

   public static function get_PointerP7Bitmap():BitmapData {
      return PointerP7Bitmap.clone();
   }

   public static function get_PointerP8Bitmap():BitmapData {
      return PointerP8Bitmap.clone();
   }

   public static function get_PointerCPUBitmap():BitmapData {
      return PointerCPUBitmap.clone();
   }

   public static function get_PointerLeftBitmap():BitmapData {
      return PointerLeftBitmap.clone();
   }

   public static function get_PointerRightBitmap():BitmapData {
      return PointerRightBitmap.clone();
   }

   public static function get_PointerUpLeftBitmap():BitmapData {
      return PointerUpLeftBitmap.clone();
   }

   public static function get_PointerUpRightBitmap():BitmapData {
      return PointerUpRightBitmap.clone();
   }

   public static function get_PointerDownLeftBitmap():BitmapData {
      return PointerDownLeftBitmap.clone();
   }

   public static function get_PointerDownRightBitmap():BitmapData {
      return PointerDownRightBitmap.clone();
   }

   public function setCursorAngle(angle:CursorRotation) {
      if (this.cursorAngle == angle && angle != SAME)
         return;
      if (angle != SAME)
         this.cursorAngle = angle;
      if (this.cursorSprite.graphic != null) {
         this.cursorSprite.graphic.destroy();
      }
      this.cursorSprite.graphic = null;
      // Main.log('setting cursor angle ${angle} on ${slot}');
      if (this.cursorAngle == LEFT) {
         this.cursorSprite.loadGraphic(this.applySlotColorFilter(PlayerSlot.PointerLeftBitmap));
      } else if (this.cursorAngle == RIGHT) {
         this.cursorSprite.loadGraphic(this.applySlotColorFilter(PlayerSlot.PointerRightBitmap));
      } else if (this.cursorAngle == UP_LEFT) {
         this.cursorSprite.loadGraphic(this.applySlotColorFilter(PlayerSlot.PointerUpLeftBitmap));
      } else if (this.cursorAngle == UP_RIGHT) {
         this.cursorSprite.loadGraphic(this.applySlotColorFilter(PlayerSlot.PointerUpRightBitmap));
      } else if (this.cursorAngle == DOWN_LEFT) {
         this.cursorSprite.loadGraphic(this.applySlotColorFilter(PlayerSlot.PointerDownLeftBitmap));
      } else if (this.cursorAngle == DOWN_RIGHT) {
         this.cursorSprite.loadGraphic(this.applySlotColorFilter(PlayerSlot.PointerDownRightBitmap));
      }
      // Main.log('setting offset');
      this.cursorSpriteOffset = PlayerSlot.getOffset(this.cursorAngle);
      this.coinSpriteOffset = PlayerSlot.getCoinOffset(this.cursorAngle);

      this.cursorSprite.graphic.persist = true;
      // Main.log('set offset to ${this.spriteOffset}');
   }

   private var ready = false;

   public var playerBox:PlayerBox;
   public var cpuSettings:CpuSettings = new CpuSettings();

   public function init() {
      if (this.ready)
         return;

      this.ready = true;

      this.coinSprite = new FlxSprite();
      this.cursorSprite = new FlxSprite();
      this.playerBox = new PlayerBox(this.slot);
      this.debugSprite = new FlxSprite();
      this.coinSprite.loadGraphic(this.applySlotColorFilter(PlayerSlot.getCoinBitmap(this.slot)));
      this.debugSprite.makeGraphic(3, 3, FlxColor.MAGENTA);

      this.coinSprite.graphic.persist = true;
      this.debugSprite.graphic.persist = true;

      this.coinSprite.scrollFactor.x = 0;
      this.coinSprite.scrollFactor.y = 0;
      this.cursorSprite.scrollFactor.x = 0;
      this.cursorSprite.scrollFactor.y = 0;
      this.debugSprite.scrollFactor.x = 0;
      this.debugSprite.scrollFactor.y = 0;

      this.setCursorAngle(RIGHT);
   }

   private function new(slot:PlayerSlotIdentifier) {
      this.slot = slot;
      this.type = NONE;

      this.input = new GenericInput(slot);
      this.fighterSelection = new FighterSelection(slot);
   }

   public function setType(type:PlayerType) {
      this.type = type;
   }

   public function moveToSlot(toSlot:PlayerSlotIdentifier) {
      if (PlayerSlot.artificalPlayerLimit && (cast toSlot) > 4)
         return;

      if (toSlot == this.slot)
         return; // no reason to swap as we are already in that slot

      var targetSlot = toSlot;
      var thisSlot = this.slot;

      PlayerSlot.players.get(toSlot).slot = thisSlot;
      this.slot = targetSlot;

      PlayerSlot.players.set(thisSlot, PlayerSlot.players.get(targetSlot));
      PlayerSlot.players.set(targetSlot, this);
   }

   /**
      returns the screen position where the cursor should be drawn and the "click point"
   **/
   public function getCursorPosition():Position {
      var inputCursor = this.input.getCursorPosition();
      return inputCursor != null ? inputCursor : this.cursorPosition;
   }

   public function update(elapsed:Float) {
      if (!this.ready)
         return;
      this.updateCursorPos(elapsed);
      var cursorPos = this.getCursorPosition();

      var cursorRotationMargin = 60;

      this.playerBox.update(elapsed);

      var setToLeft = cursorPos.x < cursorRotationMargin;
      var setToRight = cursorPos.x > (FlxG.width - cursorRotationMargin);
      var setToUp = cursorPos.y < cursorRotationMargin;
      var setToDown = cursorPos.y > (FlxG.height - cursorRotationMargin);

      var isAlreadyRight = (cursorAngle == RIGHT || cursorAngle == UP_RIGHT || cursorAngle == DOWN_RIGHT);
      var isAlreadyLeft = (cursorAngle == LEFT || cursorAngle == UP_LEFT || cursorAngle == DOWN_LEFT);

      if (this.visible) {
         // Main.debugDisplay.leftAppend += '\n${(cursorAngle == RIGHT || cursorAngle == UP_RIGHT || cursorAngle == DOWN_RIGHT)}';

         if (setToLeft) {
            if (setToUp)
               this.setCursorAngle(UP_LEFT);
            else if (setToDown)
               this.setCursorAngle(DOWN_LEFT);
            else
               this.setCursorAngle(LEFT);
         } else if (setToRight) {
            if (setToUp)
               this.setCursorAngle(UP_RIGHT);
            else if (setToDown)
               this.setCursorAngle(DOWN_RIGHT);
            else
               this.setCursorAngle(RIGHT);
         } else {
            if (setToUp) {
               if (isAlreadyRight)
                  this.setCursorAngle(UP_RIGHT);
               else
                  this.setCursorAngle(UP_LEFT);
            } else if (setToDown) {
               if (isAlreadyRight)
                  this.setCursorAngle(DOWN_RIGHT);
               else
                  this.setCursorAngle(DOWN_LEFT);
            }
         }
      }

      this.cursorSprite.x = cursorPos.x - this.cursorSpriteOffset.x;
      this.cursorSprite.y = cursorPos.y - this.cursorSpriteOffset.y;

      this.coinSprite.x = cursorPos.x - this.coinSpriteOffset.x;
      this.coinSprite.y = cursorPos.y - this.coinSpriteOffset.y;

      this.debugSprite.x = cursorPos.x;
      this.debugSprite.y = cursorPos.y;

      if (this.input.inputEnabled) {
         for (mem in GameManager.getAllObjects()) {
            // if (Std.isOfType(mem, CustomButton)) {
            if ((mem is CustomButton) && GameState.isUIOpen) {
               var button:CustomButton = cast mem;
               if (button.overlapsPoint(FlxPoint.get(cursorPos.x, cursorPos.y))) {
                  button.overHandler(this.slot);
                  if (InputHelper.isPressed(this.input.getConfirm()))
                     button.downHandler(this.slot);
                  else
                     button.upHandler(this.slot);
               } else
                  button.outHandler(this.slot);
            }
         }
         Main.debugDisplay.leftAppend += '\n[P${this.slot + 1}] {${this.input.inputType}}\n';
         if (GameState.shouldDrawCursors) {
            Main.debugDisplay.leftAppend += 'Cursor: (${cursorPos.x}, ${cursorPos.y}) from ${this.input.getCursorStick()}\nStick: ${this.input.getStick()}\nButtons: con ${this.input.getConfirm()} can ${this.input.getCancel()} act ${this.input.getMenuAction()} left ${this.input.getMenuLeft()} right ${this.input.getMenuRight()}\n';
            Main.debugDisplay.leftAppend += 'S: ${setToLeft ? 'L' : 'l'}${setToRight ? 'R' : 'r'}${setToUp ? 'U' : 'u'}${setToDown ? 'D' : 'd'} I: ${isAlreadyLeft ? 'L' : 'l'}${isAlreadyRight ? 'R' : 'r'}\n';
         }
         if (GameState.isInMatch) {
            Main.debugDisplay.leftAppend += 'Fighter: (${FlxMath.roundDecimal(this.fighter.x, 2)}, ${FlxMath.roundDecimal(this.fighter.y, 2)}) [${FlxMath.roundDecimal(this.fighter.velocity.x, 2)}, ${FlxMath.roundDecimal(this.fighter.velocity.y, 2)}] {${FlxMath.roundDecimal(this.fighter.acceleration.x, 2)}, ${FlxMath.roundDecimal(this.fighter.acceleration.y, 2)}}\n';
            Main.debugDisplay.leftAppend += '${this.fighter.getDebugString()}';
         }
      } else {
         Main.debugDisplay.leftAppend += '\n[P${this.slot + 1}] {${this.input.inputType}} ----DISABLED----';
      }
   }

   public function isReady():Bool {
      if (this.type == NONE)
         return true;
      if (this.type == CPU)
         return true; // TODO : check if a player is picking the CPUs character
      if (!this.input.inputEnabled)
         return true;
      if (this.fighterSelection.ready)
         return true;
      return false;
   }

   public function draw() {
      if (Main.debugDisplay == null || /*!this.visible ||*/ !this.ready)
         return;

      if (GameState.shouldDrawCursors) {
         this.coinSprite.draw();
         this.cursorSprite.draw();
         this.debugSprite.draw();
      }
   }

   public function drawBox() {
      if (PlayerBox.STATE != PlayerBoxState.HIDDEN)
         this.playerBox.draw();
   }
}
