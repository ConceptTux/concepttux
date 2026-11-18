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

import flixel.util.FlxTimer;
import flixel.FlxSprite;

class BrickParticle extends FlxSprite
{
    var time_until_kill:Float = 0.5;
    
    public var snow = false;

    public function new(x:Float, y:Float, number:Int)
    {
        super(x, y);

        solid = false;

        if (number == 1)
        {
            if (snow)
            {
                loadGraphic("data/images/objects/particles/sbrick-0.png");
            }
            else
            {
                loadGraphic("data/images/objects/particles/brick-0.png");
            }
            velocity.set(-100, -400);
        }
        else if (number == 2)
        {
            if (snow)
            {
                loadGraphic("data/images/objects/particles/sbrick-2.png");
            }
            else
            {
                loadGraphic("data/images/objects/particles/brick-2.png");
            }
            velocity.set(-150, -300);
        }
        else if (number == 3)
        {
            if (snow)
            {
                loadGraphic("data/images/objects/particles/sbrick-1.png");
            }
            else
            {
                loadGraphic("data/images/objects/particles/brick-1.png");
            }
            velocity.set(100, -400);
        }
        else if (number == 4)
        {
            if (snow)
            {
                loadGraphic("data/images/objects/particles/sbrick-3.png");
            }
            else
            {
                loadGraphic("data/images/objects/particles/brick-3.png");
            }
            velocity.set(150, -300);
        }
        
        new FlxTimer().start(time_until_kill, function(_) 
        {
            kill();    
        }, 1);
    }
}