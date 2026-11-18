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

package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class CreditsState extends FlxState
{
    var creditsText:FlxText;

    var speed = 20;
    var increaseOrDecreaseSpeed = 10;

    override public function create()
    {
        super.create();

        var bg = new FlxSprite();
        bg.loadGraphic("data/images/menu/title.png", false);
        add(bg);
        
        creditsText = new FlxText(-12, 240, 256, "
        SuperTux Team - Original SuperTux assets
        
        Vaesea - Coding

        AnatolyStev - Coding

        Discover Haxeflixel - Book / PDF - Original
        Code

        CNE-Flixel - HaxeFlixel fork that had
        the original version of the
        makeSolidGraphic function that I put
        in the VPBSprite.hx thing



        Press Space to play.", 8);
        creditsText.setFormat(null, 8, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        creditsText.borderSize = 1.25;
        creditsText.moves = true;
        creditsText.velocity.y = -speed;
        add(creditsText);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.SPACE)
        {
            FlxG.switchState(PlayState.new); // Switch State
        }
        
        if (FlxG.keys.justPressed.DOWN)
        {
            creditsText.velocity.y -= increaseOrDecreaseSpeed;
        }
        else if (FlxG.keys.justPressed.UP)
        {
            creditsText.velocity.y += increaseOrDecreaseSpeed;
        }
    }
}