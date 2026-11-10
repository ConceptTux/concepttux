package objects;

import flixel.FlxG;
import flixel.util.FlxTimer;
import badguys.Badguy;

class Explosion extends Badguy
{
    public function new(x:Float, y:Float)
    {
        super(x, y);

        loadGraphic("data/images/objects/explosion.png", true, 64, 64);

        animation.add("explode", [0, 1], Global.defaultFPS, true);
        animation.play("explode");

        setSize(54, 54);
        offset.set(5, 5);

        damageOthers = true;

        FlxG.camera.shake(0.03, 0.2);
        FlxG.sound.play("data/sounds/explosion.wav");

        physics.gravityEnabled = false;

        new FlxTimer().start(1.0, function(_)
        {
            alive = false; 
            exists = false;
        }, 1);
    }

    override public function interact(tux:Player)
    {
        if (currentState == DEAD)
        {
            return;
        }

        if (checkIfHerring(tux))
        {
            return;
        }
        else
        {
            tux.takeDamage();
        }
    }

    override public function kill()
    {
        return;
    }

    override public function killFall()
    {
        return;
    }

    override public function collideOtherBadguy(otherEnemy:Badguy)
    {
        otherEnemy.killFall();
    }

    override public function collideFireball(fireball:Bullet)
    {
        fireball.kill();
    }
}