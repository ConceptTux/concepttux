//  SuperTux Rebuilt
//  Copyright (C) 2026 Vaesea <sophieballvaesea@proton.me>
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

package objects;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class Coin extends FlxSprite
{
    var targetY:Int = 96;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        loadGraphic("data/images/objects/coin.png", true, 32, 32);
        animation.add("normal", [0, 1, 2, 3, 4, 5, 6, 7], 10.0, true);
        animation.play("normal");
    }

    public function collect()
    {
        if (Global.levelPaused)
        {
            return;
        }
        
        alive = false;
        solid = false;
        Global.addCoins(1);
        FlxTween.tween(this, {alpha: 0, y: y - targetY}, 0.4, {onComplete: function (_)
        {
            kill();
        }}); // thanks official haxeflixel tutorial
    }
}