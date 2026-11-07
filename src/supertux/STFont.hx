package supertux;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class STFGlyph
{
    public var graphic:FlxGraphic;
    public var shadow:FlxGraphic;
    public var advance:Int;

    public function new(graphic:FlxGraphic, shadow:FlxGraphic, advance:Int)
    {
        this.graphic = graphic;
        this.shadow = shadow;
        this.advance = advance;
    }
}

class STFont
{
    public var glyphWidth(default, null):Int;
    public var glyphHeight(default, null):Int;
    public var glyphBorder(default, null):Int;

    var glyphs:Map<Int, STFGlyph>;

    private function new()
    {
        glyphs = new Map();
    }

    public static function load(path:String):STFont
    {
        var font = new STFont();

        var data = Assets.getText(path);

        if (data == null)
        {
            throw "Could not load STF file!";
        }

        var root = STFNode.parse(data);

        font.glyphWidth =  root.getInt("glyph-width");
        font.glyphHeight = root.getInt("glyph-height");
        font.glyphBorder = root.getInt("glyph-border");

        var surface = root.getChild("surface");

        if (surface == null)
        {
            throw "STF file has no surface!";
        }

        font.loadSurface(surface);

        return font;
    }

    private function loadSurface(surface:STFNode)
    {
        var charWidth = surface.getInt("glyph-width", glyphWidth);
        
        var glyphFile = surface.getString("glyphs");
        var shadowFile = surface.getString("shadows");
        var chars = surface.getStrings("chars");

        if (chars.length == 0)
        {
            throw "STF surface has no chars!";
        }

        var glyphBitmap = Assets.getBitmapData("data/images/engine/fonts/" + glyphFile);
        var shadowBitmap = Assets.getBitmapData("data/images/engine/fonts/" + shadowFile);

        if (glyphBitmap == null)
        {
            throw "Could not load glyph image!";
        }

        if (shadowBitmap == null)
        {
            throw "Could not load shadow image!";
        }

        var wrap = Std.int(glyphBitmap.width / charWidth);

        var row:Int = 0;
        var col:Int = 0;

        for (charSet in chars)
        {
            for (i in 0...charSet.length)
            {
                var charCode = charSet.charCodeAt(i);

                var x = col * (charWidth + 2 * glyphBorder) + glyphBorder;
                var y = row * (glyphHeight + 2 * glyphBorder) + glyphBorder;

                col += 1;

                if (col == wrap)
                {
                    col = 0;
                    row += 1;
                }

                if (charCode == " ".code && glyphs.exists(" ".code))
                {
                    continue;
                }

                var glyphBitmapData = copyRegion(glyphBitmap, x, y, charWidth, glyphHeight);
                var shadowBitmapData = copyRegion(shadowBitmap, x, y, charWidth, glyphHeight);

                var glyphGraphic = FlxG.bitmap.add(glyphBitmapData);
                var shadowGraphic = FlxG.bitmap.add(shadowBitmapData);

                glyphGraphic.persist = true;
                shadowGraphic.persist = true;

                glyphs.set(charCode, new STFGlyph(glyphGraphic, shadowGraphic, charWidth));
            }

            if (col > 0 && col <= wrap)
            {
                col = 0;
                row += 1;
            }
        }
    }

    public function getGlyph(charCode:Int):STFGlyph
    {
        var glyph =
            glyphs.get(charCode);

        if (glyph != null)
            return glyph;

        return glyphs.get(" ".code);
    }

    public function getTextWidth(
        text:String
    ):Int
    {
        var width:Int = 0;

        for (i in 0...text.length)
        {
            var charCode =
                text.charCodeAt(i);

            if (charCode == "\n".code)
                continue;

            width +=
                getGlyph(charCode).advance;
        }

        return width;
    }

    private static function copyRegion(source:BitmapData, x:Int, y:Int, width:Int, height:Int):BitmapData
    {
        var result = new BitmapData(width, height, true, 0x00000000);
        result.copyPixels(source, new Rectangle(x, y, width, height), new Point(0, 0), null, null, true);

        return result;
    }
}