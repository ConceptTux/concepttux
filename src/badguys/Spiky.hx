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

import objects.Player;
import collision.Collision;
import badguys.Badguy;

class Spiky extends Badguy
{
    final maxDropHeight = 600;

    public function new(x:Float, y:Float, startDirection:BadguySpawnDirections = BadguySpawnDirections.AUTO)
    {
        super(x, y, startDirection);

        loadGraphic("data/images/creatures/badguy/spiky.png", true, 43, 42);
        animation.add("walk", [0, 1, 2, 1], 8.0, true);
        animation.add("sleeping", [3], 8.0, false);
        animation.add("wakeup", [4, 5, 6], 6.0, false);
        animation.play("walk");

        setSize(32, 32);
        offset.set(6, 10);

        physics.maxVelocityX = walkSpeed;
    }

    override private function move()
    {
        if (physics.grounded)
        {
            if (!Collision.hasGroundAhead(this, Global.PS.solids, physics, direction, 8, maxDropHeight))
            {
                flipDirection();
            }
        }

        physics.velocityX = walkSpeed * direction;
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