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

/** Stores state for an animation and automatically mixes between animations. */
class AnimationState {
	private var  data:AnimationStateData;
	var current:Animation;var previous:Animation;
	var currentTime:Float = 0;var previousTime:Float = 0;
	var currentLoop:Bool;var previousLoop:Bool;
	var mixTime:Float = 0;var mixDuration:Float = 0;

	public function new (data:AnimationStateData) {
		if (data == null) throw new IllegalArgumentException("data cannot be null.");
		this.data = data;
	}

	public function update (delta:Float):Void {
		currentTime += delta;
		previousTime += delta;
		mixTime += delta;
	}

	public function apply (skeleton:Skeleton) {
		if (current == null) return;
		if (previous != null) {
			previous.apply(skeleton, previousTime, previousLoop);
			var alpha:Float = mixTime / mixDuration;
			if (alpha >= 1) {
				alpha = 1;
				previous = null;
			}
			current.mix(skeleton, currentTime, currentLoop, alpha);
		} else
			current.apply(skeleton, currentTime, currentLoop);
	}

	public function clearAnimation () {
		previous = null;
		current = null;
	}

	/** @see #setAnimation(Animation, boolean) */
	public function setAnimationByName (animationName:String, loop:Bool) {
		var animation:Animation = data.getSkeletonData().findAnimation(animationName);
		if (animation == null) throw new IllegalArgumentException("Animation not found: " + animationName);
		setAnimation(animation, loop);
	}

	/** Set the current animation. The current animation time is set to 0.
	 * @param animation May be null. */
	public function setAnimation (animation:Animation, loop:Bool):Void {
		previous = null;
		if (animation != null && current != null) {
			mixDuration = data.getMix(current, animation);
			if (mixDuration > 0) {
				mixTime = 0;
				previous = current;
				previousTime = currentTime;
				previousLoop = currentLoop;
			}
		}
		current = animation;
		currentLoop = loop;
		currentTime = 0;
	}

	/** @return May be null. */
	public function getAnimation ():Animation {
		return current;
	}

	/** Returns the time within the current animation. */
	public function getTime ():Float {
		return currentTime;
	}

	public function setTime (time:Float) {
		currentTime = time;
	}

	/** Returns true if no animation is set or if the current time is greater than the animation duration, regardless of looping. */
	public function isComplete ():Bool {
		return current == null || currentTime >= current.getDuration();
	}

	public function getData ():AnimationStateData {
		return data;
	}

	public function toString ():String {
		return (current != null && current.getName() != null) ? current.getName() : ""+this;
	}
}
