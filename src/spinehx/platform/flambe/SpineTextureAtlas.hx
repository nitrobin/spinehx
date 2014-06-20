
package spinehx.platform.flambe;

import flambe.asset.AssetPack;
import spinehx.atlas.TextureAtlas;
import spinehx.platform.flambe.SpineTextureLoader;


class SpineTextureAtlas extends TextureAtlas
{
	public function new(pack :AssetPack, directory :String)
	{
        // var atlas:TextureAtlas = TextureAtlas.create(nme.Assets.getText("assets/" + name + ".atlas"), "assets/", new BitmapDataTextureLoader());
		var aDirName :Array<String> = directory.split("/");
		var definition :String = pack.getFile(directory + "/" + aDirName[aDirName.length-1] + ".atlas").toString();

		super(new TextureAtlasData(definition, directory + "/", false), new SpineTextureLoader(pack) );
		
	}
}