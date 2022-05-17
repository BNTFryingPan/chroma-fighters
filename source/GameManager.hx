package;

import PlayerSlot.PlayerSlotIdentifier;
import PlayerSlot.PlayerSlotIdentifier;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import haxe.EnumFlags;
import inputManager.Coordinates;
import inputManager.InputDevice;
import inputManager.InputHelper;
import inputManager.InputManager;
import inputManager.InputType;
import inputManager.MouseHandler;
import match.MatchObject;
import match.Ruleset;
import match.hitbox.AbstractHitbox;
import states.MatchState;
import states.TitleScreenState;
import states.sub.MatchResults;
#if cpp
import flixel.addons.plugin.screengrab.FlxScreenGrab;
#end

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
   public static var showTrainingHitboxes = #if debug true #else false #end;
   public static var showTrainingLaunchLines = #if debug true #else false #end;
   public static var trainingFrameStepMode:Bool = false;
   public static var trainingFrameStepTick:Bool = false;
   #if debug
   public static var animationDebugMode:Bool = false;
   public static var animationDebugTick:Bool = false;
   #end

   public static var justPaused:Bool = false;
   public static var pausedPlayer(default, set):Null<PlayerSlotIdentifier> = null;
   public static var isPaused(get, never):Bool;

   public static function set_pausedPlayer(?slot:PlayerSlotIdentifier):Null<PlayerSlotIdentifier> {
      if (slot != null)
         justPaused = true;

      return pausedPlayer = slot;
   }

   public static function get_isPaused():Bool {
      return pausedPlayer != null;
   }

   public static function trainingFrameStepCheck():Bool {
      if (trainingFrameStepMode)
         return trainingFrameStepTick;
      return true;
   }

   public static function shouldDoMatchTick():Bool {
      if (!isInMatch)
         return false;
      if (isPlayingOnline)
         return true;
      if (isTrainingMode && !isPaused)
         return true;
      if (isUIOpen)
         return false;
      return trainingFrameStepCheck() && !isPaused;
   }

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
      // FlxSpriteUtil.fill(this, 0);
      // FlxSpriteUtil.drawCircle(this, 100, 100, 100, 0xffffffff);
   }

   override public function update(elapsed:Float) {
      super.update(elapsed);
      FlxSpriteUtil.fill(this, 0);
   }

   public static function line(p1:Coordinates, p2:Coordinates, ?opts:LineStyle) {
      FlxSpriteUtil.drawLine(Main.screenSprite, p1.sx, p1.sy, p2.sx, p2.sy, opts);
      p1.putWeak();
      p2.putWeak();
   }

   public static function circle(pos:Coordinates, radius:Float, ?opts:LineStyle) {
      FlxSpriteUtil.drawCircle(Main.screenSprite, pos.sx, pos.sy, radius, 0x55FF00FF, opts);
      pos.putWeak();
   }

   public static function rect(p1:Coordinates, p2:Coordinates, ?opts:LineStyle) {
      var x = Math.min(p1.sx, p2.sx);
      var y = Math.min(p1.sy, p2.sy);
      var w = Math.max(p1.sx, p2.sx) - x;
      var h = Math.max(p1.sy, p2.sy) - y;
      FlxSpriteUtil.drawRect(Main.screenSprite, x, y, w, h, 0x2200ff00, opts);
      p1.putWeak();
      p2.putWeak();
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
   public static var ruleset:Ruleset = new Ruleset(3, 7, 1);

   public static function update(elapsed:Float) {
      // Main.fpsCounter.update();
      Main.screenSprite.update(elapsed);
      // GameState.isInMatch = (Std.isOfType(FlxG.state, MatchState));
      GameState.isInMatch = (FlxG.state is MatchState);

      if (GameState.shouldDoMatchTick()) {
         var alivePlayers = 0;
         var deadPlayers = 0;
         var lastPlayer:String = "nobody?";
         for (p in PlayerSlot.players) {
            if (p.fighter != null) {
               if (p.fighter.alive) {
                  lastPlayer = p.getName();
                  p.fighter.update(elapsed);
                  alivePlayers++;
               } else
                  deadPlayers++;
            }
            if (!GameState.isPaused && p.input.getPause() == JUST_PRESSED)
               GameManager.pause(p.slot);
         }
         if (alivePlayers <= 1 && deadPlayers > 0) {
            if (FlxG.state.subState == null)
               FlxG.state.openSubState(new MatchResults(lastPlayer));
         }
      }

      PlayerSlot.updateAll(elapsed);

      if (GameState.shouldDoMatchTick()) {
         for (player in PlayerSlot.players) {
            if (player.type != NONE && player.fighter != null && player.fighter.alive) {
               player.fighter.handleInput(elapsed, player.input);
               if (player.fighter.isInBlastzone((cast FlxG.state).stage)) {
                  player.fighter.die();
               }
            }
         }
      }

      if (GameState.isInMatch && GameState.isPaused) {
         for (player in PlayerSlot.players) {
            if (player.input.getPause() == JUST_PRESSED) {
               GameManager.unpause(player.slot);
               break;
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

      #if debug
      GameState.animationDebugTick = false;
      #end
      GameState.trainingFrameStepTick = false;
      GameState.justPaused = false;

      Main.debugDisplay.update();

      #if cpp
      if (FlxG.keys.anyJustPressed([F2])) {
         FlxScreenGrab.grab(null, true, true);
      }
      #end
   }

   public static function draw_preSubState() {
      if (GameState.isInMatch)
         for (p in PlayerSlot.players)
            if (p.fighter != null)
               p.fighter.draw();
   }

   public static function draw() {
      Main.screenSprite.draw();

      PlayerSlot.drawAll();

      // draw all the fighters

      // Main.debugDisplay.draw();

      // return (!GameState.isPaused);
   }

   public static function getAllObjects():Array<FlxBasic> {
      var ret:Array<FlxBasic> = [];

      // adds the children of the current FlxState
      var state = FlxG.state;
      while (state != null) {
         ret = ret.concat(state.members);
         // trace('added ${state.members.length} things to list from ${state}');
         state = state.subState;
      }

      for (player in PlayerSlot.players) {
         // adds player box objects
         ret.push(player.playerBox.background);
         ret.push(player.playerBox.text);
         ret.push(player.playerBox.swapButton);
         ret.push(player.playerBox.disconnectButton);

         // ads player fighter objects
         ret.push(player.fighter);
         // ret.push(player.fighter.getBasicChildren());
      }
      trace('got ${ret.length} items from all places');
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

   public static function reloadTextures() {
      for (object in GameManager.getAllObjects().filter(o -> o is IMatchObject))
         (cast object).reloadTextures(); // casts to IMatchObject
   }

   public static function pause(slot:PlayerSlotIdentifier) {
      if (GameState.isInMatch && !GameState.isPaused && FlxG.state is MatchState) {
         (cast FlxG.state).pause(slot); // casts to MatchState
         GameState.isUIOpen = true;
         GameState.shouldDrawCursors = true;
         trace('set draw cursors: ${GameState.shouldDrawCursors}');
      }
   }

   public static function unpause(slot:PlayerSlotIdentifier) {
      if (GameState.isInMatch && GameState.isPaused && GameState.pausedPlayer == slot && FlxG.state is MatchState) {
         (cast FlxG.state).unpause(); // casts to MatchState
         GameState.isUIOpen = false;
         GameState.shouldDrawCursors = false;
      }
   }

   /**
      gets the knockback multiplier of the current ruleset
   **/
   public static function getKnockbackMultiplier():Float {
      return GameManager.ruleset.knockback;
   }

   public static function isMaster(slot:PlayerSlotIdentifier):Bool {
      if (slot == P1) {
         return true;
      }

      if (PlayerSlot.getPlayer(slot).input.isKeyboard())
         return true;
      return false;
   }

   public static function returnToTitleScreen() {
      GameState.pausedPlayer = null;
      FlxG.switchState(new TitleScreenState());
   }
}
