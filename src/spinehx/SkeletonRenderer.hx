/*******************************************************************************
 * Copyright (c) 2013, Esoteric Software
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************/

package spinehx;

import flash.display.Sprite;
import spinehx.atlas.TextureAtlas.AtlasRegion;
import spinehx.atlas.TextureRegion;
import spinehx.atlas.Texture;
import spinehx.attachments.Attachment;
import spinehx.attachments.RegionAttachment;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.TriangleCulling;
import flash.geom.Rectangle;
import flash.geom.Point;
import haxe.ds.ObjectMap;

class SkeletonRenderer extends Sprite {
    var skeleton:Skeleton;

    #if (flash || cpp)
    var vs:nme.Vector<Float>;
    var idx:nme.Vector<Int>;
    var uvt:nme.Vector<Float>;
    var bd:nme.display.BitmapData;
    var filled:Bool = false;

    public function new (skeleton:Skeleton) {
       super();
       this.skeleton = skeleton;
        vs = nme.Vector.fromArray([0.0]);
        idx = nme.Vector.fromArray([0]);
        uvt = nme.Vector.fromArray([0.0]);
//        vs = new nme.Vector<Float>();
//        idx = new nme.Vector<Int>();
//        uvt = new nme.Vector<Float>();
    }

    public function clearBuffers () {
        // TODO remove this dirty hack
        vs = nme.Vector.fromArray([0.0]);
        idx = nme.Vector.fromArray([0]);
        uvt = nme.Vector.fromArray([0.0]);
        filled = false;
    }

    public function draw () {
        var vi:Int = 0;
        var vii:Int = 0;
        var ii:Int = 0;
        graphics.clear();
        var drawOrder:Array<Slot> = skeleton.drawOrder;
        for (slot in drawOrder) {
            var attachment:Attachment = slot.attachment;
            if (Std.is(attachment, RegionAttachment)) {
                var regionAttachment:RegionAttachment = cast(attachment, RegionAttachment);
                regionAttachment.updateVertices(slot);
                var vertices:Array<Float> = regionAttachment.getVertices();
                var region:TextureRegion = regionAttachment.getRegion();
                var texture:Texture = region.getTexture();
                if(bd == null){
                    bd = texture.bd;
                } else if(bd!=texture.bd){
                    throw ("Too many textures");
                    continue;
                }

                vs[vi+0] = vertices[RegionAttachment.X1]; vs[vi+1] = vertices[RegionAttachment.Y1];
                vs[vi+2] = vertices[RegionAttachment.X2]; vs[vi+3] = vertices[RegionAttachment.Y2];
                vs[vi+4] = vertices[RegionAttachment.X3]; vs[vi+5] = vertices[RegionAttachment.Y3];
                vs[vi+6] = vertices[RegionAttachment.X4]; vs[vi+7] = vertices[RegionAttachment.Y4];

                if(!filled){
                    idx[ii+0] = vii+0; idx[ii+1] = vii+1; idx[ii+2] = vii+2;
                    idx[ii+3] = vii+2; idx[ii+4] = vii+3; idx[ii+5] = vii+0;

                    uvt[vi+0] = vertices[RegionAttachment.U1]; uvt[vi+1] = vertices[RegionAttachment.V1];
                    uvt[vi+2] = vertices[RegionAttachment.U2]; uvt[vi+3] = vertices[RegionAttachment.V2];
                    uvt[vi+4] = vertices[RegionAttachment.U3]; uvt[vi+5] = vertices[RegionAttachment.V3];
                    uvt[vi+6] = vertices[RegionAttachment.U4]; uvt[vi+7] = vertices[RegionAttachment.V4];
                }
                vi += 8;
                vii += 4;
                ii += 6;
            }
        }
        filled = true;
        if(bd != null){
            graphics.beginBitmapFill(bd, null, true, true);
            graphics.drawTriangles(vs, idx, uvt, TriangleCulling.NONE);
            graphics.endFill();
        }
     }

    #else

    public var sprites:ObjectMap<RegionAttachment, Sprite> ;

    public function new (skeleton:Skeleton) {
        super();
        this.skeleton = skeleton;
        sprites = new ObjectMap<RegionAttachment, Sprite>();
    }

    public function draw () {
        graphics.clear();
		var drawOrder:Array<Slot> = skeleton.drawOrder;
		for (slot in drawOrder) {
			var attachment:Attachment = slot.attachment;
			if (Std.is(attachment, RegionAttachment)) {
				var regionAttachment:RegionAttachment = cast(attachment, RegionAttachment);
				regionAttachment.updateVertices(slot);
				var vertices:Array<Float> = regionAttachment.getVertices();

                var sprite:Sprite = get(regionAttachment);
                var bone:Bone = slot.getBone();

                var x1 = vertices[RegionAttachment.X1];
                var y1 = vertices[RegionAttachment.Y1];
                var x2 = vertices[RegionAttachment.X2];
                var y2 = vertices[RegionAttachment.Y2];
                // TODO optimize
                sprite.x = x1;
                sprite.y = y1;
                sprite.rotation = Math.atan2(y2-y1, x2-x1) * 180 / Math.PI+90;
            }
		}
	}

    public function get (regionAttachment:RegionAttachment):Sprite {
        var sprite:Sprite = sprites.get(regionAttachment);
        if(sprite == null){
            var region:TextureRegion = regionAttachment.getRegion();
            var texture:Texture = region.getTexture();
            sprite = new Sprite();
            var w:Int = region.getRegionWidth();
            var h:Int = region.getRegionHeight();
            var bd = new BitmapData(w, h);
            bd.copyPixels(texture.bd,
            new Rectangle(region.getRegionX(),region.getRegionY(),w, h), new Point(0,0));
            var bmp = new Bitmap(bd);
            bmp.y = -bd.height;
            bmp.smoothing = true;
            sprite.addChild(bmp);

            addChild(sprite);
            sprites.set(regionAttachment, sprite);
        }
        return sprite;
    }
    #end
}
