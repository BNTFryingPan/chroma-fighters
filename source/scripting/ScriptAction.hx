package scripting;

import scripting.Op.Operation;
import scripting.Op.UnOperation;

@:using(ScriptAction.ScriptActionTools)
enum ScriptAction {
   ANumber(p:Pos, value:Float);
   AIdentifier(p:Pos, name:String);
   AUnOperation(p:Pos, op:UnOperation);
   AOperation(p:Pos, op:Operation);
   AString(p:Pos, value:String);
   ACall(p:Pos, name:String, args:Int);
}

class ScriptActionTools {
   public static function getPos(a:ScriptAction):Pos {
      return a.getParameters()[0];
   }

   public static function debugPrint(a:ScriptAction):String {
      var params:Array<String> = a.getParameters().map(p -> Std.string(p));
      var formatted = '[${a.getPos()}] ${a.getName()} {${params.join(', ')}}';
      trace(formatted);
      return formatted;
   }
}
