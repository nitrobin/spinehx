package spinehx;
class Maps {
    public function new() {
    }
}

#if haxe3
typedef StringMap<T> = Map<String, T>;
#else
typedef StringMap<T> = Hash<T>;
#end