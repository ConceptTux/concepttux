package collision;

import flixel.util.FlxColor;
import misc.VPBSprite;

class Solid extends VPBSprite
{
    public function new(x:Float, y:Float, width:Float, height:Float, allowedSide:AllowedSides)
    {
        super(x, y);
        
        makeSolidGraphic(width, height, FlxColor.TRANSPARENT, allowedSide);
    }
}