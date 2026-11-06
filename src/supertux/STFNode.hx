package supertux;

class STFNode
{
    public var name:String;
    public var values:Array<String>;
    public var children:Array<STFNode>;

    public function new(name:String)
    {
        this.name = name;
        this.values = [];
        this.children = [];
    }

    public static function parse(text:String):STFNode
    {
        var parser = new STFNodeParser(text);
        return parser.parse();
    }

    public function getString(name:String, defaultValue:String = null):String
    {
        for (child in children)
        {
            if (child.name == name && child.values.length > 0)
            {
                return child.values[0];
            }
        }

        return defaultValue;
    }

    public function getStrings(name:String):Array<String>
    {
        for (child in children)
        {
            if (child.name == name)
            {
                return child.values;
            }
        }

        return [];
    }

    public function getInt(name:String, defaultValue:Int = 0):Int
    {
        var value = getString(name);

        if (value == null)
        {
            return defaultValue;
        }

        return Std.parseInt(value);
    }

    public function getBool(name:String, defaultValue:Bool = false):Bool
    {
        var value = getString(name);

        if (value == null)
        {
            return defaultValue;
        }

        return value == "#t" || value == "true" || value == "1";
    }

    public function getChild(name:String):STFNode
    {
        for (child in children)
        {
            if (child.name == name)
            {
                return child;
            }
        }

        return null;
    }
}

private class STFNodeParser
{
    private var text:String;
    private var position:Int = 0;

    public function new(text:String)
    {
        this.text = text;
    }

    public function parse():STFNode
    {
        skipWhitespace();

        if (peek() != "(")
        {
            trace("STF file must begin with '('!");
        }

        return parseNode();
    }

    private function parseNode():STFNode
    {
        expect("(");
        skipWhitespace();

        var name = readToken();
        var node = new STFNode(name);

        while (true)
        {
            skipWhitespace();

            if (position >= text.length)
            {
                trace("Unexpected end of STF file!");
            }

            if (peek() == ")")
            {
                position += 1;
                break;
            }

            if (peek() == "(")
            {
                node.children.push(parseNode());
            }
            else
            {
                node.values.push(readValue());
            }
        }

        return node;
    }

    private function readValue():String
    {
        if (peek() == "\"")
        {
            return readString();
        }

        return readToken();
    }

    private function readString():String
    {
        position += 1;

        var result = new StringBuf();

        while (position < text.length)
        {
            var c = text.charAt(position);

            position += 1;

            if (c == "\"")
            {
                return result.toString();
            }

            if (c == "\\")
            {
                if (position >= text.length)
                {
                    break;
                }

                var escaped = text.charAt(position);

                position += 1;

                switch (escaped)
                {
                    case "n":
                        result.add("\n");
                    case "r":
                        result.add("\r");
                    case "t":
                        result.add("\t");
                    case "\"":
                        result.add("\"");
                    case "\\":
                        result.add("\\");
                    default:
                        result.add(escaped);
                }
            }
            else
            {
                result.add(c);
            }
        }

        throw "Unterminated STF string!"; // get out of here with that unterminated stf string
    }

    private function readToken():String
    {
        var start = position;

        while (position < text.length)
        {
            var c = text.charAt(position);

            if (c == "(" || c == ")" || c == " " || c == "\t" || c == "\n" || c == "\r")
            {
                break;
            }

            position += 1;
        }

        return text.substring(start, position);
    }

    private function skipWhitespace()
    {
        while (position < text.length)
        {
            var c = text.charAt(position);

            if (c == " " || c == "\t" || c == "\n" || c == "\r")
            {
                position += 1;
                
                continue;
            }

            if (c == ";")
            {
                while (position < text.length && text.charAt(position) != "\n")
                {
                    position += 1;
                }

                continue;
            }

            break;
        }
    }

    private function peek():String
    {
        if (position >= text.length)
        {
            return "";
        }

        return text.charAt(position);
    }

    private function expect(value:String)
    {
        if (peek() != value)
        {
            throw "no";
        }

        position += 1;
    }
}