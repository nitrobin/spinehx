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

import spinehx.Exception;
import haxe.ds.Vector;

class Animation {

	public var name:String;
	private var timelines:Array<Timeline>;
	private var duration:Float = 0;

	public function new (name:String, timelines:Array<Timeline>, duration:Float) {
		if (name == null) throw new IllegalArgumentException("name cannot be null.");
		if (timelines == null) throw new IllegalArgumentException("timelines cannot be null.");
		this.name = name;
		this.timelines = timelines;
		this.duration = duration;
	}

	public function getTimelines ():Array<Timeline> {
		return timelines;
	}

	/** Returns the duration of the animation in seconds. */
	public function getDuration ():Float {
		return duration;
	}

	public function setDuration (duration:Float) {
		this.duration = duration;
	}

	/** Poses the skeleton at the specified time for this animation. */
	public function apply (skeleton:Skeleton, time:Float, loop:Bool) {
		if (skeleton == null) throw new IllegalArgumentException("skeleton cannot be null.");

		if (loop && duration != 0) time %= duration;
		for (timeline in timelines)
			timeline.apply(skeleton, time, 1);
	}

	/** Poses the skeleton at the specified time for this animation mixed with the current pose.
	 * @param alpha The amount of this animation that affects the current pose. */
	public function mix ( skeleton:Skeleton, time:Float, loop:Bool, alpha:Float) {
		if (skeleton == null) throw new IllegalArgumentException("skeleton cannot be null.");

		if (loop && duration != 0) time %= duration;

        for (timeline in timelines)
            timeline.apply(skeleton, time, alpha);
	}

	public function getName ():String {
		return name;
	}

	public function toString ():String {
		return name;
	}

	/** @param target After the first and before the last entry. */
	public static function binarySearch (values:Vector<Float>, target:Float, step:Int):Int {
		var low:Int = 0;
		var high:Int = Math.floor(values.length / step - 2);
		if (high == 0) return step;
		var current:Int = high >>> 1;
		while (true) {
			if (values[(current + 1) * step] <= target)
				low = current + 1;
			else
				high = current;
			if (low == high) return (low + 1) * step;
			current = (low + high) >>> 1;
		}
	}

	static function linearSearch (values:Vector<Float>, target:Float, step:Int):Int {
		var i:Int = 0;var last:Int = values.length - step;
        while (i <= last){
			if (values[i] > target) return i;
            i += step;
        }
		return -1;
	}
}

interface Timeline {
    /** Sets the value(s) for the specified time. */
    public function apply (skeleton:Skeleton, time:Float, alpha:Float):Void;
}

/** Base class for frames that use an interpolation bezier curve. */
/*abstract*/ class CurveTimeline implements Timeline {
    static private inline var LINEAR:Float = 0;
    static private inline var STEPPED:Float = -1;
    static private inline var BEZIER_SEGMENTS:Int = 10;

    private var curves:Vector<Float>; // dfx, dfy, ddfx, ddfy, dddfx, dddfy, ...

    public function new (frameCount:Int) {
        curves = ArrayUtils.allocFloat((frameCount - 1) * 6);
    }

    public function apply (skeleton:Skeleton, time:Float, alpha:Float):Void{
        throw "implement me";
    }

    public function getFrameCount ():Int {
        return Math.floor(curves.length / 6 + 1);
    }

    public function setLinear (frameIndex:Int) {
        curves[frameIndex * 6] = LINEAR;
    }

    public function setStepped (frameIndex:Int) {
        curves[frameIndex * 6] = STEPPED;
    }

    /** Sets the control handle positions for an interpolation bezier curve used to transition from this keyframe to the next.
     * cx1 and cx2 are from 0 to 1, representing the percent of time between the two keyframes. cy1 and cy2 are the percent of
     * the difference between the keyframe's values. */
    public function setCurve (frameIndex:Int, cx1:Float, cy1:Float, cx2:Float, cy2:Float) {
        var subdiv_step:Float = 1.0 / BEZIER_SEGMENTS;
        var subdiv_step2:Float = subdiv_step * subdiv_step;
        var subdiv_step3:Float = subdiv_step2 * subdiv_step;
        var pre1:Float = 3 * subdiv_step;
        var pre2:Float = 3 * subdiv_step2;
        var pre4:Float = 6 * subdiv_step2;
        var pre5:Float = 6 * subdiv_step3;
        var tmp1x:Float = -cx1 * 2 + cx2;
        var tmp1y:Float = -cy1 * 2 + cy2;
        var tmp2x:Float = (cx1 - cx2) * 3 + 1;
        var tmp2y:Float = (cy1 - cy2) * 3 + 1;
        var i:Int = frameIndex * 6;
        curves[i] = cx1 * pre1 + tmp1x * pre2 + tmp2x * subdiv_step3;
        curves[i + 1] = cy1 * pre1 + tmp1y * pre2 + tmp2y * subdiv_step3;
        curves[i + 2] = tmp1x * pre4 + tmp2x * pre5;
        curves[i + 3] = tmp1y * pre4 + tmp2y * pre5;
        curves[i + 4] = tmp2x * pre5;
        curves[i + 5] = tmp2y * pre5;
    }

    public function getCurvePercent (frameIndex:Int, percent:Float):Float {
        var curveIndex:Int = frameIndex * 6;
        var dfx:Float = curves[curveIndex];
        if (dfx == LINEAR) return percent;
        if (dfx == STEPPED) return 0;
        var dfy:Float = curves[curveIndex + 1];
        var ddfx:Float = curves[curveIndex + 2];
        var ddfy:Float = curves[curveIndex + 3];
        var dddfx:Float = curves[curveIndex + 4];
        var dddfy:Float = curves[curveIndex + 5];
        var x:Float = dfx, y:Float = dfy;
        var i:Int = BEZIER_SEGMENTS - 2;
        while (true) {
            if (x >= percent) {
                var lastX:Float = x - dfx;
                var lastY:Float = y - dfy;
                return lastY + (y - lastY) * (percent - lastX) / (x - lastX);
            }
            if (i == 0) break;
            i--;
            dfx += ddfx;
            dfy += ddfy;
            ddfx += dddfx;
            ddfy += dddfy;
            x += dfx;
            y += dfy;
        }
        return y + (1 - y) * (percent - x) / (1 - x); // Last point is 1,1.
    }
}

class RotateTimeline extends CurveTimeline {
    static private inline var LAST_FRAME_TIME:Int = -2;
    static private inline var FRAME_VALUE:Int = 1;

    private var boneIndex:Int = 0;
    private var frames:Vector<Float>; // time, angle, ...

    public function new (frameCount:Int) {
        super(frameCount);
        frames = ArrayUtils.allocFloat(frameCount * 2);
    }

    public function setBoneIndex (boneIndex:Int) {
        this.boneIndex = boneIndex;
    }

    public function getBoneIndex ():Int {
        return boneIndex;
    }

    public function getFrames ():Vector<Float> {
        return frames;
    }

    /** Sets the time and angle of the specified keyframe. */
    public function setFrame (frameIndex:Int, time:Float, angle:Float) {
        frameIndex *= 2;
        frames[frameIndex] = time;
        frames[frameIndex + 1] = angle;
    }

    public override function apply (skeleton:Skeleton, time:Float, alpha:Float) {
        if (time < frames[0]) return; // Time is before first frame.

        var bone:Bone = skeleton.bones[boneIndex];

        if (time >= frames[frames.length - 2]) { // Time is after last frame.
            var amount:Float = bone.data.rotation + frames[frames.length - 1] - bone.rotation;
            while (amount > 180)
                amount -= 360;
            while (amount < -180)
                amount += 360;
            bone.rotation += amount * alpha;
            return;
        }

        // Interpolate between the last frame and the current frame.
        var frameIndex:Int = Animation.binarySearch(frames, time, 2);
        var lastFrameValue:Float = frames[frameIndex - 1];
        var frameTime:Float = frames[frameIndex];
        var percent:Float = MathUtils.clamp(1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime), 0, 1);
        percent = getCurvePercent(Math.floor(frameIndex / 2 - 1), percent);

        var amount:Float = frames[frameIndex + FRAME_VALUE] - lastFrameValue;
        while (amount > 180)
            amount -= 360;
        while (amount < -180)
            amount += 360;
        amount = bone.data.rotation + (lastFrameValue + amount * percent) - bone.rotation;
        while (amount > 180)
            amount -= 360;
        while (amount < -180)
            amount += 360;
        bone.rotation += amount * alpha;
    }
}

class TranslateTimeline extends CurveTimeline {
    static inline var LAST_FRAME_TIME:Int = -3;
    static inline var FRAME_X:Int = 1;
    static inline var FRAME_Y:Int = 2;

    var boneIndex:Int = 0;
    var frames:Vector<Float>; // time, x, y, ...

    public function new (frameCount:Int) {
        super(frameCount);
        frames = ArrayUtils.allocFloat(frameCount * 3);
    }

    public function setBoneIndex (boneIndex:Int) {
        this.boneIndex = boneIndex;
    }

    public function getBoneIndex ():Int {
        return boneIndex;
    }

    public function getFrames ():Vector<Float> {
        return frames;
    }

    /** Sets the time and value of the specified keyframe. */
    public function setFrame (frameIndex:Int, time:Float, x:Float, y:Float) {
        frameIndex *= 3;
        frames[frameIndex] = time;
        frames[frameIndex + 1] = x;
        frames[frameIndex + 2] = y;
    }

    public override function apply (skeleton:Skeleton, time:Float, alpha:Float) {
        if (time < frames[0]) return; // Time is before first frame.

        var bone:Bone = skeleton.bones[boneIndex];

        if (time >= frames[frames.length - 3]) { // Time is after last frame.
            bone.x += (bone.data.x + frames[frames.length - 2] - bone.x) * alpha;
            bone.y += (bone.data.y + frames[frames.length - 1] - bone.y) * alpha;
            return;
        }

        // Interpolate between the last frame and the current frame.
        var frameIndex:Int = Animation.binarySearch(frames, time, 3);
        var lastFrameX:Float = frames[frameIndex - 2];
        var lastFrameY:Float = frames[frameIndex - 1];
        var frameTime:Float = frames[frameIndex];
        var percent:Float = MathUtils.clamp(1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime), 0, 1);
        percent = getCurvePercent(Math.floor(frameIndex / 3 - 1), percent);

        bone.x += (bone.data.x + lastFrameX + (frames[frameIndex + FRAME_X] - lastFrameX) * percent - bone.x) * alpha;
        bone.y += (bone.data.y + lastFrameY + (frames[frameIndex + FRAME_Y] - lastFrameY) * percent - bone.y) * alpha;
    }
}

class ScaleTimeline extends TranslateTimeline {
    public function new (frameCount:Int) {
        super(frameCount);
    }

    public override function apply (skeleton:Skeleton, time:Float, alpha:Float) {
        if (time < frames[0]) return; // Time is before first frame.

        var bone:Bone = skeleton.bones[boneIndex];
        if (time >= frames[frames.length - 3]) { // Time is after last frame.
            bone.scaleX += (bone.data.scaleX - 1 + frames[frames.length - 2] - bone.scaleX) * alpha;
            bone.scaleY += (bone.data.scaleY - 1 + frames[frames.length - 1] - bone.scaleY) * alpha;
            return;
        }

        // Interpolate between the last frame and the current frame.
        var frameIndex:Int = Animation.binarySearch(frames, time, 3);
        var lastFrameX:Float = frames[frameIndex - 2];
        var lastFrameY:Float = frames[frameIndex - 1];
        var frameTime:Float = frames[frameIndex];
        var percent:Float = MathUtils.clamp(1 - (time - frameTime) / (frames[frameIndex + TranslateTimeline.LAST_FRAME_TIME] - frameTime), 0, 1);
        percent = getCurvePercent(Math.floor(frameIndex / 3 - 1), percent);

        bone.scaleX += (bone.data.scaleX - 1 + lastFrameX + (frames[frameIndex + TranslateTimeline.FRAME_X] - lastFrameX) * percent - bone.scaleX)
            * alpha;
        bone.scaleY += (bone.data.scaleY - 1 + lastFrameY + (frames[frameIndex + TranslateTimeline.FRAME_Y] - lastFrameY) * percent - bone.scaleY)
            * alpha;
    }
}

class ColorTimeline extends CurveTimeline {
    static private inline var LAST_FRAME_TIME:Int = -5;
    static private inline var FRAME_R:Int = 1;
    static private inline var FRAME_G:Int = 2;
    static private inline var FRAME_B:Int = 3;
    static private inline var FRAME_A:Int = 4;

    private var slotIndex:Int = 0;
    private var frames:Vector<Float>; // time, r, g, b, a, ...

    public function new (frameCount:Int) {
        super(frameCount);
        frames = ArrayUtils.allocFloat(frameCount * 5);
    }

    public function setSlotIndex (slotIndex:Int) {
        this.slotIndex = slotIndex;
    }

    public function getSlotIndex ():Int {
        return slotIndex;
    }

    public function getFrames ():Vector<Float> {
        return frames;
    }

    /** Sets the time and value of the specified keyframe. */
    public function setFrame (frameIndex:Int, time:Float, r:Float, g:Float, b:Float, a:Float) {
        frameIndex *= 5;
        frames[frameIndex] = time;
        frames[frameIndex + 1] = r;
        frames[frameIndex + 2] = g;
        frames[frameIndex + 3] = b;
        frames[frameIndex + 4] = a;
    }

    public override function apply (skeleton:Skeleton, time:Float, alpha:Float) {
        if (time < frames[0]) return; // Time is before first frame.

        var color:Color = skeleton.slots[slotIndex].color;

        if (time >= frames[frames.length - 5]) { // Time is after last frame.
            var i:Int = frames.length - 1;
            var r:Float = frames[i - 3];
            var g:Float = frames[i - 2];
            var b:Float = frames[i - 1];
            var a:Float = frames[i];
            color.set(r, g, b, a);
            return;
        }

        // Interpolate between the last frame and the current frame.
        var frameIndex:Int = Animation.binarySearch(frames, time, 5);
        var lastFrameR:Float = frames[frameIndex - 4];
        var lastFrameG:Float = frames[frameIndex - 3];
        var lastFrameB:Float = frames[frameIndex - 2];
        var lastFrameA:Float = frames[frameIndex - 1];
        var frameTime:Float = frames[frameIndex];
        var percent:Float = MathUtils.clamp(1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime), 0, 1);
        percent = getCurvePercent(Math.floor(frameIndex / 5 - 1), percent);

        var r:Float = lastFrameR + (frames[frameIndex + FRAME_R] - lastFrameR) * percent;
        var g:Float = lastFrameG + (frames[frameIndex + FRAME_G] - lastFrameG) * percent;
        var b:Float = lastFrameB + (frames[frameIndex + FRAME_B] - lastFrameB) * percent;
        var a:Float = lastFrameA + (frames[frameIndex + FRAME_A] - lastFrameA) * percent;
        if (alpha < 1)
            color.add((r - color.r) * alpha, (g - color.g) * alpha, (b - color.b) * alpha, (a - color.a) * alpha);
        else
            color.set(r, g, b, a);
    }
}

class AttachmentTimeline implements Timeline {
    private var slotIndex:Int = 0;
    private var frames:Vector<Float>; // time, ...
    private var attachmentNames:Vector<String>;

    public function new (frameCount:Int) {
        frames = ArrayUtils.allocFloat(frameCount);
        attachmentNames = ArrayUtils.allocString(frameCount);
    }

    public function getFrameCount ():Int {
        return frames.length;
    }

    public function getSlotIndex ():Int {
        return slotIndex;
    }

    public function setSlotIndex (slotIndex:Int) {
        this.slotIndex = slotIndex;
    }

    public function getFrames ():Vector<Float> {
        return frames;
    }

    public function getAttachmentNames ():Vector<String> {
        return attachmentNames;
    }

    /** Sets the time and value of the specified keyframe. */
    public function setFrame (frameIndex:Int, time:Float, attachmentName:String) {
        frames[frameIndex] = time;
        attachmentNames[frameIndex] = attachmentName;
    }

    public function apply (skeleton:Skeleton, time:Float, alpha:Float) {
        if (time < frames[0]) return; // Time is before first frame.

        var frameIndex:Int;
        if (time >= frames[frames.length - 1]) // Time is after last frame.
            frameIndex = frames.length - 1;
        else
            frameIndex = Animation.binarySearch(frames, time, 1) - 1;

        var attachmentName:String = attachmentNames[frameIndex];
        skeleton.slots[slotIndex].setAttachment(
            attachmentName == null ? null : skeleton.getAttachment(slotIndex, attachmentName));
    }
}


class DrawOrderTimeline implements Timeline {
    private var frames:Vector<Float>;
    private var drawOrders:Vector<Vector<Int>>;
    
    public function new (frameCount:Int) {
        frames = new Vector(frameCount);
        drawOrders = new Vector(frameCount);
    }
    
    public function getFrameCount():Int {
        return frames.length;
    }
    
    public function getFrames():Vector<Float> {
        return frames;
    }
    
    public function getDrawOrders():Vector<Vector<Int>> {
        return drawOrders;
    }
    
    /** Sets the time of the specified keyframe.
     * @param drawOrder May be null to use bind pose draw order. */
    public function setFrame(frameIndex:Int, time:Float, drawOrder:Vector<Int>) {
        frames[frameIndex] = time;
        drawOrders[frameIndex] = drawOrder;
    }

    public function apply(skeleton:Skeleton, time:Float, alpha:Float) {
        var frames = this.frames;
        if (time < frames[0]) return; // Time is before first frame.
        
        var frameIndex:Int;
        if (time >= frames[frames.length - 1]) // Time is after last frame.
            frameIndex = frames.length - 1;
        else
            frameIndex = Animation.binarySearch(frames, time, 1) - 1;
        
        var slots:Array<Slot> = skeleton.slots;
        var drawOrderToSetupIndex:Vector<Int> = drawOrders[frameIndex];
        if (drawOrderToSetupIndex == null)
            skeleton.drawOrder = [for (x in slots) x];
        else {
            skeleton.drawOrder = [for (i in 0 ... drawOrderToSetupIndex.length) slots[drawOrderToSetupIndex[i]]];
        }
    }
}
