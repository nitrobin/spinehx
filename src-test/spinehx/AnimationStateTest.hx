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

class AnimationStateTest extends Sprite {

    var renderer:SkeletonRenderer;
    var debugRenderer:SkeletonRendererDebug;

    var atlas:TextureAtlas;
    var skeleton:Skeleton;
    var root_:Bone;
    var state:AnimationState;
    var lastTime:Float = 0.0;

    var mode:Int = 1;

    public function new() {
        super();

        atlas = TextureAtlas.create(Assets.getText("assets/spineboy.atlas"), "assets/", new BitmapDataTextureLoader());
        var json = SkeletonJson.create(atlas);
        var skeletonData:SkeletonData = json.readSkeletonData("spineboy", Assets.getText("assets/spineboy.json"));

        // Define mixing between animations.
        var stateData = new AnimationStateData(skeletonData);
        stateData.setMixByName("walk", "jump", 0.2);
        stateData.setMixByName("jump", "walk", 0.4);
        stateData.setMixByName("jump", "jump", 0.2);

        state = new AnimationState(stateData);
        state.setAnimationByName("walk", true);

        skeleton = Skeleton.create(skeletonData);

        skeleton.setX(150);
        skeleton.setY(360);
        skeleton.setFlipY(true);

        skeleton.updateWorldTransform();

        lastTime = haxe.Timer.stamp();

        renderer = new SkeletonRenderer(skeleton);
        debugRenderer = new SkeletonRendererDebug(skeleton);
        addChild(renderer);
        addChild(debugRenderer);
        addChild(new FPS());

        addEventListener(Event.ENTER_FRAME, render);
        addEventListener(Event.ADDED_TO_STAGE, added);
    }

    public function added(e:Event):Void {
        this.mouseChildren = false;
        stage.addEventListener(MouseEvent.CLICK, onClick);
    }
    public function onClick(e:Event):Void {
//        mode++;
//        mode%=3;
        state.setAnimationByName("jump", false);
        state.addAnimationByNameSimple("walk", true);
    }

    public function render(e:Event):Void {
        var delta = (haxe.Timer.stamp() - lastTime) / 3;
        lastTime = haxe.Timer.stamp();
        state.update(delta);
        state.apply(skeleton);
        if (state.getAnimation().getName() == "walk") {
            // After one second, change the current animation. Mixing is done by AnimationState for you.
            if (state.getTime() > 2) state.setAnimationByName("jump", false);
        } else {
            if (state.getTime() > 1) state.setAnimationByName("walk", true);
        }

        skeleton.updateWorldTransform();

        if(mode == 0 || mode == 1){
            renderer.visible = true;
            renderer.draw();
        } else renderer.visible = false;
        if(mode == 0 || mode == 2){
            debugRenderer.visible = true;
            debugRenderer.draw();
        } else debugRenderer.visible = false;

    }

}
