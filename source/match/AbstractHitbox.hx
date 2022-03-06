package match;

import PlayerSlot.PlayerSlotIdentifier;
import inputManager.Coordinates;
import match.MatchObject;

enum HitboxType {
   NOTHING; // doesnt do anything, only used for collisions
   TRIGGER(enter:MatchObject->Void, exit:MatchObject->Void, inside:MatchObject->Void); // may not do anything, but will run a function
   DAMAGE(damage:Float, angle:Float); // damages or launches Fighters that enter it
   WINDBOX(speed:Float, angle:Float); // moves MatchObjects that enter
}

interface IHitbox {
   public var type:HitboxType;
   public function intersectsPoint(x:Float, y:Float):Bool;
   public function intersectsHitbox(box:IHitbox):Bool;
   public function getPointClosestToInside(x:Float, y:Float, ?use:Coordinates):Coordinates;
   public function draw():Void;
}

abstract class AbstractHitbox implements IHitbox {
   public var x:Float;
   public var y:Float;

   public var duration:Float;
   public var active:Bool = true;

   public var damage:Float = 0;
   public var knockback:Float = 1;
   public var angle:Float = 0;
   public var kbGrowth:Float = 1;
   public var offsetX:Float = 0;
   public var offsetY:Float = 0;
   public var follow:Bool = true;

   public var owner:PlayerSlotIdentifier;

   public function update(elapsed:Float) {
      if (this.duration <= 0)
         this.active = false;
      else
         this.duration -= elapsed;

      if (!this.active)
         return;

      for (player in PlayerSlot.getPlayerArray()) {
         if (player.fighter != null) {
            if (player.fighter.hitbox.intersectsHitbox(this)) {
               this.onEnter(player.fighter);
            }
         }
      }
   }

   public var type:HitboxType;

   public function new(x:Float, y:Float) {
      trace('new hitbox');
      this.x = x;
      this.y = y;
   }

   public function onEnter(thing:IMatchObject):Void {};

   public function onExit(thing:IMatchObject):Void {};

   abstract public function intersectsPoint(x:Float, y:Float):Bool;

   abstract public function getPointClosestToInside(x:Float, y:Float, ?use:Coordinates):Coordinates;

   public function intersectsHitbox(box:IHitbox):Bool {
      var close = box.getPointClosestToInside(this.x, this.y);
      var ret = this.intersectsPoint(close.x, close.y);
      close.put();
      return ret;
   };

   abstract public function draw():Void;
}
