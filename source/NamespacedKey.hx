package;

import openfl.errors.TypeError;

class NamespacedKey {
	public static final DEFAULT_NAMESPACE = "chromafighers";

	public var key:String;
	public var namespace:String;

	public function new(namespace:String, key:String) {
		if (namespace == null)
			namespace = NamespacedKey.DEFAULT_NAMESPACE;
		this.namespace = namespace;
		this.key = key;
	}

	@:to
	public function toString() {
		return this.namespace + ":" + this.key;
	}

	public static function ofDefaultNamespace(obj:Dynamic) {
		if (Std.isOfType(obj, String)) {
			return oDN_string(cast obj);
		} else if (Std.isOfType(obj, NamespacedKey)) {
			return oDN_key(cast obj);
		} else {
			throw new TypeError("Invalid object passed to default namespace function.");
		}
	}

	private static function oDN_string(str:String) {
		return new NamespacedKey(NamespacedKey.DEFAULT_NAMESPACE, str);
	}

	private static function oDN_key(key:NamespacedKey) {
		return new NamespacedKey(NamespacedKey.DEFAULT_NAMESPACE, key.key);
	}

	@:from
	public static function fromString(str:String) {
		var splitKey = str.split(":");
		if (splitKey.length == 1)
			return new NamespacedKey(NamespacedKey.DEFAULT_NAMESPACE, str);
		else {
			var _namespace = splitKey[0];
			var _key = splitKey[1];
			if (splitKey.length > 2) {
				splitKey.shift();
				_key = splitKey.join(":");
			}
			return new NamespacedKey(_namespace, _key);
		}
	}
}
