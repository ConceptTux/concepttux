//  SuperTux Rebuilt
//  Copyright (C) 2026 Vaesea <sophieballvaesea@proton.me>
//                2026 AnatolyStev
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
    public static var levelPaused:Bool = false;
    public static var restart:Bool = false;

    // Checkpoint stuff
    public static var checkpointReached:Bool = false;
    public static var checkpointPosition:FlxPoint;

    // Goal stuff
    public static var goalReached:Bool = false;

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

    // Scripting functions below

    // Scripting
    public function getCoins():Int
    {
        return coins;
    }

    public function shakeCamera(intensity:Float, duration:Float)
    {
        FlxG.camera.shake(intensity, duration);
    }
}