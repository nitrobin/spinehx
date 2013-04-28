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


import spinehx.attachments.Attachment;
import spinehx.ex.IllegalArgumentException;
import Lambda;
using Lambda;

class Slot {
    public var  data:SlotData;
    public var  bone:Bone;
	private var  skeleton:Skeleton;
	public var color:Color;
    public var attachment:Attachment;
	private var attachmentTime:Float;

//	public function new () {
//		data = null;
//		bone = null;
//		skeleton = null;
//		color = new Color(1, 1, 1, 1);
//	}

	public function new (data:SlotData,  skeleton:Skeleton,  bone:Bone) {
		if (data == null) throw new IllegalArgumentException("data cannot be null.");
		if (skeleton == null) throw new IllegalArgumentException("skeleton cannot be null.");
		if (bone == null) throw new IllegalArgumentException("bone cannot be null.");
		this.data = data;
		this.skeleton = skeleton;
		this.bone = bone;
		color = new Color(1,1,1,1);
		setToBindPoseDefault();
	}

	/** Copy constructor. */
	public static function copy (slot:Slot, skeleton:Skeleton, bone:Bone):Slot {
		if (slot == null) throw new IllegalArgumentException("slot cannot be null.");
		if (skeleton == null) throw new IllegalArgumentException("skeleton cannot be null.");
		if (bone == null) throw new IllegalArgumentException("bone cannot be null.");
        var s = new Slot(slot.data, skeleton, bone);
		s.color = Color.copy(slot.color);
        s.attachment = slot.attachment;
        s.attachmentTime = slot.attachmentTime;
        return s;
	}

	public function getData ():SlotData {
		return data;
	}

	public function getSkeleton ():Skeleton {
		return skeleton;
	}

	public function getBone ():Bone {
		return bone;
	}

	public function getColor ():Color {
		return color;
	}

	/** @return May be null. */
	public function getAttachment ():Attachment {
		return attachment;
	}

	/** Sets the attachment and resets {@link #getAttachmentTime()}.
	 * @param attachment May be null. */
	public function setAttachment (attachment:Attachment) {
		this.attachment = attachment;
		attachmentTime = skeleton.time;
	}

	public function setAttachmentTime (time:Float) {
		attachmentTime = skeleton.time - time;
	}

	/** Returns the time since the attachment was set. */
	public function getAttachmentTime ():Float {
		return skeleton.time - attachmentTime;
	}

    public function setToBindPose (slotIndex:Int):Void {
		color.set2(data.color);
		setAttachment(data.attachmentName == null ? null : skeleton.getAttachment(slotIndex, data.attachmentName));
	}

	public function setToBindPoseDefault () {
		setToBindPose(skeleton.data.slots.indexOf(data/*, true*/));
	}

	public function toString ():String {
		return data.name;
	}
}
