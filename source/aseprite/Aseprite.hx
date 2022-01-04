package aseprite;

import ase.Ase;
import ase.chunks.CelChunk;
import ase.chunks.LayerChunk;
import ase.chunks.PaletteChunk;
import ase.chunks.TagsChunk;
import haxe.io.Bytes;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.utils.Assets;

enum abstract ColorDepth(Int) from Int to Int {
    var RGBA:Int = 32;
    var GREYSCALE:Int = 16;
    var INDEXED:Int = 8;
}

class Cel extends BitmapData {
    public var data(default, null):CelChunk;
}

class Color {
    public static function rgbaToargb(rgba:Bytes):UInt {
        var argb:Bytes = Bytes.alloc(4);
        argb.set(0, rgba.get(2));
        argb.set(1, rgba.get(1));
        argb.set(2, rgba.get(0));
        argb.set(3, rgba.get(3));
        return argb.getInt32(0);
    }

    public static function grayscaleTorgba(bytePair:Bytes):UInt {
        var rgba:Bytes = Bytes.alloc(4);
        var white = bytePair.get(0);
        rgba.set(0, white);
        rgba.set(1, white);
        rgba.set(2, white);
        rgba.set(3, bytePair.get(1));
        return rgba.getInt32(0);
    }

    public static function grayscaleToargba(bytePair:Bytes):UInt {
        var argb:Bytes = Bytes.alloc(4);
        var white = bytePair.get(0);
        argb.set(0, bytePair.get(1));
        argb.set(1, white);
        argb.set(2, white);
        argb.set(3, white);
        return argb.getInt32(0);
    }

    public static function indexedToargb(sprite:Aseprite, index:Int):Null<UInt> {
        if (index == sprite.ase.header.paletteEntry) {
            return 0x00000000;
        }

        if (sprite.palette.entries.exists(index)) {
            return sprite.palette.entries.get(index);
        }

        return 0x00000000;
    }
}

class Frame {}
class NineSlice {}

class Palette {
    public var data(default, null):PaletteChunk;
    public var entries(default, null):Map<Int, UInt> = [];
    public var size(get, null):Int;

    inline function get_size():Int {
        return data.paletteSize;
    }

    public function new(chunk:PaletteChunk) {
        this.data = chunk;
        for (i in data.entries.keys()) {
            var entry = data.entries[i];
            var color:Bytes = Bytes.alloc(4);
            color.set(0, entry.blue);
            color.set(1, entry.green);
            color.set(2, entry.red);
            color.set(3, entry.alpha);
            entries.set(i, color.getInt32(0));
        }
    }
}

class Slice {}

class Tag {
    public var data(default, null):ase.chunks.TagsChunk.Tag;
    public var name(get, never):String;

    public function new(data:ase.chunks.TagsChunk.Tag) {
        this.data = data;
    }

    inline function get_name():String {
        return data.tagName;
    }
}

class Aseprite {
    public var ase:Ase;

    public var frames:Array<Frame>;
    public var frameTags:TagsChunk;
    public var frameTime:Int = 0;
    public var layers:Array<LayerChunk>;
    public var palette:Palette;
    public var bitmap:Bitmap;
    public var tags:Map<String, Tag>;

    public function new(file:String) {
        if (file == null)
            return;

        Assets.loadBytes(file).onComplete(bytes -> {
            this.ase = Ase.fromBytes(bytes);
        });
    }
    /*public function parseAseprite(ase:Ase):Ase {
        for (chunk in ase.frames[0].chunks) {
            switch (chunk.header.type) {
                case ChunkType.LAYER:
            }
        }
    }*/
}
