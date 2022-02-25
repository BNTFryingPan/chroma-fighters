package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import inputManager.InputDevice;
import inputManager.InputHelper;
import inputManager.InputManager;
import inputManager.InputType;
import inputManager.MouseHandler;
import inputManager.Position;
import match.AbstractHitbox;
import states.MatchState;

enum PlayerBoxState {
   GENERIC; // used for generic screens. has swap/dc buttons and controls/name picker, but no fighter selection
   GENERIC_FIGHTER; // above but with fighter selection. used for stage select screen
   FIGHTER_SELECT; // has all the things needed for the character select screen
   IN_GAME; // shows shield, damage, stocks, etc. used in battle/replays
   HIDDEN;
}

class GameState { // this might be jank
   public static var isUIOpen = true;
   public static var shouldDrawCursors = false;
   public static var isPlayingOnline = false;
   public static var isInMatch = false;
   public static var isTrainingMode = false;
   public static var showTrainingHitboxes = false;
   public static var showTrainingLaunchLines = false;

   // public static function getShouldDrawCursors():Bool {
   //    return isUIOpen && s
   // }

   public static function shouldDrawHitboxes():Bool {
      return #if !debug isTrainingMode && #end showTrainingHitboxes;
   }
}

class ScreenSprite extends FlxSprite {
   public function new() {
      super(0, 0);
      this.scrollFactor.set(0, 0);
      this.makeGraphic(FlxG.width, FlxG.height, 0, true);
   }

   override public function draw() {
      super.draw();
      FlxSpriteUtil.fill(this, 0);
      // FlxSpriteUtil.drawCircle(this, 100, 100, 100, 0xffffffff);
   }

   private static function p(pos:Position):Position {
      return {x: pos.x - Main.screenSprite.camera.scroll.x, y: pos.y - Main.screenSprite.camera.scroll.y};
   }

   public static function line(p1:Position, p2:Position, ?opts:LineStyle) {
      p1 = p(p1);
      p2 = p(p2);
      FlxSpriteUtil.drawLine(Main.screenSprite, p1.x, p1.y, p2.x, p2.y, opts);
   }

   public static function circle(pos:Position, radius:Float, ?opts:LineStyle) {
      var m = p(pos);
      // Main.debugDisplay.rightPrepend += '${pos} -> ${m}\n';
      FlxSpriteUtil.drawCircle(Main.screenSprite, m.x, m.y, radius, 0x55FF00FF, opts);
   }

   public static function rect(p1:Position, p2:Position, ?opts:LineStyle) {
      p1 = p(p1);
      p2 = p(p2);
   }
}

class Physics {
   public static function overlapRaw(?obj1:AbstractHitbox, ?obj2:AbstractHitbox):Bool {
      if (obj1 == null || obj2 == null)
         return false;

      return false;
   }
}

class GameManager {
   public static function update(elapsed:Float) {
      // GameState.isInMatch = (Std.isOfType(FlxG.state, MatchState));
      GameState.isInMatch = (FlxG.state is MatchState);

      if (GameState.isInMatch) {
         for (p in PlayerSlot.getPlayerArray()) {
            if (p.fighter != null)
               p.fighter.update(elapsed);
         }
      }

      PlayerSlot.updateAll(elapsed);
      if (GameState.isInMatch && (GameState.isPlayingOnline || !GameState.isUIOpen)) {
         for (player in PlayerSlot.getPlayerArray(true)) {
            if (player.fighter != null && player.fighter.alive) {
               player.fighter.handleInput(elapsed, player.input);
               if (player.fighter.isInBlastzone((cast FlxG.state).stage)) {
                  player.fighter.die();
               }
            }
         }
      }

      // var pads = FlxG.gamepads.getActiveGamepads().map(p -> p.name);
      // Main.debugDisplay.rightAppend += '${pads}';

      if (InputManager.enabled && !GameState.isInMatch) {
         var emptySlot = PlayerSlot.getFirstOpenPlayerSlot();

         if (emptySlot != null) {
            if (FlxG.keys.pressed.A && FlxG.keys.pressed.S && FlxG.keys.anyJustPressed([A, S])) {
               if (PlayerSlot.getPlayerSlotByInput(KeyboardInput) == null) {
                  PlayerSlot.getPlayer(emptySlot).setNewInput(KeyboardInput, Keyboard);
               } else if (!Main.skipKeyboardModeToggleCheckNextUpdate) {
                  var keyboardPlayer = PlayerSlot.getPlayerByInput(KeyboardInput);
                  // if (Std.isOfType(keyboardPlayer.input, MouseHandler)) {
                  if ((keyboardPlayer.input is MouseHandler)) {
                     keyboardPlayer.setNewInput(KeyboardInput, Keyboard, keyboardPlayer.input.profile.name);
                     Main.debugDisplay.notify("kb player now using only kb");
                  } else {
                     keyboardPlayer.setNewInput(KeyboardAndMouseInput, Keyboard, keyboardPlayer.input.profile.name);
                     Main.debugDisplay.notify("kb player now using kb/m");
                  }
               }
            }
            for (gp in FlxG.gamepads.getActiveGamepads()) {
               if (InputHelper.isPressingConnectCombo(gp)) {
                  PlayerSlot.tryToAddPlayerFromInputDevice(gp);
               }
            }

            Main.skipKeyboardModeToggleCheckNextUpdate = false;
         }
      }

      Main.debugDisplay.update(elapsed);
   }

   public static function draw() {
      // ScreenSprite.circle({x: 100, y: 100}, 50);
      Main.screenSprite.draw();
      if (GameState.isInMatch) {
         for (p in PlayerSlot.getPlayerArray()) {
            if (p.fighter != null)
               p.fighter.draw();
         }
      }
      // ScreenSprite.circle({x: 100, y: 200}, 75);
      PlayerSlot.drawAll();
      Main.debugDisplay.draw();
   }

   public static function getAllObjects():Array<FlxBasic> {
      var ret = [];

      for (fb in FlxG.state.members) {
         ret.push(fb);
      }

      for (player in PlayerSlot.getPlayerArray()) {
         ret.push(player.playerBox.background);
         ret.push(player.playerBox.text);
         ret.push(player.playerBox.swapButton);
         ret.push(player.playerBox.disconnectButton);
      }

      return ret;
   }

   public static function collideWithStage(obj:FlxObject):Bool {
      // if (Std.isOfType(FlxG.state, MatchState)) {
      if ((FlxG.state is MatchState)) {
         var state:MatchState = cast FlxG.state;
         return FlxG.collide(obj, state.stage.mainGround);
      }
      return false;
   }
}
