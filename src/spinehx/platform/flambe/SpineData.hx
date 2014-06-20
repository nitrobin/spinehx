package spinehx.platform.flambe;

import flambe.asset.AssetPack;
import spinehx.platform.flambe.*;
import spinehx.Skeleton;
import spinehx.SkeletonData;
import spinehx.SkeletonJson;

using flambe.util.Strings;

class SpineData 
{	

	/** The skeleton information */
	public var skeleton (default, null) :Skeleton;
	/** The atlas used for this skeleton. */
	public var atlas (default, null) :SpineTextureAtlas;

	public function new(pack :AssetPack, directory :String)
	{
		var aDirName :Array<String> = directory.split("/");
		var name :String = aDirName[aDirName.length-1];

		this.atlas = new SpineTextureAtlas(pack, name);

	    var json :SkeletonJson = SkeletonJson.create(new SpineTextureAtlas(pack, name));
        var data :SkeletonData = json.readSkeletonData(name, pack.getFile(name + "/" + name + ".json").toString());
        this.skeleton = Skeleton.create(data);
	}

}