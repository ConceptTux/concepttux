package objects;

import flixel.FlxG;
import flixel.tweens.FlxTween;
import objects.Player;

class BrickBlock extends Block
{
    public var snow:Bool = false;
    public var unbreakable:Bool = false;
    var amount:Int = 5;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        immovable = true;

        loadGraphic("data/images/objects/block/brick.png", true, 32, 32);
        animation.add("brick", [0], Global.defaultFPS, false);
        animation.add("snow", [1], Global.defaultFPS, false);
        animation.add("web", [3], Global.defaultFPS, false); // Unused!
        animation.add("empty", [2], Global.defaultFPS, false);

        if (snow)
        {
            animation.play("snow");
        }
        else
        {
            animation.play("brick");
        }
    }

    override public function hit(tux:Player)
    {
        if (!hitFromBelowCheck(tux))
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

            if (tux.currentState != SMALL)
            {
                FlxTween.tween(
                    this,
                    {y: startY - 8},
                    0.05,
                    {onComplete: break_brick}
                );
            }
            else
            {
                FlxTween.tween(this, {y: startY - 8}, 0.05)
                    .wait(0.05)
                    .then(FlxTween.tween(this, {y: startY}, 0.05, {
                        onComplete: function(_)
                        {
                            hitAreaDown.exists = true;
                            hitAreaLeft.exists = true;
                            hitAreaRight.exists = true;
                        }
                    }));
            }
        }
        else
        {
            hitAreaDown.exists = false;
            hitAreaLeft.exists = false;
            hitAreaRight.exists = false;

            if (amount <= 1)
                isEmpty = true;

            createItem();
            amount -= 1;

            FlxTween.tween(this, {y: startY - 8}, 0.05)
                .wait(0.05)
                .then(FlxTween.tween(this, {y: startY}, 0.05, {
                    onComplete: function(_)
                    {
                        if (isEmpty)
                            animation.play("empty");

                        hitAreaDown.exists = true;
                        hitAreaLeft.exists = true;
                        hitAreaRight.exists = true;
                    }
                }));
        }
    }

    function break_brick(_)
    {
        hitAreaDown.kill();
        hitAreaLeft.kill();
        hitAreaRight.kill();

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
}