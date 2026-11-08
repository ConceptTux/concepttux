package objects;

// import characters.badguy.Badguy;
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

    // override public function hit(tux:Player, badguy:Badguy)
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
            // case "tuxdoll":
            //     var tuxDoll:TuxDoll = new TuxDoll(this.x, Std.int(y - 32));
            //     Global.PS.td.add(tuxDoll);
            //     FlxG.sound.play("assets/sounds/upgrade.wav");
        }
    }
}