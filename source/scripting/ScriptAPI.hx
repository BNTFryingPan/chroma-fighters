package scripting;

import haxe.Constraints.Function;

/**
   functions availble to scripts
**/
@:keep
class ScriptAPI {
   public static final functionMap:Map<String, Function> = ["addOne" => addOne];

   public static function addOne(value:Float):Float {
      return value + 1;
   }

   public static function callScriptFunction(name, ...args):Dynamic {
      trace('trying to call ${name} with args (${args.toArray().join(', ')})');
      if (Reflect.hasField(ScriptAPI, name)) {
         return Reflect.callMethod(ScriptAPI, Reflect.field(ScriptAPI, name), args.toArray());
      }
      trace('not found');
      return null;
   }
}
