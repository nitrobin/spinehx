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
class SlotData {
	public var name:String;
    public var boneData:BoneData;
    public var color:Color;
    public var attachmentName:String;

//    public function new () {
//    color = new Color(1, 1, 1, 1);
//		name = null;
//		boneData = null;
//	}

	public function new(name:String, boneData:BoneData ) {
        color = new Color(1, 1, 1, 1);
		if (name == null) throw new IllegalArgumentException("name cannot be null.");
		if (boneData == null) throw new IllegalArgumentException("boneData cannot be null.");
		this.name = name;
		this.boneData = boneData;
	}

	public function getName ():String {
		return name;
	}

	public function getBoneData ():BoneData {
		return boneData;
	}

	public function getColor ():Color {
		return color;
	}

	/** @param attachmentName May be null. */
	public function setAttachmentName (attachmentName:String):Void {
		this.attachmentName = attachmentName;
	}

	/** @return May be null. */
	public function getAttachmentName ():String {
		return attachmentName;
	}

	public function toString ():String {
		return name;
	}
}
