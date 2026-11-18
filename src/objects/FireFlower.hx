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

import flixel.tweens.FlxTween;
import flixel.FlxG;
import misc.VPBSprite;

class FireFlower extends VPBSprite
{
    public function new(x:Float, y:Float)
    {
        // HaxeFlixel
        super(x, y);

        immovable = false;

        // Load the animated graphic (which is why it has "true, 32, 32")
        loadGraphic("data/images/powerup/fireflower.png", true, 32, 32);

        // Add and play animation
        animation.add("default", [0, 1, 2, 3, 2, 1], Global.defaultFPS, true);
        animation.play("default");

        // And finally, a possibly-unnecessary setSize(), verify that this is useless by replacing it with a trace() later.
        setSize(32, 32);
    }

    override public function update(elapsed:Float)
    {
        // Extra safety!
        velocity.set(0, 0);
        acceleration.set(0, 0);
        drag.set(0, 0);

        // HaxeFlixel
        super.update(elapsed);
    }

    public function collect(tux:Player)
    {
        if (Global.levelPaused)
        {
            return;
        }
        
        FlxG.sound.play("data/sounds/fire-flower.wav");
        kill();
        tux.fireTux();
    }

    public function spawnFromBlock()
    {
        solid = false;
        physics.gravityEnabled = false;

        var startY = this.y;
        
        FlxTween.tween(this, {y: startY - 32}, 0.5, {onComplete: function(_) 
        {
            physics.gravityEnabled = true;
            solid = true;
        }, type: ONESHOT});
    }
}