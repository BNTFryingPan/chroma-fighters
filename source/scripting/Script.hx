package scripting;

import haxe.ds.GenericStack;
import scripting.Op.Operation;
import scripting.Op.UnOperation;

/*enum StackEntryType {
   NUMBER;
   STRING;
   NULL;
   }

   class StackEntry<T> {
   public final value:T;
   public final type:StackEntryType;

   private function new(type:StackEntryType, value:T) {
      this.value = value;
      this.type = type;
   }

   public function isString():Bool {
      return this.type == STRING;
   }

   public function isNumber():Bool {
      return this.type == NUMBER;
   }

   public function castTo(targetType:StackEntryType):StackEntry<Dynamic> {
      if (targetType == this.type)
         return this;

      if (targetType == STRING)
         return new StackEntry<String>(STRING, Std.string(this.value));

      if (targetType == NUMBER)
         return new StackEntry<Float>(NUMBER, Std.parseFloat(Std.string(this.value)));

      return new StackEntry<Dynamic>(NULL, null);
   }

   public static function get(value:Dynamic):StackEntry<Dynamic> {
      if (value is String) {
         return new StackEntry<String>(STRING, value);
      }
      if (value is Float || value is Int) {
         return new StackEntry<Float>(NUMBER, value);
      }

      return new StackEntry<Dynamic>(NULL, null);
   }
}*/
class Script {
   public var error:Null<String> = null;

   // private var isParsed:Fuse = new Fuse();
   private var isCompiled:Fuse = new Fuse();
   var contents:String;
   var tokens:Array<ScriptToken> = [];
   var node:ScriptNode;
   var actions:Array<ScriptAction>;
   var pos:Int = 0;

   var stack:GenericStack<Dynamic>;
   var vars:Dynamic;

   function new(script:String) {
      this.contents = script;
   }

   /*
      public function parse() {
         if (this.isParsed.isBlown())
            return;
         this.isParsed.blow();

         this.tokens = Parser.parse(this.contents);
   }*/
   public function compile() {
      this.tokens = ScriptParser.parse(this.contents);
      this.node = ScriptBuilder.build(this.tokens);
      this.actions = ScriptCompiler.compile(this.node);
   }

   public function exec(vars:Null<Dynamic>):Dynamic {
      stack = new GenericStack<Dynamic>();
      if (vars != null)
         this.vars = vars;
      
      pos = 0;
      while (pos < this.actions.length) {
         this.executeAction(this.actions[pos++]);
      }
      //for (act in this.actions) {
      //   this.executeAction(act);
      //}
      return stack.pop();
   }

   function executeAction(action:ScriptAction) {
      inline function error(text:String) {
         return '${text} at position ${action.getPos()}';
      }

      action.debugPrint();

      switch (action) {
         case ANumber(p, value):
            stack.add(value);
         case AString(p, value):
            stack.add(value);
         case AIdentifier(p, name):
            {
               var val = Reflect.field(vars, name);
               if (val is Float) {
                  stack.add(val);
               } else if (Reflect.hasField(vars, name)) {
                  throw error('variable $name is not a number');
               } else
                  throw error('varibale $name does not exist');
            }
         case AOperation(p, op):
            {
               var b = stack.pop();
               var a = stack.pop();
               if (b is String || a is String) {
                  var fin:String;
                  switch (op) {
                     case Operation.ADD:
                        fin = Std.string(a) + Std.string(b);
                     /*case Operation.MULTIPLY:
                        if (b.isNumber() || a.isNumber()) {
                           fin = Std.string(a.value * b.value);
                     } else throw error('cannot multiply a string by a string');*/
                     default: throw error('cant apply ${op.toString()} to ${a} and ${b}');
                  }
                  stack.add(fin);
               } else {
                  switch (op) {
                     case Operation.ADD: a += b;
                     case Operation.SUBTRACT: a -= b;
                     case Operation.MULTIPLY: a *= b;
                     case Operation.DIVIDE: a /= b;
                     case Operation.MOD: a %= b;
                     case Operation.DIVIDE_INT: a = Std.int(a / b);
                     default: throw error('cant apply ${op.toString()}');
                  }
                  stack.add(a);
               }
            }
         case AUnOperation(p, op):
            {
               var v = stack.pop();
               if (v is String)
                  throw error('cannot negate strings');
               switch (op) {
                  case UnOperation.NOT: v = v != 0 ? 0 : 1;
                  case UnOperation.NEGATE: v = -v;
               }
               stack.add(v);
            }
         case ACall(p, name, argCount):
            {
               var args = new Array<Dynamic>();
               args.resize(argCount);
               var i = argCount;
               while (--i >= 0)
                  args[i] = stack.pop();

               stack.add(ScriptAPI.callScriptFunction(name, ...args));
            }
         case AReturn(p):
            pos = len;
         case ADiscard(p):
            stack.pop();
      }
   }

   public static function eval(code:String):String {
      try {
         var pg = new Script(code);
         pg.compile();
         var v = pg.exec({pi: Math.PI});
         return Std.string(v);
      }
      catch (x:Dynamic)
         return Std.string(x);
   }
}
