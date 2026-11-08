package badguys;

import objects.Player;
import collision.Collision;
import badguys.Badguy;

class Spiky extends Badguy
{
    var maxDropHeight = 600;

    public function new(x:Float, y:Float, startDirection:BadguySpawnDirections = BadguySpawnDirections.AUTO)
    {
        super(x, y);

        loadGraphic("data/images/creatures/badguy/spiky.png", true, 43, 42);
        animation.add("walk", [0, 1, 2, 1], 8.0, true);
        animation.add("sleeping", [3], 8.0, false);
        animation.add("wakeup", [4, 5, 6], 6.0, false);
        animation.play("walk");

        setSize(32, 32);
        offset.set(6, 10);

        physics.maxVelocityX = walkSpeed;
    }

    override private function move()
    {
        if (physics.grounded)
        {
            if (!Collision.hasGroundAhead(this, Global.PS.solids, physics, direction, 8, maxDropHeight))
            {
                flipDirection();
            }
        }

        physics.velocityX = walkSpeed * direction;
    }

    override public function interact(tux:Player)
    {
        if (currentState == DEAD)
        {
            return;
        }

        if (checkIfHerring(tux))
        {
            killFall();
        }
        else
        {
            tux.takeDamage();
        }
    }
}