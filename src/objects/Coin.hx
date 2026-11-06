package objects;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class Coin extends FlxSprite
{
    var targetY:Int = 96;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        loadGraphic("data/images/objects/coin.png", true, 32, 32);
        animation.add("normal", [0, 1, 2, 3, 4, 5, 6, 7], 10.0, true);
        animation.play("normal");
    }

    public function collect()
    {
        alive = false;
        solid = false;
        Global.addCoins(1);
        FlxTween.tween(this, {alpha: 0, y: y - targetY}, 0.4, {onComplete: function (_)
        {
            kill();
        }}); // thanks official haxeflixel tutorial
    }
}