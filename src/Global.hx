package;

// Softcoded Level support by AnatolyStev
// Carrying over Tux's state support by AnatolyStev
// Saving and Loading support by AnatolyStev
// Original Global.hx by Discover HaxeFlixel, edited by Vaesea

import objects.Player;
import flixel.math.FlxPoint;
import lime.utils.Assets;
import states.PlayState;
import flixel.FlxG;
import haxe.Timer;

class Global
{
    // Player stuff
    public static var coins:Int = 100;
    public static var tuxState:TuxStates = SMALL;
    // Coins
    static var lastCoinSoundTime:Float = -1;

    // PlayState
    public static var PS:PlayState;
    
    // Non-hardcoded levels thing
    public static var levels:Array<String> = [];

    // Level stuff
    public static var currentLevel:Int = 0;
    public static var levelName:String;
    public static var gravity:Int = 1000;
    public static var maxFallSpeed:Int = 2000;

    // Checkpoint stuff
    public static var checkpointReached:Bool = false;
    public static var checkpointPosition:FlxPoint;

    // Current song that's playing (Could be turned into a bool?)
    public static var currentSong:String;

    // Same FPS as SuperTux, as far as I know
    // Use only for animations!
    public static final defaultFPS:Float = 10.0;

    // Borders
    public static var borderX:Int = 10;
    public static var borderY:Int = 10; 

    public static function addCoins(count:Int, playSound:Bool = true)
    {
        coins = Std.int(Math.min(coins + count, 9999));

        if (!playSound)
        {
            return;
        }

        if (count >= 100)
        {
            FlxG.sound.play("data/sounds/lifeup.wav");
        }
        else
        {
            var now = Timer.stamp();

            if (lastCoinSoundTime < 0 || now > lastCoinSoundTime + 0.010)
            {
                FlxG.sound.play("data/sounds/coin.wav");
                lastCoinSoundTime = now;
            }
        }
    }
    
    public static function removeCoins(amount:Int)
    {
        coins = Std.int(Math.max(coins - amount, 0));
    }

    // Load levels.txt file
    public static function loadLevels()
    {
        levels = Assets.getText("data/levels/levels.txt").split("\n").map(StringTools.trim).filter(function(l) return l != "");
    }
}