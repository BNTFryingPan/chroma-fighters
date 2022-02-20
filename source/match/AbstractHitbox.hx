package match;

import inputManager.Position;

enum HitboxType {
   NOTHING; // doesnt do anything, only used for collisions
   TRIGGER; // may not do anything, but will run a function
   DAMAGE; // damages or launches Fighters that enter it
   WINDBOX; // moves MatchObjects that enter
}

interface IHitbox {
   public function intersectsPoint(pos:Position):Bool;
}

abstract class AbstractHitbox implements IHitbox {
   private var x:Float;
   private var y:Float;

   public var type:HitboxType;

   public function new(x:Float, y:Float) {
      this.x = x;
      this.y = y;
   }

   public function onEnter(thing:MatchObject):Void {};

   public function onExit(thing:MatchObject):Void {};

   abstract public function intersectsPoint(pos:Position):Bool;
}
