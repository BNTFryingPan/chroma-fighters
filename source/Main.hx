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
import openfl.events.Event;
import states.TitleScreenState;

class Main extends Sprite {
   public static var instance:Main;

   // public static var fpsCounter:DebugDisplayV2;
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
      AssetHelper.ready = true;
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

      Main.debugDisplay = new DebugDisplay();

      // Main.fpsCounter.alpha = 1;

      addChild(new FlxGame(0, 0, TitleScreenState, 1, Main.targetFps, Main.targetFps, true, false));
      addChild(Main.debugDisplay);

      FlxG.fixedTimestep = true; // forces a fixed time step. this causes slowdowns on weaker hardware, but makes it more consistent for replays and online

      FlxG.gamepads.deviceConnected.add(gamepad -> { // gamepad connected
         Main.log('${gamepad.name}.${gamepad.id} connected');
         Main.debugDisplay.notify('${gamepad.name}.${gamepad.id} connected');
      });

      FlxG.gamepads.deviceDisconnected.add(gamepad -> { // gamepad connected
         Main.log('${gamepad.name}.${gamepad.id} disconnected');
         Main.debugDisplay.notify('${gamepad.name}.${gamepad.id} disconnected');
         if (InputManager.getUsedGamepads().contains(gamepad)) { // if this gamepad is used
            var slot = InputManager.getPlayerSlotByInput(gamepad);
            if (slot != null) {
               PlayerSlot.getPlayer(slot).setNewInput(NoInput); // set that player to no input; TODO : probably change this so itll pause in game
            }
         }
      });

      FlxG.keys.preventDefaultKeys.push(F3); // some browsers use the F3 key as a shortcut

      // Main.debugDisplay = new DebugDisplay();
      Main.screenSprite = new ScreenSprite();

      Application.current.window.title = 'chroma-fighters';
      FlxG.mouse.visible = false;

      registerClassesWithFlxDebuggerConsole();

      PlayerSlot.initAll();

      stage.addEventListener(Event.RESIZE, __resize);

      trace(Profile.defaultBindings[MENU_CONFIRM].map(b -> b.source));
   }

   function __resize(event:Event):Void {
      Main.debugDisplay.handleResize();
   }

   public static function registerClassesWithFlxDebuggerConsole():Void {
      #if FLX_DEBUG // flixel debugger is disabled in release builds
      FlxG.debugger.drawDebug = true;

      // add enums to flixel console
      FlxG.game.debugger.console.registerEnum(PlayerBoxState);

      // add classes to flixel console
      FlxG.game.debugger.console.registerClass(PlayerSlot);
      FlxG.game.debugger.console.registerClass(InputHelper);
      FlxG.game.debugger.console.registerClass(InputManager);
      // FlxG.game.debugger.console.registerClass(Stage);
      FlxG.game.debugger.console.registerClass(Match);
      FlxG.game.debugger.console.registerClass(PlayerBox);
      FlxG.game.debugger.console.registerClass(GameState);
      FlxG.game.debugger.console.registerClass(GameManager);
      #end
      return;
   }

   public static var skipKeyboardModeToggleCheckNextUpdate:Bool = false;
}
