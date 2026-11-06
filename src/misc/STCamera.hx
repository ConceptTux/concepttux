package misc;

import objects.Player;
import flixel.FlxG;

class STCamera
{
    public var edgeX:Float = 0.4;

    public var clampX:Float = 0.1666;
    public var clampY:Float = 0.3;

    public var kirbyRectSizeY:Float = 0.34;

    public var dynamicSpeedSM:Float = 0.8;

    public var peekArriveRatio:Float = 0.1;
    public var peekDirectionX:Int = 0;
    public var peekDirectionY:Int = 0;

    var cachedX:Float = 0;
    var cachedY:Float = 0;

    var lookaheadX:Float = 0;
    var lookaheadY:Float = 0;

    var peekX:Float = 0;
    var peekY:Float = 0;

    var lastPlayerX:Float = 0;
    var lastPlayerY:Float = 0;

    var initialized:Bool = false;

    static inline var cameraEpsilon:Float = 0.00001;

    public function new()
    {
    }

    public function reset(player:Player)
    {
        final screenWidth = FlxG.width;
        final screenHeight = FlxG.height;

        final playerX = getPlayerX(player);
        final playerY = getPlayerY(player);

        cachedX = playerX - screenWidth * 0.5;
        cachedY = playerY - screenHeight * 0.5;

        if (player.direction >= 0)
        {
            lookaheadX = screenWidth * edgeX;
        }
        else
        {
            lookaheadX = screenWidth * (1 - edgeX);
        }

        lookaheadY = 0;

        peekX = 0;
        peekY = 0;

        lastPlayerX = playerX;
        lastPlayerY = playerY;

        initialized = true;
    }

    public function update(player:Player, elapsed:Float, levelWidth:Float, levelHeight:Float)
    {
        if (!initialized)
        {
            reset(player);
            return;
        }

        if (elapsed < cameraEpsilon)
        {
            return;
        }

        final screenWidth = FlxG.width;
        final screenHeight = FlxG.height;

        final playerX = getPlayerX(player);
        final playerY = getPlayerY(player);

        final playerDeltaX = playerX - lastPlayerX;
        final playerDeltaY = playerY - lastPlayerY;

        lastPlayerX = playerX;
        lastPlayerY = playerY;


        updateHorizontal(playerX, playerDeltaX, screenWidth, levelWidth);
        updateVertical(playerY, screenHeight);

        var cameraX = cachedX;
        var cameraY = cachedY;

        final leftEdge = screenWidth * clampX;
        final rightEdge = screenWidth * (1 - clampX);

        final playerScreenX = playerX - cameraX;

        var peekTo:Float = 0;

        if (peekDirectionX < 0)
        {
            peekTo = rightEdge - playerScreenX;
        }
        else if (peekDirectionX > 0)
        {
            peekTo = leftEdge - playerScreenX;
        }

        var peekMove = (peekTo - peekX) * peekArriveRatio;

        if (Math.abs(peekMove) < 1)
        {
            peekMove = 0;
        }

        peekX += peekMove;

        cameraX -= peekX;
        cameraX = clamp(cameraX, playerX - screenWidth * (1 - clampX), playerX - screenWidth * clampX);

        cachedX = clamp(cachedX, playerX - screenWidth * (1 - clampX), playerX - screenWidth * clampX);

        final topEdge = screenHeight * clampY;
        final bottomEdge = screenHeight * (1 - clampY);

        final playerScreenY = playerY - cameraY;

        var peekTo:Float = 0;

        if (peekDirectionY < 0)
        {
            peekTo = bottomEdge - playerScreenY;
        }
        else if (peekDirectionY > 0)
        {
            peekTo = topEdge - playerScreenY;
        }

        var peekMove = (peekTo - peekY) * peekArriveRatio;

        if (Math.abs(peekMove) < 1)
        {
            peekMove = 0;
        }

        peekY += peekMove;

        cameraY -= peekY;
        cameraY = clamp(cameraY, playerY - screenHeight * (1 - clampY), playerY - screenHeight * clampY);

        cachedY = clamp(cachedY, playerY - screenHeight * (1 - clampY), playerY - screenHeight * clampY);

        cameraX = clampCameraX(cameraX, levelWidth, screenWidth);
        cameraY = clampCameraY(cameraY, levelHeight, screenHeight);

        cachedX = clampCameraX(cachedX, levelWidth, screenWidth);
        cachedY = clampCameraY(cachedY, levelHeight, screenHeight);

        FlxG.camera.scroll.set(cameraX, cameraY);
    }

    function updateHorizontal(playerX:Float, playerDeltaX:Float, screenWidth:Float, levelWidth:Float)
    {
        final leftEdge = screenWidth * edgeX;
        final rightEdge = screenWidth * (1 - edgeX);

        if (playerDeltaX < -cameraEpsilon)
        {
            lookaheadX -= playerDeltaX * dynamicSpeedSM;

            if (lookaheadX > rightEdge)
            {
                lookaheadX = rightEdge;
            }
        }
        else if (playerDeltaX > cameraEpsilon)
        {
            lookaheadX -= playerDeltaX * dynamicSpeedSM;

            if (lookaheadX < leftEdge)
            {
                lookaheadX = leftEdge;
            }
        }

        if (playerX < leftEdge)
        {
            lookaheadX = leftEdge;
        }

        if (playerX > levelWidth - leftEdge)
        {
            lookaheadX = rightEdge;
        }

        cachedX = playerX - lookaheadX;
    }

    function updateVertical( playerY:Float, screenHeight:Float)
    {
        final halfSize = kirbyRectSizeY * 0.5;

        cachedY = clamp(cachedY, playerY - screenHeight * (0.5 + halfSize), playerY - screenHeight * (0.5 - halfSize));
    }

    // width
    inline function getPlayerX(player:Player):Float
    {
        return player.x + player.width * 0.5;
    }

    // bottom
    inline function getPlayerY(player:Player):Float
    {
        return player.y + player.height;
    }

    static inline function clamp(value:Float, min:Float, max:Float):Float
    {
        if (value < min)
        {
            return min;
        }

        if (value > max)
        {
            return max;
        }

        return value;
    }

    static inline function clampCameraX(value:Float, levelWidth:Float, screenWidth:Float):Float
    {
        if (levelWidth <= screenWidth)
        {
            return (levelWidth - screenWidth) * 0.5;
        }

        return clamp(value, 0, levelWidth - screenWidth);
    }

    static inline function clampCameraY(value:Float, levelHeight:Float, screenHeight:Float):Float
    {
        if (levelHeight <= screenHeight)
        {
            return (levelHeight - screenHeight) * 0.5;
        }

        return clamp(value, 0, levelHeight - screenHeight);
    }
}