//  SuperTux Rebuilt
//  Copyright (C) 2026 AnatolyStev
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

package supertux;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class STFText extends FlxSpriteGroup
{
    public var font(default, null):STFont;

    var shadowGroup:FlxSpriteGroup;
    var glyphGroup:FlxSpriteGroup;

    var shadowSprites:Array<FlxSprite>;
    var glyphSprites:Array<FlxSprite>;

    var _text:String = "";

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