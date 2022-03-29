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
   AReturn(p:Pos); // return stack.pop();
   ADiscard(p:Pos); // stack.pop; // dont care about output
   AJump(p:Pos, to:Pos /*, condition:Null<Bool>*/); // pos = to
   AJumpUnless(p:Pos, to:Pos); // if (!pop) pos = to
   ASet(p:Pos, name:String);
}

class ScriptActionTools {
   public static function getPos(a:ScriptAction):Pos {
      return a.getParameters()[0];
   }

   public static function debugPrint(a:ScriptAction):String {
      var params:Array<String> = a.getParameters().map(p -> Std.string(p));
      return '[${params.shift()}] ${a.getName()} {${params.join(', ')}}';
      //      [ script position ]  action  name   action parameters
   }
}
