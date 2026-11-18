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

class ScriptTrigger extends FlxObject
{
    public var script:String;
    public var oneShot:Bool = false;
    public var triggered:Bool = false;

    public function new(x:Float, y:Float, width:Float, height:Float, script:String, oneShot:Bool = false)
    {
        super(x, y, width, height);
        this.script = script;
        this.oneShot = oneShot;
    }
}