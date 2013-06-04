package spinehx;
import spinehx.renderers.SkeletonRendererDebug;
import spinehx.renderers.SkeletonRenderer;
import spinehx.atlas.TextureAtlas;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

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

        atlas = TextureAtlas.create("assets/spineboy.atlas", "assets/");
        var json = SkeletonJson.create(atlas);
        var skeletonData:SkeletonData = json.readSkeletonData("spineboy", nme.Assets.getText("assets/spineboy.json"));

        // Define mixing between animations.
        var stateData = new AnimationStateData(skeletonData);
        stateData.setMixByName("walk", "jump", 0.4);
        stateData.setMixByName("jump", "walk", 0.4);

        state = new AnimationState(stateData);
        state.setAnimationByName("walk", true);

        skeleton = Skeleton.create(skeletonData);

        root_ = skeleton.getRootBone();
        root_.setX(150);
        root_.setY(360);
        skeleton.setFlipY(true);

        skeleton.updateWorldTransform();

        lastTime = haxe.Timer.stamp();

        renderer = new SkeletonRenderer(skeleton);
        debugRenderer = new SkeletonRendererDebug(skeleton);
        addChild(renderer);
        addChild(debugRenderer);
        addChild(new nme.display.FPS());

        addEventListener(Event.ENTER_FRAME, render);
        addEventListener(Event.ADDED_TO_STAGE, added);
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
