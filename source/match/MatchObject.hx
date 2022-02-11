package match;

import flixel.FlxObject;
import flixel.math.FlxPoint;

interface IMatchObject {
    // public var groundType:GroundType;
}

interface IMatchObjectWithHitbox extends IMatchObject {
    function collidesWithPoint(point:FlxPoint):Bool;
}

interface IGroundObject extends IMatchObjectWithHitbox {}

/**
    represents an object that exists on a stage during a match.
**/
abstract class MatchObject extends FlxObject implements IMatchObject {
    // idk what i needed this for. L
}
