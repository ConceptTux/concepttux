//  SuperTux Rebuilt
//  Copyright (C) 2026 AnatolyStev
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

import flixel.FlxObject;

enum BlockAreaDirections
{
    LEFT;
    DOWN;
    UP;
    RIGHT;
}

class BlockArea extends FlxObject
{
    public var block:Block;
    public var direction:BlockAreaDirections;

    public function new(block:Block, p_direction:BlockAreaDirections)
    {
        this.block = block;
        this.direction = p_direction; // i wish i did the direction in the new function earlier instead of a separate variable... fix later!
        
        if (direction == LEFT)
        {
            super(block.x - 1, block.y, 1, 32);
        }
        else if (direction == RIGHT)
        {
            super(block.x + 32, block.y, 1, 32);
        }
        else if (direction == UP)
        {
            super(block.x, block.y - 1, 32, 1);
        }
        else if (direction == DOWN)
        {
            super(block.x, block.y + 32, 32, 1);
        }
        else
        {
            trace("Unsupported direction :(");
        }
    }
}