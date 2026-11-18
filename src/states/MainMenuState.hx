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
import flixel.ui.FlxButton;

class MainMenuState extends FlxState
{
    var playButton:FlxButton;

    override public function create()
    {
        super.create();

        if (FlxG.sound.music != null) // Check if song is playing, if it is, stop song. This if statement is here just to avoid a really weird crash
        {
            FlxG.sound.music.stop();
        }

        Global.checkpointReached = false;
        Global.currentLevel = 0;
        Global.coins = 100;

        // Adding Title Screen background
        var bg = new FlxSprite();
        bg.loadGraphic("data/images/menu/title.png", false);
        add(bg);

        // Adding button, will probably be replaced by an image?
        playButton = new FlxButton(0, 0, "Play Game", clickPlay);
        playButton.screenCenter();
        add(playButton);
    }

    function clickPlay()
    {
        FlxG.switchState(CreditsState.new); // Switch State
    }
}