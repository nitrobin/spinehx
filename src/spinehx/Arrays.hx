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

}
