package badguys;

import badguys.Badguy;

class Snowball extends Badguy
{
    public function new(x:Float, y:Float, startDirection:BadguySpawnDirections = BadguySpawnDirections.AUTO)
    {
        super(x, y);

        loadGraphic("data/images/creatures/badguy/snowball.png", true, 38, 36);
        animation.add("walk", [0, 1, 2, 1], 8.0, true);
        animation.add("squished", [3], 8.0, false);
        animation.play("walk");

        setSize(32, 32);
        offset.set(2, 4);
    }

    override private function move()
    {
        physics.velocityX = walkSpeed * direction;
    }
}