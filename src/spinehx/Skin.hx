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
import spinehx.Maps.StringMap;
import spinehx.ex.IllegalArgumentException;
import spinehx.Maps;


/** Stores attachments by slot index and attachment name. */
class Skin {
    public var name:String;
    public var attachments: StringMap<AttachmentEntry>;

	public function new (name:String) {
        attachments = new StringMap<AttachmentEntry>();
		if (name == null) throw new IllegalArgumentException("name cannot be null.");
		this.name = name;
	}

	public function addAttachment (slotIndex:Int, name:String, attachment:Attachment) {
		if (attachment == null) throw new IllegalArgumentException("attachment cannot be null.");
		var entry = new AttachmentEntry(slotIndex, name, attachment);
		attachments.set(entry.getId(), entry);
	}

	/** @return May be null. */
	public function getAttachment (slotIndex:Int,  name:String):Attachment {
        var id = AttachmentEntry.makeId(slotIndex, name);
        var attachmentEntry = attachments.get(id);
        return attachmentEntry != null ? attachmentEntry.attachment : null;
	}

	public function findNamesForSlot (slotIndex:Int, names:Array<String>) {
		if (names == null) throw new IllegalArgumentException("names cannot be null.");
		for (e in attachments/*.values()*/)
			if (e.slotIndex == slotIndex) names.push(e.name);
	}

	public function findAttachmentsForSlot (slotIndex:Int, attachments:Array<Attachment>) {
		if (attachments == null) throw new IllegalArgumentException("attachments cannot be null.");
		for (e in this.attachments/*.values()*/)
			if (e.slotIndex == slotIndex) attachments.push(e.attachment);
	}

	public function clear () {
        attachments = new StringMap<AttachmentEntry>();
	}

	public function getName ():String {
		return name;
	}

	public function toString ():String {
		return name;
	}

	/** Attach each attachment in this skin if the corresponding attachment in the old skin is currently attached. */
    public function attachAll (skeleton:Skeleton,  oldSkin:Skin) {
		for (e in oldSkin.attachments/*.values()*/) {
			var slotIndex:Int = e.slotIndex;
            var value = oldSkin.attachments.get(e.getId());
			var slot:Slot = skeleton.slots[slotIndex];
			if (slot.attachment == value.attachment) {
				var attachment:Attachment = getAttachment(slotIndex, e.name);
				if (attachment != null) slot.setAttachment(attachment);
			}
		}
	}
}

class AttachmentEntry {
    public var slotIndex:Int;
    public var name:String;
    public var id:String;
    public var attachment:Attachment;

    public function new (slotIndex:Int, name:String, attachment:Attachment):Void {
        if (name == null) throw new IllegalArgumentException("name cannot be null.");
        this.slotIndex = slotIndex;
        this.name = name;
        this.attachment = attachment;
        id = makeId(slotIndex, name);
    }

//TODO remove string keys
    public static function makeId (slotIndex:Int, name:String):String {
       return slotIndex + ":" + name;
    }

    public function getId ():String {
        return id;
    }

    public function toString ():String {
        return id;
    }
}

