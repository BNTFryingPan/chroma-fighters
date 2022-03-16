package;

import NamespacedKey.AbstractNamespacedKey;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxAnimationController;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.util.typeLimit.OneOfTwo;
import haxe.extern.Rest;
import haxe.io.Bytes;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import openfl.display.BitmapData;
import openfl.media.Sound;

using StringTools;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if wackyassets
import openfl.utils.Assets as OpenFLAssets;
#end

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

enum AssetType {
   ASEPRITE;
   IMAGE;
   BYTES;
   TEXT;
   TEXT_RAW;
   JSON;
   JSON_RAW;
   SCRIPT;
   SOUND;
}

class DelayedAsset<T> {
   public final key:NamespacedKey;
   public final type:AssetType;

   private var asset:Dynamic;

   public function new(key:NamespacedKey, type:AssetType) {
      this.key = key;
      this.type = type;
   }

   public function get():Null<Dynamic> {
      if (!AssetHelper.ready)
         return null;
      if (this.asset != null)
         return this.asset;
      return this.asset = switch (this.type) {
         case ASEPRITE:
            AssetHelper.getAsepriteFile(this.key);
         case IMAGE:
            AssetHelper.getImageAsset(this.key);
         case BYTES:
            null;
         case TEXT:
            AssetHelper.getTextAsset(this.key);
         case TEXT_RAW:
            AssetHelper.getRawTextAsset(this.key);
         case JSON:
            AssetHelper.getJsonAsset(this.key);
         case JSON_RAW:
            AssetHelper.getRawJsonAsset(this.key);
         case SCRIPT:
            AssetHelper.getScriptAsset(this.key);
         case SOUND:
            AssetHelper.getSoundAsset(this.key);
      }
   }
}

class AssetHelper {
   // public static final instance = new AssetHelper();
   public static final saveDirectory:String = "./save/";
   static inline final saveNamespace:String = "chromasave";

   public static final scriptCache:Map<String, Expr> = new Map<String, Expr>();
   public static final imageCache:Map<String, BitmapData> = new Map<String, BitmapData>();
   public static final aseCache:Map<String, Bytes> = new Map<String, Bytes>();

   private static var parser:Parser = new Parser();

   public static var ready:Bool = #if sys true #else false #end;

   // private function new() {}

   ///private static final DelayedAssetTypes:Map<

   public static function loadWhenReady(key:NamespacedKey, type:AssetType):DelayedAsset<Dynamic> {
      return switch (type) {
         case ASEPRITE:
            new DelayedAsset<Bytes>(key, type);
         case IMAGE:
            new DelayedAsset<BitmapData>(key, type);
         case BYTES:
            new DelayedAsset<Bytes>(key, type);
         case TEXT:
            new DelayedAsset<Array<String>>(key, type);
         case TEXT_RAW:
            new DelayedAsset<String>(key, type);
         case JSON:
            new DelayedAsset<Dynamic>(key, type);
         case JSON_RAW:
            new DelayedAsset<String>(key, type);
         case SCRIPT:
            new DelayedAsset<Expr>(key, type);
         case SOUND:
            new DelayedAsset<FlxSound>(key, type);
      }
   }

   private static function getNullBitmap():BitmapData {
      trace('new null bitmap');
      return new BitmapData(1, 1, true, 0xFF00FFFF);
   }

   private static function getNullText():String {
      return "NOT_FOUND";
   }

   private static function getNullBytes():Bytes {
      return null;
   }

   public static function getAsepriteFile(key:NamespacedKey):Bytes {
      #if (sys && !wackyassets)
      if (aseCache.exists(key.toString())) {
         return aseCache.get(key.toString());
      }

      var assetDir = AssetHelper.getAssetDirectory(key, ".aseprite");
      if (assetDir != null) {
         var loaded = sys.io.File.getBytes(assetDir);
         aseCache.set(key.toString(), loaded);
         return loaded;
      }
      return getNullBytes();
      #else
      return getNullBytes();
      #end
   }

   public static function getImageAsset(key:NamespacedKey):BitmapData {
      if (AssetHelper.imageCache.exists(key.toString())) {
         return AssetHelper.imageCache.get(key.toString());
      }

      #if wackyassets
      var assetDir = getAssetPath(key, 'png');
      #else
      var assetDir = AssetHelper.getAssetDirectory(key, ".png");
      #end
      if (assetDir != null) {
         #if !wackyassets
         var bitmap = BitmapData.fromFile(assetDir);
         #else
         var bitmap = FlxAssets.getBitmapData(assetDir);
         #end
         AssetHelper.imageCache.set(key.toString(), bitmap);
         return bitmap;
      }

      return getNullBitmap();

      // return getAsset(key);
   }

   public static function getSoundAsset(key:NamespacedKey, loop:Bool = false, persist:Bool = false):FlxSound {
      #if wackyassets
      var assetDir = AssetHelper.getAssetPath(key, 'ogg');
      #else
      var assetDir = AssetHelper.getAssetDirectory(key, '.ogg');
      #end
      if (assetDir == null) {
         trace('sound asser dir is null!');
         return null;
      }
      #if !wackyassets
      var sound = FlxG.sound.load(Sound.fromFile(assetDir), 1, loop);
      #else
      var sound = FlxG.sound.load(OpenFLAssets.getSound(assetDir), 1, loop);
      #end
      sound.persist = persist;
      return sound;
   }

   public static function getTextAsset(key:NamespacedKey):Array<String> {
      #if (sys && !wackyassets)
      var assetDir = AssetHelper.getAssetDirectory(key, ".txt");
      if (assetDir != null) {
         return sys.io.File.getContent(assetDir).split("\n");
      }
      return [AssetHelper.getNullText()];
      #else
      return [AssetHelper.getNullText()];
      #end
   }

   public static function getRawTextAsset(key:NamespacedKey):String {
      #if (sys && !wackyassets)
      var assetDir = AssetHelper.getAssetDirectory(key, ".txt");
      if (assetDir != null) {
         return sys.io.File.getContent(assetDir);
      }
      return AssetHelper.getNullText();
      #else
      return AssetHelper.getNullText();
      #end
   }

   public static function getScriptAsset(key:NamespacedKey, ?reload:Bool = false):Expr {
      #if (sys && !wackyassets)
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
      #else
      return null;
      #end
   }

   public static function getJsonAsset(key:NamespacedKey):Dynamic {
      #if (sys && !wackyassets)
      var assetDir = AssetHelper.getAssetDirectory(key, ".json");
      if (assetDir != null) {
         return haxe.Json.parse(sys.io.File.getContent(assetDir));
      }
      return {};
      #else
      return {};
      #end
   }

   public static function getRawJsonAsset(key:NamespacedKey):String {
      #if (sys && !wackyassets)
      var assetDir = AssetHelper.getAssetDirectory(key, ".json");
      if (assetDir != null) {
         return sys.io.File.getContent(assetDir);
      }
      return "{}";
      #else
      return "{}";
      #end
   }

   private static function getFramesArray(start:Int, length:Int):Array<Int> {
      var array:Array<Int> = [];
      var cur = start;
      while (cur < (start + length)) {
         array.push(cur++);
      }
      return array;
   }

   public static function generateCombinedSpriteSheetForFighter(folderKey:NamespacedKey, sprite:FlxSprite, size:Int, play:String) {
      #if wackyassets
      var folderContents = getFolderContents(folderKey);
      #else
      var folderPath = AssetHelper.getAssetDirectory(folderKey);
      var folderContents = FileSystem.readDirectory(folderPath);
      #end

      var spritesToLoad = folderContents.filter(name -> name.endsWith('.png'));

      var animations:Array<AnimationCombinerThing> = [];
      var curFrame:Int = 0;
      for (asset in spritesToLoad) {
         var bitmap = AssetHelper.getImageAsset(folderKey.withKey(folderKey.key + '/${asset}'));
         var frames = Math.floor(bitmap.width / bitmap.height);
         trace('asset ${frames} ${bitmap.width / bitmap.height}');
         animations.push({
            bitmap: bitmap,
            frames: frames,
            startIndex: curFrame,
            name: asset.substr(0, -4)
         });
         curFrame += frames;
      }
      sprite.loadGraphic(FlxTileFrames.combineTileSets(animations.map(a -> a.bitmap), FlxPoint.weak(size, size)).parent, true, size, size);
      FlxG.bitmapLog.add(sprite.graphic.bitmap, 'combined');
      // PlayerSlot.getPlayer(0).fighter.sprite.animation.play('crouch_idle')
      for (animation in animations) {
         trace('${animation.name} ${getFramesArray(animation.startIndex, animation.frames)}');
         sprite.animation.add(animation.name, getFramesArray(animation.startIndex, animation.frames), 12, false);
      }
      sprite.animation.play(play);
      sprite.graphic.persist = true;
   }

   public static function getAssetDirectory(key:NamespacedKey, ext:String = "") {
      key.parseSpecialNamespaces();
      #if wackyassets
      return null;
      #elseif (sys)
      // #if (debug)
      // Main.log('debug paths');
      // var rootPath = "./../../../mods/";
      // var namespacedPath = "mods/";
      // #else
      // Main.log('normal paths');
      var rootPath = "./mods/";
      var namespacedPath = "mods/";
      // #end

      var fileName = key.key;
      if (ext != "" && !fileName.endsWith(ext))
         fileName += ext;

      if (key.namespace == saveNamespace) {
         /*#if debug
            rootPath = "./../../../debugSave/";
            #else */
         rootPath = "./save/";
         // #end
         namespacedPath = '';
      } else if (key.namespace == NamespacedKey.DEFAULT_NAMESPACE) {
         namespacedPath = "basegame/";
      } else {
         namespacedPath += key.namespace + "/";
      }

      // Main.log(FileSystem.absolutePath(rootPath + namespacedPath + fileName));

      if (FileSystem.exists(rootPath + namespacedPath + fileName)) {
         // Main.log("exists");
         // trace('${rootPath + namespacedPath + fileName} exists');
         return rootPath + namespacedPath + fileName;
      } else {
         // trace('${rootPath + namespacedPath + fileName} doesnt exist');
         return null;
      }
      #else
      return null;
      #end
   }

   public static function getFolderContents(key:NamespacedKey):Array<String> {
      key.parseSpecialNamespaces();

      #if wackyassets
      var contents = getAssetPathRaw(key + '__DIR');
      trace(contents);
      return contents.split(',');
      #else
      return FileSystem.readDirectory(getAssetDirectory(key));
      #end
   }

   #if wackyassets
   private static function getAssetPath(key:NamespacedKey, ?ext:String):String {
      key.parseSpecialNamespaces();
      if (key.namespace == NamespacedKey.DEFAULT_NAMESPACE) {
         // return 'mods/basegame/${key.asFileReference()}';
         if (Reflect.hasField(AssetPaths, 'mods_basegame_${key.asFileReference()}${ext == null ? "" : "__" + ext}'))
            return Reflect.field(AssetPaths, 'mods_basegame_${key.asFileReference()}${ext == null ? "" : "__" + ext}');
      }
      return null;
   }

   private static function getAssetPathRaw(path:String, ?ext:String):String {
      if (ext == null)
         return 'mods_basegame_${path}';
      if (Reflect.hasField(AssetPaths, 'mods_basegame_${path}${ext == null ? "" : "__" + ext}'))
         return Reflect.field(AssetPaths, 'mods_basegame_${path}${ext == null ? "" : "__" + ext}');
      return null;
   }
   #end
}

typedef AnimationCombinerThing = {
   var bitmap:BitmapData;
   var frames:Int;
   var startIndex:Int;
   var name:String;
}

#if wackyassets
@:build(WeirdPlatformAssets.buildFileReferences("mods"))
class AssetPaths {}
#end
