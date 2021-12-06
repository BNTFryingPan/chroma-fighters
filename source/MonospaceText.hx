package;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;

class MonospaceText extends FlxBitmapText {
    /*public static var monospaceFont:FlxBitmapFont = FlxBitmapFont.fromMonospace(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/font_mono_expanded")),
        "abcdefghijklmnop"
        + "qrstuvwxyzABCDEF"
        + "GHIJKLMNOPQRSTUV"
        + "WXYZ0123456789()"
        + "[]{}<>\\/'\";:.,`~"
        + "!@#$%^&*-_=+|?  "
        + "¡™£ñÑ⛏¿▪︎×       "
        + "♠︎♥︎◆♣︎■●•≠ ☂      "
        + "♤♡◇♧□○°≈☽☀      "
        + "        ☾☁    ♂♀"
        + "                "
        + "                "
        + "                "
        + "                "
        + "              ☆★"
        + "                ",
        FlxPoint.get(8, 8)); */
    public static var monospaceFont:FlxBitmapFont = FlxBitmapFont.fromMonospace(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace('images/font_mono')),
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890(){}[]+-/*=_!#%^\\|.,;:?<>&'\"~`☆★ " // + "[]{}<>\\/'\";:.,`~"
        // + "!@#$%^&*-_=+|?"
        , FlxPoint.get(8, 8));

    public function new(x:Float, y:Float, width:Int = 0, text:Null<String> /*, size:Int = 8*/) {
        super(MonospaceText.monospaceFont);
        trace("new mono text");
        this.text = "TEXT";
        this.x = x;
        this.y = y;
        this.fieldWidth = width;

        this.useTextColor = false;
        this.autoSize = true;
        this.multiLine = true;
    }
}
