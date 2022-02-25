package match;

import GameManager.ScreenSprite;
import inputManager.Position;
import match.AbstractHitbox;
import match.MatchObject;
import match.fighter.AbstractFighter;

class CircleHitbox extends AbstractHitbox {
   public var radius:Float;

   public function new(x:Float, y:Float, radius:Float) {
      super(x, y);
      this.radius = radius;
   }

   override public function onEnter(thing:IMatchObject):Void {
      // Main.debugDisplay.notify('enter! ${thing is AbstractFighter} ${thing is MagicFighter} ${Std.isOfType(thing, AbstractFighter)}');
      if (thing is IFighter) {
         var fighter:IFighter = cast thing;
         if (fighter.getSlot() == this.owner)
            return;
         if (fighter.iframes > 0)
            return;
         fighter.percent += this.damage;
         fighter.iframes += 0.2;
         fighter.launch(this.angle, this.knockback);
      }
   };

   public function intersectsPoint(pos:Position):Bool {
      var dx = this.x - pos.x;
      var dy = this.y - pos.y;
      // Main.debugDisplay.notify('${Math.sqrt((dx * dx) + (dy * dy))} ${Math.sqrt((dx * dx) + (dy * dy)) < this.radius}');
      return Math.sqrt((dx * dx) + (dy * dy)) < this.radius;
   }

   public function intersectsHitbox(box:IHitbox):Bool {
      return this.intersectsPoint(box.getPointClosestToInside({x: this.x, y: this.y}));
   }

   public function getPointClosestToInside(pos:Position):Position {
      if (this.intersectsPoint(pos))
         return pos;
      var angle = Math.atan2(pos.x - this.x, pos.y - this.y);
      return {x: this.x + (this.radius * Math.sin(angle)), y: this.y + (this.radius * Math.cos(angle))};
   }

   public function draw() {
      ScreenSprite.circle({x: this.x, y: this.y}, this.radius);
      ScreenSprite.line({x: this.x + (this.radius * Math.sin(this.angle - 90)), y: this.y + (this.radius * Math.cos(this.angle - 90))},
         {x: this.x, y: this.y});
   }
}
