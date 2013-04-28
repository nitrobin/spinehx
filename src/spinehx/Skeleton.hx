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

class Skeleton {
    public var data:SkeletonData;
    public var bones:Array<Bone>;
	public var slots:Array<Slot>;
    public var drawOrder:Array<Slot>;
    public var skin:Skin;
    public var color:Color;
    public var time:Float = 0;
    public var flipX:Bool;
    public var flipY:Bool;

	function new () {
        bones = new Array<Bone>();
        slots = new Array<Slot>();
        drawOrder = new Array<Slot>();
        color = new Color(1, 1, 1, 1);
    }

	public static function create (data:SkeletonData):Skeleton {
		if (data == null) throw new IllegalArgumentException("data cannot be null.");
		var s = new Skeleton();
        s.data = data;

		for (boneData in data.bones) {
			var parent:Bone = boneData.parent == null ? null : s.bones[data.bones.indexOf(boneData.parent/*, true*/)];
			s.bones.push(new Bone(boneData, parent));
		}

		for (slotData in data.slots) {
			var bone:Bone = s.bones[data.bones.indexOf(slotData.boneData/*, true*/)];
			var slot = new Slot(slotData, s, bone);
            s.slots.push(slot);
            s.drawOrder.push(slot);
		}
        return s;
	}

	/** Copy constructor. */
	public static function copy (skeleton:Skeleton) {
		if (skeleton == null) throw new IllegalArgumentException("skeleton cannot be null.");
        var s = new Skeleton();
		s.data = skeleton.data;

		for (bone in skeleton.bones) {
			var parent:Bone = bone.parent == null ? null : s.bones[skeleton.bones.indexOf(bone.parent/*, true*/)];
			s.bones.push(Bone.copy(bone, parent));
		}

		for (slot in skeleton.slots) {
			var bone:Bone = s.bones[skeleton.bones.indexOf(slot.bone/*, true*/)];
			var newSlot = Slot.copy(slot, s, bone);
			s.slots.push(newSlot);
		}

		for (slot in skeleton.drawOrder)
			s.drawOrder.push(s.slots[skeleton.slots.indexOf(slot/*, true*/)]);

		s.skin = skeleton.skin;
		s.color = Color.copy(skeleton.color);
		s.time = skeleton.time;
        return s;
	}

	/** Updates the world transform for each bone. */
	public function updateWorldTransform ():Void {
		var flipX:Bool = this.flipX;
		var flipY:Bool = this.flipY;
		for (i in 0...bones.length)
			bones[i].updateWorldTransform(flipX, flipY);
	}

	/** Sets the bones and slots to their bind pose values. */
	public function setToBindPose () {
		setBonesToBindPose();
		setSlotsToBindPose();
	}

	public function setBonesToBindPose () {
		for (i in 0...bones.length)
			bones[i].setToBindPose();
	}

	public function setSlotsToBindPose () {
		for (i in 0...slots.length)
			slots[i].setToBindPose(i);
	}

	public function getData ():SkeletonData {
		return data;
	}

	public function getBones ():Array<Bone> {
		return bones;
	}

	/** @return May return null. */
	public function getRootBone ():Bone {
		if (bones.length == 0) return null;
		return bones[0];
	}

	/** @return May be null. */
	public function findBone (boneName:String):Bone {
		if (boneName == null) throw new IllegalArgumentException("boneName cannot be null.");
		for (bone in bones) {
			if (bone.data.name == boneName) return bone;
		}
		return null;
	}

	/** @return -1 if the bone was not found. */
	public function findBoneIndex (boneName:String):Int {
		if (boneName == null) throw new IllegalArgumentException("boneName cannot be null.");
		for (i in 0...bones.length)
			if (bones[i].data.name == boneName) return i;
		return -1;
	}

	public function getSlots ():Array<Slot> {
		return slots;
	}

	/** @return May be null. */
	public function findSlot (slotName:String):Slot {
		if (slotName == null) throw new IllegalArgumentException("slotName cannot be null.");
		for (slot in slots) {
			if (slot.data.name == slotName) return slot;
		}
		return null;
	}

	/** @return -1 if the bone was not found. */
	public function findSlotIndex (slotName:String):Int {
		if (slotName == null) throw new IllegalArgumentException("slotName cannot be null.");
		for (i in 0...slots.length)
			if (slots[i].data.name == slotName) return i;
		return -1;
	}

	/** Returns the slots in the order they will be drawn. The returned array may be modified to change the draw order. */
	public function getDrawOrder ():Array<Slot> {
		return drawOrder;
	}

	/** @return May be null. */
	public function getSkin ():Skin {
		return skin;
	}

	/** Sets a skin by name.
	 * @see #setSkin(Skin) */
	public function setSkinByName (skinName:String):Void {
		var skin:Skin = data.findSkin(skinName);
		if (skin == null) throw new IllegalArgumentException("Skin not found: " + skinName);
		setSkin(skin);
	}

	/** Sets the skin used to look up attachments not found in the {@link SkeletonData#getDefaultSkin() default skin}. Attachments
	 * from the new skin are attached if the corresponding attachment from the old skin was attached.
	 * @param newSkin May be null. */
	public function setSkin (newSkin:Skin) {
		if (skin != null && newSkin != null) newSkin.attachAll(this, skin);
		skin = newSkin;
	}

	/** @return May be null. */
	public function getAttachmentByName (slotName:String, attachmentName:String):Attachment {
		return getAttachment(data.findSlotIndex(slotName), attachmentName);
	}

	/** @return May be null. */
	public function getAttachment (slotIndex:Int, attachmentName:String):Attachment {
		if (attachmentName == null) throw new IllegalArgumentException("attachmentName cannot be null.");
		if (skin != null) {
			var attachment:Attachment = skin.getAttachment(slotIndex, attachmentName);
			if (attachment != null) return attachment;
		}
		if (data.defaultSkin != null) return data.defaultSkin.getAttachment(slotIndex, attachmentName);
		return null;
	}

	/** @param attachmentName May be null. */
	public function setAttachment (slotName:String, attachmentName:String):Void {
		if (slotName == null) throw new IllegalArgumentException("slotName cannot be null.");
		for (i in 0...slots.length) {
            var slot = slots[i];
			if (slot.data.name == slotName) {
				var attachment:Attachment = null;
				if (attachmentName != null) {
					attachment = getAttachment(i, attachmentName);
					if (attachment == null)
						throw new IllegalArgumentException("Attachment not found: " + attachmentName + ", for slot: " + slotName);
				}
				slot.setAttachment(attachment);
				return;
			}
		}
		throw new IllegalArgumentException("Slot not found: " + slotName);
	}

	public function getColor ():Color {
		return color;
	}

	public function getFlipX ():Bool {
		return flipX;
	}

	public function setFlipX ( flipX:Bool) {
		this.flipX = flipX;
	}

	public function getFlipY ():Bool {
		return flipY;
	}

	public function setFlipY (flipY:Bool) {
		this.flipY = flipY;
	}

	public function getTime ():Float {
		return time;
	}

	public function setTime (time:Float) {
		this.time = time;
	}

	public function update (delta:Float) {
		time += delta;
	}

	public function toString ():String {
		return data.name != null ? data.name : ""+this;
	}
}
