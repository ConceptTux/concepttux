package supertux;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class STFText extends FlxSpriteGroup
{
    public var font(default, null):STFont;

    private var shadowGroup:FlxSpriteGroup;
    private var glyphGroup:FlxSpriteGroup;

    private var shadowSprites:Array<FlxSprite>;
    private var glyphSprites:Array<FlxSprite>;

    private var _text:String = "";

    public var text(get, set):String;

    public function new(font:STFont, x:Float = 0, y:Float = 0)
    {
        super(x, y);

        this.font = font;

        shadowSprites = [];
        glyphSprites = [];

        shadowGroup = new FlxSpriteGroup();
        glyphGroup = new FlxSpriteGroup();

        add(shadowGroup);
        add(glyphGroup);
    }

    private function get_text():String
    {
        return _text;
    }

    private function set_text(value:String):String
    {
        if (_text == value)
        {
            return value;
        }

        _text = value;

        rebuild();

        return value;
    }

    private function rebuild()
    {
        for (sprite in shadowSprites)
        {
            sprite.visible = false;
        }

        for (sprite in glyphSprites)
        {
            sprite.visible = false;
        }

        var cursorX:Float = 0;
        var cursorY:Float = 0;
        var index:Int = 0;

        for (i in 0..._text.length)
        {
            var charCode = _text.charCodeAt(i);

            if (charCode == "\n".code)
            {
                cursorX = 0;
                cursorY += font.glyphHeight;
                continue;
            }

            var glyph = font.getGlyph(charCode);

            if (charCode == " ".code)
            {
                cursorX += glyph.advance;
                continue;
            }

            var shadow = getShadowSprite(index);
            var sprite = getGlyphSprite(index);

            shadow.loadGraphic(glyph.shadow);
            shadow.visible = true;

            sprite.loadGraphic(glyph.graphic);
            sprite.visible = true;

            shadow.x = x + cursorX + 2;
            shadow.y = y + cursorY + 2;

            sprite.x = x + cursorX;
            sprite.y = y + cursorY;

            cursorX += glyph.advance;
            index += 1;
        }
    }

    private function getShadowSprite(index:Int):FlxSprite
    {
        while (shadowSprites.length <= index)
        {
            var sprite = new FlxSprite();

            sprite.scrollFactor.set(0, 0);

            shadowSprites.push(sprite);
            shadowGroup.add(sprite);
        }

        return shadowSprites[index];
    }

    private function getGlyphSprite(index:Int):FlxSprite
    {
        while (glyphSprites.length <= index)
        {
            var sprite = new FlxSprite();

            sprite.scrollFactor.set(0, 0);

            glyphSprites.push(sprite);
            glyphGroup.add(sprite);
        }

        return glyphSprites[index];
    }

    public function getTextWidth():Int
    {
        return font.getTextWidth(_text);
    }

    public function getTextHeight():Int
    {
        return font.glyphHeight;
    }
}