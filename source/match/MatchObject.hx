package match;

interface IMatchObject extends FlxObject {
    public var groundType:GroundType;
}

abstract class MatchObject extends FlxObject implements IMatchObject {
    // idk what i needed this for. L
}