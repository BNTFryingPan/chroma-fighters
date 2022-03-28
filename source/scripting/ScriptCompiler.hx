package scripting;

class ScriptCompiler {
   static var actions:Array<ScriptAction>;

   static inline function add(a:ScriptAction):Void {
      actions.push(a);
   }

   static function expr(node:ScriptNode):Void {
      switch (node) {
         case NNumber(p, f):
            add(ANumber(p, f));
         case NIdentifier(p, s):
            add(AIdentifier(p, s));
         case NUnOperator(p, op, q):
            expr(q);
            add(AUnOperation(p, op));
         case NOperator(p, op, a, b):
            expr(a);
            expr(b);
            add(AOperation(p, op));
         case NString(p, v):
            add(AString(p, v));
         case NCall(p, name, args):
            for (arg in args) {
               expr(arg);
            }
            add(ACall(p, name, args.length));
         case NBlock(p, nodes):
            for (blockNode in nodes)
               expr(blockNode);
         case NReturn(p, ret):
            expr(ret);
            add(AReturn(p));
         case NDiscard(p, ret):
            expr(ret);
            add(ADiscard(p));
      }
   }

   public static function compile(node:ScriptNode):Array<ScriptAction> {
      actions = [];
      expr(node);
      return actions;
   }
}
