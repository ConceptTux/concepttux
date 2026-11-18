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

import misc.VPBSprite;

class Bullet extends VPBSprite
{
    var speed:Float = 600;
    var speed2:Float = 0; // Don't change this!

    final maxBounces:Int = 3;
    var bounces:Int = 0; // Don't change this!

    public var direction:Int = 1; // Don't change this!

    var previousVelocityY:Float = 0.0; // Don't change this!

    public function new(x:Float, y:Float)
    {
        super(x, y);

        loadGraphic("data/images/objects/fireball.png", false);
        setSize(16, 16);

        Global.PS.activeBullets += 1;
        
        physics.velocityY = 0;

        trace(Std.string(Global.PS.activeBullets) + " / " + Std.string(Global.PS.maximumBullets));
    }

    public function setSpeed(tux:Player)
    {
        direction = tux.direction;

        if (tux.direction == 1)
        {
            if (tux.physics.velocityX >= 1)
            {
                speed = speed + tux.physics.velocityX / 2;
            }
        }
        else
        {
            if (tux.physics.velocityX <= -1)
            {
                speed = speed - tux.physics.velocityX / 2;
            }
        }

        if (tux.physics.velocityY <= 0)
        {
            speed = speed - tux.physics.velocityY;
        }

        speed2 = speed;
        physics.maxVelocityX = speed;
    }

    override public function update(elapsed:Float)
    {
        // Extra safety!
        velocity.set(0, 0);
        acceleration.set(0, 0);
        drag.set(0, 0);

        if (Global.levelPaused)
        {
            physics.setVelocity(0, 0);
            physics.setAcceleration(0, 0);
            physics.gravityEnabled = false;

            super.update(elapsed);

            return;
        }

        physics.velocityX = direction * speed2;

        if (physics.velocityY > 0)
        {
            previousVelocityY = physics.velocityY;
        }

        if (physics.grounded)
        {
            physics.velocityY = -previousVelocityY;
            bounces += 1;
            trace(bounces);
        }

        if (bounces >= maxBounces || isTouching(WALL) || isTouching(CEILING) || !isOnScreen())
        {
            kill();
        }

        super.update(elapsed);
    }

    override public function kill()
    {
        Global.PS.activeBullets -= 1;
        trace(Global.PS.activeBullets);
        alive = false;
        exists = false;
    }
}