package misc;

import flixel.FlxSprite;

class AnimatedTile extends FlxSprite
{
    public function new(x:Float, y:Float, spritePath:String, frameWidth:Int, frameHeight:Int, frameArray:Array<Int>, fps:Float = 10.0)
    {
        super(x, y);

        loadGraphic(spritePath, true, frameWidth, frameHeight);

        animation.add("normal", frameArray, fps, true);
        animation.play("normal");
    }
}