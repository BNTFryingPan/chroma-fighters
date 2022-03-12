package;

import openfl.display.FPS;
import openfl.text.TextFormat;

class DebugDisplayV2 extends FPS {
   public function new() {
      super(10, 10, 0xff00ff);
      defaultTextFormat = new TextFormat("_sans", 10, 0xff00ff);
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

      if (currentCount != cacheCount /*&& visible*/) {
         text = "FPS: " + currentFPS;

         #if (gl_stats && !disable_cffi && (!html5 || !canvas))
         text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
         text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
         text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
         #end
      }

      cacheCount = currentCount;
   }
}
