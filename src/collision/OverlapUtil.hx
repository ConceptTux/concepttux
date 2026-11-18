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

package collision;

import flixel.FlxBasic;
import flixel.FlxG;

class OverlapUtil
{
    static var activeOverlaps:Map<String, Map<String, Bool>> = new Map();

    public static function overlapOnce(objectOrGroup1:FlxBasic, objectOrGroup2:FlxBasic, ?notifyCallback:Dynamic->Dynamic->Void, ?processCallback:Dynamic->Dynamic->Bool):Bool
    {
        var callKey = objectOrGroup1.ID + ":" + objectOrGroup2.ID;
        var previousPairs = activeOverlaps.get(callKey);

        if (previousPairs == null)
        {
            previousPairs = new Map();
            activeOverlaps.set(callKey, previousPairs);
        }

        var currentPairs:Map<String, Bool> = new Map();

        var result = FlxG.overlap(objectOrGroup1, objectOrGroup2, function(obj1:FlxBasic, obj2:FlxBasic)
        {
            var pairKey = makePairKey(obj1, obj2);

            currentPairs.set(pairKey, true);

            if (!previousPairs.exists(pairKey))
            {
                if (notifyCallback != null)
                {
                    notifyCallback(obj1, obj2);
                }
            }
        }, processCallback);

        activeOverlaps.set(callKey, currentPairs);

        return result;
    }

    static function makePairKey(obj1:FlxBasic, obj2:FlxBasic):String
    {
        var id1 = obj1.ID;
        var id2 = obj2.ID;

        if (id1 > id2)
        {
            var temp = id1;
            id1 = id2;
            id2 = temp;
        }

        return id1 + ":" + id2;
    }

    public static function clear()
    {
        activeOverlaps.clear();
    }
}