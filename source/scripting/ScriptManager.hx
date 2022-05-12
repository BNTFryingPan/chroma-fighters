package scripting;

import scripting.ScriptScope;

class ScriptManager {
   var scripts:Array<Script> = [];

   public var scope:ScriptScope;

   public function new(?vars:Null<Dynamic>) {
      scope = new GlobalScriptScope(vars);
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
      // var script = AssetHelper.getScriptAsset(file);
      // return add(script, compile);
      // return new Script('l')
      return null;
   }

   public function loadThenRun(file:NamespacedKey):Script {
      var script = load(file, true);
      script.exec();
      return script;
   }
}
