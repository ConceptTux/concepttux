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

package objects;

import badguys.Badguy;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import objects.Player;

class BonusBlock extends Block
{
    public function new(x:Float, y:Float)
    {
        super(x, y);

        loadGraphic("data/images/objects/block/bonus.png", true, 32, 32);
        animation.add("normal", [0, 1, 2, 3, 4, 2, 1, 0, 0, 0], 15.0, true);
        animation.add("empty", [5], Global.defaultFPS, false);
        animation.play("normal");
    }

    override public function hit(tux:Player)
    {
        if (!hitCheck(tux))
        {
            return;
        }

        if (isEmpty)
        {
            FlxG.sound.play("data/sounds/brick.wav");
            return;
        }

        tux.physics.velocityY = 0; // Stop movement, fixes a bug

        if (tux.getCenterX() < x + width * 0.5)
        {
            bounce("right");
        }
        else if (tux.getCenterX() == x + width * 0.5)
        {
            bounce("right");
        }
        else if (tux.getCenterX() > x + width * 0.5)
        {
            bounce("left");
        }
    }

    override public function badguyHit(badguy:Badguy)
    {
        if (!badguyHitCheck(badguy))
        {
            return;
        }

        if (isEmpty)
        {
            FlxG.sound.play("data/sounds/brick.wav");
            return;
        }

        badguy.physics.velocityX = 0;

        if (badguy.currentHeldEnemyState == FLAT)
        {
            badguy.physics.velocityY = 0;
        }

        if (badguy.currentHeldEnemyState == MOVING_FLAT)
        {
            if (badguy.getRight() <= this.x)
            {
                bounce("right");
            }
            else if (badguy.x >= this.x + width)
            {
                bounce("left");
            }
        }
        else
        {
            if (badguy.getCenterX() < x + width * 0.5)
            {
                bounce("right");
            }
            else if (badguy.getCenterX() == x + width * 0.5)
            {
                bounce("right");
            }
            else if (badguy.getCenterX() > x + width * 0.5)
            {
                bounce("left");
            }
        }
    }

    function bounce(direction:String)
    {
        hitAreaDown.exists = false;
        hitAreaLeft.exists = false;
        hitAreaRight.exists = false;
        hitAreaUp.exists = false;

        FlxG.sound.play("data/sounds/brick.wav");

        isEmpty = true;

        createItem(direction);

        var startY = this.y;
        FlxTween.tween(this, {y: startY - 8}, 0.05) .wait(0.05) .then(FlxTween.tween(this, {y: startY}, 0.05, {onComplete: function(_) 
        {
            hitAreaDown.exists = true;
            hitAreaLeft.exists = true;
            hitAreaRight.exists = true;
            hitAreaUp.exists = true;
            empty(_);
        }}));
    }

    override private function createItem(direction:String)
    {
        switch(content)
        {
            case "coin":
                var coin:Coin = new Coin(this.x, this.y);
                coin.collect();
                Global.PS.itemsFlxSprite.add(coin);
            case "powerup":
                if (Global.PS.player.currentState == SMALL)
                {
                    var egg:Egg = new Egg(this.x, this.y);

                    if (direction == "left")
                    {
                        egg.spawnFromBlock("left");
                    }
                    else if (direction == "right")
                    {
                        egg.spawnFromBlock("right");
                    }
                    else
                    {
                        trace("Unsupported direction! Supported directions are \"left\" and \"right\".");
                    }

                    Global.PS.items.add(egg);
                }
                else
                {
                    var fireFlower:FireFlower = new FireFlower(this.x, this.y);
                    fireFlower.spawnFromBlock();
                    Global.PS.items.add(fireFlower);
                }
                
                FlxG.sound.play("data/sounds/upgrade.wav");
            case "tuxdoll":
                var tuxDoll:TuxDoll = new TuxDoll(this.x, Std.int(y - 32));

                if (direction == "left")
                {
                    tuxDoll.spawnFromBlock("left");
                }
                else if (direction == "right")
                {
                    tuxDoll.spawnFromBlock("right");
                }
                else
                {
                    trace("Unsupported direction! Supported directions are \"left\" and \"right\".");
                }

                Global.PS.items.add(tuxDoll);
                FlxG.sound.play("data/sounds/upgrade.wav");
        }
    }
}