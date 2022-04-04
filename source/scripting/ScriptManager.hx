package scripting;

class ScriptManager {
   static var runningScripts:Array<Script> = [];

   public static function tick() {
      for (script in runningScripts) {
         if (script.isRunning)
            script.exec(false);
      }
   }

   public static function run(script:Script):Null<Dynamic> {
      if (!script.isCompiled.isBlown()) {
         script.compile();
      }

      if (script.isSync()) {
         return script.exec(false);
      }

      runningScripts.push(script);
      return null;
   }
}
