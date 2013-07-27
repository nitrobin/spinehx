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
import spinehx.atlas.TextureAtlas;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

#if openfl
import openfl.Assets;
import openfl.display.FPS;
#else
import nme.Assets;
import nme.display.FPS;
#end

class SkeletonTest extends Sprite {
	var time:Float = 0.0;
	var renderer:SkeletonRenderer;
	var debugRenderer:SkeletonRendererDebug;

	var skeletonData:SkeletonData;
	var skeleton:Skeleton;
	var animation:Animation;
    var lastTime:Float = 0.0;
    var mode:Int = 1;

    public function new() {
        super();

        lastTime = haxe.Timer.stamp();
        name = "goblins"; // "spineboy";

        var atlas:TextureAtlas = TextureAtlas.create(Assets.getText("assets/" + name + ".atlas"), "assets/", new BitmapDataTextureLoader());

		if (true) {
            var json = SkeletonJson.create(atlas);
            // json.setScale(2);
            skeletonData = json.readSkeletonData(name, Assets.getText("assets/" + name + ".json"));
		} /*else {
			SkeletonBinary binary = new SkeletonBinary(atlas);
			// binary.setScale(2);
			skeletonData = binary.readSkeletonData(Gdx.files.internal(name + ".skel"));
		} */
		animation = skeletonData.findAnimation("walk");

		skeleton = Skeleton.create(skeletonData);
		if (name == "goblins") skeleton.setSkinByName("goblin");
		skeleton.setToSetupPose();
		skeleton = Skeleton.copy(skeleton);

        skeleton.setX(50);
        skeleton.setY(20);
        skeleton.setFlipY(true);
		skeleton.updateWorldTransform();

        renderer = new SkeletonRenderer(skeleton);
        debugRenderer = new SkeletonRendererDebug(skeleton);

        renderer.x = 0;
        renderer.y = 350;
        debugRenderer.x = 0;
        debugRenderer.y = 350;
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
//        mode++;
//        mode%=3;
        if (name == "goblins") {
            skeleton.setSkinByName(skeleton.getSkin().getName() == "goblin" ? "goblingirl" : "goblin");
            skeleton.setSlotsToSetupPose();
        }
    }

//    private static inline function log(s){
//       untyped __js__("console.log(s);");
//    }

    public function render(e:Event):Void {
        var deltaTime:Float = haxe.Timer.stamp() - lastTime;
        lastTime = haxe.Timer.stamp();
		time += deltaTime;

		var x:Float = skeleton.getX() + 160 * deltaTime * (skeleton.getFlipX() ? -1 : 1);
		if (x > stage.stageWidth) {
            x = stage.stageWidth;
            skeleton.setFlipX(true);
        }
		if (x < 0) {
            x = 0;
            skeleton.setFlipX(false);
        }
        skeleton.setX(x);

		animation.apply(skeleton, time, true);
		skeleton.updateWorldTransform();
		skeleton.update(deltaTime);


        if(mode == 0 || mode == 1){
            renderer.visible = true;
            renderer.clearBuffers();
            renderer.draw();
        } else renderer.visible = false;
        if(mode == 0 || mode == 2){
            debugRenderer.visible = true;
            debugRenderer.draw();
        } else debugRenderer.visible = false;
	}
}
