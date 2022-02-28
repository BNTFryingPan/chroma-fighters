package match;

import PlayerSlot.PlayerSlotIdentifier;
import inputManager.Position;
import match.MatchObject;
import match.fighter.AbstractFighter;
import match.fighter.MagicFighter;

enum HitboxType {
   NOTHING; // doesnt do anything, only used for collisions
   TRIGGER(enter:MatchObject->Void, exit:MatchObject->Void, inside:MatchObject->Void); // may not do anything, but will run a function
   DAMAGE(damage:Float, angle:Float); // damages or launches Fighters that enter it
   WINDBOX(speed:Float, angle:Float); // moves MatchObjects that enter
}

interface IHitbox {
   public var type:HitboxType;
   public function intersectsPoint(pos:Position):Bool;
   public function intersectsHitbox(box:IHitbox):Bool;
   public function getPointClosestToInside(pos:Position):Position;
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
   public var offset:Position = {x: 0, y: 0};
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
      this.x = x;
      this.y = y;
   }

   public function onEnter(thing:IMatchObject):Void {};

   public function onExit(thing:IMatchObject):Void {};

   abstract public function intersectsPoint(pos:Position):Bool;

   abstract public function intersectsHitbox(box:IHitbox):Bool;

   abstract public function getPointClosestToInside(pos:Position):Position;

   abstract public function draw():Void;
}
