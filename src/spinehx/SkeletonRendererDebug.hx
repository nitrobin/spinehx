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

import spinehx.attachments.RegionAttachment;
import spinehx.attachments.Attachment;
import flash.display.Sprite;
class SkeletonRendererDebug extends Sprite {
    var skeleton:Skeleton;

    public function new(skeleton:Skeleton) {
        super();
        this.skeleton = skeleton;
    }

    public function draw() {
        graphics.clear();
        graphics.lineStyle(1, 0xff0000);
        function line(x1, y1, x2, y2) {
            graphics.moveTo(x1, y1);
            graphics.lineTo(x2, y2);
        }

        for (bone in skeleton.getBones()) {
            if (bone.parent == null) continue;
            var x:Float = bone.data.length * bone.m00 + bone.worldX;
            var y:Float = bone.data.length * bone.m10 + bone.worldY;
            line(bone.worldX, bone.worldY, x, y);
        }

        graphics.lineStyle(1, 0x0000ff);
        for (slot in skeleton.getSlots()) {
            var attachment:Attachment = slot.attachment;
            if (Std.is(attachment, RegionAttachment)) {
                var regionAttachment:RegionAttachment = cast(attachment, RegionAttachment);
                regionAttachment.updateVertices(slot);
                var vertices:Array<Float> = regionAttachment.getVertices();
                line(vertices[RegionAttachment.X1], vertices[RegionAttachment.Y1], vertices[RegionAttachment.X2], vertices[RegionAttachment.Y2]);
                line(vertices[RegionAttachment.X2], vertices[RegionAttachment.Y2], vertices[RegionAttachment.X3], vertices[RegionAttachment.Y3]);
                line(vertices[RegionAttachment.X3], vertices[RegionAttachment.Y3], vertices[RegionAttachment.X4], vertices[RegionAttachment.Y4]);
                line(vertices[RegionAttachment.X4], vertices[RegionAttachment.Y4], vertices[RegionAttachment.X1], vertices[RegionAttachment.Y1]);
            }
        }

        graphics.lineStyle(1, 0x00ff00);
//        graphics.beginFill(0x00ff00);
        for (bone in skeleton.getBones()) {
            graphics.drawCircle(bone.worldX, bone.worldY, 3);
        }
        graphics.endFill();
    }
}
