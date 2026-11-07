package badguys;

import flixel.util.FlxTimer;
import flixel.FlxObject;
import flixel.FlxG;
import objects.Player;
import misc.VPBSprite;

enum BadguySpawnDirections
{
    LEFT;
    RIGHT;
    AUTO;
}

enum BadguyStates
{
    ALIVE;
    DEAD;
}

enum CarryableEnemyStates
{
    NORMAL;
    FLAT;
    MOVING_FLAT;
    HELD;
}

class Badguy extends VPBSprite
{
    // States
    var currentState:BadguyStates = ALIVE;
    var currentHeldEnemyState:CarryableEnemyStates = NORMAL;

    // Spawn direction
    var spawnDirection:BadguySpawnDirections = AUTO;

    // Iceblock Badguy stuff
    public var canBeHeld:Bool = false;
    public var held:Player = null;
    var waitToCollide:Float = 0.0;
    var damageOthers:Bool = false;

    // Powerup bullet stuff
    var flammable:Bool = true;
    var freezable:Bool = true;

    // Movement
    var walkSpeed:Int = 80;
    var loadWhenLevelLoads:Bool = false;
    public var direction:Int = -1;
    var appeared:Bool = false;
    
    // Other
    var dieFall:Bool = false;

    public function new(x:Float, y:Float, startDirection:BadguySpawnDirections = BadguySpawnDirections.AUTO)
    {
        super(x, y);

        immovable = false;

        initDirection(Global.PS.player);
    }

    override public function update(elapsed:Float)
    {
        // Extra safety!
        velocity.set(0, 0);
        acceleration.set(0, 0);
        drag.set(0, 0);
        
        if (waitToCollide > 0)
        {
            waitToCollide -= elapsed;
        }

        if (!offScreenCheck(Global.PS.player))
        {
            appeared = true;
        }
        else
        {
            appeared = false;
        }

        if (appeared && currentState != DEAD)
        {
            move();

            if (isWalkingIntoWall())
            {
                flipDirection();
            }
        }

        if (canBeHeld)
        {
            if (currentHeldEnemyState == HELD && held != null)
            {
                if (held.flipX)
                {
                    x = held.x + 16;
                }
                else if (!held.flipX)
                {
                    x = held.x + 16;
                }

                y = held.y;
                flipX = !held.flipX;
            }

            if (justTouched(WALL) && isOnScreen() && currentHeldEnemyState == MOVING_FLAT)
            {
                FlxG.sound.play("data/sounds/iceblock_bump.wav", 1.0, false);
            }
        }

        super.update(elapsed);
    }

    function flipDirection()
    {
        flipX = !flipX;
        direction = -direction;
    }

    // Badguys override this
    function move()
    {
    }

    public function interact(tux:Player)
    {
        if (currentState == DEAD)
        {
            return;
        }

        checkIfHerring(tux);

        var tuxStomp = (tux.getBottom() < (this.y + 16)); // Tux stomp check

        if (!alive || waitToCollide > 0)
        {
            return;
        }

        if (currentHeldEnemyState == MOVING_FLAT)
        {
            damageOthers = true;
        }

        FlxObject.separateY(tux, this);

        if (tuxStomp) // Can't just do the simple isTouching UP thing because then if the player hits the corner of the enemy, they take damage. That's not exactly fair
        {
            tux.y -= 1; // Keeping this thing originally from Milestone Mix just to be safe...

            if (FlxG.keys.anyPressed([SPACE, UP, W]))
            {
                tux.physics.velocityY = -520;
            }
            else
            {
                tux.physics.velocityY = -520 / 2;
            }

            if (!canBeHeld)
            {
                kill();
            }
            else
            {
                waitToCollide = 0.25;

                if (currentHeldEnemyState == MOVING_FLAT)
                {
                    currentHeldEnemyState = FLAT;
                    animation.play("flat");
                    physics.velocityX = 0;
                }
                else if (currentHeldEnemyState == FLAT)
                {
                    direction = tux.direction;
                    flipX = !tux.flipX;
                    currentHeldEnemyState = MOVING_FLAT;
                    damageOthers = true;
                }
                else
                {
                    animation.play("flat");
                    currentHeldEnemyState = FLAT;
                    physics.velocityX = 0;
                }
            }

            return;
        }

        // if (canBeHeld && currentHeldEnemyState == FLAT)
        // {
        //     if (!isTouching(UP) && FlxG.keys.pressed.CONTROL && tux.heldEnemy == null)
        //     {
        //        tux.holdEnemy(this);
        //        return;
        //     }

        //     if (!tuxStomp)
        //     {
        //         direction = tux.direction;
        //         flipX = !tux.flipX;
        //         currentHeldEnemyState = MovingSquished;
        //         damageOthers = true;
        //         FlxG.sound.play("assets/sounds/kick.wav");
        //         waitToCollide = 0.25;
        //         return;
        //     }
        // }

        // Shouldn't get this far unless Tux should actually be damaged
        tux.takeDamage();
    }

    override public function kill()
    {
        currentState = DEAD;
        
        if (!dieFall) // Squish
        {
            FlxG.sound.play('data/sounds/squish.wav');
            physics.velocityX = 0;
            physics.velocityY = 0;
            physics.accelerationX = 0;
            animation.play("squished");

            new FlxTimer().start(2.0, function(_)
            {
                alive = false;
                exists = false;
                visible = false;
            }, 1);
        }
        else // Fall
        {
            FlxG.sound.play("data/sounds/fall.wav");

            physics.accelerationX = 0;
            physics.velocityX = 0;
            physics.velocityY = 0;

            flipY = true;
            solid = false;
        }
    }

    public function killFall()
    {
        dieFall = true;
        kill();
    }

    public function collideOtherBadguy(otherBadguy:Badguy)
    {
        if (currentState == DEAD || otherBadguy.currentState == DEAD)
        {
            return;
        }
        
        if (otherBadguy.damageOthers)
        {
            killFall();
        }
        else
        {
            FlxObject.separate(this, otherBadguy);
        }
    }

    // public function collideFireball(fireball:Fireball)
    // {
    //     fireball.kill();

    //     if (canFireballDamage)
    //     {
    //         killFall();
    //     }
    // }

    // public function pickUp(tux:Tux)
    // {
    //     if (canBeHeld == true)
    //     {
    //         if (currentHeldEnemyState != Squished || held != null)
    //         {
    //             return;
    //         }

    //         currentHeldEnemyState = Held;
    //         held = tux;
    //         solid = false;
    //         velocity.x = 0;
    //         velocity.y = 0;
    //         animation.play("flat");
    //     }
    // }

    // public function enemyThrow()
    // {
    //     if (canBeHeld == true)
    //     {
    //         if (currentHeldEnemyState != Held || held == null)
    //         {
    //             return;
    //         }

    //         currentHeldEnemyState = MovingSquished;
    //         direction = held.direction;
    //         flipX = !held.flipX;
    //         solid = true;
    //         damageOthers = true;
    //         held = null;
    //         waitToCollide = 0.25;
    //         FlxG.sound.play("assets/sounds/kick.wav");
    //     }
    // }

    function checkIfHerring(tux:Player)
    {
        if (tux.invincible)
        {
            killFall();
        }
    }

    public function offScreenCheck(tux:Player)
    {
        final distanceX = Math.abs(tux.getCenterX() - this.getCenterX());
        final distanceY = Math.abs(tux.getCenterY() - this.getCenterY());

        return !(distanceX <= 1280 && distanceY <= 800); // TODO: add variables for these numbers
    }

    function initDirection(tux:Player)
    {
        if (spawnDirection == AUTO)
        {
            if (tux.x > x + width)
            {
                direction = 1;
                flipX = !flipX;
            }
            else
            {
                direction = -1;
            }
        }
        else if (spawnDirection == LEFT)
        {
            direction = -1;
        }
        else if (spawnDirection == RIGHT)
        {
            direction = 1;
            flipX = !flipX;
        }
    }
}