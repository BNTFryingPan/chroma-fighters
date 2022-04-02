package scripting;

import flixel.FlxG;
import flixel.system.debug.log.LogStyle;
import haxe.ds.GenericStack;
import scripting.Op.Operation;
import scripting.Op.UnOperation;

enum StackEntryType {
   // floats and ints
   NUMBER;
   // strings
   STRING;
   // booleans
   BOOLEAN;
   // callable function
   FUNCTION;
   // arbitrary haxe objects. probably insecure to use, but its an option.
   DYNAMIC;
   // null
   NULL;
}

/**
   basically wraps access to haxe types
**/
class StackEntry<T> {
   public var value:T;
   public final type:StackEntryType;

   private function new(type:StackEntryType, value:T) {
      this.value = value;
      this.type = type;
   }

   public function isOfType(type:StackEntryType):Bool {
      return this.type == type;
   }

   public function isTruthy():Bool {
      return Script.isTruthy(this.value);
   }

   public function asType(targetType:StackEntryType):Dynamic {
      if (targetType == this.type)
         return this.value;

      if (targetType == STRING)
         return Std.string(this.value);

      if (targetType == NUMBER)
         return Std.parseFloat(Std.string(this.value));

      if (targetType == BOOLEAN)
         return this.isTruthy();

      if (targetType == NULL)
         return null;

      if (targetType == FUNCTION) {
         if (this.type == DYNAMIC)
            return this; // a dynamic value could be a function, but otherwise, its not
         return null;
      }

      if (targetType == DYNAMIC)
         return this.value;

      return null;
   }

   public static function get(value:Dynamic):StackEntry<Dynamic> {
      if (value is String) {
         return new StackEntry<String>(STRING, value);
      }
      if (value is Float || value is Int) {
         return new StackEntry<Float>(NUMBER, value);
      }
      if (value is Bool) {
         return new StackEntry<Bool>(BOOLEAN, value);
      }
      if (value == null) {
         return new StackEntry<Dynamic>(NULL, null);
      }
      return new StackEntry<Dynamic>(DYNAMIC, value);
   }
}

#if js
@:expose
#end
class Script {
   public var error:Null<String> = null;

   public static var DEBUG_TOKENS:Bool = true;
   public static var DEBUG_NODE_TREE:Bool = false;
   public static var DEBUG_BYTECODE:Bool = true;
   public static var DEBUG_RUNTIME:Bool = false;

   // private var isParsed:Fuse = new Fuse();
   private var isCompiled:Fuse = new Fuse();
   var contents:String;
   var tokens:Array<ScriptToken> = [];
   var node:ScriptNode;
   var actions:Array<ScriptAction>;

   public var isRunning:Bool = false;
   public var isPaused:Bool = false;

   var pausedFor:Int = 0;
   var pos:Int = 0;

   var stack:GenericStack<StackEntry<Dynamic>>;
   var vars:Dynamic;

   // var discarded:Dynamic = null;

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
      if (this.isCompiled.isBlown()) // already parsed
         return;
      this.isCompiled.blow();
      this.tokens = ScriptParser.parse(this.contents);
      if (Script.DEBUG_TOKENS)
         trace('parsed: ' + tokens.map(t -> t.debugPrint()).join(''));
      this.node = ScriptBuilder.build(this.tokens);
      if (Script.DEBUG_NODE_TREE)
         trace(this.node.debugPrint());
      this.actions = ScriptCompiler.compile(this.node);
      if (Script.DEBUG_BYTECODE)
         trace('"bytecode":\n${actions.map(a -> a.debugPrint()).join('\n')}');
   }

   public function exec(vars:Null<Dynamic>):Dynamic {
      // if (forceRestart || !this.isRunning) {
      stack = new GenericStack<StackEntry<Dynamic>>();
      pos = 0;
      if (vars != null) {
         this.vars = vars;
      }
      // }
      // if (this.isPaused) {
      //   this.pausedFor--;
      //   if (this.pausedFor > 0) return null;
      // }
      // this.isRunning = true;
      // this.isPaused = false;
      while (pos < this.actions.length) {
         var action = this.actions[pos++];
         this.executeAction(action);
         if (Script.DEBUG_RUNTIME)
            trace('<exec> ${action.debugPrint()} (${stack.first().value}, $pos)');
      }
      // for (act in this.actions) {
      //   this.executeAction(act);
      // }
      // if (this.isPaused)
      //   return null;
      // this.isRunning = false;
      return accessStack();
   }

   function accessStack(pop:Bool = true):StackEntry<Dynamic> {
      var top = (pop ? stack.pop() : stack.first());
      if (top == null) {
         return StackEntry.get(null);
      }
      return top;
   }

   function step():Dynamic {
      var action = this.actions[this.pos++];
      this.executeAction(action);
      if (Script.DEBUG_RUNTIME)
         trace('<exec> ${action.debugPrint()} (${stack.first().value}, $pos)');

      return accessStack(false);
   }

   function executeAction(action:ScriptAction) {
      inline function error(text:String) {
         return '${text} on line ${action.getPos().line} at position ${action.getPos().linepos}';
      }

      switch (action) {
         // case APause(p, frames):
         // isPaused = true;
         // pausedFor = frames;
         case ANumber(p, value):
            stack.add(StackEntry.get(value));
         case AString(p, value):
            stack.add(StackEntry.get(value));
         case AIdentifier(p, name):
            {
               if (!Reflect.hasField(vars, name))
                  throw error('variable $name does not exist when referenced');

               var val = Reflect.field(vars, name);
               stack.add(StackEntry.get(val));
            }
         case AOperation(p, op):
            {
               var b = accessStack();
               var a = accessStack();
               if (op == Operation.EQUALS) {
                  trace('checking if ${a} == ${b} (${a == b}');
                  stack.add(StackEntry.get(a.value == b.value)); // a = (a == b);
               } else if (op == Operation.NOT_EQUALS) {
                  trace('checking if ${a} != ${b} (${a != b}');
                  stack.add(StackEntry.get(a.value != b.value)); // a = (a != b);
               } else {
                  try {
                     switch (op) {
                        case Operation.ADD: a.value += b.value;
                        case Operation.SUBTRACT: a.value -= b.value;
                        case Operation.MULTIPLY: a.value *= b.value;
                        case Operation.DIVIDE: a.value /= b.value;
                        case Operation.MOD: a.value %= b.value;
                        case Operation.DIVIDE_INT: a = StackEntry.get(Std.int(a.value / b.value));
                        case Operation.LESS_THAN: a = StackEntry.get(a.value < b.value);
                        case Operation.LESS_THAN_OR_EQUALS: a = StackEntry.get(a.value <= b.value);
                        case Operation.GREATER_THAN: a = StackEntry.get(a.value > b.value);
                        case Operation.GREATER_THAN_OR_EQUALS: a = StackEntry.get(a.value >= b.value);
                        case Operation.BIT_SHIFT_LEFT: a.value <<= b.value;
                        case Operation.BIT_SHIFT_RIGHT: a.value >>= b.value;
                        case Operation.BIT_AND: a.value &= b.value;
                        case Operation.BIT_OR: a.value |= b.value;
                        case Operation.BIT_XOR: a.value ^= b.value;
                        default:
                           throw error('Dont know how to apply ${op.toString()}');
                     } catch (err) {
                        throw error('cant apply ${op.toString()} between types ${a.type.getName().toLowerCase()} and ${b.type.getName().toLowerCase()}');
                     }
                  }
                  stack.add(a);
               }
            }
         case AUnOperation(p, op):
            {
               var v = accessStack();
               switch (op) {
                  case UnOperation.NOT: {
                     if (v.isOfType(NUMBER))
                        v.value = v.value != 0 ? 0 : 1;
                     else if (v.isOfType(BOOLEAN))
                        v.value = !v.value;
                     else
                        throw error('cannot flip value of type ${v.type.getName().toLowerCase()}');
                  }
                  case UnOperation.NEGATE: {
                     if (v.isOfType(NUMBER))
                        v.value = -v.value;
                     else
                        throw error('cannot negate value of type ${v.type.getName().toLowerCase()}');
                     }
               }
               stack.add(v);
            }
         case ACall(p, name, argCount):
            {
               var args = new Array<Dynamic>();
               var i = argCount;
               while (--i >= 0)
                  args[i] = accessStack().value;

               stack.add(StackEntry.get(Script.callFunctionFromScript(name, p, ...args)));
            }
         case AReturn(p):
            pos = actions.length;
         case ADiscard(p):
            accessStack();
         case AJump(p, to):
            pos = to;
         case AJumpUnless(p, to):
            if (!accessStack().isTruthy()) {
               pos = to;
            }
         case AJumpIf(p, to):
            if (accessStack().isTruthy()) {
               pos = to;
            }
         case AAnd(p, to):
            if (accessStack(false).isTruthy())
               accessStack();
            else
               pos = to;
         case AOr(p, to):
            if (accessStack(false).isTruthy())
               pos = to;
            else
               accessStack();
         case ASet(p, name):
            Reflect.setField(vars, name, accessStack().value);
            
      }
   }

   public static function isTruthy(value:Dynamic):Bool {
      if (Script.DEBUG_RUNTIME)
         trace('checking truthiness of `${Std.string(value)}`');
      if (value is Bool) {
         return value;
      }
      if (value is Int || value is Float) {
         if (value == 0)
            return false;
         if (value == Math.NaN)
            return false;
         return true;
      }
      if (value is String) {
         if (value == '')
            return false;
         return true;
      }
      if (value == null) {
         return false;
      }
      return false;
   }

   public static function eval(code:String):String {
      try {
         var pg = new Script(code);
         pg.compile();
         var v = pg.exec({pi: Math.PI});
         return Std.string(v);
      }
      catch (x:Dynamic) {
         #if FLX_DEBUG
         FlxG.log.advanced(x, errorLogStyle, false);
         #end
         return null;
      }
   }

   #if flixel
   public static final errorLogStyle:LogStyle = new LogStyle("[SCRIPT ERROR]", "ff00ff", 12, false, false, false, "flixel/sounds/beep", false);
   #end
}
