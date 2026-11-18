//  SuperTux Rebuilt
//  Copyright (C) 2026 Vaesea <sophieballvaesea@proton.me>
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

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