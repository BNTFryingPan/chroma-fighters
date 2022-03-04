package;

import AssetHelper;
import GameManager.GameState;
import exception.DebugException;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import inputManager.Action;
import inputManager.InputManager;
import lime.system.System as LimeSys;
import openfl.system.Capabilities as FlCap;
import states.BaseState;
import states.MatchState;
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

   #if cpp
   private static final os:String = '${FlCap.os}';
   #else
   private static final os:String = 'windows lmao';
   #end

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

      this.leftText.scrollFactor.x = 0;
      this.leftText.scrollFactor.y = 0;
      this.rightText.scrollFactor.x = 0;
      this.rightText.scrollFactor.y = 0;
      this.notif.scrollFactor.x = 0;
      this.notif.scrollFactor.y = 0;
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
      this.notifTween = FlxTween.num(1, 0, 2.0, {startDelay: 0.5, type: FlxTweenType.ONESHOT}, tweenFunction.bind());
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
            this.notify('Crashing in ${10 - Math.floor(this.crashHeldDuration)} seconds...');

            if (this.crashHeldDuration > 10) {
               throw new DebugException('Debug Crash');
            }
         }

         if (FlxG.keys.anyJustPressed([ONE])) {
            this.hasTriggeredDebugAction = true;
            if (GameState.isInMatch && !GameState.isPlayingOnline #if !debug && GameState.isTrainingMode #end) {
               FlxG.timeScale = Math.max(0.1, FlxG.timeScale - 0.1);
               this.notify('Time scale lowered to ${FlxMath.roundDecimal(FlxG.timeScale, 1)} (-0.1)');
            } else {
               this.notify(#if debug 'Time scale only allowed offline' #else 'Time scale only allowed in offline training' #end
               );
            }
         }

         if (FlxG.keys.anyJustPressed([TWO])) {
            this.hasTriggeredDebugAction = true;
            if (GameState.isInMatch && !GameState.isPlayingOnline #if !debug && GameState.isTrainingMode #end) {
               FlxG.timeScale = 1;
               this.notify('Time scale reset to ${FlxMath.roundDecimal(FlxG.timeScale, 1)} (=1)');
            } else {
               this.notify(#if debug 'Time scale only allowed offline' #else 'Time scale only allowed in offline training' #end
               );
            }
         }

         if (FlxG.keys.anyJustPressed([THREE])) {
            this.hasTriggeredDebugAction = true;
            if (GameState.isInMatch && !GameState.isPlayingOnline #if !debug && GameState.isTrainingMode #end) {
               FlxG.timeScale = Math.min(2, FlxG.timeScale + 0.1);
               this.notify('Time scale increased to ${FlxMath.roundDecimal(FlxG.timeScale, 1)} (+0.1)');
            } else {
               this.notify(#if debug 'Time scale only allowed offline' #else 'Time scale only allowed in offline training' #end
               );
            }
         }

         if (FlxG.keys.anyJustPressed([Y])) {
            this.hasTriggeredDebugAction = true;
            #if hl
            Gc.dumpMemory('hlmemory.dump');
            this.notify('dumped memory to `hlmemory.dump`');
            #else
            this.notify('dump not supported on this target');
            #end
         }

         if (FlxG.keys.anyJustPressed([T])) {
            this.hasTriggeredDebugAction = true;
            // TODO: reload textures
            if (FlxG.keys.anyPressed([SHIFT])) {
               AssetHelper.aseCache.clear();
               AssetHelper.imageCache.clear();
               AssetHelper.scriptCache.clear();
               this.notify('Cleared all AssetHelper caches');
            } else {
               AssetHelper.imageCache.clear();
               this.notify('Cleared AssetHelper BitmapData cache');
            }
         }

         if (FlxG.keys.anyJustPressed([R])) {
            this.hasTriggeredDebugAction = true;
            AssetHelper.scriptCache.clear();
            this.notify('Cleared script cache');
         }

         if (FlxG.keys.anyJustPressed([B])) {
            this.hasTriggeredDebugAction = true;
            if (FlxG.keys.anyPressed([SHIFT])) {
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

         if (FlxG.keys.anyJustPressed([Q])) {
            this.hasTriggeredDebugAction = true;
            if (!InputManager.enabled) {
               this.notify('Input Manager not enabled yet...');
            } else {
               PlayerSlot.getPlayer(P2).setNewInput(CPUInput);
               PlayerSlot.getPlayer(P2).fighterSelection.ready = true;
               PlayerSlot.getPlayer(P1).fighterSelection.ready = true;
               FlxG.switchState(new MatchState());
            }
         }

         if (FlxG.keys.anyJustPressed([W])) {
            this.hasTriggeredDebugAction = true;
            #if debug
            GameState.animationDebugMode = !GameState.animationDebugMode;
            this.notify('Animation debugger ${GameState.showTrainingHitboxes ? 'en' : 'dis'}abled.');
            #else
            this.notify('Animation debugger not available in non-debug builds');
            #end
         }
      }

      if (FlxG.keys.anyJustReleased([F3])) {
         if (!this.hasTriggeredDebugAction) {
            this.visible = !this.visible;
         }

         this.hasTriggeredDebugAction = false;
      }

      #if debug
      if (GameState.animationDebugMode && FlxG.keys.anyPressed([F4])) {
         if (FlxG.keys.anyJustPressed([ONE])) {
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
         this.leftText.text = this.leftPrepend;
         if (this.leftPrepend != "" && !StringTools.endsWith(this.leftText.text, "\n"))
            this.leftText.text += "\n";

         // this.leftText.text += 'Game ${Version.getVersionString()} (${#if debug 'debug' #else 'release' #end})\n';
         var stateId = 'Unknown';
         // if (Std.isOfType(FlxG.state, BaseState)) {
         if ((FlxG.state is BaseState)) {
            var state:BaseState = cast FlxG.state;
            stateId = state.stateId();
         }
         this.leftText.text += 'FPS: ${Main.fpsCounter.currentFPS}\nState: ${stateId}\n';

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
         var gp = FlxG.gamepads.getFirstActiveGamepad();
         this.rightText.text += 'gp: ${gp == null ? 'none' : gp.name}';

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
