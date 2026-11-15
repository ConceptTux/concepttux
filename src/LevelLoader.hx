package;

import badguys.Stalactite;
import misc.AnimatedTiles.AnimatedTile;
import collision.HurtSolid;
import badguys.FlyingSnowball;
import badguys.MrBomb;
import badguys.BouncingSnowball;
import badguys.Jumpy;
import badguys.Spiky;
import badguys.Iceblock;
import badguys.Smartball;
import badguys.Badguy;
import badguys.Snowball;
import objects.BrickBlock;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledGroupLayer;
import haxe.io.Path;
import misc.STBackground;
import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.addons.editors.tiled.TiledImageLayer;
import objects.Checkpoint;
import flixel.util.FlxGradient;
import flixel.util.FlxColor;
import collision.SlopeSolid;
import collision.Solid;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import objects.Coin;
import objects.Goal;
import states.PlayState;
import objects.BonusBlock;

class LevelLoader extends FlxState
{
    public static var tiledMap:TiledMap;

    public static function loadLevel(state:PlayState, level:String)
    {
        var mapPath = "data/levels/world1/" + level + ".tmx";
        tiledMap = new TiledMap(mapPath);

        // Don't remove the custom properties of the base level unless you remove one of the custom properties here!
        // Removing gradient especially might also cause a crash!
        var song = tiledMap.properties.get("Music");
        var levelName = tiledMap.properties.get("Level Name");
        var gradientBottom:FlxColor = FlxColor.fromString(tiledMap.properties.get("Bottom Color"));
        var gradientTop:FlxColor = FlxColor.fromString(tiledMap.properties.get("Top Color"));

        var gradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [gradientTop, gradientBottom]);
        gradient.scrollFactor.set(0, 0);

        state.add(gradient);

        Global.levelName = levelName;

        // FlxG.sound.playMusic(song, 1.0, true); only add back if there's a problem
        Global.currentSong = song;

        FlxG.camera.bgColor = tiledMap.backgroundColor;

        loadBackgroundLayers(state, tiledMap.layers, mapPath);
        
        // Background
        var backgroundLayer:TiledTileLayer = cast tiledMap.getLayer("Background");
        
        var backgroundMap = new FlxTilemap();
        backgroundMap.loadMapFromArray(backgroundLayer.tileArray, tiledMap.width, tiledMap.height, "data/images/tiled/tiles.png", 32, 32, Global.PS.startingTile);
        backgroundMap.solid = false;

        // Interactive / Main
        var interactiveLayer:TiledTileLayer = cast tiledMap.getLayer("Main");

        state.map = new FlxTilemap();
        state.map.loadMapFromArray(interactiveLayer.tileArray, tiledMap.width, tiledMap.height, "data/images/tiled/tiles.png", 32, 32, Global.PS.startingTile);
        state.map.solid = false;

        state.add(backgroundMap);

        // Load front animated tiles
        for (object in getLevelObjects(tiledMap, "AnimatedTilesFront"))
        {
            switch (object.type)
            {
                default:
                    final spritePath = resolveTiledImagePath(mapPath, getStringProperty(object.properties, "Image", "data/images/engine/missing.png"));
                    final frameWidth = getIntProperty(object.properties, "Frame Width", 32);
                    final frameHeight = getIntProperty(object.properties, "Frame Height", 32);
                    final frames = getIntArray(getStringProperty(object.properties, "Frames", ""));
                    final fps = getFloatProperty(object.properties, "FPS", 10.0);

                    if (frameWidth <= 0 || frameHeight <= 0 || frames.length == 0)
                    {
                        trace("You set up a foreground Animated Tile incorrectly!");
                    }

                    state.animTilesFront.add(new AnimatedTile(object.x, object.y - frameHeight, spritePath, frameWidth, frameHeight, frames, fps));
            }
        }

        for (object in getLevelObjects(tiledMap, "AnimatedTilesBack"))
        {
            switch (object.type)
            {
                default:
                    final spritePath = resolveTiledImagePath(mapPath, getStringProperty(object.properties, "Image", "data/images/engine/missing.png"));
                    final frameWidth = getIntProperty(object.properties, "Frame Width", 32);
                    final frameHeight = getIntProperty(object.properties, "Frame Height", 32);
                    final frames = getIntArray(getStringProperty(object.properties, "Frames", ""));
                    final fps = getFloatProperty(object.properties, "FPS", 10.0);

                    if (frameWidth <= 0 || frameHeight <= 0 || frames.length == 0)
                    {
                        trace("You set up a background Animated Tile incorrectly!");
                    }

                    state.animTilesBack.add(new AnimatedTile(object.x, object.y - frameHeight, spritePath, frameWidth, frameHeight, frames, fps));
            }
        }

        for (object in getLevelObjects(tiledMap, "Solid"))
        {
            switch (object.type)
            {
                default:
                    state.solids.add(new Solid(object.x, object.y, object.width, object.height, ALL));
                case "unisolid_top":
                    state.solids.add(new Solid(object.x, object.y, object.width, object.height, UP));
                case "slope_r":
                    state.solids.add(new SlopeSolid(object.x, object.y, object.width, object.height, true));
                case "slope_l":
                    state.solids.add(new SlopeSolid(object.x, object.y, object.width, object.height, false));
                case "ceiling_slope_r":
                    state.solids.add(new SlopeSolid(object.x, object.y, object.width, object.height, true, true));
                case "ceiling_slope_l":
                    state.solids.add(new SlopeSolid(object.x, object.y, object.width, object.height, false, true));
                case "hurt":
                    state.hurtCollision.add(new HurtSolid(object.x, object.y, object.width, object.height, ALL));
            }
        }

        // Load goal
        for (object in getLevelObjects(tiledMap, "Level"))
        {
            switch (object.type)
            {
                case "goal":
                    final stopTux = getBoolProperty(object.properties, "Stop Tux", false);
                    state.items.add(new Goal(object.x, object.y, object.width, object.height, stopTux));
                case "checkpoint":
                    state.checkpoint = new Checkpoint(object.x, object.y - 32);
            }
        }

        // Load coins
        for (object in getLevelObjects(tiledMap, "Objects"))
        {
            switch (object.type)
            {
                default:
                    trace("Object has no type!");
                case "coin":
                    state.itemsFlxSprite.add(new Coin(object.x, object.y - 32));
                case "bonus_coin":
                    var bonusBlockCoin:BonusBlock = new BonusBlock(object.x, object.y - 32);
                    bonusBlockCoin.content = "coin";
                    state.solids.add(bonusBlockCoin);
                case "bonus_powerup":
                    var bonusBlockPowerup:BonusBlock = new BonusBlock(object.x, object.y - 32);
                    bonusBlockPowerup.content = "powerup";
                    state.solids.add(bonusBlockPowerup);
                case "bonus_tuxdoll":
                    var bonusBlockTuxDoll:BonusBlock = new BonusBlock(object.x, object.y - 32);
                    bonusBlockTuxDoll.content = "tuxdoll";
                    state.solids.add(bonusBlockTuxDoll);
                case "brick":
                    final spritePath = resolveTiledImagePath(mapPath, getStringProperty(object.properties, "Image", "data/images/objects/brick/brick.png"));
                    state.solids.add(new BrickBlock(object.x, object.y - 32, spritePath));
                case "brickCoin":
                    final spritePath = resolveTiledImagePath(mapPath, getStringProperty(object.properties, "Image", "data/images/objects/brick/brick.png"));
                    var brickCoin = new BrickBlock(object.x, object.y - 32, spritePath);
                    brickCoin.unbreakable = true;
                    state.solids.add(brickCoin);
            }
        }

        for (object in getLevelObjects(tiledMap, "Badguys"))
        {
            switch (object.type)
            {
                default:
                    trace("Badguy has no type, or it's type is invalid!");
                case "snowball":
                    var direction = getBadguyDirection(object);
                    state.badguys.add(new Snowball(object.x, object.y - 32, direction));
                case "smartball":
                    var direction = getBadguyDirection(object);
                    state.badguys.add(new Smartball(object.x, object.y - 32, direction));
                case "iceblock":
                    var direction = getBadguyDirection(object);
                    state.badguys.add(new Iceblock(object.x, object.y - 30, direction));
                case "spiky":
                    var direction = getBadguyDirection(object);
                    state.badguys.add(new Spiky(object.x, object.y - 32, direction));
                case "jumpy":
                    var direction = getBadguyDirection(object);
                    state.badguys.add(new Jumpy(object.x, object.y - 44, direction));
                case "bouncingsnowball":
                    var direction = getBadguyDirection(object);
                    state.badguys.add(new BouncingSnowball(object.x, object.y - 30, direction));
                case "bomb":
                    var direction = getBadguyDirection(object);
                    state.badguys.add(new MrBomb(object.x, object.y - 30, direction));
                case "flyingsnowball":
                    var direction = getBadguyDirection(object);
                    state.badguys.add(new FlyingSnowball(object.x, object.y - 32, direction));
                case "stalactite":
                    state.badguys.add(new Stalactite(object.x, object.y - 45, AUTO));
            }
        }

        // Don't be like me. Don't remove this
        var playerThing:TiledObject = getLevelObjects(tiledMap, "Player")[0];
        var playerPosition:FlxPoint = new FlxPoint(playerThing.x, playerThing.y);

        // Checkpoint
        if (Global.checkpointReached)
        {
            playerPosition = Global.checkpointPosition;
        }
        else
        {
            playerPosition.set(playerPosition.x, playerPosition.y);
        }

        // Finally set the player's position to playerPosition
        state.player.setPosition(playerPosition.x, playerPosition.y - 31);
    }

    public static function getLevelObjects(map:TiledMap, layer:String):Array<TiledObject>
    {
        if ((map != null) && (map.getLayer(layer) != null))
        {
            var objLayer:TiledObjectLayer = cast map.getLayer(layer);
            return objLayer.objects;
        }
        else
        {
            trace("Object layer " + layer + " not found! Also credits to Discover Haxeflixel.");
            return [];
        }
    }

    static function getFloatProperty(properties:TiledPropertySet, name:String, defaultValue:Float):Float
    {
        var value = properties.get(name);

        if (value == null || value == "")
        {
            return defaultValue;
        }

        var parsed = Std.parseFloat(value);

        return Math.isNaN(parsed) ? defaultValue : parsed;
    }

    static function getIntProperty(properties:TiledPropertySet, name:String, defaultValue:Int):Int
    {
        var value = properties.get(name);

        if (value == null || value == "")
        {
            return defaultValue;
        }

        var parsed = Std.parseInt(value);

        return Math.isNaN(parsed) ? defaultValue : parsed;
    }

    static function getStringProperty(properties:TiledPropertySet, name:String, defaultValue:String):String
    {
        var value = properties.get(name);

        if (value == null || value == "")
        {
            return defaultValue;
        }

        return value;
    }

    static function getBoolProperty(properties:TiledPropertySet, name:String, defaultValue:Bool):Bool
    {
        var value = properties.get(name);

        if (value == null || value == "")
        {
            return defaultValue;
        }

        switch (value.toLowerCase())
        {
            case "true", "1", "yes":
                return true;
            case "false", "0", "no":
                return false;
            default:
                return defaultValue;
        }
    }

    static function getIntArray(value:String):Array<Int>
    {
        var result:Array<Int> = [];

        if (value == null || StringTools.trim(value) == "")
        {
            return result;
        }

        for (part in value.split(","))
        {
            final trimmed = StringTools.trim(part);

            if (trimmed == "")
            {
                continue;
            }

            final number = Std.parseInt(trimmed);

            if (number == null)
            {
                trace("Invalid integer in array!");
                return [];
            }

            result.push(number);
        }

        return result;
    }

    static function parseBackgroundAlignment(value:String):STBackgroundAlignment
    {
        if (value == null)
        {
            return NONE;
        }

        switch (value.toLowerCase())
        {
            case "left":
                return LEFT;
            case "right":
                return RIGHT;
            case "top":
                return TOP;
            case "bottom":
                return BOTTOM;
            default:
                return NONE;
        }
    }

    static function resolveTiledImagePath(mapPath:String, imagePath:String):String
    {
        if (imagePath == null || imagePath == "")
        {
            return null;
        }

        if (StringTools.startsWith(imagePath, "data/"))
        {
            return Path.normalize(imagePath);
        }

        var mapDirectory = Path.directory(mapPath);

        return Path.normalize(Path.join([mapDirectory, imagePath]));
    }

    static function loadBackgroundLayers(state:PlayState, layers:Array<TiledLayer>, mapPath:String)
    {
        for (layer in layers)
        {
            if (Std.isOfType(layer, TiledGroupLayer))
            {
                var group:TiledGroupLayer = cast layer;

                loadBackgroundLayers(state, group.layers, mapPath);

                continue;
            }

            if (!Std.isOfType(layer, TiledImageLayer))
            {
                continue;
            }

            var imageLayer:TiledImageLayer = cast layer;

            // TODO: Remove (along with removing the load property from all backgrounds)
            if (!getBoolProperty(imageLayer.properties, "Load", false))
            {
                continue;
            }

            if (imageLayer.imagePath == null || imageLayer.imagePath == "")
            {
                continue;
            }

            var speed = getFloatProperty(imageLayer.properties, "Speed X", 1.0);
            var speedY = getFloatProperty(imageLayer.properties, "Speed Y", speed);

            var alignment = parseBackgroundAlignment(getStringProperty(imageLayer.properties, "Alignment", "none"));

            var imageTop = getStringProperty(imageLayer.properties, "Image Top", null);

            if (imageTop != null)
            {
                imageTop = resolveTiledImagePath(mapPath, imageTop);
            }

            var imageBottom = getStringProperty(imageLayer.properties, "Image Bottom", null);

            if (imageBottom != null)
            {
                imageBottom = resolveTiledImagePath(mapPath, imageBottom);
            }

            var backgroundImage = resolveTiledImagePath(mapPath, imageLayer.imagePath);

            var background = new STBackground(backgroundImage, speed, speedY, alignment, imageTop, imageBottom, imageLayer.opacity, imageLayer.visible);

            state.levelBackgrounds.push(background);
            state.add(background);
        }
    }

    static function getBadguyDirection(object:TiledObject):BadguySpawnDirections
    {
        var direction = object.properties.get("direction");

        if (direction == null || direction == "")
        {
            return BadguySpawnDirections.AUTO;
        }

        switch (direction.toLowerCase())
        {
            case "left":
                return BadguySpawnDirections.LEFT;
            case "right":
                return BadguySpawnDirections.RIGHT;
            case "auto":
                return BadguySpawnDirections.AUTO;
            default:
                return BadguySpawnDirections.AUTO;
        }
    }
}