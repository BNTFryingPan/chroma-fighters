package;

import GameManager.GameState;
import exception.DebugException;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import inputManager.InputManager;
import lime.app.Application;
import openfl.display.FPS;
import openfl.events.Event;
import openfl.events.EventType;
import openfl.net.FileReference;
import openfl.system.Capabilities as FlCap;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import states.BaseState;
import states.MatchState;
#if hl
import hl.Gc;
#elseif cpp
import cpp.vm.Gc;
#end

class DebugDisplay extends FPS {
   #if cpp
   private static final os:String = '${FlCap.os}';
   #else
   private static final os:String = 'windows lmao';
   #end

   private final rightText:TextField;

   private final _renderer:String = Application.current.window.context.type;

   public static final _systemText = '${FlCap.manufacturer} ${DebugDisplay.os}(${FlCap.cpuArchitecture})';
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
      trace('new debug display v2');
      defaultTextFormat = new TextFormat("_sans", 10, 0xff00ff);
      this.rightText = new TextField();

      this.autoSize = TextFieldAutoSize.LEFT;
      this.visible = DebugDisplay.startVisible;

      this.rightText.defaultTextFormat = new TextFormat("_sans", 10, 0xff00ff, null, null, null, null, null, TextFormatAlign.RIGHT);
      this.rightText.autoSize = TextFieldAutoSize.RIGHT;
      this.rightText.x = Application.current.window.width - this.rightText.width;
      this.rightText.selectable = false;
      this.rightText.mouseEnabled = false;
      this.rightText.y = 10;

      this.notif = new TextField();
      this.notif.defaultTextFormat = new TextFormat("_sans", 10, 0xff00ff);
      this.notif.autoSize = TextFieldAutoSize.RIGHT;
      this.notif.selectable = false;
      this.notif.mouseEnabled = false;

      addEventListener(Event.ADDED, __added);
   }

   override function set_visible(value:Bool):Bool {
      this.rightText.visible = value;
      return this.visible;
      // return super.set_visible(value);
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

   public function handleDebugKeys(elapsed:Float) {
      if (FlxG.keys.justReleased.C) {
         this.crashHeldDuration = 0;
      } else if (FlxG.keys.pressed.C) {
         this.crashHeldDuration += elapsed;
         this.notify('Crashing in ${10 - Math.floor(this.crashHeldDuration)} seconds...');

         if (this.crashHeldDuration >= 10)
            throw new DebugException('Debug Crash');
      }

      /*if (FlxG.keys.justPressed.D) {
         this.hasTriggeredDebugAction = true;

         var file = new FileReference();

      }*/

      if (FlxG.keys.justPressed.ONE) {
         this.hasTriggeredDebugAction = true;
         if (GameState.isInMatch) {} else {
            MenuMusicManager.musicState = TITLE;
         }
      }

      if (FlxG.keys.justPressed.TWO) {
         this.hasTriggeredDebugAction = true;
         if (GameState.isInMatch) {
            if (!GameState.isPlayingOnline #if !debug && GameState.isTrainingMode #end) {
               FlxG.timeScale = 1;
               this.notify('Time scale reset to ${FlxMath.roundDecimal(FlxG.timeScale, 1)} (=1)');
            } else {
               this.notify(#if debug 'Time scale only allowed offline' #else 'Time scale only allowed in offline training' #end
               );
            }
         } else {
            MenuMusicManager.musicState = FIGHTER_SELECT;
         }
      }

      if (FlxG.keys.justPressed.THREE) {
         this.hasTriggeredDebugAction = true;
         if (GameState.isInMatch) {
            if (!GameState.isPlayingOnline #if !debug && GameState.isTrainingMode #end) {
               FlxG.timeScale = Math.min(2, FlxG.timeScale + 0.1);
               this.notify('Time scale increased to ${FlxMath.roundDecimal(FlxG.timeScale, 1)} (+0.1)');
            } else {
               this.notify(#if debug 'Time scale only allowed offline' #else 'Time scale only allowed in offline training' #end
               );
            }
         } else {
            MenuMusicManager.musicState = STAGE_SELECT;
         }
      }

      if (FlxG.keys.justPressed.FOUR) {
         if (!GameState.isInMatch) {
            this.hasTriggeredDebugAction = true;
            MenuMusicManager.musicState = SUB_PURE;
         }
      }

      if (FlxG.keys.justPressed.FIVE) {
         if (!GameState.isInMatch) {
            this.hasTriggeredDebugAction = true;
            MenuMusicManager.musicState = SUB_A;
         }
      }

      if (FlxG.keys.justPressed.SIX) {
         if (!GameState.isInMatch) {
            this.hasTriggeredDebugAction = true;
            MenuMusicManager.musicState = SUB_B;
         }
      }

      if (FlxG.keys.justPressed.SEVEN) {
         if (!GameState.isInMatch) {
            this.hasTriggeredDebugAction = true;
            MenuMusicManager.musicState = WACKY;
         }
      }

      if (GameState.trainingFrameStepMode && FlxG.keys.justPressed.FOUR) {
         this.hasTriggeredDebugAction = true;
         GameState.trainingFrameStepTick = true;
         this.notify('Next frame');
      }

      if (FlxG.keys.justPressed.Y) {
         this.hasTriggeredDebugAction = true;
         #if hl
         Gc.dumpMemory('hlmemory.dump');
         this.notify('dumped memory to `hlmemory.dump`');
         #else
         this.notify('dump not supported on this target');
         #end
      }

      if (FlxG.keys.justPressed.T) {
         this.hasTriggeredDebugAction = true;
         // TODO: reload textures
         AssetHelper.imageCache.clear();
         if (FlxG.keys.pressed.SHIFT) {
            AssetHelper.aseCache.clear();
            AssetHelper.scriptCache.clear();
            this.notify('Cleared all AssetHelper caches');
         } else {
            this.notify('Cleared AssetHelper BitmapData cache');
         }
         GameManager.reloadTextures();
      }

      if (FlxG.keys.justPressed.R) {
         this.hasTriggeredDebugAction = true;
         AssetHelper.scriptCache.clear();
         this.notify('Cleared script cache');
      }

      if (FlxG.keys.justPressed.B) {
         this.hasTriggeredDebugAction = true;
         if (FlxG.keys.pressed.SHIFT) {
            #if FLX_DEBUG
            FlxG.debugger.drawDebug = !FlxG.debugger.drawDebug;
            this.notify('Flixel debug drawing ${FlxG.debugger.drawDebug ? 'en' : 'dis'}abled.');
            #else
            this.notify('Flixel debugger not available in non-debug builds!');
            #end
         } else {
            GameState.showTrainingHitboxes = !GameState.showTrainingHitboxes;
            this.notify('Hitbox rendering ${GameState.showTrainingHitboxes ? 'en' : 'dis'}abled.');
         }
      }

      if (FlxG.keys.justPressed.H) {
         this.hasTriggeredDebugAction = true;
         #if hl
         Gc.major();
         this.notify('Ran major garbage collector');
         #elseif cpp
         Gc.run(FlxG.keys.pressed.SHIFT);
         this.notify('Ran cpp major garbage collector');
         #else
         this.notify('garbage collector not supported on this target');
         #end
      }

      if (FlxG.keys.justPressed.Q) {
         this.hasTriggeredDebugAction = true;
         if (!InputManager.enabled) {
            this.notify('Input Manager not enabled yet...');
         } else {
            PlayerSlot.getPlayer(P2).setNewInput(CPUInput);
            PlayerSlot.getPlayer(P2).fighterSelection.ready = true;
            PlayerSlot.getPlayer(P1).fighterSelection.ready = true;
            FlxG.switchState(new MatchState(new NamespacedKey('cf_stages', 'chroma_fracture')));
         }
      }

      if (FlxG.keys.justPressed.W) {
         this.hasTriggeredDebugAction = true;
         #if debug
         GameState.animationDebugMode = !GameState.animationDebugMode;
         this.notify('Animation debugger ${GameState.animationDebugMode ? 'en' : 'dis'}abled.');
         #else
         this.notify('Animation debugger not available in non-debug builds');
         #end
      }

      if (FlxG.keys.justPressed.E) {
         this.hasTriggeredDebugAction = true;
         if (GameState.isInMatch && (#if !debug GameState.isTrainingMode && #end!GameState.isPlayingOnline)) {
            GameState.trainingFrameStepMode = !GameState.trainingFrameStepMode;
            this.notify('Frame step ${GameState.trainingFrameStepMode ? 'en' : 'dis'}abled.');
         } else {
            this.notify('Frame step only allowed offline in training');
         }
      }

      if (FlxG.keys.justPressed.M) {
         this.hasTriggeredDebugAction = true;
         MenuMusicManager.pause();
         AssetHelper.getSoundAsset(NamespacedKey.ofDefaultNamespace('sound/amogus3')).play().onComplete = MenuMusicManager.resume;
      }
   }

   public function update() {
      if (FlxG.keys.pressed.F3) {
         this.handleDebugKeys(FlxG.elapsed);
      }

      if (FlxG.keys.justReleased.F3) {
         if (!this.hasTriggeredDebugAction) {
            DebugDisplay.showMinimalInfo = !DebugDisplay.showMinimalInfo;
         }
         this.hasTriggeredDebugAction = false;
      }

      #if debug
      if (GameState.animationDebugMode && FlxG.keys.pressed.F4) {
         if (FlxG.keys.justPressed.ONE) {
            GameState.animationDebugTick = true;
            this.notify('AnimDebugger: Next frame');
         }
      }
      #end

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
         if (DebugDisplay.shouldShowAdditions) {
            lText += DebugDisplay.leftPrepend;
            if (DebugDisplay.leftPrepend != "" && !StringTools.endsWith(lText, "\n"))
               lText += "\n";
         }

         lText += 'FPS: ${this.currentFPS}\n';

         // this.leftText.text += 'Game ${Version.getVersionString()} (${#if debug 'debug' #else 'release' #end})\n';
         if (!DebugDisplay.showMinimalInfo) {
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
         if (DebugDisplay.shouldShowAdditions)
            lText += DebugDisplay.leftAppend;

         var rText = '';
         if (DebugDisplay.shouldShowAdditions) {
            rText += DebugDisplay.rightPrepend;
            if (DebugDisplay.rightPrepend != "" && !StringTools.endsWith(rText, "\n"))
               rText += "\n";
         }

         #if !debug
         if (!showMinimalInfo) {
         #end
            rText += 'Haxe: ${DebugDisplay._haxeVersion}\n';
            rText += 'Flixel: ${FlxG.VERSION.toString()}\n';
         #if !debug
         }
         #end

         if (!showMinimalInfo) {
            rText += 'Renderer: ${this._renderer}\n';
            // this.rightText.text += 'Build: ${Build.getBuildNumber()}\n';
            rText += 'Mem: ${round(memStats.currentMemory)} / ${round(maxMemory)}MB\n';
            rText += 'Alloc: ${round(memStats.allocationCount)} / ${round(memStats.totalAllocated)}\n';
            rText += 'System: ${DebugDisplay._systemText}\n';
         }
         if (!showReducedInfo)
            rText += 'SysRaw: ${DebugDisplay._rawSystemText}\n';
         // this.rightText.text += 'Elapsed: ${}';
         // this.rightText.text += 'Platform: ${LimeSys.platformName} (${LimeSys.platformVersion})\n\n';
         // this.rightText.text += 'CPU: \n';
         if (!showReducedInfo)
            rText += MenuMusicManager.debugText();

         if (DebugDisplay.shouldShowAdditions)
            rText += '${DebugDisplay.rightAppend}';

         this.text = lText;
         this.rightText.text = rText;

         // this.leftText.text = lText;
         // this.rightText.text = rText;
         // this.leftText = new FlxText(10, 10, FlxG.width - 20, lText, DebugDisplay.fontSize);
         // this.rightText = new FlxText(10, 10, FlxG.width - 20, rText, DebugDisplay.fontSize);
         // this.rightText.alignment = RIGHT;
      }
      DebugDisplay.rightPrepend = "";
      DebugDisplay.rightAppend = "";
      DebugDisplay.leftPrepend = "";
      DebugDisplay.leftAppend = "";
   }

   private function __added(event:Event):Void {
      Main.instance.addChild(this.rightText);
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
      return (!showReducedInfo) && (!showMinimalInfo);
   }

   public function handleResize() {
      this.rightText.x = Application.current.window.width - this.rightText.width - 10;
      // this.notif.y = Application.current.window.height - this.notif.height - 10;
   }
}
