package;

import flixel.FlxG;
import flixel.FlxGame;
import inputManager.InputHelper;
import inputManager.InputManager;
import lime.app.Application;
import match.Fighter;
import match.Match;
import match.Stage;
import openfl.display.FPS;
import openfl.display.Sprite;
import states.TitleScreenState;

class Main extends Sprite {
    public static var fpsCounter:FPS;
    public static var debugDisplay:DebugDisplay;
    public static var targetFps:Int = 90;

    public static function log(data:Dynamic) {
        try {
            FlxG.log.add(data);
        }
        catch (err) {
            null;
        }
        trace(data);
    }

    public function new() {
        super();
        FlxG.autoPause = false;

        // TODO : load fps setting from settings file (i dont think it can be changed without a restart)
        // Main.targetFps = 60;

        Main.fpsCounter = new FPS(10, 10, 0xFFFFFF);
        addChild(Main.fpsCounter);
        Main.fpsCounter.alpha = 0;

        addChild(new FlxGame(0, 0, TitleScreenState, 1, Main.targetFps, Main.targetFps, true, false));

        Main.debugDisplay = new DebugDisplay();

        Application.current.window.title = 'chroma-fighters';
        FlxG.mouse.visible = false;

        registerClassesWithFlxDebuggerConsole();

        PlayerSlot.initAll();
    }

    public static function registerClassesWithFlxDebuggerConsole():Void {
        #if FLX_DEBUG
        FlxG.game.debugger.console.registerClass(PlayerSlot);
        FlxG.game.debugger.console.registerClass(InputHelper);
        FlxG.game.debugger.console.registerClass(InputManager);
        FlxG.game.debugger.console.registerClass(Fighter);
        FlxG.game.debugger.console.registerClass(Stage);
        FlxG.game.debugger.console.registerClass(Match);
        FlxG.game.debugger.console.registerClass(GameManager);
        #end
        return;
    }

    public static var skipKeyboardModeToggleCheckNextUpdate:Bool = false;
}
