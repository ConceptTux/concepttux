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

import objects.Bullet;
import flixel.util.FlxTimer;
import objects.Player;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import collision.SlopeSolid;
import flixel.util.FlxDirectionFlags;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import badguys.Badguy;

enum StalactiteStates
{
    ON_CEILING;
    SHAKING;
    FALLING;
}

class Stalactite extends Badguy
{
    // Shaking
    final shakeDuration:Float = 0.8;
    final shakeIntensity:Float = 0.15;
    
    // Self-explanatory
    var playerDetection:FlxSprite;

    // State
    var currentStalactiteState:StalactiteStates = ON_CEILING;

    public function new(x:Float, y:Float, startDirection:BadguySpawnDirections = BadguySpawnDirections.AUTO)
    {
        super(x, y, startDirection);

        physics.gravityEnabled = false;

        loadGraphic("data/images/creatures/badguy/stalactite.png", true, 32, 48);
        animation.add("normal", [0], Global.defaultFPS, false);
        animation.add("broken", [1], Global.defaultFPS, false);
        animation.play("normal");

        setSize(20, 45);
        offset.set(6, 0);

        createPlayerDetection();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (playerDetection.overlaps(Global.PS.player) && currentStalactiteState == ON_CEILING)
        {
            shake();
        }
    }

    public function fall(_)
    {
        currentStalactiteState = FALLING;
        physics.gravityEnabled = true;
    }

    override public function interact(tux:Player)
    {
        if (currentState == DEAD)
        {
            return;
        }

        if (!checkIfHerring(tux))
        {
            tux.takeDamage();
        }
    }

    override private function move()
    {
        if (physics.grounded && currentStalactiteState == FALLING)
        {
            kill();
        }
    }

    function createPlayerDetection()
    {
        final detectionWidth:Float = 40;
        final maxDetectionHeight:Float = 400;

        final detectionX = x - detectionWidth * 0.5;
        final detectionY = y + height;

        var nearestGroundY = detectionY + maxDetectionHeight;

        for (member in Global.PS.solids.members)
        {
            if (member == null || !Std.isOfType(member, FlxObject))
            {
                continue;
            }

            final solid:FlxObject = cast member;

            if (solid == this || !solid.exists || !solid.active || !solid.solid || solid.width <= 0 || solid.height <= 0 || !solid.allowCollisions.has(FlxDirectionFlags.UP))
            {
                continue;
            }

            final overlapLeft = Math.max(detectionX, solid.x);
            final overlapRight = Math.min(detectionX + detectionWidth, solid.x + solid.width);

            if (overlapLeft >= overlapRight)
            {
                continue;
            }

            var groundY:Float;

            if (Std.isOfType(solid, SlopeSolid))
            {
                final slope:SlopeSolid = cast solid;

                groundY = Math.min(slope.surfaceYAt(overlapLeft), slope.surfaceYAt(overlapRight));
            }
            else
            {
                groundY = solid.y;
            }

            if (groundY >= detectionY && groundY < nearestGroundY)
            {
                nearestGroundY = groundY;
            }
        }

        final detectionHeight = Std.int(Math.max(1, nearestGroundY - detectionY));

        playerDetection = new FlxSprite(detectionX, detectionY);
        playerDetection.makeGraphic(Std.int(detectionWidth), detectionHeight, FlxColor.TRANSPARENT);

        playerDetection.immovable = true;
        playerDetection.solid = false;

        Global.PS.add(playerDetection);
    }

    override public function kill()
    {
        if (currentState == DEAD)
        {
            return;
        }

        currentState = DEAD;
        FlxG.sound.play("data/sounds/icecrash.ogg");
        physics.velocityY = 0;
        physics.accelerationX = 0;
        animation.play("broken");

        new FlxTimer().start(2.0, function(_)
        {
            alive = false;
            exists = false;
        }, 1);
    }

    override public function killFall()
    {
        return;
    }

    override public function collideFireball(fireball:Bullet)
    {
        if (currentStalactiteState != ON_CEILING)
        {
            return;
        }

        fireball.kill();

        FlxG.sound.play("data/sounds/sizzle.ogg");

        shake();
    }

    function shake()
    {
        if (currentStalactiteState == SHAKING)
        {
            return;
        }

        currentStalactiteState = SHAKING;
        immovable = false;
        damageOthers = true;
        FlxG.sound.play("data/sounds/cracking.wav");
        FlxTween.shake(this, shakeIntensity, shakeDuration, X, {onComplete: fall});
    }

    override private function initDirection(tux:Player)
    {
        return;
    }
}