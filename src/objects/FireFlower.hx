package objects;

import flixel.tweens.FlxTween;
import flixel.FlxG;
import misc.VPBSprite;

class FireFlower extends VPBSprite
{
    public function new(x:Float, y:Float)
    {
        // HaxeFlixel
        super(x, y);

        immovable = false;

        // Load the animated graphic (which is why it has "true, 32, 32")
        loadGraphic("data/images/powerup/fireflower.png", true, 32, 32);

        // Add and play animation
        animation.add("default", [0, 1, 2, 3, 2, 1], Global.defaultFPS, true);
        animation.play("default");

        // And finally, a possibly-unnecessary setSize(), verify that this is useless by replacing it with a trace() later.
        setSize(32, 32);
    }

    override public function update(elapsed:Float)
    {
        // Extra safety!
        velocity.set(0, 0);
        acceleration.set(0, 0);
        drag.set(0, 0);

        // HaxeFlixel
        super.update(elapsed);
    }

    public function collect(tux:Player)
    {
        FlxG.sound.play("data/sounds/fire-flower.wav");
        kill();
        tux.fireTux();
    }

    public function spawnFromBlock()
    {
        solid = false;
        physics.gravityEnabled = false;

        var startY = this.y;
        
        FlxTween.tween(this, {y: startY - 32}, 0.5, {onComplete: function(_) 
        {
            physics.gravityEnabled = true;
            solid = true;
        }, type: ONESHOT});
    }
}