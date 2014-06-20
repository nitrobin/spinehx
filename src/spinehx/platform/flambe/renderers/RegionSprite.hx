//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package spinehx.platform.flambe.renderers;

import flambe.display.Graphics;
import flambe.display.Sprite;
import flambe.display.Texture;
import spinehx.atlas.TextureRegion;
import spinehx.attachments.RegionAttachment;
import spinehx.atlas.TextureAtlas;

/**
 * An instanced Flump atlased texture.
 */
class RegionSprite extends Sprite
{
    /** The region attachment for this sprite */
    public var regionAttachment (default, null):RegionAttachment;
    /** The texture to use for rendering. */
    public var region(default, null) :AtlasRegion;
    /** The atlas to draw from. */
    public var atlas(default, null) :Texture;

    public function new (regionAttachment :RegionAttachment)
    {
        super();
        this.regionAttachment = regionAttachment;
        this.region = cast regionAttachment.getRegion();
        this.atlas = cast(region.getTexture(), SpineTexture).texture;

        this.anchorX._ = regionAttachment.width / 2;
        this.anchorY._ = regionAttachment.height / 2;

        if (region.rotate) {
            _w = region.getRegionHeight(); // Swap width and height if rotated texture.
            _h = region.getRegionWidth();
            rotation._ = 90;
            this.anchorX._ += region.getRegionWidth();
        } else {
            _w = region.getRegionWidth();
            _h = region.getRegionHeight();
        }
    }

    override public function draw (g :Graphics)
    {
        g.drawSubImage(atlas, 0, 0, region.getRegionX(), region.getRegionY(), _w, _h);
    }

    override public function getNaturalWidth () :Float
    {
        return region.getRegionWidth();
    }

    override public function getNaturalHeight () :Float
    {
        return region.getRegionHeight();
    }

    /** The real width of this region */
    private var _w :Float = 0;
    /** The real height of this region */
    private var _h :Float = 0;

}
