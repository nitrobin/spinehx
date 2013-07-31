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

/** 
 *
 * Flambe renderer by Kipp Ashford.
 * 
 */
package spinehx.platform.flambe.renderers;

import flambe.Component;
import flambe.display.Sprite;
import flambe.display.Texture;
import flambe.Entity;
import flambe.util.Assert;

import flambe.util.Value;
import haxe.ds.ObjectMap;

import spinehx.Animation;
import spinehx.AnimationState;
import spinehx.atlas.TextureAtlas.AtlasRegion;
import spinehx.atlas.TextureRegion;
import spinehx.attachments.Attachment;
import spinehx.attachments.RegionAttachment;
import spinehx.platform.flambe.renderers.RegionSprite;
import spinehx.platform.flambe.SpineTexture;

class SpineMovie extends Component
{
    /** Skeleton information. */
    public var skeleton (default, null) :Skeleton;
    /** The skin currently being used. */
    public var skin (default, null) :Value<String>;
    /** The sprites based on region attachment */
    public var sprites :ObjectMap<RegionAttachment, RegionSprite> ;

    public function new (data :SpineData, skin :Null<String> = null)
    {
        this.skin = new Value("default");

        skeleton = data.skeleton;
        if (skeleton.data.getSkins().length > 1) {
            if (skin != null) {
                setSkin(skin);
            } else {
                setSkin(skeleton.data.getSkins()[1].getName()); // Set to the first skin unless otherwise specified.
            }
        }

        skeleton.setFlipY(true); // I don't know why we need this, but it keeps everything upright.
        _state = new AnimationState(new AnimationStateData(skeleton.data));
        skeleton.setToSetupPose();
        _holder = new Entity();
        sprites = new ObjectMap<RegionAttachment, RegionSprite>();
    }

    override public function onAdded()
    {
        owner.addChild(_holder);
    }

    /**
     *  Sets up mixing between one animation and the other.
     */ 
    public function setMix(fromName:String, toName:String, duration:Float) :SpineMovie
    {
        var from :Animation = skeleton.data.findAnimation(fromName);
        var to :Animation = skeleton.data.findAnimation(toName);
        
        if (from == null) {
            Assert.fail("SpineMovie.setMix() from animation name '" + fromName + "' is not a valid animation.");
        }
        if (to == null) {
            Assert.fail("SpineMovie.setMix() to animation name '" + toName + "' is not a valid animation.");
        }

        _state.getData().setMix(from, to, duration);
        return this;
    }

    public function setSkin(id :String) :SpineMovie
    {
        if (skeleton.data.getSkins().length > 1) {
            this.skeleton.setSkinByName(id);
            this.skin._ = id;
        }
        return this;
    }

    public function play(id :String) :SpineMovie
    {
        _state.setAnimationByName(id, false);
        if (_loop != null) {
            _state.addAnimationByNameSimple(_loop, true);
        }
        return this;
    }

    public function loop(id :String) :SpineMovie
    {
        _loop = id;
        _state.setAnimationByName(id, true);

        // animation = skeleton.data.findAnimation(id);
        return this;        
    }

    override public function onUpdate(dt :Float)
    {
        _state.update(dt);
        _state.apply(skeleton);

        skeleton.updateWorldTransform();
        skeleton.update(dt);

        clearBuffers();
        draw();
    }
    
    private inline function clearBuffers()
    {
        for (s in sprites) {
            s.visible = false;
        }
    }

    private inline function draw ()
    {
        var drawOrder:Array<Slot> = skeleton.drawOrder;
        var flipX:Int = (skeleton.flipX) ? -1 : 1;
        var flipY:Int = (skeleton.flipY) ? 1 : -1;
        var flip:Int = flipX * flipY;

        var i :Int = -1, nLen :Int = drawOrder.length-1;
        while (i++ < nLen)
        {
            var slot :Slot = drawOrder[i];
            var attachment :Attachment = slot.attachment;

            if (Std.is(attachment, RegionAttachment))
            {
                var regionAttachment:RegionAttachment = cast(attachment, RegionAttachment);
                regionAttachment.updateVertices(slot);

                var vertices = regionAttachment.getVertices();
                var partSprite :RegionSprite = sprites.get(regionAttachment);
                
                if(partSprite == null)
                {
                    partSprite = new RegionSprite(regionAttachment);
                    var part :Entity = new Entity().add(partSprite);
                    sprites.set(regionAttachment, partSprite);
                    _holder.addChild(part);
                }

                var region :AtlasRegion = cast regionAttachment.getRegion();
                var bone :Bone = slot.getBone();
                var x :Float = regionAttachment.x - region.offsetX;
                var y :Float = regionAttachment.y - region.offsetY;

                partSprite.x._ = bone.worldX + x * bone.m00 + y * bone.m01;
                partSprite.y._ = bone.worldY + x * bone.m10 + y * bone.m11;
                partSprite.rotation._ = (!region.rotate ? 0 : 90 ) -(bone.worldRotation + regionAttachment.rotation) * flip;
                partSprite.scaleX._ = (bone.worldScaleX + regionAttachment.scaleX - 1) * flipX;
                partSprite.scaleY._ = (bone.worldScaleY + regionAttachment.scaleY - 1) * flipY;
                partSprite.visible = true;
            }
        }
    }

    /** The container for this skeleton. */
    private var _holder :Entity;
    /** If the running animation should loop or not. */
    private var _loop :String;
    /** The animation state data. */
    private var _state (default, null) :AnimationState;
}
