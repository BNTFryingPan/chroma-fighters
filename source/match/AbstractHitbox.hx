package match;

import inputManager.Position;

enum HitboxType {
   TRIGGER; // may not do anything, but will run a function
   DAMAGE; // damages or launches Fighters that enter it
   WINDBOX; // moves MatchObjects that enter
}

abstract class AbstractHitbox {
   private var x:Float;
   private var y:Float;

   public var type:HitboxType;

   public function new(x:Float, y:Float) {
      this.x = x;
      this.y = y;
   }

   abstract public function intersectsPoint(pos:Position):Bool;

   public function onEnter(thing:MatchObject):Void {};

   public function onExit(thing:MatchObject):Void {};
}
