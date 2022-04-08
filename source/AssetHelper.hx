package;

import NamespacedKey.AbstractNamespacedKey;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxAnimationController;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.util.typeLimit.OneOfTwo;
import haxe.extern.Rest;
import haxe.io.Bytes;
import openfl.display.BitmapData;
import openfl.media.Sound;
import scripting.Script;

using StringTools;

// import hscript.Expr;
// import hscript.Interp;
// import hscript.Parser;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
#if wackyassets
import openfl.utils.Assets as OpenFLAssets;
#end

/*class ModScript {
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
}*/
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

/**
 * special version of openfls BitmapData that cannot be disposed (normally).
 * this exists soley to help with issues casued by flixel disposing it when i dont want it to (so i can cache it)
 */
class PersistentBitmapData extends BitmapData {
   override public function dispose():Void {
      // just dont dispose the image lmao
   }

   // a way to dispose anyways, just in case i want to manually do it
   public function reallyDispose():Void {
      super.dispose();
   }

   public function new(width:Int, height:Int, transparent:Bool = true, fillColor:UInt = 0xffffffff) {
      #if memtraces
      trace('new persistent bitmap');
      #end
      super(width, height, transparent, fillColor);
   }

   public static function fromFile(path:String) {
      #if (js && html5)
      return null;
      #else
      var bitmapData = new PersistentBitmapData(0, 0, true, 0);
      bitmapData.__fromFile(path);
      return bitmapData.image != null ? bitmapData : null;
      #end
   }
}

class AssetHelper {
   // public static final instance = new AssetHelper();
   public static final saveDirectory:String = "./save/";
   static inline final saveNamespace:String = "chromasave";

   // public static final scriptCache:Map<String, Expr> = new Map<String, Expr>();
   public static final imageCache:Map<String, BitmapData> = new Map<String, BitmapData>();
   public static final aseCache:Map<String, Bytes> = new Map<String, Bytes>();

   // private static var parser:Parser = new Parser();
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
            new DelayedAsset<Script>(key, type);
         case SOUND:
            new DelayedAsset<FlxSound>(key, type);
      }
   }

   private static function getNullBitmap():BitmapData {
      #if memtraces
      trace('new null bitmap');
      #end
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

      var assetDir = AssetHelper.getAssetDirectory(key, ".png");

      if (assetDir != null) {
         #if wackyassets
         var bitmap = FlxAssets.getBitmapData(assetDir);
         #else
         var bitmap = PersistentBitmapData.fromFile(assetDir);
         #end
         AssetHelper.imageCache.set(key.toString(), bitmap);
         return bitmap;
      }
      trace('couldnt get ${assetDir} ${key}');
      return getNullBitmap();

      // return getAsset(key);
   }

   public static function getSoundAsset(key:NamespacedKey, loop:Bool = false, persist:Bool = false):FlxSound {
      var assetDir = AssetHelper.getAssetDirectory(key, '.ogg');
      if (assetDir == null) {
         trace('sound asser dir is null!');
         return null;
      }
      #if wackyassets
      var soundFile = OpenFLAssets.getSound(assetDir);
      #else
      var soundFile = Sound.fromFile(assetDir);
      #end

      var sound = FlxG.sound.load(soundFile, 1, loop);

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

   public static function getScriptAsset(key:NamespacedKey, ?reload:Bool = false):Script {
      var isCFASM = key.key.endsWith('.cfasm'); // .cfasm = chroma-fighters assembly
      var ext = isCFASM ? '.cfasm' : '.cfs';

      var assetDir = AssetHelper.getAssetDirectory(key, ext);

      if (assetDir == null) {
         return new Script('return 0');
      }

      #if wackyassets
      var contents = OpenFLAssets.getText(assetDir);
      #else
      var contents = sys.io.File.getContent(assetDir);
      #end

      return new Script(contents);
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

   public static function generateCombinedSpriteSheetForFighter(folderKey:NamespacedKey, sprite:FlxSprite, size:Int, play:String):Void {
      folderKey.parseSpecialNamespaces();
      var cacheKey = folderKey.withKey(folderKey.key + '?combined');

      var bitmap:BitmapData;

      #if wackyassets
      var folderContents = getFolderContents(folderKey);
      #else
      var folderPath = AssetHelper.getAssetDirectory(folderKey);
      var folderContents = FileSystem.readDirectory(folderPath);
      #end

      var spritesToLoad = folderContents.filter(name -> name.endsWith('.png'));
      spritesToLoad = spritesToLoad.map(name -> name.split('.')[0]);

      var animations:Array<AnimationCombinerThing> = [];
      var curFrame:Int = 0;
      // var oldPersist = FlxGraphic.defaultPersist;
      // FlxGraphic.defaultPersist = true;
      for (asset in spritesToLoad) {
         #if wackyassets
         var thisBitmap = AssetHelper.getImageAsset(folderKey.withKey(folderKey.key + '/${asset}'));
         #else
         var thisBitmap = AssetHelper.getImageAsset(folderKey.withKey(folderKey.key + '/${asset}'));
         #end
         var frames = Math.floor(thisBitmap.width / thisBitmap.height);
         // trace('asset ${frames} ${thisBitmap.width / thisBitmap.height}');
         animations.push({
            bitmap: thisBitmap,
            frames: frames,
            startIndex: curFrame,
            name: asset
         });
         curFrame += frames;
      }

      if (imageCache.exists(cacheKey.toString())) {
         bitmap = imageCache.get(cacheKey.toString());
         #if memtraces
         trace('reusing bitmap');
         #end
      } else {
         bitmap = FlxTileFrames.combineTileSets(animations.map(a -> a.bitmap), FlxPoint.weak(size, size)).parent.bitmap;
         imageCache.set(cacheKey.toString(), bitmap);
      }
      // FlxGraphic.defaultPersist = oldPersist;
      sprite.loadGraphic(bitmap, true, size, size);
      FlxG.bitmapLog.add(bitmap, cacheKey.toString());
      // PlayerSlot.getPlayer(0).fighter.sprite.animation.play('crouch_idle')
      for (animation in animations) {
         // trace('${animation.name} ${getFramesArray(animation.startIndex, animation.frames)}');
         sprite.animation.add(animation.name, getFramesArray(animation.startIndex, animation.frames), 12, false);
      }
      sprite.animation.play(play);
      sprite.graphic.persist = true;
      // trace(sprite.animation.getNameList());
   }

   public static function getAssetDirectory(key:NamespacedKey, ext:String = "") {
      key.parseSpecialNamespaces();
      #if wackyassets
      if (key.namespace == NamespacedKey.DEFAULT_NAMESPACE) {
         #if memtraces
         trace(key.asFileReference() + '__' + (ext == null ? '' : ext));
         #end
         return getAssetPathRaw(key.asFileReference(), ext);
      }
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
      var contents = getAssetPathRaw(key.asFileReference() + '__DIR');
      trace(contents);
      return contents.split(',');
      #else
      return FileSystem.readDirectory(getAssetDirectory(key));
      #end
   }

   #if wackyassets
   private static function getAssetPathRaw(path:String, ?ext:String):String {
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
