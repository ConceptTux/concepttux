package objects;

// Buttjumping still has an issue (You can skid when you hit the ground after the bounce when Tux should really just duck. He ducks after that though? But if you time stuff right, that can act weird too).
// -AnatolyStev

// Roll jumping is temporarily removed due to issues.

import misc.VPBSprite;
import collision.Collision;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.FlxG;

enum TuxStates
{
    SMALL;
    BIG;
    FIRE;
}

class Player extends VPBSprite
{
    // Movement
    var walkAcceleration:Int = 300;
    var runAcceleration:Int = 400;
    var walkStartSpeed:Int = 100;
    var walkSpeed:Int = 230;
    var runSpeed:Int = 320;
    var friction:Int = 450;
    public var minJumpHeight:Int = -520;
    public var maxJumpHeight:Int = -580;
    var duckJumpHeight:Int = -300;
    var jumpCancel:Float = 3.0;
    var speed:Int = 0;
    var decelerateOnJumpRelease:Float = 0.5;

    // Jump buffering
    var jumpBufferTime:Float = 0.25;
    var jumpBuffer:Float = 0.0; // Don't change!
    var jumpCutRequested:Bool = false;

    // Ducking
    var ducking:Bool = false;

    // Skidding
    var skidThreshold:Float = 200;
    var skidAccelerationMultiplier:Float = 2.5;
    var reverseAccelerationMultiplier:Float = 2.0;
    var skidTime:Float = 0.3;
    var skidTimer:Float = 0.0;

    // Backflipping
    var backflipping:Bool = false;
    var backflipDirection:Int = 1;
    var backflipElapsed:Float = 0.0;
    var backflipTimer:Float = 0.0;
    var backflipTime:Float = 2.1;
    var backflipSpeed:Int = 100;
    var backflipRotateSpeed:Float = 0.5;
    var backflipLandingTimer:Float = 0.0;
    var backflipLandingTime:Float = 0.1;
    var rollJumpRequested:Bool = false;

    // Buttjump (aka Ground Pound if you play Mario)
    var fakeButtjump:Bool = false;
    public var actualButtjump:Bool = false;
    var buttjumpMinVelocityY:Float = 400;
    var buttjumpBounced:Bool = false;
    
    // Direction
    public var direction:Int = 1;

    // Powerup
    public var currentState:TuxStates = SMALL;
    public var invincible:Bool = false;

    // Damage
    var canTakeDamage:Bool = true;
    var invSeconds:Float = 1.8;

    public function new()
    {
        super();

        reloadGraphics();

        // Add deceleration (drag) and gravity
        physics.maxVelocityX = runSpeed;
        physics.maxVelocityY = Global.maxFallSpeed;
    }

    override public function update(elapsed:Float)
    {
        // Debug
        if (FlxG.keys.justPressed.ONE)
        {
            smallTux();
        }
        if (FlxG.keys.justPressed.TWO)
        {
            bigTux();
        }
        if (FlxG.keys.justPressed.THREE)
        {
            fireTux();
        }

        // Stop the player from falling off the map through the left
        if (x < 0)
        {
            x = 0;
        }

        if (x > Global.PS.map.width - this.width)
        {
            x = Global.PS.map.width - this.width;
        }

        // Kill the player when they fall into the void
        if (y > Global.PS.map.height)
        {
            die();
        }

        // Functions
        move(elapsed);
        animate();

        // Extra safety!
        velocity.set(0, 0);
        acceleration.set(0, 0);
        drag.set(0, 0);

        super.update(elapsed);
    }

    // One frame late but that's ok!
    function animate()
    {
        if (!ducking && skidTimer <= 0 && !backflipping && !(fakeButtjump || actualButtjump))
        {
            // If Tux is on the ground, play stand or walk
            if (physics.grounded)
            {
                // If the player is on the floor and staying where they are, stand
                if (physics.velocityX == 0 || isWalkingIntoWall())
                {
                    animation.play("stand");
                }
                else
                {
                    animation.play("walk");
                }
            }
            else
            {
                animation.play("jump");
            }
        }
        else if (ducking && skidTimer <= 0 && !backflipping && !(fakeButtjump || actualButtjump))
        {
            animation.play("duck");
        }
        else if (!ducking && skidTimer > 0 && !backflipping && !(fakeButtjump || actualButtjump))
        {
            animation.play("skid");
        }
        else if (ducking && skidTimer <= 0 && backflipping && !(fakeButtjump || actualButtjump)) // this reveals a bug that i dont want to fix right now (tux doesnt stop ducking when backflip starts!!!!!)
        {
            animation.play("backflip");
        }
        else if (!ducking && skidTimer <= 0 && !backflipping && (fakeButtjump || actualButtjump))
        {
            animation.play("buttjump");
        }
    }

    function move(elapsed:Float)
    {
        // Jump buffer timer thing
        if (jumpBuffer > 0)
        {
            jumpBuffer -= elapsed;
        }

        // Skid timer thing
        if (skidTimer > 0)
        {
            skidTimer -= elapsed;

            if (skidTimer < 0)
            {
                skidTimer = 0;
            }
        }

        // Backflip timer thing
        if (backflipTimer > 0)
        {
            backflipTimer -= elapsed;

            if (backflipTimer < 0)
                backflipTimer = 0;
        }

        // Backflip landing timer thing. This is not backflipTimer
        if (backflipLandingTimer > 0)
        {
            backflipLandingTimer -= elapsed;

            if (backflipLandingTimer < 0)
                backflipLandingTimer = 0;
        }

        if (backflipping)
        {
            backflipElapsed += elapsed;
            
            direction = backflipDirection == 1 ? -1 : 1;

            physics.velocityX = backflipSpeed * backflipDirection;
            physics.accelerationX = 0;

            // Rotate
            angle += (direction == -1 ? 1 : -1) * elapsed * (360 / backflipRotateSpeed);

            // stop the backflip
            if ((physics.grounded && !rollJumpRequested) && (backflipLandingTimer <= 0 || backflipTimer <= 0))
            {
                stopBackflip();
            }
        }
        else
        {
            // Speed is, by default, 0
            physics.accelerationX = 0;

            // Input direction is by default, 0
            var directionInput:Int = 0;

            // If player presses left, move left. If player presses right, move right
            var duck_on_floor = (ducking && physics.grounded);
            
            // Left / Right movement (if not ducking!)
            if (!duck_on_floor)
            {
                if (FlxG.keys.anyPressed([LEFT, A]))
                {
                    flipX = true; // Flip player
                    direction = -1; // Set direction
                    directionInput = -1;
                }
                else if (FlxG.keys.anyPressed([RIGHT, D]))
                {
                    flipX = false; // Unflip player
                    direction = 1; // Set direction
                    directionInput = 1;
                }
            }

            if (directionInput != 0)
            {
                if (Math.abs(physics.velocityX) < walkStartSpeed)
                {
                    physics.velocityX = directionInput * walkStartSpeed;
                }

                if (Math.abs(physics.velocityX) < walkSpeed)
                {
                    physics.accelerationX = directionInput * walkAcceleration;
                }
                else
                {
                    physics.accelerationX = directionInput * runAcceleration;
                }

                // Skidding
                if (physics.grounded && ((physics.velocityX < 0 && directionInput > 0) || (physics.velocityX > 0 && directionInput < 0)))
                {
                    if (Math.abs(physics.velocityX) > skidThreshold)
                    {
                        physics.accelerationX = directionInput * runAcceleration * skidAccelerationMultiplier;

                        if (skidTimer <= 0)
                        {
                            skidTimer = skidTime;

                            FlxG.sound.play("data/sounds/skid.wav");
                        }
                    }
                    else
                    {
                        physics.accelerationX = directionInput * walkAcceleration * reverseAccelerationMultiplier;
                    }
                }
            }
            else
            {
                applyFriction();
            }
        }

        // Jump buffering and jumping
        if (FlxG.keys.anyJustPressed([SPACE]))
        {
            jumpBuffer = jumpBufferTime;
            jumpCutRequested = false;

            // if (!physics.grounded)
            // {
            //     rollJumpRequested = true;
            // }
        }

        if (FlxG.keys.anyJustReleased([SPACE]))
        {
            jumpCutRequested = true;
        }

        if (jumpBuffer > 0 && physics.grounded)
        {
            jumpBuffer = 0;
            // rollJumpRequested = false;

            if (backflipping && physics.grounded && ducking && backflipLandingTimer > 0 && backflipTimer > 0 && backflipDirection != 0 && rollJumpRequested)
            {
                backflipLandingTimer = 0;
                backflipping = true;

                physics.velocityY = duckJumpHeight;
                physics.velocityX = backflipSpeed * backflipDirection;
                physics.accelerationX = 0;
                physics.setGravityModifier(1);

                skidTimer = 0;

                FlxG.sound.play("data/sounds/jump.wav");
            }
            else if (!backflipping && physics.grounded && ducking && !rollJumpRequested)
            {
                var horizontalHeld =
                    FlxG.keys.anyPressed([LEFT, A, RIGHT, D]);

                if (Math.abs(physics.velocityX) > 0.001 || horizontalHeld)
                {
                    physics.velocityY = duckJumpHeight;
                    physics.setGravityModifier(1);

                    skidTimer = 0;

                    FlxG.sound.play("data/sounds/jump.wav");
                }
                else
                {
                    doBackflip();
                }
            }
            else if (!backflipping && physics.grounded && !ducking && !rollJumpRequested)
            {
                if (Math.abs(physics.velocityX) > walkSpeed)
                {
                    physics.velocityY = maxJumpHeight;
                }
                else
                {
                    physics.velocityY = minJumpHeight;
                }

                if (jumpCutRequested || !FlxG.keys.anyPressed([SPACE]))
                {
                    physics.setGravityModifier(jumpCancel);
                }
                else
                {
                    physics.setGravityModifier(1);
                }

                skidTimer = 0;
                FlxG.sound.play("data/sounds/jump.wav");
            }
        }

        // Variable jump height
        if (physics.velocityY < 0 && FlxG.keys.anyJustReleased([SPACE]) && !backflipping)
        {
            physics.setGravityModifier(jumpCancel);
        }

        if (physics.gravityModifier > 1 && physics.velocityY >= 0)
        {
            physics.setGravityModifier(1);
        }

        if (currentState != SMALL)
        {
            if (physics.grounded)
            {
                if (actualButtjump && !buttjumpBounced)
                {
                    actualButtjump = false;
                    buttjumpBounced = true;

                    physics.velocityY = duckJumpHeight;
                    physics.setGravityModifier(1);
                }
                else if (buttjumpBounced)
                {
                    fakeButtjump = false;
                    actualButtjump = false;
                    buttjumpBounced = false;

                    skidTimer = 0;

                    if (!backflipping && FlxG.keys.anyPressed([DOWN, S]))
                    {
                        setDucking(true);
                    }
                }

                if (!buttjumpBounced && !actualButtjump)
                {
                    if (!ducking && FlxG.keys.anyPressed([DOWN, S]))
                    {
                        setDucking(true);
                        stopBackflip();
                    }
                    else if (ducking && !FlxG.keys.anyPressed([DOWN, S]) && !backflipping)
                    {
                        setDucking(false);
                    }
                }
            }
            else if (!physics.grounded && !ducking && !backflipping)
            {
                if (!fakeButtjump && !actualButtjump && !buttjumpBounced)
                {
                    fakeButtjump = true;
                }

                if (fakeButtjump && !buttjumpBounced && physics.velocityY >= buttjumpMinVelocityY)
                {
                    actualButtjump = true;
                }
            }

            if (!FlxG.keys.anyPressed([DOWN, S]))
            {
                fakeButtjump = false;
                actualButtjump = false;
                buttjumpBounced = false;
            }
        }
        else
        {
            fakeButtjump = false;
            actualButtjump = false;
            buttjumpBounced = false;
            ducking = false;
            stopBackflip();
        }
    }

    function applyFriction()
    {
        if (physics.grounded && Math.abs(physics.velocityX) < walkStartSpeed)
        {
            physics.velocityX = 0;
            physics.accelerationX = 0;
            return;
        }

        if (physics.velocityX < 0)
        {
            physics.accelerationX = friction;
        }
        else if (physics.velocityX > 0)
        {
            physics.accelerationX = -friction;
        }
    }

    public function die()
    {
        if (Global.coins >= 25)
        {
            Global.coins -= 25;
        }
        
        FlxG.resetState();
    }

    public function takeDamage()
    {
        if (canTakeDamage)
        {
            canTakeDamage = false;
            FlxTween.flicker(this, invSeconds, 0.1, {type: ONESHOT});
            new FlxTimer().start(invSeconds, function(_)
            {
                canTakeDamage = true;
            }, 1);
            FlxG.sound.play("data/sounds/hurt.wav");
            
            if (currentState == FIRE)
            {
                currentState = BIG;
                reloadGraphics();
            }
            else if (currentState == BIG)
            {
                var prevBottom = y + height;
                currentState = SMALL;
                reloadGraphics();
                y = prevBottom - height;
            }
            else if (currentState == SMALL)
            {
                die();
            }
        }
    }

    public function bigTux()
    {
        if (currentState == SMALL)
        {
            var smallHeight = height;
            currentState = BIG;
            reloadGraphics();
            y -= height - smallHeight;
        }
    }

    public function smallTux()
    {
        if (currentState != SMALL)
        {
            var prevBottom = y + height;
            currentState = SMALL;
            reloadGraphics();
            y = prevBottom - height;
        }
    }

    public function fireTux()
    {
        if (currentState != SMALL)
        {
            currentState = FIRE;
            reloadGraphics();
        }
        else
        {
            var smallHeight = height;
            currentState = FIRE;
            reloadGraphics();
            y -= height - smallHeight;
        }
    }

    public function reloadGraphics()
    {
        animation.reset();

        switch(currentState)
        {
            case SMALL:
                loadGraphic("data/images/creatures/tux/small_tux.png", true, 49, 48);
                animation.add("stand", [0], 10.0, false);
                animation.add("walk", [1, 2, 3, 4, 5, 6, 7, 8], 15.0, true);
                animation.add("jump", [9], 10.0, false);
                animation.add("kick", [10], 10.0, false);
                animation.add("skid", [11], 10.0, false);
                setSize(30, 31);
                offset.set(9, 17);
            case BIG:
                loadGraphic("data/images/creatures/tux/big_tux.png", true, 64, 80);
                animation.add("stand", [0], 10.0, false);
                animation.add("walk", [1, 2, 3, 4, 5, 6], 15.0, true);
                animation.add("idle", [7, 8, 7], 5.0, false);
                animation.add("duck", [9], 10.0, false);
                animation.add("jump", [10], 10.0, false);
                animation.add("backflip", [11], 10.0, false);
                animation.add("buttjump", [12], 10.0, false);
                animation.add("kick", [13], 10.0, false);
                animation.add("skid", [14], 10.0, false);
                setSize(30, 60);
                offset.set(17, 20);
            case FIRE:
                loadGraphic("data/images/creatures/tux/fire_tux.png", true, 64, 80);
                animation.add("stand", [0], 10.0, false);
                animation.add("walk", [1, 2, 3, 4, 5, 6], 15.0, true);
                animation.add("idle", [7, 8, 7], 5.0, false);
                animation.add("duck", [9], 10.0, false);
                animation.add("jump", [10], 10.0, false);
                animation.add("backflip", [11], 10.0, false);
                animation.add("buttjump", [12], 10.0, false);
                animation.add("kick", [13], 10.0, false);
                animation.add("skid", [14], 10.0, false);
                setSize(30, 60);
                offset.set(17, 20);
        }
    }

    function setDucking(value:Bool):Bool
    {
        if (value == ducking)
        {
            return true;
        }

        if (value)
        {
            final oldHeight = height;

            setSize(30, 31);
            offset.set(17, 49);

            y += oldHeight - height;

            ducking = true;

            return true;
        }

        final oldHeight = height;
        final newHeight = 60.0;
        final standY = y - (newHeight - oldHeight);

        if (!Collision.canOccupy(this, Global.PS.solids, x, standY, 30, newHeight))
        {
            return false;
        }

        setSize(30, newHeight);
        offset.set(17, 20);
        y = standY;

        ducking = false;

        return true;
    }

    // Unfinished?
    function doBackflip()
    {
        if (!ducking || backflipping)
        {
            return;
        }

        // It's always the reverse of Tux's current direction
        backflipDirection = (direction == -1) ? 1 : -1;

        fakeButtjump = false;
        actualButtjump = false;

        backflipping = true;
        backflipTimer = backflipTime;
        backflipElapsed = 0;

        // No air flower yet...
        physics.velocityY = maxJumpHeight;

        // Reverse movement
        physics.velocityX = backflipSpeed * backflipDirection;
        physics.accelerationX = 0;

        physics.setGravityModifier(1);

        skidTimer = 0;

        FlxG.sound.play("data/sounds/flip.wav");
    }

    function stopBackflip()
    {
        if (backflipping)
        {
            backflipping = false;
            physics.velocityX = 0;
            angle = 0;
            backflipDirection = 0;
        }
    }
}