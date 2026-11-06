package objects;

import flixel.FlxObject;

enum BlockAreaDirections
{
    LEFT;
    DOWN;
    UP;
    RIGHT;
}

class BlockArea extends FlxObject
{
    public var block:Block;
    public var direction:BlockAreaDirections;

    public function new(block:Block, p_direction:BlockAreaDirections)
    {
        this.block = block;
        this.direction = p_direction; // i wish i did the direction in the new function earlier instead of a separate variable... fix later!
        
        if (direction == LEFT)
        {
            super(block.x - 1, block.y, 1, 32);
        }
        else if (direction == RIGHT)
        {
            super(block.x + 32, block.y, 1, 32);
        }
        else if (direction == UP)
        {
            super(block.x, block.y - 1, 32, 1);
        }
        else if (direction == DOWN)
        {
            super(block.x, block.y + 32, 32, 1);
        }
        else
        {
            trace("Unsupported direction :(");
        }
    }
}