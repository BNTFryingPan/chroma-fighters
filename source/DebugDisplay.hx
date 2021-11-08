package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import hl.Gc;
import lime.system.System as LimeSys;
import openfl.system.Capabilities as FlCap;
import openfl.system.System as FlSys;

class DebugDisplay extends FlxBasic {
	public var leftText:FlxText;
	public var leftPrepend:String = "";
	public var leftAppend:String = "";

	public var rightText:FlxText;
	public var rightPrepend:String = "";
	public var rightAppend:String = "";

	public var maxMemory:Float = 0;

	public function new() {
		super();

		this.active = false;

		this.leftText = new FlxText(10, 10, 0, "debug-left", 20);

		this.rightText = new FlxText(10, 10, FlxG.width - 20, "debug-right", 20);
		this.rightText.alignment = RIGHT;
	}

	public override function destroy() {
		this.leftText.destroy();
		this.rightText.destroy();
		super.destroy();
	}

	public override function update(elapsed:Float) {
		var memStatsRaw = Gc.stats();
		var memStats = {
			totalAllocated: Math.round(memStatsRaw.totalAllocated / 1024 / 1024 * 100) / 10,
			currentMemory: Math.round(memStatsRaw.currentMemory / 1024 / 1024 * 100) / 10,
			allocationCount: Math.round(memStatsRaw.allocationCount / 1024 / 1024 * 100) / 10,
		};

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
			this.rightText.text += 'Mem: ${memStats.currentMemory} / ${maxMemory}MB\n';
			this.rightText.text += 'Alloc: ${memStats.allocationCount} / ${memStats.totalAllocated}\n';
			this.rightText.text += 'System: ${LimeSys.platformName} (${FlCap.cpuArchitecture})\n\n';
			// this.rightText.text += 'Platform: ${LimeSys.platformName} (${LimeSys.platformVersion})\n\n';
			// this.rightText.text += 'CPU: \n';

			this.rightText.text += this.rightAppend;
		}
	}

	public override function draw():Void {
		if (this.visible) {
			this.leftText.draw();
			this.rightText.draw();
			super.draw();
		}
	}

	@:noCompletion
	override function set_camera(Value:FlxCamera):FlxCamera {
		this.leftText.cameras = [Value];
		this.rightText.cameras = [Value];

		return super.set_camera(Value);
	}

	@:noCompletion
	override function set_cameras(Value:Array<FlxCamera>):Array<FlxCamera> {
		this.leftText.cameras = Value;
		this.rightText.cameras = Value;

		return super.set_cameras(Value);
	}
}
