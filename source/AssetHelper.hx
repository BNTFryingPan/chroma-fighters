package;

import NamespacedKey.AbstractNamespacedKey;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxAnimationController;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.util.typeLimit.OneOfTwo;
import haxe.extern.Rest;
import haxe.io.Bytes;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import openfl.display.BitmapData;
import openfl.media.Sound;
import flixel.system.FlxAssets;

using StringTools;

#if sys
import sys.FileSystem;
import sys.io.File;
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

class AssetHelper {
   // public static final instance = new AssetHelper();
   public static final saveDirectory:String = "./save/";
   static inline final saveNamespace:String = "chromasave";

   public static final scriptCache:Map<String, Expr> = new Map<String, Expr>();
   public static final imageCache:Map<String, BitmapData> = new Map<String, BitmapData>();
   public static final aseCache:Map<String, Bytes> = new Map<String, Bytes>();

   private static var parser:Parser = new Parser();

   // private function new() {}

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
      #if (sys && !mobile)
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

      #if !sys
      var assetDir = getAssetPath(key, 'png');
      #else
      var assetDir = AssetHelper.getAssetDirectory(key, ".png");
      #end
      if (assetDir != null) {
         #if sys
         var bitmap = BitmapData.fromFile(assetDir);
         #else
         var bitmap = FlxAssets.getBitmapData(assetDir);
         #end
         AssetHelper.imageCache.set(key.toString(), bitmap);
         return bitmap;
      }

      return getNullBitmap();

      //return getAsset(key);
   }

   public static function getSoundAsset(key:NamespacedKey, loop:Bool = false, persist:Bool = false):FlxSound {
      #if !sys
      var assetDir = AssetHelper.getAssetPath(key);
      #else
      var assetDir = AssetHelper.getAssetDirectory(key, '.ogg');
      #end
      if (assetDir == null) {
         return null;
      }
      #if sys
      var sound = FlxG.sound.load(Sound.fromFile(assetDir), 1, loop);
      #else
      var sound = FlxG.sound.load(FlxAssets.getSound(assetDir), 1, loop);
      #end
      sound.persist = persist;
      return sound;
   }

   public static function getTextAsset(key:NamespacedKey):Array<String> {
      #if (sys && !mobile)
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
      #if (sys && !mobile)
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
      #if (sys && !mobile)
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
      #if (sys && !mobile)
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
      #if (sys && !mobile)
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
      #if sys
      var folderPath = AssetHelper.getAssetDirectory(folderKey);

      var spritesToLoad = FileSystem.readDirectory(folderPath).filter(name -> name.endsWith('.png'));
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
      #else
      return;
      #end
   }

   public static function getAssetDirectory(key:NamespacedKey, ext:String = "") {
      key.parseSpecialNamespaces();
      #if mobile
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

   #if !sys
   private static function getAssetPath(key:NamespacedKey, ?ext:String):String {
      key.parseSpecialNamespaces();
      if (key.namespace == NamespacedKey.DEFAULT_NAMESPACE)
         //return 'mods/basegame/${key.asFileReference()}';
         if (Reflect.hasField(AssetPaths, 'mods_basegame_${key.asFileReference()}${ext == null ? "" : "__" + ext}'))
            return Reflect.field(AssetPaths, 'mods_basegame_${key.asFileReference()}${ext == null ? "" : "__" + ext}');
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

#if !sys
@:build(WeirdPlatformAssets.buildFileReferences("mods", true))
class AssetPaths {}
#end
