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

import badguys.Badguy;
import flixel.FlxSprite;

class Block extends FlxSprite
{
    public var content:String;
    public var isEmpty:Bool = false;
    public var hitAreaDown:BlockArea;
    public var hitAreaLeft:BlockArea;
    public var hitAreaRight:BlockArea;
    public var hitAreaUp:BlockArea;

    var hitTolerance:Float = 0.5;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        
        hitAreaDown = new BlockArea(this, DOWN);
        hitAreaLeft = new BlockArea(this, LEFT);
        hitAreaRight = new BlockArea(this, RIGHT);
        hitAreaUp = new BlockArea(this, UP);
        
        Global.PS.blocks.add(hitAreaDown);
        Global.PS.blocks.add(hitAreaLeft);
        Global.PS.blocks.add(hitAreaRight);
        Global.PS.blocks.add(hitAreaUp);
    }

    // Blocks override this
    // public function hit(tux:Player, badguy:Badguy)
    public function hit(tux:Player)
    {
    }

    // Blocks override this
    public function badguyHit(badguy:Badguy)
    {
    }

    public function hitCheck(tux:Player):Bool
    {
        if (tux == null)
        {
            return false;
        }

        var below = tux.y > (y + height - hitTolerance) && tux.physics.velocityY <= 0;
        var above = tux.getBottom() < (y + hitTolerance) && tux.actualButtjump;

        return below || above;
    }

    public function badguyHitCheck(badguy:Badguy):Bool
    {
        if (badguy.currentHeldEnemyState != MOVING_FLAT && badguy.currentHeldEnemyState != FLAT)
        {
            return false;
        }
        
        if (badguy.currentHeldEnemyState == MOVING_FLAT)
        {
            var left = badguy.getRight() <= this.x;
            var right = badguy.x >= this.x + this.width;

            return left || right;
        }
        else
        {
            var below = badguy.y > (y + height - hitTolerance) && badguy.physics.velocityY <= 0;

            return below;
        }
    }

    function empty(_)
    {
        animation.play("empty");
    }

    // Blocks override this
    function createItem(direction:String)
    {
    }
}