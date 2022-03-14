package;

import flixel.FlxG;
import flixel.tweens.FlxTween;
import lime.app.Application;
import openfl.display.FPS;
import openfl.system.Capabilities as FlCap;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import states.BaseState;
#if hl
import hl.Gc;
#elseif cpp
import cpp.vm.Gc;
#end

class DebugDisplayV2 extends FPS {
   #if cpp
   private static final os:String = '${FlCap.os}';
   #else
   private static final os:String = 'windows lmao';
   #end

   private final rightText:TextField;

   private final _renderer:String = Application.current.window.context.type;

   public static final _systemText = '${FlCap.manufacturer} ${DebugDisplayV2.os}(${FlCap.cpuArchitecture})';
   public static final _rawSystemText = '${FlCap.version}';
   public static final _haxeVersion = '${haxe.macro.Compiler.getDefine("haxe")}';

   public static var leftPrepend:String = '';
   public static var leftAppend:String = '';

   public static var rightPrepend:String = '';
   public static var rightAppend:String = '';

   public static var maxMemory:Float;

   public static var showReducedInfo:Bool = false;
   public static var showMinimalInfo:Bool = false;

   private var notif:TextField;

   public static var shouldShowAdditions(get, never):Bool;
   public static final startVisible:Bool = #if debug true #else false #end;

   public function new() {
      super(10, 10, 0xff00ff);
      defaultTextFormat = new TextFormat("_sans", 10, 0xff00ff);

      // this.autoSize = TextFieldAut
      this.visible = DebugDisplayV2.startVisible;

      this.rightText = new TextField();
      Main.instance.addChild(this.rightText);

      this.rightText.width = Application.current.window.width;
      this.rightText.height = Application.current.window.height;
      this.rightText.defaultTextFormat = new TextFormat("_sans", 10, 0xff00ff, null, null, null, null, null, TextFormatAlign.RIGHT);
      this.rightText.visible = this.visible;
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
      this.notifTween = FlxTween.num(1, 0, 2.0, {startDelay: 0.5, type: FlxTweenType.ONESHOT}, tweenFunction.bind());
   }

   var notifTween:FlxTween;
   var hasTriggeredDebugAction:Bool = false;

   var crashHeldDuration:Float = 0.0;
   var crashHeldMajor:Bool = false;

   public function update() {
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
         var lText = '';
         if (DebugDisplayV2.shouldShowAdditions) {
            lText += DebugDisplayV2.leftPrepend;
            if (DebugDisplayV2.leftPrepend != "" && !StringTools.endsWith(lText, "\n"))
               lText += "\n";
         }

         lText += 'FPS: ${this.currentFPS}\n';

         // this.leftText.text += 'Game ${Version.getVersionString()} (${#if debug 'debug' #else 'release' #end})\n';
         if (!DebugDisplayV2.showMinimalInfo) {
            var stateId = 'Unknown';
            // if (Std.isOfType(FlxG.state, BaseState)) {
            if ((FlxG.state is BaseState)) {
               var state:BaseState = cast FlxG.state;

               stateId = state.stateId();
            }
            lText += 'State: ${stateId}\n';
         }

         #if telemetry
         lText += '[Telemetry Build]\n';
         #end
         if (DebugDisplayV2.shouldShowAdditions)
            lText += DebugDisplayV2.leftAppend;

         var rText = '';
         if (DebugDisplayV2.shouldShowAdditions) {
            rText += DebugDisplayV2.rightPrepend;
            if (DebugDisplayV2.rightPrepend != "" && !StringTools.endsWith(rText, "\n"))
               rText += "\n";
         }

         rText += 'Haxe: ${DebugDisplayV2._haxeVersion}\n';
         rText += 'Flixel: ${FlxG.VERSION.toString()}\n';

         if (!showMinimalInfo) {
            rText += 'Renderer: ${this._renderer}\n';
            // this.rightText.text += 'Build: ${Build.getBuildNumber()}\n';
            rText += 'Mem: ${round(memStats.currentMemory)} / ${round(maxMemory)}MB\n';
            rText += 'Alloc: ${round(memStats.allocationCount)} / ${round(memStats.totalAllocated)}\n';
            rText += 'System: ${DebugDisplayV2._systemText}\n';
         }
         if (!showReducedInfo)
            rText += 'SysRaw: ${DebugDisplayV2._rawSystemText}\n';
         // this.rightText.text += 'Elapsed: ${}';
         // this.rightText.text += 'Platform: ${LimeSys.platformName} (${LimeSys.platformVersion})\n\n';
         // this.rightText.text += 'CPU: \n';
         if (!showReducedInfo)
            rText += MenuMusicManager.debugText();

         if (DebugDisplayV2.shouldShowAdditions)
            rText += '${DebugDisplayV2.rightAppend}';

         this.text = lText;
         this.rightText.text = rText;

         // this.leftText.text = lText;
         // this.rightText.text = rText;
         // this.leftText = new FlxText(10, 10, FlxG.width - 20, lText, DebugDisplay.fontSize);
         // this.rightText = new FlxText(10, 10, FlxG.width - 20, rText, DebugDisplay.fontSize);
         // this.rightText.alignment = RIGHT;
      }
      DebugDisplayV2.rightPrepend = "";
      DebugDisplayV2.rightAppend = "";
      DebugDisplayV2.leftPrepend = "";
      DebugDisplayV2.leftAppend = "";
   }

   @:noCompletion
   private #if !flash override #end function __enterFrame(deltaTime:Float):Void {
      currentTime += deltaTime;
      times.push(currentTime);

      while (times[0] < currentTime - 1000) {
         times.shift();
      }

      var currentCount = times.length;
      currentFPS = Math.round((currentCount + cacheCount) / 2);

      /*if (currentCount != cacheCount /*&& visible) {
         text = "FPS: " + currentFPS;

         #if (gl_stats && !disable_cffi && (!html5 || !canvas))
         text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
         text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
         text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
         #end
      }*/

      cacheCount = currentCount;
   }

   static function get_shouldShowAdditions():Bool {
      return !showReducedInfo || !showMinimalInfo;
   }
}
