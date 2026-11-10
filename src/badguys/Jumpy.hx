package badguys;

import badguys.Badguy;
import objects.Player;

class Jumpy extends Badguy
{
    var jumpHeight = -600;

    public function new(x:Float, y:Float, startDirection:BadguySpawnDirections = BadguySpawnDirections.AUTO)
    {
        super(x, y, startDirection);

        loadGraphic("data/images/creatures/badguy/snowjumpy.png", true, 47, 54);
        animation.add("jump", [0, 1, 2], 6.0, false);
        animation.play("jump", false, false, 2);

        loadWhenLevelLoads = true;

        setSize(32, 44);
        offset.set(7, 10);
    }

    override public function move()
    {
        if (physics.grounded) // When touching floor, jump!
        {
            physics.velocityY = jumpHeight;
            animation.play("jump");
        }

        if (currentState == DEAD)
        {
            return;
        }

        if (Global.PS.player != null)
        {
            direction = Global.PS.player.getCenterX() < getCenterX() ? -1 : 1;
            flipX = direction == 1;
        }
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