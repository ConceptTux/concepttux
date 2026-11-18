//  SuperTux Rebuilt
//  Copyright (C) 2026 Vaesea <sophieballvaesea@proton.me>
//                2026 AnatolyStev
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