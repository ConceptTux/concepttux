package badguys;

import objects.Bullet;
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

enum BombStates
{
    WALKING;
    TICKING;
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
    var currentBombState:BombStates = WALKING;

    // Spawn direction
    var spawnDirection:BadguySpawnDirections = AUTO;

    // Iceblock Badguy stuff
    public var canBeHeld:Bool = false;
    public var held:Player = null;
    var waitToCollide:Float = 0.0;
    var damageOthers:Bool = false;
    final maxSquishes = 10;
    var squishes = 0; // Don't change this!

    // Bomb Badguy stuff
    public var bomb:Bool = false;

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

                if (canBeHeld && currentHeldEnemyState == MOVING_FLAT)
                {
                    FlxG.sound.play("data/sounds/iceblock_bump.wav", 1.0, false);
                }
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

        if (currentHeldEnemyState == HELD)
        {
            return;
        }

        if (checkIfHerring(tux))
        {
            killFall();
            return;
        }

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

            squishes += 1;

            if (currentBombState != TICKING)
            {
                if (FlxG.keys.anyPressed([SPACE, UP, W]))
                {
                    tux.physics.velocityY = tux.minJumpHeight;
                }
                else
                {
                    tux.physics.velocityY = tux.minJumpHeight * 0.5;
                }
            }

            if (!canBeHeld)
            {
                kill();
            }
            else
            {
                if (squishes >= maxSquishes)
                {
                    killFall();
                    return;
                }

                waitToCollide = 0.25;

                if (!bomb)
                {
                    if (currentHeldEnemyState == MOVING_FLAT)
                    {
                        turnFlat();
                    }
                    else if (currentHeldEnemyState == FLAT)
                    {
                        direction = tux.direction;
                        flipX = !tux.flipX;
                        currentHeldEnemyState = MOVING_FLAT;
                        damageOthers = true;

                        FlxG.sound.play("data/sounds/stomp.wav");
                        FlxG.sound.play("data/sounds/kick.wav");
                    }
                    else
                    {
                        turnFlat();
                    }
                }
                else
                {
                    turnFlat();
                    kill();
                }
            }

            return;
        }

        if (canBeHeld && currentHeldEnemyState == FLAT)
        {
            if (!tuxStomp && FlxG.keys.pressed.CONTROL && tux.heldBadguy == null)
            {
               tux.holdEnemy(this);
               return;
            }

            if (!tuxStomp && !bomb)
            {
                direction = tux.direction;
                flipX = !tux.flipX;
                kickOrThrow();
                return;
            }
        }

        if (currentBombState == TICKING)
        {
            return;
        }

        // Shouldn't get this far unless Tux should actually be damaged
        tux.takeDamage();
    }

    override public function kill()
    {
        if (currentState == DEAD)
        {
            return;
        }

        currentState = DEAD;

        if (!physics.gravityEnabled)
        {
            physics.gravityEnabled = true;
            physics.maxVelocityY = Global.gravity;
        }
        
        if (!dieFall) // Squish
        {
            FlxG.sound.play("data/sounds/squish.wav");
            physics.velocityX = 0;
            physics.velocityY = 0;
            physics.accelerationX = 0;
            animation.play("squished");

            new FlxTimer().start(2.0, function(_)
            {
                alive = false;
                exists = false;
                visible = false; // might not be needed?
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
        if (currentState == DEAD || otherBadguy.currentState == DEAD || currentBombState == TICKING || otherBadguy.currentBombState == TICKING)
        {
            return;
        }
        
        if (this.damageOthers)
        {
            otherBadguy.killFall();
        }
        else if (otherBadguy.damageOthers)
        {
            killFall();
        }
        else
        {
            FlxObject.separate(this, otherBadguy);
        }
    }

    public function collideFireball(fireball:Bullet)
    {
        if (currentState == DEAD)
        {
            return;
        }

        fireball.kill();

        if (flammable)
        {
            killFall();
        }
    }

    public function pickUp(tux:Player):Bool
    {
        if (!canBeHeld || currentHeldEnemyState != FLAT || held != null || tux.heldBadguy != null)
        {
            return false;
        }

        currentHeldEnemyState = HELD;
        held = tux;
        solid = false;

        physics.velocityX = 0;
        physics.velocityY = 0;
        physics.accelerationX = 0;
        physics.accelerationY = 0;
        physics.gravityEnabled = false;
        physics.grounded = false; // Should automatically be set, but just to be safe...

        velocity.set(0, 0);
        acceleration.set(0, 0);

        if (!bomb)
        {
            animation.play("flat");
        }

        return true;
    }

    public function enemyThrow()
    {
        if (canBeHeld)
        {
            if (currentHeldEnemyState != HELD || held == null)
            {
                return;
            }

            direction = held.direction;
            flipX = !held.flipX;

            kickOrThrow();
        }
    }

    function checkIfHerring(tux:Player):Bool
    {
        if (tux.invincible)
        {
            return true;
        }

        return false;
    }

    public function offScreenCheck(tux:Player)
    {
        if (loadWhenLevelLoads)
        {
            return false;
        }

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

    function kickOrThrow()
    {
        if (!bomb)
        {
            currentHeldEnemyState = MOVING_FLAT;
            damageOthers = true;
        }
        else
        {
            currentHeldEnemyState = FLAT;
        }

        solid = true;

        held = null;
        waitToCollide = 0.25;

        physics.gravityEnabled = true;
        physics.grounded = false; // extra safety, clears old grounded state just in case!

        physics.velocityX = 0;
        physics.velocityY = 0;
        physics.accelerationX = 0;
        physics.accelerationY = 0;

        if (!bomb)
        {
            FlxG.sound.play("data/sounds/kick.wav");
        }
    }

    function turnFlat()
    {
        if (!bomb)
        {
            animation.play("flat");
        }

        currentHeldEnemyState = FLAT;
        physics.velocityX = 0;

        if (!bomb)
        {
            FlxG.sound.play("data/sounds/stomp.wav");
        }
        else
        {
            FlxG.sound.play("data/sounds/squish.wav");
        }
    }
}