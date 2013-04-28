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

import spinehx.ex.IllegalArgumentException;
class Bone {
    public var data:BoneData;
    public var parent:Bone;
    public var x:Float = 0;
    public var y:Float = 0;
    public var rotation:Float = 0;
    public var scaleX:Float = 0;
    public var scaleY:Float = 0;

    public var m00:Float = 0;public var m01:Float = 0;public var worldX:Float = 0; // a b x
    public var m10:Float = 0;public var m11:Float = 0;public var worldY:Float = 0; // c d y
    public var worldRotation:Float = 0;
    public var worldScaleX:Float = 0;
    public var worldScaleY:Float = 0;

	/** @param parent May be null. */
	public function new(data:BoneData, parent:Bone) {
		if (data == null) throw new IllegalArgumentException("data cannot be null.");
		this.data = data;
		this.parent = parent;
		setToBindPose();
	}

	/** Copy constructor.
	 * @param parent May be null. */
	public static function copy (bone:Bone, parent:Bone):Bone {
		if (bone == null) throw new IllegalArgumentException("bone cannot be null.");
		var b = new Bone(bone.data, parent);
		b.x = bone.x;
        b.y = bone.y;
        b.rotation = bone.rotation;
        b.scaleX = bone.scaleX;
        b.scaleY = bone.scaleY;
        return b;
	}

	/** Computes the world SRT using the parent bone and the local SRT. */
	public function updateWorldTransform (flipX:Bool, flipY:Bool):Void {
		var parent:Bone = this.parent;
		if (parent != null) {
			worldX = x * parent.m00 + y * parent.m01 + parent.worldX;
			worldY = x * parent.m10 + y * parent.m11 + parent.worldY;
			worldScaleX = parent.worldScaleX * scaleX;
			worldScaleY = parent.worldScaleY * scaleY;
			worldRotation = parent.worldRotation + rotation;
		} else {
			worldX = x;
			worldY = y;
			worldScaleX = scaleX;
			worldScaleY = scaleY;
			worldRotation = rotation;
		}
        var radians:Float = worldRotation * Math.PI / 180;

        var cos:Float = Math.cos(radians);
		var sin:Float = Math.sin(radians);
		m00 = cos * worldScaleX;
		m10 = sin * worldScaleX;
		m01 = -sin * worldScaleY;
		m11 = cos * worldScaleY;
		if (flipX) {
			m00 = -m00;
			m01 = -m01;
		}
		if (flipY) {
			m10 = -m10;
			m11 = -m11;
		}
	}

	public function setToBindPose ():Void {
		var data:BoneData = this.data;
		x = data.x;
		y = data.y;
		rotation = data.rotation;
		scaleX = data.scaleX;
		scaleY = data.scaleY;
	}

	public function getData ():BoneData {
		return data;
	}

	public function getParent ():Bone {
		return parent;
	}

	public function getX ():Float {
		return x;
	}

	public function setX (x:Float):Void {
		this.x = x;
	}

	public function getY ():Float {
		return y;
	}

	public function setY (y:Float):Void {
		this.y = y;
	}

	public function getRotation ():Float {
		return rotation;
	}

	public function setRotation (rotation:Float):Void {
		this.rotation = rotation;
	}

	public function getScaleX ():Float {
		return scaleX;
	}

	public function setScaleX (scaleX:Float):Void {
		this.scaleX = scaleX;
	}

	public function getScaleY ():Float {
		return scaleY;
	}

	public function setScaleY (scaleY:Float):Void {
		this.scaleY = scaleY;
	}

	public function getM00 ():Float {
		return m00;
	}

	public function getM01 ():Float {
		return m01;
	}

	public function getM10 ():Float {
		return m10;
	}

	public function getM11 ():Float {
		return m11;
	}

	public function getWorldX ():Float {
		return worldX;
	}

	public function getWorldY ():Float {
		return worldY;
	}

	public function getWorldRotation ():Float {
		return worldRotation;
	}

	public function getWorldScaleX ():Float {
		return worldScaleX;
	}

	public function getWorldScaleY ():Float {
		return worldScaleY;
	}

//	public Matrix3 getWorldTransform (Matrix3 worldTransform) {
//		if (worldTransform == null) throw new IllegalArgumentException("worldTransform cannot be null.");
//		float[] val = worldTransform.val;
//		val[M00] = m00;
//		val[M01] = m01;
//		val[M02] = worldX;
//		val[M10] = m10;
//		val[M11] = m11;
//		val[M12] = worldY;
//		val[M20] = 0;
//		val[M21] = 0;
//		val[M22] = 1;
//		return worldTransform;
//	}

	public function toString ():String {
		return data.name;
	}
}
