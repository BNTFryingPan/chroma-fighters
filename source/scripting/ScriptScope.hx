package scripting;

import haxe.Rest;

interface ScopeAccess {
   function getVar(name:String):Dynamic;
   function setVar(name:String, value:Dynamic):Void;
   function exists(name:String):Bool;
   function call(name:String, pos:Pos, ...args:Dynamic):Dynamic;
}

typedef ScriptScopeOptions = {
   var allowMath:Bool;
}

enum Internal_ScopeVarValue {
   NULL;
   VALUE(value:Dynamic);
}

enum ScopeJumpStack {
   NoJump;
   Jump(to:Int);
}

@:keep
typedef ScriptMath = Math;

/*class ScopeStackCell implements ScopeAccess {
   public var scope:ScriptScope;
   public var next:Null<ScopeStackCell>;

   public function new(scope:ScriptScope, next:Null<ScopeStackCell>) {
      this.scope = scope;
      this.next = next;
   }

   public function exists(name:String):Bool {
      if (this.scope.exists(name))
         return true;
      if (this.scope.jumpstack.match(NoJump))
         return false;
      return this.next.exists(name);
   }

   public function getVar(name:String):Internal_ScopeVarValue {
      if (this.scope.exists(name))
         return VALUE(this.scope.getVar(name));
      if (this.scope.jumpstack.match(NoJump))
         return NULL;
      return this.next.getVar(name);
   }

   public function setVar(name:String, value:Dynamic) {
      if (this.scope.exists(name))
         return this.scope.setVar(name, value);
      if (this.scope.jumpstack.match(NoJump))
         return;
      return this.next.setVar(name, value);
   }

   public function call(name:String, pos:Pos, args:Rest<Dynamic>):Internal_ScopeVarValue {
      if (this.scope.exists(name))
         return VALUE(this.scope.getVar(name));
      if (this.scope.jumpstack.match(NoJump))
         return NULL;
      return this.next.call(name, pos, args);
   }
   }

   class ScopeStack implements ScopeAccess {
   var head:Null<ScopeStackCell>;
   var global:Null<GlobalScriptScope>;

   public var top(get, never):Null<ScriptScope>;

   function get_top():Null<ScriptScope> {
      if (this.head == null) {
         if (this.global != null)
            return cast this.global;
         return null;
      }
      return cast this.head.scope;
   }

   public function new() {}

   public function add(scope:ScriptScope) {
      this.head = new ScopeStackCell(scope, this.head);
   }

   public function pop():Null<ScriptScope> {
      if (this.top == null)
         return null;

      var ret = this.top;
      if (this.head == null)
         return ret;
      this.head = this.head.next;
      return ret;
   }

   public function exists(name:String):Bool {
      if (this.head != null && this.head.exists(name))
         return true;
      if (this.global != null && this.global.exists(name))
         return true;
      return false;
   }

   public function getVar(name:String):Dynamic {
      if (this.global != null) {
         var globalValue = this.global.getVar(name);
         if (globalValue.match(VALUE(_)))
            return globalValue.getParameters()[0];
      }
      if (this.head != null) {
         var headValue = this.head.getVar(name);
         if (headValue.match(VALUE(_)))
            return headValue.getParameters()[0];
      }
      return null;
   }

   public function setVar(name:String, value:Dynamic) {
      /*if (this.global != null) {
            var globalExists = this.global.exists(name);
         }
         if (this.exists())
         if (this.scope.exists(name))
            return this.scope.setVar(name, value);
         if (this.scope.jumpstack.match(NoJump))
            return;
         return this.next.setVar(name, value); */
/*}

   public function call(name:String, pos:Pos, args:Rest<Dynamic>):Internal_ScopeVarValue {
      if (this.scope.exists(name))
         return VALUE(this.scope.getVar(name));
      if (this.scope.jumpstack.match(NoJump))
         return NULL;
      return this.next.call(name, pos, args);
   }
}*/
class ScriptScope implements ScopeAccess {
   public var dynamicVars:Dynamic;
   public var jumpstack:ScopeJumpStack;

   public function exists(name:String):Bool {
      if (Reflect.hasField(dynamicVars, name)) // priority doesnt matter here, its an OR
         return true;
      return false;
   }

   public function setVar(name:String, value:Dynamic) {
      Reflect.setField(dynamicVars, name, value);
   }

   public function getVar(name:String):Dynamic {
      return Reflect.field(dynamicVars, name);
   }

   public function call(name:String, pos:Pos, ...args:Dynamic):Dynamic {
      var func = Reflect.field(dynamicVars, name);
      if (Reflect.isFunction(func))
         throw 'tried calling function in dynamic vars. this is not good!';

      throw 'tried calling non-function value';
   }

   public function new(?vars:Null<Dynamic>) {
      this.dynamicVars = vars;
   }
}

class GlobalScriptScope extends ScriptScope {
   public var interop_read:Map<String, Dynamic> = [];
   public var interop_write:Map<String, Dynamic> = [];
   public var api_classes:Array<Class<Dynamic>> = [];

   public var options:ScriptScopeOptions = {allowMath: true};

   override public function exists(name:String):Bool {
      if (interop_read.exists(name))
         return true;
      if (interop_write.exists(name))
         return true;
      return super.exists(name);
   }

   override public function setVar(name:String, value:Dynamic) {
      if (interop_read.exists(name)) // readonly always takes priority over write and dynamic
         throw 'Cannot write to read-only variable $name';

      if (interop_write.exists(name)) {
         interop_write.set(name, value);
         return;
      }

      super.setVar(name, value);
   }

   override public function getVar(name:String):Null<Dynamic> {
      if (interop_read.exists(name))
         return interop_read.get(name);

      if (interop_write.exists(name))
         return interop_write.get(name);

      return super.getVar(name);
   }

   override public function call(name, pos, ...args:Dynamic):Dynamic {
      for (clazz in api_classes) {
         if (Reflect.hasField(clazz, name)) {
            var func = Reflect.field(clazz, name);
            if (Reflect.isFunction(func))
               return Reflect.callMethod(null, func, args.toArray());
         }
      }

      if (interop_read.exists(name)) {
         var func = interop_read.get(name);
         if (Reflect.isFunction(func)) {
            return Reflect.callMethod(null, func, args.toArray());
         }
      }

      if (interop_read.exists(name)) {
         var func = interop_write.get(name);
         if (Reflect.isFunction(func)) {
            throw 'tried calling function in writable interop. this is probably a bug!';
         }
      }

      return super.call(name, pos, args);
   }

   public function new(?vars:Null<Dynamic>, addDefaults:Bool = true) {
      super(vars);
      if (!addDefaults)
         return;
      this.api_classes.push(ScriptAPI);
   }
}
