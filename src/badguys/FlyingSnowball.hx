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

package badguys;

import flixel.util.FlxTimer;
import badguys.Badguy;

class FlyingSnowball extends Badguy
{
    final flySpeed = 100;
    var flyDirection = 1; // 1 = up, -1 = down

    public function new(x:Float, y:Float, startDirection:BadguySpawnDirections = BadguySpawnDirections.AUTO)
    {
        super(x, y, startDirection);

        loadGraphic("data/images/creatures/badguy/flyingsnowball.png", true, 40, 43);
        animation.add("fly", [0, 1], 8.0, true);
        animation.add("squished", [2], 8.0, false);
        animation.play("fly");

        setSize(32, 32);
        offset.set(4, 5);

        physics.gravityEnabled = false;
        physics.velocityY = -flySpeed;
        flyDirection = 1;
        physics.maxVelocityY = flySpeed;

        loadWhenLevelLoads = true;

        new FlxTimer().start(0.5, moveVertical, 1);
    }

    override public function move()
    {
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

    function moveVertical(_)
    {
        if (currentState == DEAD)
        {
            physics.maxVelocityY = Global.gravity;

            return;
        }

        flyDirection *= -1;
        physics.velocityY = -flySpeed * flyDirection;

        new FlxTimer().start(1.0, moveVertical, 1);
    }
}