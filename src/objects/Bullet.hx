package objects;

import misc.VPBSprite;

class Bullet extends VPBSprite
{
    var speed:Float = 600;
    var speed2:Float = 0; // Don't change this!

    final maxBounces:Int = 3;
    var bounces:Int = 0; // Don't change this!

    public var direction:Int = 1; // Don't change this!

    var previousVelocityY:Float = 0.0; // Don't change this!

    public function new(x:Float, y:Float)
    {
        super(x, y);

        loadGraphic("data/images/objects/fireball.png", false);
        setSize(16, 16);

        Global.PS.activeBullets += 1;
        
        physics.velocityY = 0;

        trace(Std.string(Global.PS.activeBullets) + " / " + Std.string(Global.PS.maximumBullets));
    }

    public function setSpeed(tux:Player)
    {
        direction = tux.direction;

        if (tux.direction == 1)
        {
            if (tux.physics.velocityX >= 1)
            {
                speed = speed + tux.physics.velocityX / 2;
            }
        }
        else
        {
            if (tux.physics.velocityX <= -1)
            {
                speed = speed - tux.physics.velocityX / 2;
            }
        }

        if (tux.physics.velocityY <= 0)
        {
            speed = speed - tux.physics.velocityY;
        }

        speed2 = speed;
        physics.maxVelocityX = speed;
    }

    override public function update(elapsed:Float)
    {
        // Extra safety!
        velocity.set(0, 0);
        acceleration.set(0, 0);
        drag.set(0, 0);

        physics.velocityX = direction * speed2;

        if (physics.velocityY > 0)
        {
            previousVelocityY = physics.velocityY;
        }

        if (physics.grounded)
        {
            physics.velocityY = -previousVelocityY;
            bounces += 1;
            trace(bounces);
        }

        if (bounces >= maxBounces || isTouching(WALL) || isTouching(CEILING) || !isOnScreen())
        {
            kill();
        }

        super.update(elapsed);
    }

    override public function kill()
    {
        Global.PS.activeBullets -= 1;
        trace(Global.PS.activeBullets);
        alive = false;
        exists = false;
    }
}