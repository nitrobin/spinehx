package spinehx;
import haxe.Json;
import Reflect;

typedef JsonNode = Dynamic;


class JsonUtils {
    public static function parse(data:String):JsonNode {
        return cast Json.parse(data);
    }

    public static function fields(node:JsonNode):Array<String> {
        return Reflect.fields(node);
    }

    public static function getNode(node:JsonNode, field:String):JsonNode {
        return cast Reflect.getProperty(node, field);
    }

    public static function getDynamic(node:JsonNode, field:String):Dynamic {
        return Reflect.getProperty(node, field);
    }

    public static function getNodesArray(node:JsonNode, field:String):Array<JsonNode> {
        return cast(Reflect.getProperty(node, field), Array<JsonNode>);
    }

    public static function getInt(node:JsonNode, field:String):Int {
        return cast Reflect.getProperty(node, field);
    }
    public static function getFlt(node:JsonNode, field:String):Float {
        return cast Reflect.getProperty(node, field);
    }
    public static function getStr(node:JsonNode, field:String):String {
        return cast Reflect.getProperty(node, field);
    }
    public static function getBool(node:JsonNode, field:String, defaultValue:Bool = false):Bool {
        var value = Reflect.getProperty(node, field);
        if(value == null){
           return defaultValue;
        }
        return cast value;
    }
}
