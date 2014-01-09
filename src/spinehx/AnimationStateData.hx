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

/** Stores mixing times between animations. */
class AnimationStateData {
    public var defaultMixTime:Float=0;
    
	private var skeletonData:SkeletonData;
	var animationToMixTime:Map<String, Null<Float>> ;

	public function new (skeletonData:SkeletonData) {
        animationToMixTime = new Map();
		this.skeletonData = skeletonData;
	}

	public function getSkeletonData ():SkeletonData {
		return skeletonData;
	}

	public function setMixByName (fromName:String, toName:String, duration:Float):Void {
		var _from:Animation = skeletonData.findAnimation(fromName);
		if (_from == null) throw new IllegalArgumentException("Animation not found: " + fromName);
		var _to:Animation = skeletonData.findAnimation(toName);
		if (_to == null) throw new IllegalArgumentException("Animation not found: " + toName);
        var id = makeIdByName(fromName, toName);
        animationToMixTime.set(id, duration);
    }

	public function setMix (_from:Animation, _to:Animation, duration:Float):Void {
		if (_from == null) throw new IllegalArgumentException("_from cannot be null.");
		if (_to == null) throw new IllegalArgumentException("_to cannot be null.");
        var id = makeId(_from, _to);
        animationToMixTime.set(id, duration);
	}

	public function getMix (_from:Animation, _to:Animation):Float {
		var id = makeId(_from, _to);
		var time:Null<Float> = animationToMixTime.get(id);
		if (time == null) return defaultMixTime;
		return time;
	}

    //TODO remove string keys
    private static inline function makeIdByName (name1:String, name2:String):String {
        return name1 + ":" + name2;
    }
    private static inline function makeId (a1:Animation, a2:Animation):String {
        return makeIdByName(a1.getName(), a2.getName());
    }
}

