package spinehx;
class GUID {
    private static var id:Int = 0;

    public static function nextId():Int {
        return id++;
    }
}
