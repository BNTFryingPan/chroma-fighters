package inputManager;

class StickVector {
	public var x:Float;
	public var y:Float;

	public function new(x:Float = 0.0, y:Float = 0.0) {
		this.x = x;
		this.y = y;
	}

	function withX(x:Float) {
		return new StickVector(x, this.y);
	}

	function withY(y:Float) {
		return new StickVector(this.x, y);
	}
}
