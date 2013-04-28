package spinehx;
class Arrays {
    public function new() {
    }

    public static function allocFloat(n:Int):Array<Float> {
        var a = new Array<Float>();
        a[n-1] = 0;
        for (i in 0...n) {
            a[i] = 0;
        }
        return a;
    }

    public static function alloc <T>(n:Int, value:T):Array<T> {
        var a = new Array<T>();
        a[n-1] = value;
        for (i in 0...n) {
            a[i] = value;
        }
        return a;
    }

}
