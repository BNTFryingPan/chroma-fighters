package scripting;

import scripting.Op;

enum ScriptNode {
   NNumber(p:Pos, f:Float);
   NIdentifier(p:Pos, s:String);
   NCall(p:Pos, name:String, args:Array<Dynamic>);
   NUnOperator(p:Pos, op:UnOperation, q:ScriptNode);
   NOperator(p:Pos, op:Operation, a:ScriptNode, b:ScriptNode);
   NString(p:Pos, v:String);
   NBlock(p:Pos, nodes:Array<ScriptNode>);
   NReturn(p:Pos, node:ScriptNode);
   NDiscard(p:Pos, node:ScriptNode);
}
