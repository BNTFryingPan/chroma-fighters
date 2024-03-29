package match.stage;

typedef StageModOption = {
   public var type:String;
   public var defaultValue:Dynamic;
   public var maxValue:Float;
   public var minValue:Float;
   public var step:Float;
}

typedef StageModJson = {
   public var author:String;
   public var type:String;
   public var version:String;
   public var description:String;
   public var name:String;
   public var id:String;
   public var tags:Array<String>;
   public var options:Map<String, StageModOption>;
   public var script:String;
   public var include:Map<String, String>;
   public var isInBaseGame:Bool;
}

class ScriptedStage extends AbstractStage {
   public function new(key, opts) {
      super(opts);
   }
}
