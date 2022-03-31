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
   AJumpIf(p:Pos, to:Pos); // if (pop) pos = to
   ASet(p:Pos, name:String);
   AAnd(p:Pos, to:Pos); // if (top) pop() else pos = to
   AOr(p:Pos, to:Pos); // if (top) pos = to else pop()
   APause(p:Pos);
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

   public static function asBytecode(a:ScriptAction):String {
      
   }

   public static function fromBytecode(s:String, line:Int):ScriptAction {
      var parts:Array<String> = s.split(' ').shift();

      // parse the string. splitting on spaces doesnt do what i need it to
      var pos = parts[0].length;
      while (pos < s.length) {
         var start = pos;
         var c = s.charCodeAt(pos++);
         switch (c) {
            case '"'.code | "'".code:
               while (pos < s.length) {
                  var n = s.charCodeAt(pos++);
                  if (n == c && s.charCodeAt(pos-2) != '\\'.code)
                     break;
               }
            case ' '.code:
               if (!inString) {
                  parts.push(currentPart);
                  currentPart = '';
               }
            case 'b'.code:
               (s.charCodeAt(pos) == '0'.code)
         }
         currentPart += s.charAt(pos-1)
      }

      var p:Pos = {line: line, pos: 0, linepos: 0}

      return switch (parts[0].toUpperCase()) {
         case "NUMBER":
            ANumber(p, Std.parseFloat(parts[1]));
         case "IDENTIFIER":
            AIdentifier(p, parts[1]);
         case "UNOPERATION":
         case "OPERATION":
         case "STRING":
         case "CALL":
      }
   }
}
