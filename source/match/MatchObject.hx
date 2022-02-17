package match;

import flixel.FlxObject;
import flixel.math.FlxPoint;

interface IMatchObject {
   // public var groundType:GroundType;
   public var canBeMoved:Bool;
   public var position(get, set):Float;
   public function moveBy(x:Float, y:Float):Void;
}

interface IMatchObjectWithHitbox extends IMatchObject {
   public var hitbox:AbstractHitbox;
   public function collidesWithPoint(pos:Position):Bool;
   public function collidesWithObject(obj:IMatchObjectWithHitbox):Bool;
}

interface IGroundObject extends IMatchObjectWithHitbox {
   public var groundType:GroundType;
}

/**
   i didnt want to do this, but i think i have to
**/
class Physics {
   public static function collide(obj1:IMatchObjectWithHitbox, obj2:IMatchObjectWithHitbox) {
      if ()
   }
}

/**
   represents an object that exists on a stage during a match.
**/
abstract class MatchObject extends FlxObject implements IMatchObject {
   private final rand:MatchRandom;

   public function new() {
      super();
      this.rand = new MatchRandom();
   }

   // idk what i needed this for. L
}
