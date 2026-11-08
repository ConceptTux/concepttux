package objects;

import flixel.tweens.FlxTween;
import flixel.FlxG;
import misc.VPBSprite;

class Egg extends VPBSprite
{
    var direction:Int = 1;

    var movementEnabled:Bool = true;
    final moveSpeed:Int = 100; // based on milestone 1, probably same in milestone 2 idk

    public function new(x:Float, y:Float)
    {
        // HaxeFlixel
        super(x, y);

        immovable = false;

        // Set max speed so the Egg doesn't go too fast (it shouldn't anyways)
        physics.maxVelocityX = moveSpeed;

        // Load egg sprite (TODO: possibly remake the sprite in the future for it to look good when rotating?)
        loadGraphic("data/images/powerup/egg.png");

        // And finally, a possibly-unnecessary setSize(), verify that this is useless by replacing it with a trace() later.
        setSize(32, 32);
    }

    override public function update(elapsed:Float)
    {
        // Movement
        if (movementEnabled)
        {
            physics.velocityX = direction * moveSpeed;
        }

        // Flip when hitting a wall
        if (isWalkingIntoWall())
        {
            direction = -direction;
        }

        // Extra safety!
        velocity.set(0, 0);
        acceleration.set(0, 0);
        drag.set(0, 0);

        // HaxeFlixel
        super.update(elapsed);
    }

    public function collect(tux:Player)
    {
        FlxG.sound.play("data/sounds/grow.ogg");
        kill();
        tux.bigTux();
    }

    public function spawnFromBlock(direction:String)
    {
        solid = false;
        physics.gravityEnabled = false;
        movementEnabled = false;

        var startY = this.y;

        if (direction == "left")
        {
            this.direction = -1;
        }
        else if (direction == "right")
        {
            this.direction = 1;
        }
        else
        {
            trace("Unsupported direction! Supported directions are \"left\" and \"right\".");
        }

        FlxTween.tween(this, {y: startY - 32}, 0.5, {onComplete: function(_) 
        {
            physics.gravityEnabled = true;
            movementEnabled = true;
            solid = true;
        }, type: ONESHOT});
    }
}