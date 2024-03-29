package;

#if wackyassets
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;

using StringTools;
using flixel.util.FlxArrayUtil;

class WeirdPlatformAssets {
   public static function buildFileReferences(directory:String = "assets/"):Array<Field> {
      if (!directory.endsWith("/"))
         directory += "/";

      Context.registerModuleDependency(Context.getLocalModule(), directory);

      var fileReferences:Array<FileReference> = getFileReferences(directory);
      var fields:Array<Field> = Context.getBuildFields();

      for (fileRef in fileReferences) {
         // create new field based on file references!
         fields.push({
            name: fileRef.name,
            doc: fileRef.documentation,
            access: [Access.APublic, Access.AStatic, Access.AInline],
            kind: FieldType.FVar(macro:String, macro $v{fileRef.value}),
            pos: Context.currentPos()
         });
      }
      return fields;
   }

   static function getFileReferences(directory:String):Array<FileReference> {
      var fileReferences:Array<FileReference> = [];
      var resolvedPath = #if (ios || tvos) "../assets/" + directory #else directory #end;
      var directoryInfo = FileSystem.readDirectory(resolvedPath);
      for (name in directoryInfo) {
         if (!FileSystem.isDirectory(resolvedPath + name)) {
            // ignore invisible files
            if (name.startsWith("."))
               continue;

            var reference = FileReference.fromPath(directory + name);
            if (reference != null)
               fileReferences.push(reference);
         } else {
            fileReferences = fileReferences.concat(getFileReferences(directory + name + "/"));
				fileReferences.push(new FolderReference(directory + name, FileSystem.readDirectory(resolvedPath + name)));
         }
      }

      return fileReferences;
   }
}

private class FolderReference extends FileReference {
	public function new(name:String, contents:Array<String>) {
		super(name.split("/").join('_').split("-").join("_").split(".").join("__") + '__DIR', contents.join(','));
	}
}

private class FileReference {
   private static var validIdentifierPattern = ~/^[_A-Za-z]\w*$/;

   public static function fromPath(value:String):Null<FileReference> {
      // replace some forbidden names to underscores, since variables cannot have these symbols.
      var name = value.split("/").join('_').split("-").join("_").split(".").join("__");
      if (!validIdentifierPattern.match(name)) // #1796
         return null;
      return new FileReference(name, value);
   }

   public var name(default, null):String;
   public var value(default, null):String;
   public var documentation(default, null):String;

   function new(name:String, value:String) {
      this.name = name;
      this.value = value;
      this.documentation = "`\"" + value + "\"` (auto generated).";
   }
}
#end
