package scripting;

typedef ScriptScopeOptions = {
   var allowMath:Bool;
}

@:keep
typedef ScriptMath = Math;

class ScriptScope {
   public var dynamicVars:Dynamic;
   public var interop_read:Map<String, Dynamic> = [];
   public var interop_write:Map<String, Dynamic> = [];
   public var api_classes:Array<Class<Dynamic>> = [];

   public var options:ScriptScopeOptions = {allowMath: true};

   public function exists(name:String):Bool {
      if (Reflect.hasField(dynamicVars, name)) // priority doesnt matter here, its an OR
         return true;
      if (interop_read.exists(name))
         return true;
      if (interop_write.exists(name))
         return true;
      return false;
   }

   public function setVar(name:String, value:Dynamic) {
      if (interop_read.exists(name)) // readonly always takes priority over write and dynamic
         throw 'Cannot write to read-only variable $name';

      if (interop_write.exists(name)) {
         interop_write.set(name, value);
         return;
      }
      Reflect.setField(dynamicVars, name, value);
   }

   public function getVar(name:String):Null<Dynamic> {
      if (interop_read.exists(name))
         return interop_read.get(name);

      if (interop_write.exists(name))
         return interop_write.get(name);

      return Reflect.field(dynamicVars, name);
   }

   public function call(name, pos, ...args:Dynamic):Dynamic {
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

      var func = Reflect.field(dynamicVars, name);
      if (Reflect.isFunction(func))
         throw 'tried calling function in dynamic vars. this is not good!';

      throw 'tried calling non-function value';
   }

   public function new(?vars:Null<Dynamic>, addDefaults:Bool = true) {
      this.dynamicVars = vars;
      if (!addDefaults)
         return;
      this.api_classes.push(ScriptAPI);
   }
}

class ScriptManager {
   var scripts:Array<Script> = [];

   public var scope:ScriptScope;

   public function new(?vars:Null<Dynamic>) {
      scope = new ScriptScope(vars);
   }

   public function tick() {
      for (script in scripts) {
         if (script.isRunning)
            script.exec(false);
      }
   }

   public function add(script:Script, compile:Bool = true):Script {
      if (compile && !script.isCompiled.isBlown()) {
         script.compile();
      }

      scripts.push(script);
      script.manager = this;
      return script;
   }

   public function addThenRun(script:Script):Script {
      add(script, true).exec();
      return script;
   }

   public function load(file:NamespacedKey, compile:Bool = true):Script {
      var script = AssetHelper.getScriptAsset(file);
      return add(script, compile);
   }

   public function loadThenRun(file:NamespacedKey):Script {
      var script = load(file, true);
      script.exec();
      return script;
   }
}
