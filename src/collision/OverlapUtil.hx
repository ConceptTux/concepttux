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