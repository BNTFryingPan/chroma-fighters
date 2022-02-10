package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import lime.system.System as LimeSys;
import openfl.system.Capabilities as FlCap;
#if hl
import hl.Gc;
#elseif cpp
import cpp.vm.Gc;
#end

class DebugDisplay extends FlxBasic {
    public var leftText:FlxText;
    public var leftPrepend:String = "";
    public var leftAppend:String = "";

    public var rightText:FlxText;
    public var rightPrepend:String = "";
    public var rightAppend:String = "";

    private var finalLeftText:String = "";
    private var finalRightText:String = "";

    public var notif:FlxText;

    public var maxMemory:Float = 0;

    public static final fontSize:Int = 8;

    private static final os:String = '${FlCap.os}';

    public function new() {
        super();

        this.active = true;
        this.visible = true;

        this.leftText = new FlxText(10, 10, 0, "debug-left", DebugDisplay.fontSize);

        this.rightText = new FlxText(10, 10, FlxG.width - 20, "debug-right", DebugDisplay.fontSize);
        this.rightText.alignment = RIGHT;

        this.notif = new FlxText(10, FlxG.height - 20, 0, "", DebugDisplay.fontSize);
        this.notif.alignment = RIGHT;
        this.notif.alpha = 0;
    }

    public override function destroy() {
        this.leftText.destroy();
        this.rightText.destroy();
        this.notif.destroy();
        super.destroy();
    }

    private function round(f:Float):Float {
        return Math.round(f * 1000) / 1000;
    }

    public function notify(text:String) {
        this.notif.text = text;
        this.notif.alpha = 1;

        function tweenFunction(v:Float) {
            this.notif.alpha = v;
        }

        if (this.notifTween != null) {
            this.notifTween.cancel();
        }
        this.notifTween = FlxTween.num(1, 0, 2.0, {startDelay: 0, type: ONESHOT}, tweenFunction.bind());
    }

    var notifTween:FlxTween;
    var hasTriggeredDebugAction:Bool = false;

    var crashHeldDuration:Float = 0.0;
    var crashHeldMajor:Bool = false;

    public override function update(elapsed:Float) {
        if (FlxG.keys.anyPressed([F3])) {
            if (FlxG.keys.anyJustReleased([C])) {
                this.crashHeldDuration = 0.0;
            }
            if (FlxG.keys.anyPressed([C])) {
                this.crashHeldDuration += elapsed;
                this.notify('crash timer: ${this.crashHeldDuration}')

                if (this.crashHeldDuration > 1000) {
                    throw new DebugException('aaaa')
                }
            }
            if (FlxG.keys.anyJustPressed([Y])) {
                this.hasTriggeredDebugAction = true;
                #if hl
                Gc.dumpMemory('hlmemory.dump');
                this.notify('dumped memory to `hlmemory.dump`')
                #else
                this.notify('dump not supported on this target');
                #end
            }

            if (FlxG.keys.anyJustPressed([T])) {
                this.hasTriggeredDebugAction = true;
                // TODO: reload textures
                this.notify('reloaded textures (jk not yet)');
            }

            if (FlxG.keys.anyJustPressed([H])) {
                this.hasTriggeredDebugAction = true;
                #if hl
                Gc.major();
                this.notify('Ran major garbage collector');
                #elseif cpp
                Gc.run(FlxG.keys.anyPressed([SHIFT]));
                this.notify('Ran cpp major garbage collector');
                #else
                this.notify('garbage collector not supported on this target');
                #end
            }
        }

        if (FlxG.keys.anyJustReleased([F3])) {
            if (!this.hasTriggeredDebugAction) {
                this.visible = !this.visible;
            }

            this.hasTriggeredDebugAction = false;
        }

        #if hl
        var memStatsRaw = Gc.stats();
        var memStats = {
            totalAllocated: Math.round(memStatsRaw.totalAllocated / 1024 / 1024 * 100) / 10,
            currentMemory: Math.round(memStatsRaw.currentMemory / 1024 / 1024 * 100) / 10,
            allocationCount: Math.round(memStatsRaw.allocationCount / 1024 / 1024 * 100) / 10,
        };
        #elseif cpp
        var memStats = {
            totalAllocated: (Gc.memInfo(Gc.MEM_INFO_RESERVED) / 1024) / 1000,
            currentMemory: (Gc.memInfo(Gc.MEM_INFO_CURRENT) / 1024) / 1000,
            allocationCount: 0,
        };
        #else
        var memStats = {
            totalAllocated: 0,
            currentMemory: 0,
            allocationCount: 0,
        };
        #end

        if (memStats.currentMemory > maxMemory)
            maxMemory = memStats.currentMemory;
        if (this.visible) {
            this.leftText.text = this.leftPrepend;
            if (this.leftPrepend != "" && !StringTools.endsWith(this.leftText.text, "\n"))
                this.leftText.text += "\n";

            // this.leftText.text += 'Game ${Version.getVersionString()} (${#if debug 'debug' #else 'release' #end})\n';
            this.leftText.text += 'FPS: ${Main.fpsCounter.currentFPS}\n';

            this.leftText.text += this.leftAppend;

            this.rightText.text = this.rightPrepend;
            if (this.rightPrepend != "" && !StringTools.endsWith(this.rightText.text, "\n"))
                this.rightText.text += "\n";

            this.rightText.text += 'Haxe: ${haxe.macro.Compiler.getDefine("haxe")}\n';
            this.rightText.text += 'Flixel: ${FlxG.VERSION.toString()}\n';
            // this.rightText.text += 'Build: ${Build.getBuildNumber()}\n';
            this.rightText.text += 'Mem: ${round(memStats.currentMemory)} / ${round(maxMemory)}MB\n';
            this.rightText.text += 'Alloc: ${round(memStats.allocationCount)} / ${round(memStats.totalAllocated)}\n';
            this.rightText.text += 'System: ${FlCap.manufacturer} ${DebugDisplay.os} (${FlCap.cpuArchitecture})\n';
            this.rightText.text += 'SysRaw: ${FlCap.version}';
            // this.rightText.text += 'Elapsed: ${}';
            // this.rightText.text += 'Platform: ${LimeSys.platformName} (${LimeSys.platformVersion})\n\n';
            // this.rightText.text += 'CPU: \n';

            this.rightText.text += '\n${this.rightAppend}';
        }
        this.rightPrepend = "";
        this.rightAppend = "";
        this.leftPrepend = "";
        this.leftAppend = "";
    }

    public override function draw():Void {
        if (this.visible) {
            this.leftText.draw();
            this.rightText.draw();
            super.draw();
        }
        this.notif.draw();
    }

    @:noCompletion
    override function set_camera(Value:FlxCamera):FlxCamera {
        this.leftText.cameras = [Value];
        this.rightText.cameras = [Value];
        this.notif.cameras = [Value];

        return super.set_camera(Value);
    }

    @:noCompletion
    override function set_cameras(Value:Array<FlxCamera>):Array<FlxCamera> {
        this.leftText.cameras = Value;
        this.rightText.cameras = Value;
        this.notif.cameras = Value;

        return super.set_cameras(Value);
    }
}
