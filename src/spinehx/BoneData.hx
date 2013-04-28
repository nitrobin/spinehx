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
class BoneData {
    public var parent:BoneData;
    public var name:String;
    public var length:Float = 0;
    public var x:Float = 0;
    public var y:Float = 0;
    public var rotation:Float = 0;
    public var scaleX:Float = 1;
    public var scaleY:Float = 1;

	/** @param parent May be null. */
	public function new (name:String, parent:BoneData) {
		if (name == null) throw new IllegalArgumentException("name cannot be null.");
		this.name = name;
		this.parent = parent;
	}

	/** Copy constructor.
	 * @param parent May be null. */
	public static function copy (bone:BoneData, parent:BoneData=null):BoneData {
		if (bone == null) throw new IllegalArgumentException("bone cannot be null.");
		var b = new BoneData(bone.name, parent);
		b.length = bone.length;
		b.x = bone.x;
		b.y = bone.y;
		b.rotation = bone.rotation;
		b.scaleX = bone.scaleX;
		b.scaleY = bone.scaleY;
        return b;
	}

	/** @return May be null. */
	public function getParent ():BoneData {
		return parent;
	}

	public function getName ():String {
		return name;
	}

	public function getLength ():Float {
		return length;
	}

	public function setLength (length:Float):Void {
		this.length = length;
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

	public function toString ():String {
		return name;
	}
}
