package badguys;

import collision.Collision;
import badguys.Badguy;

class Iceblock extends Badguy
{
    final kickSpeed = 500;

    public function new(x:Float, y:Float, startDirection:BadguySpawnDirections = BadguySpawnDirections.AUTO)
    {
        super(x, y);

        loadGraphic("data/images/creatures/badguy/iceblock.png", true, 35, 38);
        animation.add("walk", [0, 1, 2, 1], 8.0, true);
        animation.add("flat", [3], 8.0, false);
        animation.play("walk");

        setSize(31, 30);
        offset.set(2, 8);

        canBeHeld = true;

        physics.maxVelocityX = walkSpeed;
    }

    override public function move()
    {
        if (currentHeldEnemyState == MOVING_FLAT)
        {
            physics.maxVelocityX = kickSpeed;
            physics.velocityX = direction * kickSpeed;
        }
        else if (currentHeldEnemyState == FLAT || currentHeldEnemyState == HELD)
        {
            physics.velocityX = 0;

            if (currentHeldEnemyState == HELD)
            {
                physics.velocityY = 0;
                physics.accelerationY = 0;
                physics.gravityEnabled = false;
            }
        }
        else
        {
            physics.velocityX = walkSpeed * direction;
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (currentHeldEnemyState == HELD && held != null)
        {
            if (held.flipX)
            {
                x = held.x - 15;
            }
            else if (!held.flipX)
            {
                x = held.x + 15;
            }

            if (held.currentState == SMALL || held.ducking)
            {
                y = held.y - 2;
            }
            else
            {
                y = held.y + 8;
            }

            flipX = !held.flipX;
        }
    }
}