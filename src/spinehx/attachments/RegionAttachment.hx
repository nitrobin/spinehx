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

package spinehx.attachments;
import spinehx.atlas.TextureRegion;
import spinehx.ex.IllegalArgumentException;
import spinehx.ex.IllegalStateException;
import spinehx.atlas.TextureAtlas;
import spinehx.Arrays;

class RegionAttachment extends Attachment {
    public static inline var X1 = 0;
    public static inline var Y1 = 1;
    public static inline var C1 = 2;
    public static inline var U1 = 3;
    public static inline var V1 = 4;
    public static inline var X2 = 5;
    public static inline var Y2 = 6;
    public static inline var C2 = 7;
    public static inline var U2 = 8;
    public static inline var V2 = 9;
    public static inline var X3 = 10;
    public static inline var Y3 = 11;
    public static inline var C3 = 12;
    public static inline var U3 = 13;
    public static inline var V3 = 14;
    public static inline var X4 = 15;
    public static inline var Y4 = 16;
    public static inline var C4 = 17;
    public static inline var U4 = 18;
    public static inline var V4 = 19;

    public var region:TextureRegion;
    public var x:Float = 0;
    public var y:Float = 0;
    public var scaleX:Float = 0;
    public var scaleY:Float = 0;
    public var rotation:Float = 0;
    public var width:Float = 0;
    public var height:Float = 0;
    public var vertices:Array<Float>;
    public var offset:Array<Float>;

	public function new (name:String) {
		super(name);
        vertices = Arrays.allocFloat(20);
        offset = Arrays.allocFloat(8);
	}

	public function updateOffset ():Void {
		var width:Float = getWidth();
		var height:Float = getHeight();
		var localX2:Float = width / 2;
		var localY2:Float = height / 2;
		var localX:Float = -localX2;
		var localY:Float = -localY2;
		if (Std.is(region, AtlasRegion)) {
			var region:AtlasRegion = cast(this.region, AtlasRegion);
			if (region.rotate) {
				localX += region.offsetX / region.originalWidth * height;
				localY += region.offsetY / region.originalHeight * width;
				localX2 -= (region.originalWidth - region.offsetX - region.packedHeight) / region.originalWidth * width;
				localY2 -= (region.originalHeight - region.offsetY - region.packedWidth) / region.originalHeight * height;
			} else {
                localX += region.offsetX / region.originalWidth * width;
				localY += region.offsetY / region.originalHeight * height;
				localX2 -= (region.originalWidth - region.offsetX - region.packedWidth) / region.originalWidth * width;
				localY2 -= (region.originalHeight - region.offsetY - region.packedHeight) / region.originalHeight * height;
            }
        }
		var scaleX:Float = getScaleX();
		var scaleY:Float = getScaleY();
		localX *= scaleX;
		localY *= scaleY;
		localX2 *= scaleX;
		localY2 *= scaleY;
		var rotation:Float = MathUtils.degToRad(getRotation());
		var cos:Float = Math.cos(rotation);
		var sin:Float = Math.sin(rotation);
		var x:Float = getX();
		var y:Float = getY();
		var localXCos:Float = localX * cos + x;
		var localXSin:Float = localX * sin;
		var localYCos:Float = localY * cos + y;
		var localYSin:Float = localY * sin;
		var localX2Cos:Float = localX2 * cos + x;
		var localX2Sin:Float = localX2 * sin;
		var localY2Cos:Float = localY2 * cos + y;
		var localY2Sin:Float = localY2 * sin;
		var offset:Array<Float> = this.offset;
		offset[0] = localXCos - localYSin;
		offset[1] = localYCos + localXSin;
		offset[2] = localXCos - localY2Sin;
		offset[3] = localY2Cos + localXSin;
		offset[4] = localX2Cos - localY2Sin;
		offset[5] = localY2Cos + localX2Sin;
		offset[6] = localX2Cos - localYSin;
		offset[7] = localYCos + localX2Sin;
	}

	public function setRegion (region:TextureRegion):Void {
		if (region == null) throw new IllegalArgumentException("region cannot be null.");
		var oldRegion:TextureRegion = this.region;
		this.region = region;
		var vertices:Array<Float> = this.vertices;
		if (Std.is(region, AtlasRegion) && (cast(region,AtlasRegion)).rotate) {
			vertices[U2] = region.getU();
			vertices[V2] = region.getV2();
			vertices[U3] = region.getU();
			vertices[V3] = region.getV();
			vertices[U4] = region.getU2();
			vertices[V4] = region.getV();
			vertices[U1] = region.getU2();
			vertices[V1] = region.getV2();
		} else {
			vertices[U1] = region.getU();
			vertices[V1] = region.getV2();
			vertices[U2] = region.getU();
			vertices[V2] = region.getV();
			vertices[U3] = region.getU2();
			vertices[V3] = region.getV();
			vertices[U4] = region.getU2();
			vertices[V4] = region.getV2();
		}
		updateOffset();
	}

	public function getRegion ():TextureRegion {
		if (region == null) throw new IllegalStateException("Region has not been set: " + this);
		return region;
	}

	public function updateVertices (slot:Slot):Void {
		var skeletonColor:Color = slot.getSkeleton().getColor();
		var slotColor:Color = slot.getColor();
		var color:Float = NumberUtils.intToFloatColor( //
			(Math.floor(255 * skeletonColor.a * slotColor.a) << 24) //
				| (Math.floor(255 * skeletonColor.b * slotColor.b) << 16) //
				| (Math.floor(255 * skeletonColor.g * slotColor.g) << 8) //
				| (Math.floor(255 * skeletonColor.r * slotColor.r)));
		var vertices:Array<Float> = this.vertices;
		vertices[C1] = color;
		vertices[C2] = color;
		vertices[C3] = color;
		vertices[C4] = color;

		var offset:Array<Float> = this.offset;
		var bone:Bone = slot.getBone();
		var x:Float = bone.getWorldX();
		var y:Float = bone.getWorldY();
		var m00:Float = bone.getM00();
		var m01:Float = bone.getM01();
		var m10:Float = bone.getM10();
		var m11:Float = bone.getM11();
		vertices[X1] = offset[0] * m00 + offset[1] * m01 + x;
		vertices[Y1] = offset[0] * m10 + offset[1] * m11 + y;
		vertices[X2] = offset[2] * m00 + offset[3] * m01 + x;
		vertices[Y2] = offset[2] * m10 + offset[3] * m11 + y;
		vertices[X3] = offset[4] * m00 + offset[5] * m01 + x;
		vertices[Y3] = offset[4] * m10 + offset[5] * m11 + y;
		vertices[X4] = offset[6] * m00 + offset[7] * m01 + x;
		vertices[Y4] = offset[6] * m10 + offset[7] * m11 + y;
	}

	public function getVertices ():Array<Float> {
		return vertices;
	}

	public function getX ():Float {
		return x;
	}

	public function setX (x:Float) {
		this.x = x;
	}

	public function getY ():Float {
		return y;
	}

	public function setY (y:Float) {
		this.y = y;
	}

	public function getScaleX ():Float {
		return scaleX;
	}

	public function setScaleX (scaleX:Float) {
		this.scaleX = scaleX;
	}

	public function getScaleY ():Float {
		return scaleY;
	}

	public function setScaleY (scaleY:Float) {
		this.scaleY = scaleY;
	}

	public function getRotation ():Float {
		return rotation;
	}

	public function setRotation (rotation:Float) {
		this.rotation = rotation;
	}

	public function getWidth ():Float {
		return width;
	}

	public function setWidth (width:Float) {
		this.width = width;
	}

	public function getHeight ():Float {
		return height;
	}

	public function setHeight (height:Float) {
		this.height = height;
	}

}

class NumberUtils {
    public static function intToFloatColor(value:Int):Float {
        return value;//TODO
    }
}

