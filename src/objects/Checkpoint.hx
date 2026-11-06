package objects;

import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import objects.Player;
import flixel.FlxSprite;

class Checkpoint extends FlxSprite
{
    final particleAcceleration = 1000;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        loadGraphic("data/images/objects/resetpoints/bell.png", true, 32, 32);

        animation.add("normal", [2], Global.defaultFPS, false);
        animation.add("ringing", [1, 0, 1, 2, 3, 4, 3, 2], Global.defaultFPS, true);

        if (Global.checkpointReached)
        {
            animation.play("ringing");
        }
        else
        {
            animation.play("normal");
        }
    }

    public function reach(tux:Player)
    {
        if (Global.checkpointReached)
        {
            return;
        }

        trace("Checkpoint reached!");

        Global.checkpointReached = true;
        Global.checkpointPosition = getPosition();

        // 0, 1, 2, 3, 4, 5, 6, 7 iterations (it is always 1 below the number of the 0...[something])
        // this is a note to remind myself!
        // -vaesea
        for (i in 0...8)
        {
            var dust:FlxParticle = new FlxParticle();

            dust.loadGraphic("data/images/objects/particles/reset.png");
            dust.setPosition(this.x + this.width * 0.5, this.y + this.height * 0.5);
            
            var countX = (i % 2 == 0) ? 1 : -1; // checks odd / even
            var countY = (Math.floor(i / 2) == 0) ? -1 : 1; // if 0, 1 it = -1, if 2, 3 it = 1... i think?

            // it goes 0, 1, 2, 3, 4, 5, 6, 7 which is not 1, 2, 3, 4, 5, 6, 7, 8 like i previously thought
            if (i == 0 || i == 1 || i == 2 || i == 3) // corner
            {
                dust.velocity.x = FlxG.random.float(450, 900) * countX;
                dust.velocity.y = FlxG.random.float(450, 900) * countY;
            }
            else if (i == 4) // top
            {
                dust.velocity.x = 0;
                dust.velocity.y = -FlxG.random.float(450, 900);
            }
            else if (i == 5) // bottom
            {
                dust.velocity.x = 0;
                dust.velocity.y = 0;
            }
            else if (i == 6) // left
            {
                dust.velocity.x = -FlxG.random.float(450, 900);
                dust.velocity.y = 0;
            }
            else if (i == 7) // right
            {
                dust.velocity.x = FlxG.random.float(450, 900);
                dust.velocity.y = 0;
            }

            dust.acceleration.y = particleAcceleration;
            dust.lifespan = 6;
            dust.exists = true;

            Global.PS.add(dust);
        }

        FlxG.sound.play("data/sounds/savebell2.wav");

        animation.play("ringing");
    }
}