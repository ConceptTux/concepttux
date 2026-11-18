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

package objects;

import misc.VPBSprite;

class TuxDoll extends VPBSprite
{
    var direction:Int = 1;

    var movementEnabled:Bool = true;
    final jumpHeight:Int = -400;
    final moveSpeed:Int = 100;

    public function new(x:Float, y:Float)
    {
        // HaxeFlixel
        super(x, y);

        immovable = false;
        onlyHalfSolid = true;

        // Set max speed so the Tux Doll doesn't go too fast (it shouldn't anyways)
        physics.maxVelocityX = moveSpeed;

        // Load Tux Doll sprite
        loadGraphic("data/images/powerup/tuxdoll.png");

        // And finally, a possibly-unnecessary setSize(), verify that this is useless by replacing it with a trace() later.
        setSize(32, 32);
    }

    override public function update(elapsed:Float)
    {
        if (Global.levelPaused)
        {
            physics.setVelocity(0, 0);
            physics.setAcceleration(0, 0);
            physics.gravityEnabled = false;

            velocity.set(0, 0);
            acceleration.set(0, 0);
            drag.set(0, 0);

            super.update(elapsed);

            return;
        }

        if (movementEnabled)
        {
            physics.velocityX = direction * moveSpeed;
        }

        // Extra safety!
        velocity.set(0, 0);
        acceleration.set(0, 0);
        drag.set(0, 0);

        super.update(elapsed);
    }

    public function collect()
    {
        if (Global.levelPaused)
        {
            return;
        }

        kill();
        
        Global.addCoins(100, true);
    }

    public function spawnFromBlock(direction:String)
    {
        if (Global.levelPaused)
        {
            return;
        }
        
        physics.velocityY = jumpHeight;

        if (direction == "left")
        {
            this.direction = -1;
        }
        else if (direction == "right")
        {
            this.direction = 1;
        }
        else
        {
            trace("Unsupported direction! Supported directions are \"left\" and \"right\".");
        }
    }
}