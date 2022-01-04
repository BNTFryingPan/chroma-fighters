package;

import flixel.util.typeLimit.OneOfTwo;
import haxe.extern.Rest;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import openfl.display.BitmapData;
import sys.FileSystem;
import sys.io.File;

class ModScript {
    public var interp:Interp;
    public var script:Expr;

    private var originalKey:NamespacedKey;

    public function new(asset:NamespacedKey) {
        this.originalKey = asset;
        this.reload();
    }

    public function reload() {
        this.interp.variables.clear();
        this.script = AssetHelper.getScriptAsset(this.originalKey, true);
        this.interp.execute(this.script);
    }

    public function shareFunctionMap(functionMap:Map<String, Null<Dynamic>->Null<Dynamic>>) {
        for (key => func in functionMap.keyValueIterator()) {
            this.interp.variables.set(key, func);
        }
    }

    public function getVariable(name:String):Dynamic {
        return this.interp.variables.exists(name) ? this.interp.variables.get(name) : null;
    }

    public function callFunction(name:String, args:Array<Dynamic>):Dynamic {
        if (!this.interp.variables.exists(name))
            return null;

        var func:Array<Dynamic>->Dynamic = cast this.interp.variables.get(name);
        return func(args);
    }
}

class AssetHelper {
    public static final instance = new AssetHelper();
    public static final saveDirectory:String = "./save/";
    static inline final saveNamespace:String = "chromasave";

    public static var scriptCache:Map<String, Expr> = new Map<String, Expr>();
    public static var imageCache:Map<String, BitmapData> = new Map<String, BitmapData>();

    private static var parser:Parser = new Parser();

    private function new() {}

    /*private static function getNullBitmap():BitmapData {
        return 
    }*/
    private static function getNullText():String {
        return "NOT_FOUND";
    }

    public static function getImageAsset(key:NamespacedKey):BitmapData {
        // Main.log(AssetHelper.imageCache.toString());
        if (AssetHelper.imageCache.exists(key.toString())) {
            // Main.log("returning from cache");
            return AssetHelper.imageCache.get(key.toString());
        }
        // Main.log("getImageAsset");
        var assetDir = AssetHelper.getAssetDirectory(key, ".png");
        // Main.log('got directory: ' + assetDir);
        // Main.log(assetDir);
        if (assetDir != null) {
            var loaded:BitmapData = BitmapData.fromFile(assetDir);
            AssetHelper.imageCache.set(key.toString(), loaded);
            return loaded;
        }
        return null;
    }

    public static function getTextAsset(key:NamespacedKey):Array<String> {
        var assetDir = AssetHelper.getAssetDirectory(key, ".txt");
        if (assetDir != null) {
            return sys.io.File.getContent(assetDir).split("\n");
        }
        return [AssetHelper.getNullText()];
    }

    public static function getRawTextAsset(key:NamespacedKey):String {
        var assetDir = AssetHelper.getAssetDirectory(key, ".txt");
        if (assetDir != null) {
            return sys.io.File.getContent(assetDir);
        }
        return AssetHelper.getNullText();
    }

    public static function getScriptAsset(key:NamespacedKey, ?reload:Bool = false):Expr {
        if ((!reload) && AssetHelper.scriptCache.exists(key.toString())) {
            return AssetHelper.scriptCache.get(key.toString());
        }
        var assetDir = AssetHelper.getAssetDirectory(key, ".cfs");
        if (assetDir != null) {
            var parsed = AssetHelper.parser.parseString(sys.io.File.getContent(assetDir));
            AssetHelper.scriptCache.set(key.toString(), parsed);
            return parsed;
        }
        return null;
    }

    public static function getJsonAsset(key:NamespacedKey):Dynamic {
        var assetDir = AssetHelper.getAssetDirectory(key, ".json");
        if (assetDir != null) {
            return haxe.Json.parse(sys.io.File.getContent(assetDir));
        }
        return {};
    }

    public static function getRawJsonAsset(key:NamespacedKey):String {
        var assetDir = AssetHelper.getAssetDirectory(key, ".json");
        if (assetDir != null) {
            return sys.io.File.getContent(assetDir);
        }
        return "{}";
    }

    public static function getAssetDirectory(key:NamespacedKey, ext:String = "") {
        #if (debug && !mobile)
        // Main.log('debug paths');
        var rootPath = "./../../../mods/";
        var namespacedPath = "mods/";
        #else
        // Main.log('normal paths');
        var rootPath = "./mods/";
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

        // Main.log(FileSystem.absolutePath(rootPath + namespacedPath + fileName));

        #if (!mobile)
        if (FileSystem.exists(rootPath + namespacedPath + fileName)) {
            // Main.log("exists");
            return rootPath + namespacedPath + fileName;
        } else
            return null;
        #else
        // if (sys.io.)
        return null;
        #end
    }
}
