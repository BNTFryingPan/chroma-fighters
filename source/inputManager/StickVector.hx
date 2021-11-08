package inputManager;

class StickVector {
	public var x:Float;
	public var y:Float;

	public function new(x:Float = 0.0, y:Float = 0.0) {
		this.x = x;
		this.y = y;
	}

	public function withX(x:Float) {
		return new StickVector(x, this.y);
	}

	public function withY(y:Float) {
		return new StickVector(this.x, y);
	}

	public function toString() {
		return 'StickVector(${this.x}, ${this.y})';
	}
}
