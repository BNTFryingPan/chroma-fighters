package match;

import GameManager.ScreenSprite;
import inputManager.Coordinates;
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
         fighter.launch(this.angle, AbstractFighter.calculateKnockback(fighter.getPercent(), this.knockback, this.damage, 1, this.kbGrowth));
      }
   };

   public function intersectsPoint(x:Float, y:Float):Bool {
      var dx = this.x - x;
      var dy = this.y - y;
      // Main.debugDisplay.notify('${Math.sqrt((dx * dx) + (dy * dy))} ${Math.sqrt((dx * dx) + (dy * dy)) < this.radius}');
      return Math.sqrt((dx * dx) + (dy * dy)) < this.radius;
   }

   public function intersectsCircle(x, y, radius):Bool {
      var thisCoords = Coordinates.get(this.x, this.y);
      var ret = thisCoords.distanceFrom(x, y) <= (this.radius + radius);
      thisCoords.put();
      return ret;
   }

   override public function intersectsHitbox(box:IHitbox):Bool {
      if (box is CircleHitbox) {
         var circle:CircleHitbox = cast box;
         return this.intersectsCircle(circle.x, circle.y, circle.radius);
      }
      return super.intersectsHitbox(box);
   }

   public function getPointClosestToInside(x:Float, y:Float, ?use:Coordinates):Coordinates {
      if (use == null)
         use = Coordinates.get();
      if (this.intersectsPoint(x, y))
         return use.set(x, y);
      var angle = Math.atan2(x - this.x, y - this.y);
      use.set(this.x + (this.radius * Math.sin(angle)), this.y + (this.radius * Math.cos(angle)));
      ScreenSprite.line(use, Coordinates.weak(x, y), {thickness: 3, color: 0xff0000ff});
      return use;
   }

   public function draw() {
      ScreenSprite.circle(Coordinates.weak(this.x, this.y), this.radius);
      var lAngle = ((-this.angle) + 90) * (Math.PI / 180);
      ScreenSprite.line(Coordinates.weak(this.x + (this.radius * Math.cos(lAngle)), this.y + (this.radius * Math.sin(lAngle) * -1)),
         Coordinates.weak(this.x, this.y));
   }
}
