//  SuperTux Rebuilt
//  Copyright (C) 2026 AnatolyStev
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

package misc;

import supertux.STFont;
import supertux.STFText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class PlayerStatus extends FlxSpriteGroup
{
    public static inline var startCoins:Int = 100;
    public static inline var maxCoins:Int = 9999;

    var displayedCoins:Int = -1;

    var displayedCoinsFrame:Int = 0;

    var coinStatus:FlxSprite;
    var coinText:STFText;
    var font:STFont;

    var lastCoins:Int = -1;

    public function new()
    {
        super();

        font = STFont.load("data/fonts/yellow.stf");

        coinStatus = new FlxSprite();
        coinStatus.loadGraphic("data/images/engine/hud/coins.png");

        coinText = new STFText(font);

        coinStatus.scrollFactor.set(0, 0);
        coinText.scrollFactor.set(0, 0);

        add(coinStatus);
        add(coinText);

        resetHUD();
    }

    public function resetHUD()
    {
        displayedCoins = -1;
        displayedCoinsFrame = 0;

        updateDisplayedCoins();
        updateLayout();
    }

    override public function update(elapsed:Float)
    {
        if (Global.coins != lastCoins)
        {
            lastCoins = Global.coins;

            coinText.text = Std.string(Global.coins);

            updateLayout();
        }

        super.update(elapsed);
    }

    private function updateDisplayedCoins()
    {
        if (displayedCoins == -1)
        {
            displayedCoins = Global.coins;
            displayedCoinsFrame = 0;
        }

        displayedCoinsFrame += 1;

        if (displayedCoinsFrame > 2)
        {
            displayedCoinsFrame = 0;

            if (displayedCoins < Global.coins)
            {
                displayedCoins += 1;
            }

            if (displayedCoins > Global.coins)
            {
                displayedCoins -= 1;
            }
        }

        displayedCoins = Std.int(Math.max(0, Math.min(displayedCoins, maxCoins)));

        coinText.text = Std.string(displayedCoins);
    }

    private function updateLayout()
    {
        var textWidth = font.getTextWidth(coinText.text);

        coinText.x = FlxG.width - Global.borderX - textWidth;
        coinText.y = Global.borderY;

        coinStatus.x = FlxG.width - Global.borderX - coinStatus.width - textWidth;
        coinStatus.y = Global.borderY + 1;
    }
}