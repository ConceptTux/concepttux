# SuperTux Rebuilt
SuperTux Rebuilt is a fanmade attempt to "rebuild" SuperTux from the ground up with
a focus on simplicity and fun rather than complicated puzzles and mechanics.

Run and jump through multiple worlds, fighting enemies and collecting powerups on 
the way.

This is not an official SuperTux Team project.

## Goals
- [x] Go back to old versions of SuperTux to start again
- [ ] Entire engine remake using HaxeFlixel (Makes everything easier) 
- [ ] Mod support (Polymod)
- [ ] Replacement of Squirrel support with `hscript`
- [x] Tiled support (for levels)
- [ ] Removal of unnecessary tilesets
- [ ] Redesigning of low quality tilesets (Removal if necessary)
- [x] JSON support rather than .sprite
- [ ] Forest World redesign (based on 0.6.3's worldmap?)
- [ ] Turning SuperTux into a simple, fun platformer similar to Super Mario without complicated puzzles

## Building
> Tip: If you run into an error (or multiple), look at the workflow file for your platform before making an issue.

You need Haxe 4.3.7 with these libraries (Use `haxelib install (library)` for each one without the brackets):
- `flixel` (I recommend following the full HaxeFlixel installation guide)
- `flixel-addons`
- `lime` (HaxeFlixel dependency, automatically installed with installing `flixel`)
- `openfl` (HaxeFlixel dependency, automatically installed with installing `flixel`)
- `hxcpp` (HaxeFlixel dependency)

You also need Git.

After installing each library, run this command in the same directory as the Project.xml 
(root directory): `haxelib run lime test (platform) -debug` (If you set up Lime, you can 
omit `haxelib run`)

Your build should appear in `(projectfolder)/export/(platform)/bin`.

Supported platforms are:
- Windows
- Mac
- Linux
- HTML5 (Web)

Platforms such as Android or iOS might compile (keyword: "might") but it may have issues.

## Playing
### Arrow Keys
- Left = Tux moves left
- Right = Tux moves right
- Down = Tux ducks

### Other
- Space = Tux jumps
- Control = Tux does an action (Picks up object and/or throws fire) (When released, held object is placed / thrown)

### Debug
- One = Tux turns into Small Tux
- Two = Tux turns into Big Tux
- Three = Tux turns into Fire Tux
