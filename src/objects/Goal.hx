package objects;

import flixel.FlxG;
import misc.VPBSprite;
import states.MainMenuState;
import states.PlayState;

class Goal extends VPBSprite
{
    var stopTux:Bool = false;

    public function new(x:Float, y:Float, width:Float, height:Float, stopTux:Bool = false)
    {
        super(x, y);

        this.stopTux = stopTux;
        
        makeSolidGraphic(width, height, ALL);
    }

    public function reach(player:Player)
    {
        if (solid)
        {
            solid = false;
            Global.currentLevel += 1;
        }

        if (stopTux)
        {
            trace("reached stoptux goal!!!!");

            if (Global.goalReached)
            {
                Global.levelPaused = true;

                player.physics.setVelocity(0, 0);
                player.physics.setAcceleration(0, 0);
            }
            else
            {
                Global.goalReached = true;
                Global.levelPaused = true;

                player.physics.setVelocity(0, 0);
                player.physics.setAcceleration(0, 0);
                
                if (FlxG.sound.music != null) // Check if song is playing, if it is, stop song. This if statement is here just to avoid a really weird crash
                {
                    FlxG.sound.music.stop();
                }

                FlxG.sound.playMusic("data/music/leveldone.ogg", 1.0, false, function() 
                {
                    nextLevel();
                });
            }
        }
        else
        {
            if (!Global.goalReached)
            {
                Global.goalReached = true;
                
                player.physics.velocityX = 230;
                player.physics.accelerationX = 0;

                player.direction = 1;
                player.flipX = false;
                player.skidTimer = 0.0;
                player.ducking = false;
                player.backflipping = false;
                player.inCutscene = true;
                player.angle = 0;

                FlxG.timeScale = 0.5;
                
                if (FlxG.sound.music != null) // Check if song is playing, if it is, stop song. This if statement is here just to avoid a really weird crash
                {
                    FlxG.sound.music.stop();
                }

                FlxG.sound.playMusic("data/music/leveldone.ogg", 1.0, false, function() 
                {
                    nextLevel();
                });
            }
        }
    }

    function nextLevel()
    {
        if (Global.currentLevel >= Global.levels.length)
        {
            FlxG.timeScale = 1.0;
            FlxG.switchState(MainMenuState.new);
        }
        else
        {
            FlxG.switchState(PlayState.new);
        }
    }
}