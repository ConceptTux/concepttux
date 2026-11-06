package;

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
        state.add(state.map);

        // Load solids
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
            }
        }

        // Load goal
        for (object in getLevelObjects(tiledMap, "Level"))
        {
            switch (object.type)
            {
                case "goal":
                    state.items.add(new Goal(object.x, object.y, object.width, object.height));
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
                    state.items.add(new Coin(object.x, object.y - 32));
                case "bonus_coin":
                    var bonusBlockCoin:BonusBlock = new BonusBlock(object.x, object.y - 32);
                    bonusBlockCoin.content = "coin";
                    state.solids.add(bonusBlockCoin);
                case "brick":
                    state.solids.add(new BrickBlock(object.x, object.y - 32));
                case "brickCoin":
                    var brickCoin = new BrickBlock(object.x, object.y - 32);
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

    static function getStringProperty(properties:TiledPropertySet, name:String, defaultValue:String):String
    {
        var value = properties.get(name);

        if (value == null || value == "")
        {
            return defaultValue;
        }

        return value;
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