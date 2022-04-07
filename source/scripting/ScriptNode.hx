package scripting;

import scripting.Op;

@:using(ScriptNode.ScriptNodeTools)
enum ScriptNode {
   NNumber(p:Pos, f:Float);
   NIdentifier(p:Pos, s:String);
   NUnOperator(p:Pos, op:UnOperation, q:ScriptNode);
   NOperator(p:Pos, op:Operation, a:ScriptNode, b:ScriptNode);
   NCall(p:Pos, name:String, args:Array<Dynamic>);
   NString(p:Pos, v:String);
   NBlock(p:Pos, nodes:Array<ScriptNode>);
   NReturn(p:Pos, node:ScriptNode);
   NDiscard(p:Pos, node:ScriptNode);
   NPause(p:Pos, time:ScriptNode);
   // NTypeOf(p:Pos, node:ScriptNode);
   NConditional(p:Pos, condition:ScriptNode, result:ScriptNode, elseResult:Null<ScriptNode>);
   NSet(p:Pos, node:ScriptNode, value:ScriptNode);
   NWhile(p:Pos, condition:ScriptNode, expr:ScriptNode);
   NWhileDo(p:Pos, condition:ScriptNode, expr:ScriptNode);
   NFor(p:Pos, init:ScriptNode, condition:ScriptNode, post:ScriptNode, node:ScriptNode);
   NBreak(p:Pos);
   NContinue(p:Pos);
   NFunction(p:Pos, name:String, args:Array<String>, body:ScriptNode);
}

class ScriptNodeTools {
   public static function getPos(a:ScriptNode):Pos {
      return a.getParameters()[0];
   }

   private static function convertParamToString(param:Dynamic):String {
      if (param is Array) {
         return '[' + param.map(p -> convertParamToString(p)).join(', ') + ']';
      }
      if (param is ScriptNode) {
         return ScriptNodeTools.debugPrint(param);
      }
      if (param is Int || param is Float || param is Bool) {
         return Std.string(param);
      }
      if (param is String) {
         '"${Std.string(param)}"';
      }
      return '{"type": "${Type.typeof(param)}", "value": "${Std.string(param)}"}';
   }

   public static function debugPrint(a:ScriptNode):String {
      // gets the syntax tree of this node
      var params = a.getParameters().map(p -> convertParamToString(p));
      return '{"nodeType": "${a.getName()}", "params": [${params.join(', ')}]}';
      // var params:Array<String> = a.getParameters().map(p -> Std.string(p));
      // var formatted = '[${a.getPos()}] ${a.getName()} {${params.join(', ')}}';
      // trace(formatted);
      // return formatted;
   }
}
