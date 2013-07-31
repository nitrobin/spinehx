package spinehx.platform.flambe;

import flambe.asset.AssetPack;

using flambe.util.Strings;

class SpineTexture implements spinehx.atlas.Texture {
    
    public var texture(default, null) :flambe.display.Texture;

    public function new(pack :AssetPack, file :String) {
        texture = pack.getTexture(file.removeFileExtension());
    }

    public function getWidth() :Int {
        return texture.width;
    }

    public function getHeight() :Int {
        return texture.height;
    }

    public function dispose() :Void {
    	texture.dispose();
    }

    public function setWrap(uWrap, vWrap) :Void {}

    public function setFilter(minFilter, magFilter) :Void {}
}
