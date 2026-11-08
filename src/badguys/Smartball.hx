package badguys;

import collision.Collision;
import badguys.Badguy;

class Smartball extends Badguy
{
    public function new(x:Float, y:Float, startDirection:BadguySpawnDirections = BadguySpawnDirections.AUTO)
    {
        super(x, y);

        loadGraphic("data/images/creatures/badguy/smartball.png", true, 38, 38);
        animation.add("walk", [0, 1, 2, 1], 8.0, true);
        animation.add("squished", [3], 8.0, false);
        animation.play("walk");

        setSize(32, 32);
        offset.set(3, 6);

        physics.maxVelocityX = walkSpeed;
    }

    override private function move()
    {
        if (physics.grounded)
        {
            if (!Collision.hasGroundAhead(this, Global.PS.solids, physics, direction))
            {
                flipDirection();
            }
        }

        physics.velocityX = walkSpeed * direction;
    }
}