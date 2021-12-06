package;

import flixel.FlxG;
import flixel.FlxGame;
import lime.app.Application;
import openfl.display.FPS;
import openfl.display.Sprite;
import states.TitleScreenState;

class Main extends Sprite {
    public static var fpsCounter:FPS;
    public static var debugDisplay:DebugDisplay;
    public static var targetFps:Int = 144;

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
        trace("new main");

        // TODO : load fps setting from settings file (i dont think it can be changed without a restart)
        // Main.targetFps = 60;

        addChild(new FlxGame(0, 0, TitleScreenState, 1, Main.targetFps, Main.targetFps, true, false));

        Main.debugDisplay = new DebugDisplay();
        FlxG.state.add(Main.debugDisplay);

        Main.fpsCounter = new FPS(10, 10, 0xFFFFFF);
        addChild(Main.fpsCounter);
        Main.fpsCounter.alpha = 0;

        Application.current.window.title = 'chroma-fighters';
        FlxG.mouse.visible = false;
    }
}
