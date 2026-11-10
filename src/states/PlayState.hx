package states;

import objects.FireFlower;
import objects.Bullet;
import misc.VPBSprite;
import objects.Egg;
import misc.PlayerStatus;
import badguys.Badguy;
import collision.OverlapUtil;
import objects.BlockArea;
import objects.Checkpoint;
import flixel.addons.editors.tiled.TiledTileLayer;
import collision.Collision;
import objects.Player;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import objects.Coin;
import objects.Goal;
import states.substates.IntroSubState;
import misc.STCamera;
import misc.STBackground;

class PlayState extends FlxState
{
	// The main tiles
	public var map:FlxTilemap;

	/* If you add another tileset before the main tileset, 
	   the main tileset will start with a different id */
	public var startingTile = 1;

	// Add things (Variables)
	public var player(default, null):Player;
	public var items(default, null):FlxTypedGroup<VPBSprite>;
	public var itemsFlxSprite(default, null):FlxTypedGroup<FlxSprite>;
	public var blocks(default, null):FlxTypedGroup<BlockArea>;
	public var badguys(default, null):FlxTypedGroup<Badguy>;
	public var bullets(default, null):FlxTypedGroup<Bullet>;
	
	/* If you're planning on adding more things (like enemies)
	   that can't go in the items group, add them to entities!
	   It will save you from having a headache when you start
	   to add enemies! :3 */
	var entities:FlxGroup;

	public var solids:FlxGroup;

	// TODO: Allow for more checkpoints
	public var checkpoint:Checkpoint;

	var levelCamera:STCamera;

	public var playerStatus:PlayerStatus;

	public var levelBackgrounds:Array<STBackground> = [];

	// Bullets
    public var activeBullets:Int = 0; // Don't change this!
    public var maximumBullets:Int = 0;

	override public function create()
	{
		super.create();

		// Just so Global.PS actually works...
		Global.PS = this;

		// Add things part 2
		entities = new FlxGroup();
		solids = new FlxGroup();
		player = new Player();
		items = new FlxTypedGroup<VPBSprite>();
		itemsFlxSprite = new FlxTypedGroup<FlxSprite>();
		bullets = new FlxTypedGroup<Bullet>();
		blocks = new FlxTypedGroup<BlockArea>();
		badguys = new FlxTypedGroup<Badguy>();
		playerStatus = new PlayerStatus();

		// The number of the level to load
		var numberOfLevel = Global.levels[Global.currentLevel];

		// Load the level
		LevelLoader.loadLevel(this, numberOfLevel);

		// Fixes overlapping somehow
		FlxG.worldBounds.set(0, 0, map.width, map.height);

		// Add things part 3
		entities.add(bullets);
		entities.add(items);
		entities.add(itemsFlxSprite);
		entities.add(badguys);
		add(solids);
		add(blocks);
		add(checkpoint);
		add(entities);
		add(player);

		// Add foreground tiles (I tried thinking of a better way to add this but I'm too tired)
		var foregroundLayer:TiledTileLayer = cast LevelLoader.tiledMap.getLayer("Foreground");
        
        var foregroundMap = new FlxTilemap();
        foregroundMap.loadMapFromArray(foregroundLayer.tileArray, LevelLoader.tiledMap.width, LevelLoader.tiledMap.height, "data/images/tiled/tiles.png", 32, 32, startingTile);
        foregroundMap.solid = false;

		add(foregroundMap);

		// Camera
		levelCamera = new STCamera();
		levelCamera.reset(player);

    	add(playerStatus);

		playerStatus.cameras = [FlxG.camera];
		playerStatus.scrollFactor.set(0, 0);

		openSubState(new IntroSubState(FlxColor.BLACK));
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		Collision.resolve(player, solids, player.physics, elapsed);

		// what the hell is all this
		// nvm it's because badguy.physics
		for (badguy in badguys.members)
		{
			if (badguy != null && badguy.exists)
			{
				Collision.resolve(badguy, solids, badguy.physics, elapsed);
			}
		}

		for (item in items.members)
		{
			if (item != null && item.exists)
			{
				Collision.resolve(item, solids, item.physics, elapsed);
			}
		}

		for (bullet in bullets.members)
		{
			if (bullet != null && bullet.exists)
			{
				Collision.resolve(bullet, solids, bullet.physics, elapsed);
			}
		}

		// Tux collision
		OverlapUtil.overlapOnce(entities, player, collideEntities);
		OverlapUtil.overlapOnce(checkpoint, player, collideEntities);
		OverlapUtil.overlapOnce(player, blocks, function(tux:Player, area:BlockArea)
		{
			if (area.direction == DOWN)
			{
				area.block.hit(player);
			}

			if (area.direction == UP && player.actualButtjump)
			{
				area.block.hit(player);
			}
		});

		FlxG.overlap(entities, badguys, function(entity:FlxSprite, badguy:Badguy) 
		{
			if (Std.isOfType(entity, Badguy))
			{
				badguy.collideOtherBadguy(cast entity);
			}

			if (Std.isOfType(entity, Bullet))
			{
				badguy.collideFireball(cast entity);
			}
		});

		// Update camera
		levelCamera.update(player, elapsed, map.width, map.height);

		// Update background(s)
		for (background in levelBackgrounds)
		{
			background.updateBackground(FlxG.camera.scroll.x, FlxG.camera.scroll.y, map.width, map.height);
		}
	}

	function collideEntities(entity:FlxSprite, player:Player)
	{
		if (Std.isOfType(entity, Coin))
		{
			(cast entity).collect();
		}
		if (Std.isOfType(entity, Egg) || Std.isOfType(entity, FireFlower))
		{
			(cast entity).collect(player);
		}

		if (Std.isOfType(entity, Goal))
		{
			(cast entity).reach(player);
		}

		if (Std.isOfType(entity, Checkpoint))
		{
			(cast entity).reach(player);
		}
		
		if (Std.isOfType(entity, Badguy))
		{
			(cast entity).interact(player);
		}
	}
}
