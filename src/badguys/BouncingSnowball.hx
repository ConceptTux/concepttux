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

import badguys.Badguy;

class BouncingSnowball extends Badguy
{
    final jumpHeight = -450;

    public function new(x:Float, y:Float, startDirection:BadguySpawnDirections = BadguySpawnDirections.AUTO)
    {
        super(x, y, startDirection);

        loadGraphic("data/images/creatures/badguy/bouncingsnowball.png", true, 35, 32);
        animation.add("bounce", [0, 1, 2, 3, 4], 8.0, true);
        animation.add("squished", [5], 8.0, false);
        animation.play("bounce");

        setSize(31, 30);
        offset.set(2, 2);

        physics.maxVelocityX = walkSpeed;
    }

    override private function move()
    {
        if (physics.grounded) // When touching floor, jump!
        {
            physics.velocityY = jumpHeight;
        }

        physics.velocityX = walkSpeed * direction;
    }
}