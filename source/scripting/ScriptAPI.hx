package scripting;

import flixel.FlxG;

/**
   default functions availble to scripts
**/
@:keep
class ScriptAPI {
   public static function addOne(scriptPos:Pos, value:Float):Float {
      return value + 1;
   }

   public static function print(scriptPos:Pos, value:Dynamic):Dynamic {
      trace('[Script:${scriptPos}] ${Std.string(value)}');
      #if flixel
      FlxG.log.advanced('[Script:${scriptPos}] ${Std.string(value)}');
      #end
      return value;
   }

   public static function callScriptFunction(name, scriptPos:Pos, ...args:Dynamic):Dynamic {
      if (Reflect.hasField(ScriptAPI, name)) {
         args.prepend(scriptPos);
         return Reflect.callMethod(ScriptAPI, Reflect.field(ScriptAPI, name), args.toArray());
      }
      trace('not found');
      return null;
   }
}
