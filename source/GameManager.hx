package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import inputManager.InputDevice;
import inputManager.InputHelper;
import inputManager.InputManager;
import inputManager.InputType;
import inputManager.MouseHandler;
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
   // public static function getShouldDrawCursors():Bool {
   //    return isUIOpen && s
   // }
}

class GameManager {
   public static function update(elapsed:Float) {
      GameState.isInMatch = (Std.isOfType(FlxG.state, MatchState));

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
                  if (Std.isOfType(keyboardPlayer.input, MouseHandler)) {
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
      if (Std.isOfType(FlxG.state, MatchState)) {
         var state:MatchState = cast FlxG.state;
         return FlxG.collide(obj, state.stage.mainGround);
      }
      return false;
   }
}
