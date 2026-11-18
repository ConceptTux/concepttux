//  SuperTux Rebuilt
//  Copyright (C) 2026 AnatolyStev
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

package misc;

import flixel.util.FlxTimer;
import flixel.FlxG;
import hscript.Interp;
import hscript.Parser;

class LevelScript
{
    public var parser:Parser;
    public var interp:Interp;
    
    public function new()
    {
        parser = new Parser();
        parser.allowTypes = true;
        interp = new Interp();

        exposeObjects();
    }

    function exposeObjects()
    {
        // Exposing FlxG and Global maybe isn't the best idea... whatever!
        interp.variables.set("FlxG", FlxG);
        interp.variables.set("Global", Global);
        interp.variables.set("Level", Global.PS);
        interp.variables.set("Tux", Global.PS.player);

        interp.variables.set("wait", function(seconds:Float, callback:Void->Void)
        {
            new FlxTimer().start(seconds, function(_)
            {
                if (callback != null)
                {
                    callback();
                }
            });
        });
    }

    public function runCode(code:String)
    {
        if (code == null || StringTools.trim(code) == "")
        {
            return;
        }

        try
        {
            interp.execute(parser.parseString(code));
        }
        catch (e:Dynamic)
        {
            trace("Error!" + e);
        }
    }
}