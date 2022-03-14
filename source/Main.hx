package;

import GameManager.PlayerBoxState;
import GameManager;
import PlayerSlot.PlayerBox;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.graphics.FlxGraphic;
import inputManager.Action;
import inputManager.GenericButton;
import inputManager.InputHelper;
import inputManager.InputManager;
import inputManager.Profile;
import lime.app.Application;
import lime.utils.Log;
import lime.utils.LogLevel;
import match.Match;
import openfl.display.FPS;
import openfl.display.Sprite;
import states.TitleScreenState;

class Main extends Sprite {
   public static var instance:Main;

   public static var fpsCounter:DebugDisplayV2;
   public static var debugDisplay:DebugDisplay;
   public static var targetFps:Int = 60;
   public static var screenSprite:ScreenSprite;

   public static function log(data:Dynamic) {
      try {
         FlxG.log.add(data);
      }
      catch (err) {
         null;
      }
      trace(data);
   }

   // public static function  // some mod logging function idrk anymore

   public function new() {
      super();
      Main.instance = this;
      // FlxGraphic.defaultPersist = true;
      FlxG.autoPause = false;
      #if debug
      Log.level = LogLevel.VERBOSE;
      #else
      Log.level = LogLevel.ERROR;
      #end

      // TODO : load fps setting from settings file (i dont think it can be changed without a restart)
      // Main.targetFps = 60;

      Main.fpsCounter = new DebugDisplayV2();

      Main.fpsCounter.alpha = 1;

      addChild(new FlxGame(0, 0, TitleScreenState, 1, Main.targetFps, Main.targetFps, true, false));
      addChild(Main.fpsCounter);

      FlxG.fixedTimestep = true;

      FlxG.gamepads.deviceConnected.add(gamepad -> {
         Main.log('${gamepad.name}.${gamepad.id} connected');
         Main.debugDisplay.notify('${gamepad.name}.${gamepad.id} connected');
      });

      FlxG.gamepads.deviceDisconnected.add(gamepad -> {
         Main.log('${gamepad.name}.${gamepad.id} disconnected');
         Main.debugDisplay.notify('${gamepad.name}.${gamepad.id} disconnected');
         if (InputManager.getUsedGamepads().contains(gamepad)) {
            var slot = InputManager.getPlayerSlotByInput(gamepad);
            if (slot != null) {
               PlayerSlot.getPlayer(slot).setNewInput(NoInput);
            }
         }
      });

      Main.debugDisplay = new DebugDisplay();
      Main.screenSprite = new ScreenSprite();

      Application.current.window.title = 'chroma-fighters';
      FlxG.mouse.visible = false;

      registerClassesWithFlxDebuggerConsole();

      PlayerSlot.initAll();

      trace(Profile.defaultBindings[MENU_CONFIRM].map(b -> b.source));
   }

   public static function registerClassesWithFlxDebuggerConsole():Void {
      #if FLX_DEBUG
      FlxG.debugger.drawDebug = true;

      FlxG.game.debugger.console.registerClass(PlayerSlot);
      FlxG.game.debugger.console.registerClass(InputHelper);
      FlxG.game.debugger.console.registerClass(InputManager);
      // FlxG.game.debugger.console.registerClass(Stage);
      FlxG.game.debugger.console.registerClass(Match);
      FlxG.game.debugger.console.registerClass(PlayerBox);
      FlxG.game.debugger.console.registerEnum(PlayerBoxState);
      FlxG.game.debugger.console.registerClass(GameState);
      // FlxG.game.debugger.console.registerClass(GameManager);
      #end
      return;
   }

   public static var skipKeyboardModeToggleCheckNextUpdate:Bool = false;
}
