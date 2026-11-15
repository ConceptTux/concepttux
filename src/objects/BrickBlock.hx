package objects;

import badguys.Badguy;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import objects.Player;

class BrickBlock extends Block
{
    public var snow:Bool = false;
    public var unbreakable:Bool = false;
    var amount:Int = 5;

    public function new(x:Float, y:Float, spritePath:String = "data/images/objects/brick/brick.png")
    {
        super(x, y);
        immovable = true;

        loadGraphic(spritePath, true, 32, 32);
        animation.add("normal", [0], Global.defaultFPS, false);
        animation.add("empty", [1], Global.defaultFPS, false);
        animation.play("normal");

        if (spritePath == "data/images/objects/brick/brick-snow.png")
        {
            snow = true;
        }
    }

    override public function hit(tux:Player)
    {
        if (!hitCheck(tux))
        {
            return;
        }

        if (isEmpty)
        {
            return;
        }

        FlxG.sound.play("data/sounds/brick.wav");

        var startY = this.y;

        tux.physics.velocityY = 0; // Stop movement, fixes a bug

        if (!unbreakable)
        {
            hitAreaDown.exists = false;
            hitAreaLeft.exists = false;
            hitAreaRight.exists = false;
            hitAreaUp.exists = false;

            if (tux.currentState != SMALL)
            {
                FlxTween.tween(this, {y: startY - 8}, 0.05, {onComplete: break_brick});
            }
            else
            {
                FlxTween.tween(this, {y: startY - 8}, 0.05) .wait(0.05) .then(FlxTween.tween(this, {y: startY}, 0.05, 
                {
                    onComplete: function(_)
                    {
                        hitAreaDown.exists = true;
                        hitAreaLeft.exists = true;
                        hitAreaRight.exists = true;
                        hitAreaUp.exists = true;
                    }
                }));
            }
        }
        else
        {
            hitAreaDown.exists = false;
            hitAreaLeft.exists = false;
            hitAreaRight.exists = false;
            hitAreaUp.exists = false;

            if (amount <= 1)
            {
                isEmpty = true;
            }

            createItem("");
            amount -= 1;

            FlxTween.tween(this, {y: startY - 8}, 0.05) .wait(0.05) .then(FlxTween.tween(this, {y: startY}, 0.05, 
            {
                onComplete: function(_)
                {
                    if (isEmpty)
                    {
                        animation.play("empty");
                    }

                    hitAreaDown.exists = true;
                    hitAreaLeft.exists = true;
                    hitAreaRight.exists = true;
                    hitAreaUp.exists = true;
                }
            }));
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
            return;
        }

        FlxG.sound.play("data/sounds/brick.wav");

        var startY = this.y;

        badguy.physics.velocityX = 0; // Stop movement, fixes a bug

        if (badguy.currentHeldEnemyState == FLAT)
        {
            badguy.physics.velocityY = 0;
        }

        if (!unbreakable)
        {
            hitAreaDown.exists = false;
            hitAreaLeft.exists = false;
            hitAreaRight.exists = false;
            hitAreaUp.exists = false;

            FlxTween.tween(this, {y: startY - 8}, 0.05, {onComplete: break_brick});
        }
        else
        {
            hitAreaDown.exists = false;
            hitAreaLeft.exists = false;
            hitAreaRight.exists = false;
            hitAreaUp.exists = false;

            if (amount <= 1)
            {
                isEmpty = true;
            }

            createItem("");
            amount -= 1;

            FlxTween.tween(this, {y: startY - 8}, 0.05) .wait(0.05) .then(FlxTween.tween(this, {y: startY}, 0.05, 
            {
                onComplete: function(_)
                {
                    if (isEmpty)
                    {
                        animation.play("empty");
                    }

                    hitAreaDown.exists = true;
                    hitAreaLeft.exists = true;
                    hitAreaRight.exists = true;
                    hitAreaUp.exists = true;
                }
            }));
        }
    }

    function break_brick(_)
    {
        hitAreaDown.kill();
        hitAreaLeft.kill();
        hitAreaRight.kill();
        hitAreaUp.kill();

        var brick_1:BrickParticle = new BrickParticle(x, y, 1);
        var brick_2:BrickParticle = new BrickParticle(x, y + 16, 2);
        var brick_3:BrickParticle = new BrickParticle(x + 16, y, 3);
        var brick_4:BrickParticle = new BrickParticle(x + 16, y + 16, 4);

        brick_1.snow = this.snow; // using "this" to make it more readable...
        brick_2.snow = this.snow;
        brick_3.snow = this.snow;
        brick_4.snow = this.snow;

        Global.PS.add(brick_1);
        Global.PS.add(brick_2);
        Global.PS.add(brick_3);
        Global.PS.add(brick_4);

        kill();
    }

    override private function createItem(direction:String)
    {
        var coin:Coin = new Coin(this.x, this.y);
        coin.collect();
        Global.PS.itemsFlxSprite.add(coin);
    }
}