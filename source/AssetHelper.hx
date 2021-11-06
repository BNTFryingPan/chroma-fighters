package;

import haxe.xml.Access;
import hscript.Expr;
import hscript.Parser;
import lime.graphics.Image;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;
import sys.FileSystem;

class TilesheetJsonDataAssetClass {
	public var type:String;
	public var source:String;
	public var width:Int;
	public var height:Int;
	public var properties:Null<TilesheetJsonDataProperties>;
}

class TilesheetJsonDataProperties {
	public var color:Null<TilesheetJsonDataColorModifiers>;
}

class TilesheetJsonDataColorModifiers {
	public var multiplier:Null<TilesheetJsonDataColors<Float>>;
	public var offset:Null<TilesheetJsonDataColors<Int>>;
}

class TilesheetJsonDataColors<T> {
	public var red:Null<T>;
	public var green:Null<T>;
	public var blue:Null<T>;
	public var alpha:Null<T>;
}

class AssetHelper {
	public static final instance = new AssetHelper();

	private function new() {}

	public static function getTilesheetAsset(key:NamespacedKey):BitmapData {
		var rawTilesheetData = AssetHelper.getRawJsonAsset(key);
		if (rawTilesheetData == null) {
			return getImageAsset(key);
		} else {
			var parser = new json2object.JsonParser<TilesheetJsonDataAssetClass>();
			var tilesheetData:TilesheetJsonDataAssetClass = parser.fromJson(rawTilesheetData);

			if (tilesheetData.type == "full") {
				var imageData = getImageAsset(NamespacedKey.fromString(tilesheetData.source));
				if (imageData != null) {
					var colorMultipliers = tilesheetData.properties.color.multiplier;
					var colorOffsets = tilesheetData.properties.color.offset;
					// trace(tilesheetData.properties.color);
					var colorTransformer = new ColorTransform(colorMultipliers.red, colorMultipliers.green, colorMultipliers.blue, colorMultipliers.alpha,
						colorOffsets.red, colorOffsets.green, colorOffsets.blue, colorOffsets.alpha);
					imageData.colorTransform(new Rectangle(0, 0, imageData.width, imageData.height), colorTransformer);
				}
				return imageData;
			}
			return null;
		}
	}

	public static function getImageAsset(key:NamespacedKey):BitmapData {
		trace(key);
		var assetDir = AssetHelper.getAssetDirectory(key, ".png");
		trace(assetDir);
		if (assetDir != null) {
			return BitmapData.fromFile(assetDir);
		}
		return null;
	}

	public static function getTextAsset(key:NamespacedKey):Array<String> {
		var assetDir = AssetHelper.getAssetDirectory(key, ".txt");
		if (assetDir != null) {
			return sys.io.File.getContent(assetDir).split("\n");
		}
		return null;
	}

	public static function getRawTextAsset(key:NamespacedKey):String {
		var assetDir = AssetHelper.getAssetDirectory(key, ".txt");
		if (assetDir != null) {
			return sys.io.File.getContent(assetDir);
		}
		return null;
	}

	public static var scriptCache:Map<NamespacedKey, Expr> = new Map<NamespacedKey, Expr>();

	public static function getScriptAsset(key:NamespacedKey):Expr {
		if (AssetHelper.scriptCache.exists(key)) {
			return AssetHelper.scriptCache.get(key);
		}
		var assetDir = AssetHelper.getAssetDirectory(key, ".hsc");
		if (assetDir != null) {
			var parsed = new Parser().parseString(sys.io.File.getContent(assetDir));
			AssetHelper.scriptCache.set(key, parsed);
			return parsed;
		}
		return null;
	}

	public static function getLevelAsset(key:NamespacedKey):Xml {
		var assetDir = AssetHelper.getAssetDirectory(key, ".tmx");
		if (assetDir != null) {
			return Xml.parse(sys.io.File.getContent(assetDir));
		}
		return null;
	}

	public static function getJsonAsset(key:NamespacedKey):Dynamic {
		var assetDir = AssetHelper.getAssetDirectory(key, ".json");
		if (assetDir != null) {
			return haxe.Json.parse(sys.io.File.getContent(assetDir));
		}
		return null;
	}

	public static function getRawJsonAsset(key:NamespacedKey):String {
		var assetDir = AssetHelper.getAssetDirectory(key, ".json");
		if (assetDir != null) {
			return sys.io.File.getContent(assetDir);
		}
		return null;
	}

	public static function getAssetDirectory(key:NamespacedKey, ext:String = "") {
		#if debug
		var rootPath = "./../../../assets/";
		var namespacedPath = "debug_mods/";
		#else
		var rootPath = "./assets/";
		var namespacedPath = "mods/";
		#end

		var fileName = key.key;
		if (ext != "" && !StringTools.endsWith(fileName, ext)) {
			fileName += ext;
		}

		if (key.namespace == NamespacedKey.DEFAULT_NAMESPACE) {
			namespacedPath = "basegame/";
		} else {
			namespacedPath += key.namespace + "/";
		}

		trace(rootPath + namespacedPath + fileName);
		// trace(rootPath + namespacedPath + fileName);
		if (FileSystem.exists(rootPath + namespacedPath + fileName)) {
			// trace("exists");
			return rootPath + namespacedPath + fileName;
		} else
			return null;
	}
}
