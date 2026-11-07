package misc;

import physics.Physics;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;

enum AllowedSides
{
    ALL;
    LEFT;
    RIGHT;
    DOWN;
    UP;
}

/** Updated FlxSprite thing.
 *
 * Use for objects with the need for collision and physics!
*/
class VPBSprite extends FlxSprite
{
    public var physics:Physics;
    
    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);

        physics = new Physics(Global.gravity);
    }

    // Copied from cne-flixel, now with the ability to set which side is solid.

    /**
	 * This function creates a solid colored rectangular image dynamically.
	 *
	 * HaxeFlixel's graphic caching system keeps track of loaded image data.
	 * When you make an identical copy of a previously used image, by default
	 * HaxeFlixel copies the previous reference onto the pixels field instead
	 * of creating another copy of the image data, to save memory.
	 *
	 * @param   Width    The width of the sprite you want to generate.
	 * @param   Height   The height of the sprite you want to generate.
	 * @param   Color    Specifies the color of the generated block (ARGB format).
	 * @param   Unique   Whether the graphic should be a unique instance in the graphics cache. Default is `false`.
	 *                   Set this to `true` if you want to modify the `pixels` field without changing the
	 *                   `pixels` of other sprites with the same `BitmapData`.
	 * @param   Key      An optional `String` key to identify this graphic in the cache.
	 *                   If `null`, the key is determined by `Width`, `Height` and `Color`.
	 *                   If `Unique` is `true` and a graphic with this `Key` already exists,
	 *                   it is used as a prefix to find a new unique name like `"Key3"`.
	 * @return  This `VPBSprite` instance (nice for chaining stuff together, if you're into that).
	*/
    public function makeSolidGraphic(Width:Float, Height:Float, Color:FlxColor = FlxColor.TRANSPARENT, SolidSide:AllowedSides = ALL, Unique:Bool = false,?Key:String):FlxSprite
    {
        var graph:FlxGraphic = FlxG.bitmap.create(1, 1, Color, Unique, Key);

		frames = graph.imageFrame;
		scale.set(Width, Height);
		updateHitbox();

        switch (SolidSide)
        {
            case ALL: // Supported
                allowCollisions = FlxDirectionFlags.ANY;
            case LEFT: // Unsupported
                allowCollisions = FlxDirectionFlags.LEFT;
            case RIGHT: // Unsupported
                allowCollisions = FlxDirectionFlags.RIGHT;
            case DOWN: // Unsupported
                allowCollisions = FlxDirectionFlags.DOWN;
            case UP: // Supported
                allowCollisions = FlxDirectionFlags.UP;
        }
        
        immovable = true;
        moves = false;
        return this;
    }

    // Random functions to save having to type and think below

    /** Gets the bottom of the sprite
     *
     * Returns "y + height"
    */
    public function getBottom()
    {
        return y + height;
    }

    /** Gets the right side of the sprite
     *
     * Returns "x + width"
    */
    public function getRight()
    {
        return x + width;
    }

    /** Gets the center of the sprite's width
     *
     * Returns "x + width * 0.5"
    */
    public function getCenterX()
    {
        return x + width * 0.5;
    }

    /** Gets the center of the sprite's height
     *
     * Returns "y + height * 0.5"
    */
    public function getCenterY()
    {
        return y + height * 0.5;
    }

    /** Returns whether the character is walking into the wall **/
    function isWalkingIntoWall()
    {
        return (physics.velocityX > 0 && isTouching(RIGHT)) || (physics.velocityX < 0 && isTouching(LEFT));
    }
}