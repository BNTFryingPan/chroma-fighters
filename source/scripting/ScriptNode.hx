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
   NConditional(p:Pos, condition:ScriptNode, result:ScriptNode, elseResult:Null<ScriptNode>);
}

class ScriptNodeTools {
   public static function getPos(a:ScriptNode):Pos {
      return a.getParameters()[0];
   }

   public static function debugPrint(a:ScriptNode):String {
      // gets the syntax tree of this node
      var params = [
         for (param in a.getParameters()) {
            if (param is Array) {
               var array:Array<Dynamic> = cast param;
               '[${[for ( subParam in array ) {
                  if ( subParam is ScriptNode ) {
                     ScriptNodeTools.debugPrint(subParam);
                  } else {
                     Std.string( subParam ); 
                  }
               }].join(',
               ')}]';
            }
            // else if (Reflect.isEnumValue(param))
            else if (param is ScriptNode)
               ScriptNodeTools.debugPrint(param);
            else
               Std.string(param);
         }
      ];
      return '{"type": "${a.getName()}", "params": [${params.join(', ')}]}';
      // var params:Array<String> = a.getParameters().map(p -> Std.string(p));
      // var formatted = '[${a.getPos()}] ${a.getName()} {${params.join(', ')}}';
      // trace(formatted);
      // return formatted;
   }
}
