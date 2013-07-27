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

import spinehx.platform.nme.BitmapDataTextureLoader;
import spinehx.platform.nme.renderers.SkeletonRendererDebug;
import spinehx.platform.nme.renderers.SkeletonRenderer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import spinehx.Bone;
import spinehx.atlas.TextureAtlas;
import spinehx.SkeletonJson;
import spinehx.Animation;
import spinehx.Skeleton;
import spinehx.SkeletonData;

#if openfl
import openfl.Assets;
import openfl.display.FPS;
#else
import nme.Assets;
import nme.display.FPS;
#end

class MixTest extends Sprite {
	var time:Float = 0.0;
	var renderer:SkeletonRenderer;
	var debugRenderer:SkeletonRendererDebug;

	var skeletonData:SkeletonData;
	var skeleton:Skeleton;
	var walkAnimation:Animation;
	var jumpAnimation:Animation;
    var lastTime:Float = 0.0;
    var mode:Int = 1;

    public function new() {
        super();
		var name = "spineboy";

		var atlas:TextureAtlas = TextureAtlas.create(Assets.getText("assets/" + name + ".atlas"), "assets/", new BitmapDataTextureLoader());

		if (true) {
			var json = SkeletonJson.create(atlas);
			// json.setScale(2);
			skeletonData = json.readSkeletonData(name, Assets.getText("assets/" + name + ".json"));
		} /*else {
			SkeletonBinary binary = new SkeletonBinary(atlas);
			// binary.setScale(2);
			skeletonData = binary.readSkeletonData(Gdx.files.internal(name + ".skel"));
		}*/
		walkAnimation = skeletonData.findAnimation("walk");
		jumpAnimation = skeletonData.findAnimation("jump");

		skeleton = Skeleton.create(skeletonData);

        skeleton.setX(-50);
        skeleton.setY(20);
        skeleton.setFlipY(true);
		skeleton.updateWorldTransform();
        lastTime = haxe.Timer.stamp();

        renderer = new SkeletonRenderer(skeleton);
        debugRenderer = new SkeletonRendererDebug(skeleton);

        renderer.x = 0;
        renderer.y = 300;
        debugRenderer.x = 0;
        debugRenderer.y = 300;
        addChild(renderer);
        addChild(debugRenderer);
        addChild(new FPS());

        addEventListener(Event.ENTER_FRAME, render);
        addEventListener(Event.ADDED_TO_STAGE, added);  renderer.draw();
    }

    public function added(e:Event):Void {
        this.mouseChildren = false;
        stage.addEventListener(MouseEvent.CLICK, onClick);
    }

    public function onClick(e:Event):Void {
        mode++;
        mode%=3;
    }

    public function render(e:Event):Void {
        var deltaTime:Float = haxe.Timer.stamp() - lastTime;
        var delta = (deltaTime) / 4.0;   // Reduced to make mixing easier to see.
        lastTime = haxe.Timer.stamp();

		var jump:Float = jumpAnimation.getDuration();
		var beforeJump:Float = 1.0;
		var blendIn:Float = 0.4;
		var blendOut:Float = 0.4;
		var blendOutStart:Float = beforeJump + jump - blendOut;
		var total:Float = 3.75;

		time += delta;

		var root_:Bone = skeleton.getRootBone();
		var speed:Float = 180;
		if (time > beforeJump + blendIn && time < blendOutStart) speed = 360;
		root_.setX(root_.getX() + speed * delta);

		// This shows how to manage state manually. See AnimationStatesTest.
		if (time > total) {
			// restart
			time = 0;
			root_.setX(-50);
		} else if (time > beforeJump + jump) {
			// just walk after jump
			walkAnimation.apply(skeleton, time, true);
		} else if (time > blendOutStart) {
			// blend out jump
			walkAnimation.apply(skeleton, time, true);
			jumpAnimation.mix(skeleton, time - beforeJump, false, 1 - (time - blendOutStart) / blendOut);
		} else if (time > beforeJump + blendIn) {
			// just jump
			jumpAnimation.apply(skeleton, time - beforeJump, false);
		} else if (time > beforeJump) {
			// blend in jump
			walkAnimation.apply(skeleton, time, true);
			jumpAnimation.mix(skeleton, time - beforeJump, false, (time - beforeJump) / blendIn);
		} else {
			// just walk before jump
			walkAnimation.apply(skeleton, time, true);
		}

		skeleton.updateWorldTransform();
		skeleton.update(deltaTime);


        if(mode == 0 || mode == 1){
            renderer.visible = true;
            renderer.draw();
        } else renderer.visible = false;
        if(mode == 0 || mode == 2){
            debugRenderer.visible = true;
            debugRenderer.draw();
        } else debugRenderer.visible = false;
	}

//	public void resize (int width, int height) {
//		batch.getProjectionMatrix().setToOrtho2D(0, 0, width, height);
//		debugRenderer.getShapeRenderer().setProjectionMatrix(batch.getProjectionMatrix());
//	}

//	public static void main (String[] args) throws Exception {
//		new LwjglApplication(new MixTest());
//	}
}
