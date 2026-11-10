package badguys;

// TODO: Add a way for the player to hold bombs (useful for puzzles)

import objects.Explosion;
import flixel.sound.FlxSound;
import flixel.FlxG;
import collision.Collision;
import badguys.Badguy;

class MrBomb extends Badguy
{
    var fizz:FlxSound;

    public function new(x:Float, y:Float, startDirection:BadguySpawnDirections = BadguySpawnDirections.AUTO)
    {
        super(x, y, startDirection);

        fizz = FlxG.sound.create("data/sounds/fizz.wav").setup(0.25, -1, false);

        loadGraphic("data/images/creatures/badguy/mrbomb.png", true, 42, 40);
        animation.add("walk", [0, 1, 2, 1], 8.0, true);
        animation.add("ticking", [3, 4, 5, 6, 7, 6, 5, 4, 3, 4, 5, 6, 7, 6, 5, 4, 3, 5, 7, 5, 3, 5, 7, 5, 3, 7, 3, 7], 10.0, false);
        animation.play("walk");

        setSize(30, 32);
        offset.set(6, 8);

        physics.maxVelocityX = walkSpeed;

        canBeHeld = true;
        bomb = true;
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

    override private function move()
    {
        if (physics.grounded)
        {
            if (!Collision.hasGroundAhead(this, Global.PS.solids, physics, direction))
            {
                flipDirection();
            }
        }
        
        if (currentBombState == WALKING && currentHeldEnemyState == NORMAL)
        {
            physics.velocityX = walkSpeed * direction;
        }
        else
        {
            physics.velocityX = 0;
            physics.accelerationX = 0;
        }

        if (animation.finished && animation.name == "ticking")
        {
            explode();
        }
    }

    override public function kill()
    {
        if (dieFall)
        {
            explode();
            return;
        }

        if (currentBombState == TICKING)
        {
            return;
        }

        fizz.play();

        currentBombState = TICKING;
        
        physics.velocityX = 0;
        physics.accelerationX = 0;

        animation.play("ticking");

        trace(currentBombState);
    }

    function explode()
    {
        var explosion:Explosion = new Explosion(this.x - 10, this.y - 10);
        Global.PS.badguys.add(explosion);

        if (held != null)
        {
            held.heldBadguy == null;
            held == null;
        }

        fizz.stop();

        alive = false;
        exists = false;
    }
}