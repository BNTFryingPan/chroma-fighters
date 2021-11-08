package;

import hscript.Expr;
import hscript.Parser;
import openfl.display.BitmapData;
import sys.FileSystem;

class AssetHelper {
	public static final instance = new AssetHelper();
	public static final saveDirectory:String = "./save/";
	static inline final saveNamespace:String = "chromasave";

	private function new() {}

	public static function getImageAsset(key:NamespacedKey):BitmapData {
		// trace(key);
		var assetDir = AssetHelper.getAssetDirectory(key, ".png");
		// trace(assetDir);
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

		if (key.namespace == saveNamespace) {
			#if debug
			rootPath = "./../../../debugSave/";
			#else
			rootPath = "./save/";
			#end
			namespacedPath = '';
		} else if (key.namespace == NamespacedKey.DEFAULT_NAMESPACE) {
			namespacedPath = "basegame/";
		} else {
			namespacedPath += key.namespace + "/";
		}

		// trace(rootPath + namespacedPath + fileName);
		// trace(rootPath + namespacedPath + fileName);
		if (FileSystem.exists(rootPath + namespacedPath + fileName)) {
			// trace("exists");
			return rootPath + namespacedPath + fileName;
		} else
			return null;
	}
}
