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

class SkeletonData {
	public var name:String;
    public var bones :Array<BoneData>; // Ordered parents first.
    public var slots :Array<SlotData>; // Bind pose draw order.
    public var skins :Array<Skin>;
    public var animations :Array<Animation>;
    public var defaultSkin:Skin;

    public function new() {
        clear();
    }


	public function clear ():Void {
        bones = new Array<BoneData>(); // Ordered parents first.
        slots = new Array<SlotData>(); // Bind pose draw order.
        skins = new Array<Skin>();
        animations = new Array<Animation>();
		defaultSkin = null;
	}

	// --- Bones.

	public function addBone (bone:BoneData):Void {
		if (bone == null) throw new IllegalArgumentException("bone cannot be null.");
		bones.push(bone);
	}

	public function getBones ():Array<BoneData> {
		return bones;
	}

	/** @return May be null. */
	public function findBone (boneName:String):BoneData {
		if (boneName == null) throw new IllegalArgumentException("boneName cannot be null.");
		for (bone in bones) {
			if (bone.name == boneName) return bone;
		}
		return null;
	}

	/** @return -1 if the bone was not found. */
	public function findBoneIndex (boneName:String):Int {
		if (boneName == null) throw new IllegalArgumentException("boneName cannot be null.");
		for (i in 0...bones.length)
			if (bones[i].name == boneName) return i;
		return -1;
	}

	// --- Slots.

	public function addSlot (slot:SlotData):Void {
		if (slot == null) throw new IllegalArgumentException("slot cannot be null.");
		slots.push(slot);
	}

	public function getSlots ():Array<SlotData> {
		return slots;
	}

	/** @return May be null. */
	public function findSlot (slotName:String):SlotData {
		if (slotName == null) throw new IllegalArgumentException("slotName cannot be null.");
		for (slot in slots) {
			if (slot.name == slotName) return slot;
		}
		return null;
	}

	/** @return -1 if the bone was not found. */
	public function findSlotIndex (slotName:String) {
		if (slotName == null) throw new IllegalArgumentException("slotName cannot be null.");
		for (i in 0...slots.length)
			if (slots[i].name == slotName) return i;
		return -1;
	}

	// --- Skins.

	/** @return May be null. */
	public function getDefaultSkin ():Skin {
		return defaultSkin;
	}

	/** @param defaultSkin May be null. */
	public function setDefaultSkin (defaultSkin:Skin):Void {
		this.defaultSkin = defaultSkin;
	}

	public function addSkin (skin:Skin):Void {
		if (skin == null) throw new IllegalArgumentException("skin cannot be null.");
		skins.push(skin);
	}

	/** @return May be null. */
	public function findSkin (skinName:String):Skin {
		if (skinName == null) throw new IllegalArgumentException("skinName cannot be null.");
		for (skin in skins)
			if (skin.name == skinName) return skin;
		return null;
	}

	/** Returns all skins, including the default skin. */
	public function getSkins ():Array<Skin> {
		return skins;
	}

	// --- Animations.

	public function addAnimation (animation:Animation):Void {
		if (animation == null) throw new IllegalArgumentException("animation cannot be null.");
		animations.push(animation);
	}

	public function getAnimations ():Array<Animation> {
		return animations;
	}

	/** @return May be null. */
	public function findAnimation (animationName:String):Animation {
		if (animationName == null) throw new IllegalArgumentException("animationName cannot be null.");
		for (animation in animations) {
			if (animation.name == animationName) return animation;
		}
		return null;
	}

	// ---

	/** @return May be null. */
	public function getName ():String {
		return name;
	}

	/** @param name May be null. */
	public function setName (name:String) {
		this.name = name;
	}

	public function toString ():String {
		return name != null ? name : ""+this;
	}
}
