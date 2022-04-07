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
   AJumpPush(p:Pos, to:Int); // jumpstack.add(pos) pos = to;
   AJumpPop(p:Pos); // pos = jumpstack.pop()
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
      return '[${params.shift()}] ${a.getName()} {${params.join(', ')}}';
      //      [ script position ]  action  name   action parameters
   }

   public static function asBytecode(a:ScriptAction):String {
      var params = a.getParameters().map(p -> Std.string(p));
      params.shift(); // dont care about pos
      var stringParams = params.map(p -> {
         if (a.getName() == 'AUnOperation' || a.getName() == 'AOperation') {
            return StringTools.hex(Std.parseInt(p), 2);
         }
         if (p is String) {
            return '"$p"';
         }
         return Std.string(p);
      });
      return '${a.getName().substring(1).toUpperCase()} ${stringParams.join(" ")}';
   }

   public static function fromBytecode(s:String, line:Int):ScriptAction {
      var parts:Array<Dynamic> = [s.split(' ').shift()];

      // parse the string. splitting on spaces doesnt do what i need it to
      var pos = cast(parts[0], String).length;
      while (pos < s.length) {
         var start = pos;
         var c = s.charCodeAt(pos++);
         switch (c) {
            case '"'.code | "'".code:
               while (pos < s.length) {
                  var n = s.charCodeAt(pos++);
                  if (n == c && s.charCodeAt(pos - 2) != '\\'.code) {
                     parts.push(s.substring(start, pos - 1));
                     break;
                  }
               }
            case ' '.code:
               pos++;
            default:
               if (c >= "0".code && c <= "9".code || c == ".".code) {
                  var dot = c == '.'.code;
                  while (pos < s.length) {
                     c = s.charCodeAt(pos);
                     if (c >= "0".code && c <= "9".code) {
                        pos++;
                     } else if (c == '.'.code && !dot) {
                        pos++;
                        dot = true;
                     } else
                        break;
                  }
               }
         }
      }

      var p:Pos = {line: line, pos: 0, linePos: 0}

      switch (parts.shift().toUpperCase()) {
         case "NUMBER":
            return ANumber(p, Std.parseFloat(parts[0]));
         case "IDENTIFIER":
            return AIdentifier(p, parts[0]);
         case "UNOPERATION":
            return AUnOperation(p, parts[0]);
         case "OPERATION":
            return AOperation(p, parts[0]);
         case "STRING":
            return AString(p, parts[0]);
         case "CALL":
            return ACall(p, parts[0], parts[1]);
         case "RETURN":
            return AReturn(p);
         case "DISCARD":
            return ADiscard(p);
         case "JUMP":
            return AJump(p, parts[0]);
         case "JUMPIF":
            return AJumpIf(p, parts[0]);
         case "JUMPUNLESS":
            return AJumpUnless(p, parts[0]);
         case "SET":
            return ASet(p, parts[0]);
         case "AND":
            return AAnd(p, parts[0]);
         case "OR":
            return AOr(p, parts[0]);
         case "PAUSE":
            return APause(p);
         default:
            throw 'Unknown action on line ${line}';
      }
      return ANumber(p, 0);
   }
}
