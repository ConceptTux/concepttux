package misc;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

enum STBackgroundAlignment
{
    NONE;
    LEFT;
    RIGHT;
    TOP;
    BOTTOM;
}

class STBackground extends FlxTypedGroup<FlxSprite>
{
    public var imagePath:String;
    public var imageTopPath:String;
    public var imageBottomPath:String;

    public var speed:Float;
    public var speedY:Float;

    public var alignment:STBackgroundAlignment;

    public var scrollSpeedX:Float = 0;
    public var scrollSpeedY:Float = 0;
    public var scrollOffsetX:Float = 0;
    public var scrollOffsetY:Float = 0;

    var mainTemplate:FlxSprite;
    var topTemplate:FlxSprite;
    var bottomTemplate:FlxSprite;

    var mainWidth:Float = 0;
    var mainHeight:Float = 0;

    var tiles:Array<FlxSprite> = [];
    var tileSources:Array<Int> = [];

    public var layerOpacity:Float = 1.0;

    public function new(image:String, speed:Float, ?speedY:Float, alignment:STBackgroundAlignment = NONE, ?imageTop:String, ?imageBottom:String, opacity:Float = 1.0, visible:Bool = true)
    {
        super();

        active = false;

        layerOpacity = opacity;
        this.visible = visible;

        this.imagePath = image;
        this.imageTopPath = imageTop;
        this.imageBottomPath = imageBottom;

        this.speed = speed;
        this.speedY = speedY == null ? speed : speedY;

        this.alignment = alignment;

        mainTemplate = new FlxSprite(0, 0, imagePath);
        mainTemplate.visible = false;
        mainTemplate.exists = false;
        add(mainTemplate);

        mainWidth = mainTemplate.frameWidth;
        mainHeight = mainTemplate.frameHeight;

        if (imageTopPath != null && imageTopPath != "")
        {
            topTemplate = new FlxSprite(0, 0, imageTopPath);

            topTemplate.visible = false;
            topTemplate.exists = false;

            add(topTemplate);
        }

        if (imageBottomPath != null && imageBottomPath != "")
        {
            bottomTemplate = new FlxSprite(0, 0, imageBottomPath);

            bottomTemplate.visible = false;
            bottomTemplate.exists = false;

            add(bottomTemplate);
        }
    }

    public function updateBackground(cameraX:Float, cameraY:Float, levelWidth:Float, levelHeight:Float)
    {
        if (mainTemplate == null || mainWidth <= 0 || mainHeight <= 0)
        {
            return;
        }

        final screenWidth = FlxG.width;
        final screenHeight = FlxG.height;

        final translationRangeX = levelWidth - screenWidth;
        final translationRangeY = levelHeight - screenHeight;

        final centerOffsetX = cameraX - translationRangeX * 0.5;
        final centerOffsetY = cameraY - translationRangeY * 0.5;

        final posX = levelWidth * 0.5 + centerOffsetX * (1.0 - speed);
        final posY = levelHeight * 0.5 + centerOffsetY * (1.0 - speed);

        final parallaxWidth = (1.0 - speed) * screenWidth + levelWidth * speed;
        final parallaxHeight = (1.0 - speed) * screenHeight + levelHeight * speed;

        final startX:Int = Std.int(Math.floor((cameraX - (posX - mainWidth * 0.5)) / mainWidth));
        final startY:Int = Std.int(Math.floor((cameraY - (posY - mainHeight * 0.5)) / mainHeight));

        final endX:Int = Std.int(Math.ceil((cameraX + screenWidth - (posX + mainWidth * 0.5)) / mainWidth)) + 1;
        final endY:Int = Std.int(Math.ceil((cameraY + screenHeight - (posY + mainHeight * 0.5)) / mainHeight)) + 1;

        var tileIndex = 0;

        switch (alignment)
        {
            case NONE:
                for (y in startY...endY)
                {
                    for (x in startX...endX)
                    {
                        var tileX = posX + x * mainWidth - mainWidth * 0.5;
                        var tileY = posY + y * mainHeight - mainHeight * 0.5;

                        var source = 0;

                        if (y < 0 && topTemplate != null)
                        {
                            source = 1;
                        }
                        else if (y > 0 && bottomTemplate != null)
                        {
                            source = 2;
                        }

                        setTile(tileIndex++, source, tileX, tileY);
                    }
                }
            case LEFT:
                for (y in startY...endY)
                {
                    final tileX = posX - parallaxWidth * 0.5;
                    final tileY = posY + y * mainHeight - mainHeight * 0.5;

                    setTile(tileIndex++, 0, tileX, tileY);
                }
            case RIGHT:
                for (y in startY...endY)
                {
                    final tileX = posX + parallaxWidth * 0.5 - mainWidth;
                    final tileY = posY + y * mainHeight - mainHeight * 0.5;

                    setTile(tileIndex++, 0, tileX, tileY);
                }
            case TOP:
                for (x in startX...endX)
                {
                    final tileX = posX + x * mainWidth - mainWidth * 0.5;
                    final tileY = posY - parallaxHeight * 0.5;

                    setTile(tileIndex++, 0, tileX, tileY);
                }
            case BOTTOM:
                for (x in startX...endX)
                {
                    final tileX = posX + x * mainWidth - mainWidth * 0.5;
                    final tileY = posY - mainHeight + parallaxHeight * 0.5;

                    setTile(tileIndex++, 0, tileX, tileY);
                }
        }

        while (tileIndex < tiles.length)
        {
            tiles[tileIndex].visible = false;
            tiles[tileIndex].exists = false;
            tileIndex += 1;
        }
    }

    function setTile(index:Int, source:Int, x:Float, y:Float)
    {
        ensureTile(index);

        final tile = tiles[index];

        if (tileSources[index] != source)
        {
            switch (source)
            {
                case 1:
                    if (topTemplate != null)
                    {
                        tile.loadGraphicFromSprite(topTemplate);
                    }
                    else
                    {
                        tile.loadGraphicFromSprite(mainTemplate);
                    }
                case 2:
                    if (bottomTemplate != null)
                    {
                        tile.loadGraphicFromSprite(bottomTemplate);
                    }
                    else
                    {
                        tile.loadGraphicFromSprite(mainTemplate);
                    }
                default:
                    tile.loadGraphicFromSprite(mainTemplate);
            }

            tileSources[index] = source;
        }

        tile.setPosition(x, y);

        tile.scrollFactor.set(1, 1);

        tile.visible = true;
        tile.exists = true;
        tile.active = false;
    }

    function ensureTile(index:Int)
    {
        while (tiles.length <= index)
        {
            final tile = new FlxSprite();

            tile.visible = false;
            tile.exists = false;
            tile.active = false;

            add(tile);

            tiles.push(tile);
            tileSources.push(-1);
        }
    }
}