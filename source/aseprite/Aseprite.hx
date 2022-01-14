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

typedef NineSliceSlices = Array<Array<BitmapData>>;

typedef FrameLayer = {
    layerChunk:LayerChunk,
    cel:Cel,
}

class Cel extends BitmapData {
    public var data(default, null):CelChunk;

    public function new(sprite:Aseprite, chunk:CelChunk) {
        super(chunk.width, chunk.height, true, 0x00000000);
        this.data = chunk;

        var pixelInput:BytesInput = new BytesInput(data.rawData);
        var pixels:ByteArray = new ByteArray(chunk.width * chunk.data * 4);

        for (_ in 0...data.height) {
            for (_ in 0...data.width) {
                var pixel:UInt = 0x00000000;

                switch (sprite.ase.header.colorDepth) {
                    case ColorDepth.RGBA:
                        pixel = pixelInput.read(4).rgbaToargb();
                    case ColorDepth.GREYSCALE:
                        pixel = pixelInput.read(2).greyscaleToargba();
                    case ColorDepth.INDEXED:
                        pixel = sprite.indexedToargb(pixelInput.readByte());
                }

                pixels.writeUnsignedInt(pixel);
            }
        }

        pixels.position = 0;
        lock();
        setPixels(rect, pixels);
        unlock();

        pixels.clear();
    }
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

class Frame {
    public static var blendModes:Array<BlendMode> = [
        NORMAL, // 0 - Normal
        MULTIPLY, // 1 - Multiply
        SCREEN, // 2 - Scren
        OVERLAY, // 3 - Overlay
        DARKEN, // 4 - Darken
        LIGHTEN, // 5 -Lighten
        NORMAL, // 6 - Color Dodge - NOT IMPLEMENTED
        NORMAL, // 7 - Color Burn - NOT IMPLEMENTED
        HARDLIGHT, // 8 - Hard Light
        NORMAL, // 9 - Soft Light - NOT IMPLEMENTED
        DIFFERENCE, // 10 - Difference
        ERASE, // 11 - Exclusion - Not sure about that
        NORMAL, // 12 - Hue - NOT IMPLEMENTED
        NORMAL, // 13 - Saturation - NOT IMPLEMENTED
        NORMAL, // 14 - Color - NOT IMPLEMENTED
        NORMAL, // 15 - Luminosity - NOT IMPLEMENTED
        ADD, // 16 - Addition
        SUBTRACT, // 17 - Subtract
        NORMAL // 18 - Divide - NOT IMPLEMENTED
    ];

    private var frame:ase.Frame;
    private var renderWidth:Int;
    private var renderHeight:Int;

    public var bitmapData:BitmapData;
    public var duration(get, never):Int;
    public var layers(default, null):Array<FrameLayer> = [];
    public var layersMap(default, null):Map<String, FrameLayer> = [];
    public var tags(default, null):Array<String> = [];
    public var index(default, null):Int;
    public var nineSlices:NineSliceSlices;
    public var sprite(default, null):Aseprite;

    inline function get_duration():Int {
        return frame.header.duration;
    }

    public function new(index:Int, ?frameBitmapData:BitmapData, ?nineSlices:NineSliceSlices, ?renderWidth:Int, ?renderHeight:Int, ?sprite:Aseprite, ?frame:ase.Frame) {
        if (sprite != null)
            this.sprite = sprite;

        if (frameBitmapData != null) {
            this.bitmapData = frameBitmapData;
            return;
        }
            
        if (nineSlices != null) {
            this.nineSlices = nineSlices;
        } else {
            this.bitmapData = new BitmapData(sprite.ase.header.width, sprite.ase.header.height, true, 0x00000000);
            this.frame = frame;

            for (layer in sprite.aLayers) {
                var layerDef:FrameLayer = {layerChunk: layer, cel: null};
                this.layers.push(layerDef);
                this.layersMap.set(layer.name, layerDef);
            }

            for (chunk in frame.chunks.filter(c -> { c.header.type==ChunkType.CEL })) {
                var cel:CelChunk = cast chunk;
                this.layers[cel.layerIndex].cel = (
                    cel.celType == CelType.LINKED ?
                    sprite.aFrames[cel.linkedFrame].layers[cel.layerIndex].cel :
                    new Cel(sprite, cel)
                );
            }
        }

        for (layer in this.layers.filter(l -> {return (l.cel != null && (l.layerChunk.flags & LayerFlags.VISIBLE != 0))})) {
            var blendMode:BlendMode = Frame.blendModes[layer.layerChunk.blendMode];
            var matrix:Matrix = new Matrix();
            matrix.translate(layer.cel.data.xPosition, layer.cel.data.yPosition);
            bitmapData.lock();
            bitmapData.draw(layer.cel, matrix, null, blendMode);
            bitmapData.unlock();
        }
    }

    public function render9Slice(renderWidth:Int, renderHeight:Int) {
        if (null) if (this.bitmapData != null) {
            this.bitmapData.dispose();
            this.bitmapData = null;
        }

        var centerWidth = renderWidth - (nineSlices[0][0].width + nineSlices[0][2].width);
        var centerHeight = renderHeight - (nineSlices[0][0].height + nineSlices[2][0].height);
        var centerX = nineSlices[0][0].width;
        var centerY = nineSlices[0][0].height;

        var xs = [0, centerX, centerX + centerWidth];
        var ys = [0, centerY, centerY + centerHeight];

        var widths:Array<Int> = [nineSlices[0][0].width, centerWidth, nineSlices[0][2].width];
        var heights:Array<Int> = [nineSlices[0][0].height, centerHeight, nineSlices[2][0].height];

        var render = new Sprite();

        for (row in 0...3) {
            for (col in 0...3) {
                var sliceRender = new Shape();

                sliceRender.graphics.beginBitmapFill(nineSlices[row][col]);
                sliceRender.graphics.drawRect(0, 0, widths[col], heights[row]);
                sliceRender.graphics.endFill();

                sliceRender.x = xs[col];
                sliceRender.y = ys[row];

                render.addChild(sliceRender);
            }
        }

        bitmapData = new BitmapData(renderWidth, renderHeight, true, 0x00000000);
        bitmapData.draw(render);
    }

    public function resize(newWidth:Int, newHeight:Int) {
        this.render9Slice(newWidth, newHeight);
    }
}

class NineSlice extends FlxSprite {
    public static function generate(bitmap:BitmapData, sliceKey:SliceKey):NineSliceSlices {
        var result:NineSliceSlices = [for (_ in 0...3) [for (_ in 0...3) null]];

        var xs = [
            sliceKey.xOrigin,
            sliceKey.xOrigin + sliceKey.xCenter,
            sliceKey.xOrigin + sliceKey.xCenter + sliceKey.centerWidth,
        ];

        var ys = [
            sliceKey.yOrigin,
            sliceKey.yOrigin + sliceKey.yCenter,
            sliceKey.yOrigin + sliceKey.yCenter + sliceKey.centerHeight,
        ];

        var widths = [
            sliceKey.xCenter,
            sliceKey.centerWidth,
            sliceKey.width - (sliceKey.xCenter + sliceKey.centerWidth)
        ];

        var heights = [
            sliceKey.yCenter,
            sliceKey.centerHeight,
            sliceKey.height - (sliceKey.yCenter + sliceKey.centerHeight)
        ];

        var zeroPoint = new Point(0, 0);

        for (row in 0...3) {
            for (col in 0...3) {
                var slice = new BitmapData(widths[col], heights[row]);
                slice.copyPixels(bitmap, new Rectangle(xs[col], ys[row], widths[col], heights[row]), zeroPoint);
                result[row][col] = slice;
            }
        }

        return result;
    }
}

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

class Slice {
    public var name(get, never):String;
    public var data(default, null):SliceChunk;
    public var has9Slices(get, never):Bool;
    public var firstKey(get, never):SliceKey;

    public function new(data:SliceChunk) {
        this.data = data;
    }

    inline function get_name() {
        return data.name;
    }

    inline function get_has9Slices() {
        return data.has9Slices;
    }

    inline function get_firstKey() {
        return data.sliceKeys[0];
    }
}

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

    public var filePath:String;

    public var aFrames(default, null):Array<Frame> = [];
    public var aFrameTags:TagsChunk;
    public var aFrameTime:Int = 0;
    public var aLayers(default, null):Array<LayerChunk> = [];
    public var aPalette(default, null):Palette;
    public var aBitmap(default, null):Bitmap;
    public var aPlaying(default, null):Bool
    public var playBackSpeed:Int = 20;

    public var aTags(default, null):Map<String, Tag> = [];

    public var onFinished:Void -> Void = null;
    public var onFrame:Array<Int -> Void> = [];
    public var onTag:Array<Array<String> -> Void> = [];

    public var currentFrame(default, set):Int = -1;
    public var currentRepeat:Int = 0;
    public var currentTag:String;
    public var alternatingDirection:Int = AnimationDirection.FORWARD;
    public var direction:Int = AnimationDirection.FORWARD;
    public var repeats:Int = -1;

    public var toFrame(get, never):Int;
    public var fromFrame(get, never):Int;

    public var slices(default, null):Map<String, Slice> = [];

    public static function fromBytes(bytes:Bytes, useEnterFrame:Bool = true) {
        return null;
    }

    public function new(x:Float, y:Float, width, height, ?file:String, ?bytes:Bytes) {
        super(x, y);
        
        this.makeGraphic(width, height, KColor.TRANSPARENT);
        if (file != null) {
            this.filePath = file;

            bytes = AssetHelper.getAsepriteFile(/* what */);
        }

        if (bytes != null) {
            ase = Ase.fromBytes(data);
            parseAsepriteFile(ase);
        }
    }
    

    override public function update(elapsed:Float) {
        super.update(elapsed);
        if (aPlaying)
            advance(playBackSpeed);
    }

    public function setPlaybackSpeed(val:Int) {
        this.playBackSpeed = val;
        return this;
    }

    public function play(?tagName:String = null, ?repeats:Int = -1, ?onFinished:Void->Void=null) {
        if (tagName != null)
            currentTag = tagName;
        
        aPlaying = true;
        this.repeats = currentRepeat = repeats;
        this.onFinished = onFinished;
        
        return this;
    }

    public function pause() {
        this.aPlaying = false;
        return this;
    }

    public function stop() {
        this.pause();
        this.currentFrame = this.fromFrame;
        this.currentRepeat = this.repeats;
        return thi;
    }

    public function spawn(?sliceName:String, ?spriteWidth:Int, ?spriteHeight:Int, ?useEnterFrame:Bool) {
        return null;
    }

    public function advance(time:Int) {
        if (!this.aPlaying)
            return this;

        if (time < 0)
            throw 'what lmao';
        
        this.aFrameTime += time;

        while (this.aFrameTime > this.aFrames[this.currentFrame].duration) {
            this.aFrameTime -= this.aFrames[this.currentFrame].duration;
            nextFrame();
        }

        return this;
    }

    public function nextFrame() {
        var currentDirection = direction;
        if (direction == AnimationDirection.PING_PONG)
            currentDirection = this.alternatingDirection;

        var futureFrame = currentFrame;
        var alternationDirection = currentDirection;

        if (currentDirection == AnimationDirection.FORWARD)
            futureFrame = currentFrame + 1;
        else if (currentDirection == AnimationDirection.REVERSE) {
            futureFrame = currentFrame - 1;
            alternationDirection = AnimationDirection.FORWARD;
        }

        if (!(futureFrame > toFrame || futureFrame < fromFrame)) {
            currentFrame == futureFrame;
            return this;
        }

        if ((repeats == -1) || (repeats != -1 && --currentRepeat > 0)) {
            currentFrame = (direction == AnimationDirection.PING_PONG ? currentFrame + (alternationDirection == AnimationDirection.FORWARD ? 1 : -1) : fromFrame);
            return this
        }

        pause();
        if (onFinished != null) {
            onFinished();
            onFinished = null;
        }

        return this;
    }

    public function resize(newWidth:Int, newHeight:Int) {
        setGraphicSize(newWidth, newHeight);
        updateHitbox();
        return this;
    }

    public function parseAsepriteFile(value:Ase):Ase {
        ase = value;

        for (chunk in ase.frames[0].chunks) {
            switch (chunk.header.type) {
                case ChunkType.LAYER:
                    aLayers.push(cast chunk);
                case ChunkType.PALETTE:
                    aPalette = new Palette(cast chunk);
                case ChunkType.TAGS:
                    aFrameTags = cast chunk;
                    for (frameTagData in aFrameTags.tags) {
                        var animationTag = new Tag(frameTagData);
                        var tagName = frameTagData.tagName;

                        if (aTags.exists(tagName)) {
                            var num = 1;
                            var newName = '${tagName}_${num}';
                            while (aTags.exists(newName))
                                newName = '${tagName}_${num++}';
                            // log a warning about tag rename
                        }

                        aTags.set(tagName, animationTag);
                    }
                case ChunkType.SLICE:
                    var newSlice = new Slice(cast chunk);
                    slices[newSlice.name] = newSlice;
                case _:
                    // do nothing
            }
        }

        for (index in 0...ase.frames.length) {
            var frame = ase.frames[index];
            var newFrame:Frame = new Frame(index, this, frame);
            aFrames.push(newFrame);
        }

        for (tag in aTags) for (frameIndex in tag.data.fromFrame...tag.data.toFrame + 1) aFrames[frameIndex].tags.push(tag.name);

        currentFrame = 0;
        return ase;
    }

    inline function get_toFrame():Int {
        return currentTag != null ? aTags[currentTag].data.toFrame : aFrames.length-1;
    }

    inline function get_fromFrame():Int {
        return currentTag != null ? aTags[currentTag].data.fromFrame : 0;
    }

    function set_currentFrame(value:Int):Int {
        if (value < 0)
            value = 0;
        
        if (value >= aFrames.length)
            value = aFrames.length-1;

        this.currentFrame = value;
        var frameData = this.aFrames[this.currentFrame].bitmapData;

        if (this.graphic != null) {
            this.graphic.bitmap.fillRect(new Rectangle(0, 0, frameWidth, frameHeight), KColor.TRANSPARENT);
            this.graphic.bitmap.draw(frameData);
        }

        return currentFrame;
    }
}
