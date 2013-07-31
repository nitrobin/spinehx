package spinehx.platform.flambe;

import flambe.asset.AssetPack;
import spinehx.atlas.Texture;
import spinehx.atlas.TextureLoader;
import spinehx.platform.flambe.SpineTexture;

class SpineTextureLoader implements TextureLoader {

	/** The asset pack to draw textures from. */
	public var pack (default, null) :AssetPack;

    public function new(pack :AssetPack)
    {
    	this.pack = pack;
    }

    public function loadTexture(textureFile :String, format, useMipMaps) :Texture
    {
         return new SpineTexture(pack, textureFile);
    }
}
