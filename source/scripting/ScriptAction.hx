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
   ACall(p:Pos, name:String, args:Int); // name(args);
   AReturn(p:Pos); // return stack.pop();
   ADiscard(p:Pos); // stack.pop; // dont care about output
   AJump(p:Pos, to:Int /*, condition:Null<Bool>*/); // pos = to
   AJumpUnless(p:Pos, to:Int); // if (!pop) pos = to
   AJumpIf(p:Pos, to:Int); // if (pop) pos = to
   ASet(p:Pos, name:String);
   AAnd(p:Pos, to:Int); // if (top) pop() else pos = to
   AOr(p:Pos, to:Int); // if (top) pos = to else pop()
   APause(p:Pos); // pauses execution
}

class ScriptActionTools {
   public static function getPos(a:ScriptAction):Pos {
      return a.getParameters()[0];
   }

   public static function debugPrint(a:ScriptAction):String {
      var params:Array<String> = a.getParameters().map(p -> Std.string(p));
      return '[${params.shift().pos}] ${a.getName()} {${params.join(', ')}}';
      //      [ script position ]  action  name   action parameters
   }

   public static function asBytecode(a:ScriptAction):String {
      var params = a.getParameters().map(p -> Std.string(p));
      params.shift(); // dont care about pos
      var stringParams = params.map(p -> {
         if (a.getName() == 'AUnOperation' || a.getName() == 'AOperation') {
            return StringTools.hex(p, 2);
         }
         if (p is String) {
            return '"$p"';
         }
         return Std.string(p);
      })
      return '${a.getName().substring(1).toUpperCase()} ${params.join(" ")}';
   }

   public static function fromBytecode(s:String, line:Int):ScriptAction {
      var parts:Array<Dynamic> = [s.split(' ').shift()];

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
                  if (currentPart.toUpperCase() == 'true') parts.push(true);
                  else if (currentPart.toLowerCase() == 'false') parts.push(false);
                  else parts.push(currentPart);
                  currentPart = '';
               }
         }
         currentPart += s.charAt(pos-1)
      }

      var p:Pos = {line: line, pos: 0, linepos: 0}

      return switch (parts.shift().toUpperCase()) {
         case "NUMBER":
            ANumber(p, Std.parseFloat(parts[0]));
         case "IDENTIFIER":
            AIdentifier(p, parts[0]);
         case "UNOPERATION":
            AUnOperation(p, parts[0]);
         case "OPERATION":
            AOperation(p, parts[0]);
         case "STRING":
            AString(p, parts[0])
         case "CALL":
            ACall(p, parts[0], parts[1]);
         case "RETURN":
            AReturn(p);
         case "DISCARD":
            ADiscard(p);
         case "JUMP":
            AJump(p, parts[0]);
         case "JUMPIF":
            AJumpIf(p, parts[0]);
         case "JUMPUNLESS":
            AJumpUnless(p, parts[0]);
         case "SET":
            ASet(p, parts[0]);
         case "AND":
            AAnd(p, parts[0]);
         case "OR":
            AOr(p, parts[0]);
         case "PAUSE":
            APause(p);
         default:
            throw 'Unknown action on line ${line}';
      }
   }
}
