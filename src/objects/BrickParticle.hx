package objects;

import flixel.util.FlxTimer;
import flixel.FlxSprite;

class BrickParticle extends FlxSprite
{
    var time_until_kill:Float = 0.5;
    
    public var snow = false;

    public function new(x:Float, y:Float, number:Int)
    {
        super(x, y);

        solid = false;

        if (number == 1)
        {
            if (snow)
            {
                loadGraphic("data/images/objects/particles/sbrick-0.png");
            }
            else
            {
                loadGraphic("data/images/objects/particles/brick-0.png");
            }
            velocity.set(-100, -400);
        }
        else if (number == 2)
        {
            if (snow)
            {
                loadGraphic("data/images/objects/particles/sbrick-2.png");
            }
            else
            {
                loadGraphic("data/images/objects/particles/brick-2.png");
            }
            velocity.set(-150, -300);
        }
        else if (number == 3)
        {
            if (snow)
            {
                loadGraphic("data/images/objects/particles/sbrick-1.png");
            }
            else
            {
                loadGraphic("data/images/objects/particles/brick-1.png");
            }
            velocity.set(100, -400);
        }
        else if (number == 4)
        {
            if (snow)
            {
                loadGraphic("data/images/objects/particles/sbrick-3.png");
            }
            else
            {
                loadGraphic("data/images/objects/particles/brick-3.png");
            }
            velocity.set(150, -300);
        }
        
        new FlxTimer().start(time_until_kill, function(_) 
        {
            kill();    
        }, 1);
    }
}