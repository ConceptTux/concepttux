package badguys;

import badguys.Badguy;

class BouncingSnowball extends Badguy
{
    final jumpHeight = -450;

    public function new(x:Float, y:Float, startDirection:BadguySpawnDirections = BadguySpawnDirections.AUTO)
    {
        super(x, y);

        loadGraphic("data/images/creatures/badguy/bouncingsnowball.png", true, 35, 32);
        animation.add("bounce", [0, 1, 2, 3, 4], 8.0, true);
        animation.add("squished", [5], 8.0, false);
        animation.play("bounce");

        setSize(31, 30);
        offset.set(2, 2);

        physics.maxVelocityX = walkSpeed;
    }

    override private function move()
    {
        if (physics.grounded) // When touching floor, jump!
        {
            physics.velocityY = jumpHeight;
        }

        physics.velocityX = walkSpeed * direction;
    }
}