// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.core;

import haxe.Timer;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.display.Stage3D;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DCompareMode;
import openfl.display3D.Context3DRenderMode;
import openfl.display3D.Context3DStencilAction;
import openfl.display3D.Context3DTriangleFace;
import openfl.display3D.Program3D;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.errors.IllegalOperationError;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.geom.Rectangle;
import openfl.gl.GLShader;
import openfl.Lib;
import openfl.system.Capabilities;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.ui.Mouse;
import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;
import openfl.utils.ByteArray;
import starling.events.EnterFrameEvent;
import starling.utils.StarlingUtils;

import starling.events.KeyboardEvent;
import starling.animation.Juggler;
import starling.display.DisplayObject;
import starling.display.Stage;
import starling.events.EventDispatcher;
import starling.events.ResizeEvent;
import starling.events.TouchPhase;
import starling.events.TouchProcessor;
import starling.utils.HAlign;
import starling.utils.SystemUtil;
import starling.utils.VAlign;

/** Dispatched when a new render context is created. The 'data' property references the context. */
@:meta(Event(name='context3DCreate', type='starling.events.Event'))

/** Dispatched when the root class has been created. The 'data' property references that object. */
@:meta(Event(name='rootCreated', type='starling.events.Event'))

/** Dispatched when a fatal error is encountered. The 'data' property contains an error string. */
@:meta(Event(name='fatalError', type='starling.events.Event'))

/** The Starling class represents the core of the Starling framework.
 *
 *  <p>The Starling framework makes it possible to create 2D applications and games that make
 *  use of the Stage3D architecture introduced in Flash Player 11. It implements a display tree
 *  system that is very similar to that of conventional Flash, while leveraging modern GPUs
 *  to speed up rendering.</p>
 *  
 *  <p>The Starling class represents the link between the conventional Flash display tree and
 *  the Starling display tree. To create a Starling-powered application, you have to create
 *  an instance of the Starling class:</p>
 *  
 *  <pre>var starling:Starling = new Starling(Game, stage);</pre>
 *  
 *  <p>The first parameter has to be a Starling display object class, e.g. a subclass of 
 *  <code>starling.display.Sprite</code>. In the sample above, the class "Game" is the
 *  application root. An instance of "Game" will be created as soon as Starling is initialized.
 *  The second parameter is the conventional (Flash) stage object. Per default, Starling will
 *  display its contents directly below the stage.</p>
 *  
 *  <p>It is recommended to store the Starling instance as a member variable, to make sure
 *  that the Garbage Collector does not destroy it. After creating the Starling object, you 
 *  have to start it up like this:</p>
 * 
 *  <pre>starling.start();</pre>
 * 
 *  <p>It will now render the contents of the "Game" class in the frame rate that is set up for
 *  the application (as defined in the Flash stage).</p> 
 * 
 *  <strong>Context3D Profiles</strong>
 * 
 *  <p>Stage3D supports different rendering profiles, and Starling works with all of them. The
 *  last parameter of the Starling constructor allows you to choose which profile you want.
 *  The following profiles are available:</p>
 * 
 *  <ul>
 *    <li>BASELINE_CONSTRAINED: provides the broadest hardware reach. If you develop for the
 *        browser, this is the profile you should test with.</li>
 *    <li>BASELINE: recommend for any mobile application, as it allows Starling to use a more
 *        memory efficient texture type (RectangleTextures). It also supports more complex
 *        AGAL code.</li>
 *    <li>BASELINE_EXTENDED: adds support for textures up to 4096x4096 pixels. This is
 *        especially useful on mobile devices with very high resolutions.</li>
 *  </ul>
 *  
 *  <p>The recommendation is to deploy your app with the profile "auto" (which makes Starling
 *  pick the best available of those three), but test it in all available profiles.</p>
 *  
 *  <strong>Accessing the Starling object</strong>
 * 
 *  <p>From within your application, you can access the current Starling object anytime
 *  through the static method <code>Starling.current</code>. It will return the active Starling
 *  instance (most applications will only have one Starling object, anyway).</p> 
 * 
 *  <strong>Viewport</strong>
 * 
 *  <p>The area the Starling content is rendered into is, per default, the complete size of the 
 *  stage. You can, however, use the "viewPort" property to change it. This can be  useful 
 *  when you want to render only into a part of the screen, or if the player size changes. For
 *  the latter, you can listen to the RESIZE-event dispatched by the Starling
 *  stage.</p>
 * 
 *  <strong>Native overlay</strong>
 *  
 *  <p>Sometimes you will want to display native Flash content on top of Starling. That's what the
 *  <code>nativeOverlay</code> property is for. It returns a Flash Sprite lying directly
 *  on top of the Starling content. You can add conventional Flash objects to that overlay.</p>
 *  
 *  <p>Beware, though, that conventional Flash content on top of 3D content can lead to
 *  performance penalties on some (mobile) platforms. For that reason, always remove all child
 *  objects from the overlay when you don't need them any longer. Starling will remove the 
 *  overlay from the display list when it's empty.</p>
 *  
 *  <strong>Multitouch</strong>
 *  
 *  <p>Starling supports multitouch input on devices that provide it. During development, 
 *  where most of us are working with a conventional mouse and keyboard, Starling can simulate 
 *  multitouch events with the help of the "Shift" and "Ctrl" (Mac: "Cmd") keys. Activate
 *  this feature by enabling the <code>simulateMultitouch</code> property.</p>
 *  
 *  <strong>Handling a lost render context</strong>
 *  
 *  <p>On some operating systems and under certain conditions (e.g. returning from system
 *  sleep), Starling's stage3D render context may be lost. Starling can recover from a lost
 *  context if the class property "handleLostContext" is set to "true". Keep in mind, however, 
 *  that this comes at the price of increased memory consumption; Starling will cache textures 
 *  in RAM to be able to restore them when the context is lost. (Except if you use the
 *  'AssetManager' for your textures. It is smart enough to recreate a texture directly
 *  from its origin.)</p> 
 *  
 *  <p>In case you want to react to a context loss, Starling dispatches an event with
 *  the type "Event.CONTEXT3D_CREATE" when the context is restored. You can recreate any 
 *  invalid resources in a corresponding event listener.</p>
 * 
 *  <strong>Sharing a 3D Context</strong>
 * 
 *  <p>Per default, Starling handles the Stage3D context itself. If you want to combine
 *  Starling with another Stage3D engine, however, this may not be what you want. In this case,
 *  you can make use of the <code>shareContext</code> property:</p> 
 *  
 *  <ol>
 *    <li>Manually create and configure a context3D object that both frameworks can work with
 *        (through <code>stage3D.requestContext3D</code> and
 *        <code>context.configureBackBuffer</code>).</li>
 *    <li>Initialize Starling with the stage3D instance that contains that configured context.
 *        This will automatically enable <code>shareContext</code>.</li>
 *    <li>Call <code>start()</code> on your Starling instance (as usual). This will make  
 *        Starling queue input events (keyboard/mouse/touch).</li>
 *    <li>Create a game loop (e.g. using the native <code>ENTER_FRAME</code> event) and let it  
 *        call Starling's <code>nextFrame</code> as well as the equivalent method of the other 
 *        Stage3D engine. Surround those calls with <code>context.clear()</code> and 
 *        <code>context.present()</code>.</li>
 *  </ol>
 *  
 *  <p>The Starling wiki contains a <a href="http://goo.gl/BsXzw">tutorial</a> with more 
 *  information about this topic.</p>
 * 
 */ 
class Starling extends EventDispatcher
{
	/** The version of the Starling framework. */
	public static var VERSION:String = "1.6.1";
	
	/** The key for the shader programs stored in 'contextData' */
	private static var PROGRAM_DATA_NAME:String = "Starling.programs"; 
	
	// members
	
	private var mStage3D:Stage3D;
	private var mStage:Stage; // starling.display.stage!
	private var mRootClass:Class<Dynamic>;
	private var mRoot:DisplayObject;
	private var mJuggler:Juggler;
	private var mSupport:RenderSupport;
	private var mTouchProcessor:TouchProcessor;
	private var mAntiAliasing:Int;
	private var mSimulateMultitouch:Bool;
	private var mEnableErrorChecking:Bool;
	private var mLastFrameTimestamp:Float;
	private var mLeftMouseDown:Bool;
	private var mStatsDisplay:StatsDisplay;
	private var mShareContext:Bool = false;
	private var mProfile:String;
	private var mContext:Context3D;
	private var mStarted:Bool;
	private var mRendering:Bool;
	private var mSupportHighResolutions:Bool;
	
	private var mViewPort:Rectangle;
	private var mPreviousViewPort:Rectangle;
	private var mClippedViewPort:Rectangle;

	private var mNativeStage:flash.display.Stage;
	private var mNativeOverlay:flash.display.Sprite;
	private var mNativeStageContentScaleFactor:Float;

	private static var sCurrent:Starling;
	private static var sHandleLostContext:Bool = true;
	private static var sContextData = new Map<Stage3D, Map<String, Dynamic>>();
	private static var sAll = new Array<Starling>();
	var profiles:Array<String>;
	var currentProfile:String;
	var tempRenderMode:String;
	private var stageWidth:Int;
	private var stageHeight:Int;
	private var statsHAlign:HAlign;
	private var statsVAlign:VAlign;
	private var statsScale:Float;
	
	private var touchEventTypes(get, null):Array<Dynamic>;
	
	private var programs(get, null):Map<String, Program3D>;
	public var isStarted(get, null):Bool;
	public var juggler(get, null):Juggler;
	public var context(get, null):Context3D;
	public var contextData(get, null):Map<String, Dynamic>;
	public var backBufferWidth(get, null):Int;
	public var backBufferHeight(get, null):Int;
	public var backBufferPixelsPerPoint(get, null):Int;
	public var simulateMultitouch(get, set):Bool;
	public var enableErrorChecking(get, set):Bool;
	public var antiAliasing(get, set):Int;
	public var viewPort(get, set):Rectangle;
	public var contentScaleFactor(get, null):Float;
	public var nativeOverlay(get, null):Sprite;
	public var showStats(get, set):Bool;
	public var stage(get, null):Stage;
	public var stage3D(get, null):Stage3D;
	public var nativeStage(get, null):flash.display.Stage;
	public var root(get, null):DisplayObject;
	public var rootClass(get, set):Class<Dynamic>;
	public var shareContext(get, set) : Bool;
	public var profile(get, null):String;
	public var supportHighResolutions(get, set):Bool;
	public var touchProcessor(get, set):TouchProcessor;
	public var contextValid(get, null):Bool;
	public static var current(get, null):Starling;
	public static var all(get, null):Array<Starling>;
	public static var Context(get, null):Context3D;
	public static var Juggler(get, null):Juggler;
	public static var ContentScaleFactor(get, null):Float;
	public static var multitouchEnabled(get, set):Bool;
	public static var handleLostContext(get, set):Bool;
	
	// construction
	
	/** Creates a new Starling instance. 
	 *  @param rootClass  A subclass of 'starling.display.DisplayObject'. It will be created
	 *                    as soon as initialization is finished and will become the first child
	 *                    of the Starling stage. Pass <code>null</code> if you don't want to
	 *                    create a root object right away. (You can use the
	 *                    <code>rootClass</code> property later to make that happen.)
	 *  @param stage      The Flash (2D) stage.
	 *  @param viewPort   A rectangle describing the area into which the content will be 
	 *                    rendered. Default: stage size
	 *  @param stage3D    The Stage3D object into which the content will be rendered. If it 
	 *                    already contains a context, <code>sharedContext</code> will be set
	 *                    to <code>true</code>. Default: the first available Stage3D.
	 *  @param renderMode The Context3D render mode that should be requested.
	 *                    Use this parameter if you want to force "software" rendering.
	 *  @param profile    The Context3D profile that should be requested.
	 *
	 *                    <ul>
	 *                    <li>If you pass a profile String, this profile is enforced.</li>
	 *                    <li>Pass an Array of profiles to make Starling pick the first
	 *                        one that works (starting with the first array element).</li>
	 *                    <li>Pass the String "auto" to make Starling pick the best available
	 *                        profile automatically.</li>
	 *                    </ul>
	 */
	public function new(rootClass:Class<Dynamic>, stage:flash.display.Stage, 
							 viewPort:Rectangle=null, stage3D:Stage3D=null,
							 renderMode:String="auto", profile:Dynamic="baselineConstrained")
	{
		super();
		if (stage == null) throw new ArgumentError("Stage must not be null");
		if (viewPort == null) viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		if (stage3D == null) stage3D = stage.stage3Ds[0];

		SystemUtil.initialize();
		sAll.push(this);
		makeCurrent();
		
		mRootClass = rootClass;
		mViewPort = viewPort;
		mPreviousViewPort = new Rectangle();
		mStage3D = stage3D;
		mStage = new Stage(Std.int(viewPort.width), Std.int(viewPort.height), stage.color);
		mNativeOverlay = new Sprite();
		mNativeStage = stage;
		mNativeStage.addChild(mNativeOverlay);
		mNativeStageContentScaleFactor = 1.0;
		mTouchProcessor = new TouchProcessor(mStage);
		mJuggler = new Juggler();
		mAntiAliasing = 0;
		mSimulateMultitouch = false;
		mEnableErrorChecking = false;
		mSupportHighResolutions = false;
		mLastFrameTimestamp = Lib.getTimer() / 1000.0;
		mSupport  = new RenderSupport();
		
		// for context data, we actually reference by stage3D, since it survives a context loss
		sContextData[stage3D] = new Map<String, Map<String, Dynamic>>();
		sContextData[stage3D][PROGRAM_DATA_NAME] = new Map<String, Dynamic>();

		// all other modes are problematic in Starling, so we force those here
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		// register touch/mouse event handlers            
		for (touchEventType in touchEventTypes) {
			stage.addEventListener(touchEventType, onTouch, false, 0, true);
		}
		
		// register other event handlers
		stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, onKey, false, 0, true);
		stage.addEventListener(openfl.events.KeyboardEvent.KEY_UP, onKey, false, 0, true);
		stage.addEventListener(Event.RESIZE, onResize, false, 0, true);
		stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave, false, 0, true);
		
		mStage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated, false, 10, true);
		mStage3D.addEventListener(ErrorEvent.ERROR, onStage3DError, false, 10, true);
		
		if (mStage3D.context3D != null && mStage3D.context3D.driverInfo != "Disposed")
		{
			if (profile == "auto" || Std.is(profile, Array))
				throw new ArgumentError("When sharing the context3D, " +
					"the actual profile has to be supplied");
			else {
				//mProfile = "profile" in mStage3D.context3D ? mStage3D.context3D["profile"] : cast profile;
				mProfile = Reflect.hasField(mStage3D.context3D, "profile") ? Reflect.getProperty(mStage3D.context3D, "profile") : cast profile;
			}
			
			mShareContext = true;
			Timer.delay(initialize, 1); //Lib.setTimeout(initialize, 1); // we don't call it right away, because Starling should
									   // behave the same way with or without a shared context
		}
		else
		{
			if (!SystemUtil.supportsDepthAndStencil)
				trace("[Starling] Mask support requires 'depthAndStencil' to be enabled" +
					  " in the application descriptor.");
					  
			mShareContext = false;
			requestContext3D(stage3D, renderMode, profile);
		}
	}
	
	/** Disposes all children of the stage and the render context; removes all registered
	 *  event listeners. */
	public function dispose():Void
	{
		stop(true);

		mNativeStage.removeEventListener(Event.ENTER_FRAME, onEnterFrame, false);
		mNativeStage.removeEventListener(openfl.events.KeyboardEvent.KEY_DOWN, onKey, false);
		mNativeStage.removeEventListener(openfl.events.KeyboardEvent.KEY_UP, onKey, false);
		mNativeStage.removeEventListener(Event.RESIZE, onResize, false);
		mNativeStage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave, false);
		mNativeStage.removeChild(mNativeOverlay);
		
		mStage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated, false);
		mStage3D.removeEventListener(ErrorEvent.ERROR, onStage3DError, false);
		
		for (touchEventType in touchEventTypes)
			mNativeStage.removeEventListener(touchEventType, onTouch, false);
		
		if (mStage != null) mStage.dispose();
		if (mSupport != null) mSupport.dispose();
		if (mTouchProcessor != null) mTouchProcessor.dispose();
		if (sCurrent == this) sCurrent = null;
		if (mContext != null && mShareContext) 
		{
			// Per default, the context is recreated as long as there are listeners on it.
			// Beginning with AIR 3.6, we can avoid that with an additional parameter.
			StarlingUtils.execute(mContext.dispose, [false]);
		}

		var index:Int =  sAll.indexOf(this);
		if (index != -1) sAll.splice(index, 1);
	}
	
	// functions
	
	private function requestContext3D(stage3D:Stage3D, renderMode:String, profile:Dynamic):Void
	{
		tempRenderMode = renderMode;
		profiles = null;
		currentProfile = null;
		
		if (profile == "auto")
			profiles = ["standardExtended", "standard", "standardConstrained", "baselineExtended", "baseline", "baselineConstrained"];
		else if (Std.is(profile, String))
			profiles = [cast(profile, String)];
		else if (Std.is(profile, Array))
			profiles = cast (profile);
		else
			throw new ArgumentError("Profile must be of type 'String' or 'Array'");
		
		mStage3D.addEventListener(Event.CONTEXT3D_CREATE, onCreated, false, 100);
		mStage3D.addEventListener(ErrorEvent.ERROR, onError, false, 100);
		
		requestNextProfile();
	}
	
	private function requestNextProfile():Void
	{
		currentProfile = profiles.shift();
		try {
			StarlingUtils.execute(mStage3D.requestContext3D, [tempRenderMode/*, currentProfile*/]);
		}
		catch (error:Error)
		{
			if (profiles.length != 0) Timer.delay(requestNextProfile, 1); // Lib.setTimeout(requestNextProfile, 1);
			else throw error;
		}
	}
	
	private function onCreated(event:Event):Void
	{
		var context:Context3D = stage3D.context3D;
		context.setStencilActions(
			cast Context3DTriangleFace.FRONT_AND_BACK,
			cast Context3DCompareMode.EQUAL, 
			cast Context3DStencilAction.DECREMENT_SATURATE
		);
		
		var renderModeStr:String = "";
		
		//if (tempRenderMode == Context3DRenderMode.AUTO) renderModeStr = "auto";
		//else if (tempRenderMode == Context3DRenderMode.SOFTWARE) renderModeStr = "software";
		
		var auto:String = "auto";
		#if js
			auto = Context3DRenderMode.AUTO.getName();
		#end
		if (tempRenderMode == auto && profiles.length != 0 && context.driverInfo.indexOf("Software") != -1)
		{
			onError(event);
		}
		else
		{
			mProfile = currentProfile;
			onFinished();
		}
	}
	
	private function onError(event:Event):Void
	{
		if (profiles.length != 0)
		{
			event.stopImmediatePropagation();
			Timer.delay(requestNextProfile, 1);
		}
		else onFinished();
	}
	
	private function onFinished():Void
	{
		mStage3D.removeEventListener(Event.CONTEXT3D_CREATE, onCreated);
		mStage3D.removeEventListener(ErrorEvent.ERROR, onError);
	}

	
	private function initialize():Void
	{
		makeCurrent();
		
		initializeGraphicsAPI();
		Timer.delay(initializeRoot, 1);
		
		mTouchProcessor.simulateMultitouch = mSimulateMultitouch;
		mLastFrameTimestamp = Lib.getTimer() / 1000.0;
	}
	
	private function initializeGraphicsAPI():Void
	{
		mContext = mStage3D.context3D;
		mContext.enableErrorChecking = mEnableErrorChecking;
		contextData[PROGRAM_DATA_NAME] = new Map<String, Dynamic>();
		
		trace("[Starling] Initialization complete.");
		trace("[Starling] Display Driver:", mContext.driverInfo);
		
		#if flash
			mNativeStage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		#else
			mContext.setRenderMethod(onEnterFrame);
		#end
		
		updateViewPort(true);
		dispatchEventWith(Event.CONTEXT3D_CREATE, false, mContext);
	}
	
	private function initializeRoot():Void
	{
		if (mRoot == null && mRootClass != null)
		{
			mRoot = cast (Type.createInstance(mRootClass, []), DisplayObject);
			if (mRoot == null) throw new Error("Invalid root class: " + mRootClass);
			mStage.addChildAt(mRoot, 0);
			dispatchEventWith(starling.events.Event.ROOT_CREATED, false, mRoot);
		}
	}
	
	/** Calls <code>advanceTime()</code> (with the time that has passed since the last frame)
	 *  and <code>render()</code>. */ 
	public function nextFrame():Void
	{
		var now:Float = Lib.getTimer() / 1000.0;
		var passedTime:Float = now - mLastFrameTimestamp;
		mLastFrameTimestamp = now;
		
		// to avoid overloading time-based animations, the maximum delta is truncated.
		if (passedTime > 1.0) passedTime = 1.0;
		
		advanceTime(passedTime);
		render();
	}
	
	/** Dispatches ENTER_FRAME events on the display list, advances the Juggler 
	 *  and processes touches. */
	public function advanceTime(passedTime:Float):Void
	{
		if (!contextValid)
			return;
		
		makeCurrent();
		
		mTouchProcessor.advanceTime(passedTime);
		mStage.advanceTime(passedTime);
		mJuggler.advanceTime(passedTime);
	}
	
	/** Renders the complete display list. Before rendering, the context is cleared; afterwards,
	 *  it is presented. This can be avoided by enabling <code>shareContext</code>.*/ 
	public function render():Void
	{
		if (!contextValid)
			return;
		
		makeCurrent();
		updateViewPort();
		mSupport.nextFrame();
		
		var scaleX:Float = mViewPort.width  / mStage.stageWidth;
		var scaleY:Float = mViewPort.height / mStage.stageHeight;
		
		mContext.setDepthTest(false, Context3DCompareMode.ALWAYS);
		mContext.setCulling(Context3DTriangleFace.NONE);
		
		//mContext.setStencilReferenceValue(0);
		
		mSupport.stencilReferenceValue = 0;
		mSupport.renderTarget = null; // back buffer
		mSupport.setProjectionMatrix(
			mViewPort.x < 0 ? -mViewPort.x / scaleX : 0.0,
			mViewPort.y < 0 ? -mViewPort.y / scaleY : 0.0,
			mClippedViewPort.width  / scaleX,
			mClippedViewPort.height / scaleY,
			mStage.stageWidth, mStage.stageHeight, mStage.cameraPosition);
		
		if (mShareContext == false)
			RenderSupport.Clear(mStage.color, 1.0);
		
		
		mStage.render(mSupport, 1.0);
		mSupport.finishQuadBatch();
		
		if (mStatsDisplay != null)
			mStatsDisplay.drawCount = mSupport.drawCount;
		
		if (mShareContext == false)
			mContext.present();
		
	}
	
	private function updateViewPort(forceUpdate:Bool=false):Void
	{
		// the last set viewport is stored in a variable; that way, people can modify the
		// viewPort directly (without a copy) and we still know if it has changed.
		
		if (forceUpdate || mPreviousViewPort.width != mViewPort.width || 
			mPreviousViewPort.height != mViewPort.height ||
			mPreviousViewPort.x != mViewPort.x || mPreviousViewPort.y != mViewPort.y)
		{
			mPreviousViewPort.setTo(mViewPort.x, mViewPort.y, mViewPort.width, mViewPort.height);
			
			// Constrained mode requires that the viewport is within the native stage bounds;
			// thus, we use a clipped viewport when configuring the back buffer. (In baseline
			// mode, that's not necessary, but it does not hurt either.)
			
			mClippedViewPort = mViewPort.intersection(
				new Rectangle(0, 0, mNativeStage.stageWidth, mNativeStage.stageHeight));
			
			if (!mShareContext)
			{
				// setting x and y might move the context to invalid bounds (since changing
				// the size happens in a separate operation) -- so we have no choice but to
				// set the backbuffer to a very small size first, to be on the safe side.
				
				if (mProfile == "baselineConstrained")
					configureBackBuffer(32, 32, mAntiAliasing, true);
				
				mStage3D.x = mClippedViewPort.x;
				mStage3D.y = mClippedViewPort.y;
				
				configureBackBuffer(Std.int(mClippedViewPort.width), Std.int(mClippedViewPort.height),
					mAntiAliasing, true, mSupportHighResolutions);
				
				if (mSupportHighResolutions && Reflect.hasField(mNativeStage, "contentsScaleFactor"))
					mNativeStageContentScaleFactor = Reflect.getProperty(mNativeStage, "contentsScaleFactor");// mNativeStage["contentsScaleFactor"];
				else
					mNativeStageContentScaleFactor = 1.0;
			}
		}
	}
	
	/** Configures the back buffer while automatically keeping backwards compatibility with
	 *  AIR versions that do not support the "wantsBestResolution" argument. */
	private function configureBackBuffer(width:Int, height:Int, antiAlias:Int, 
										 enableDepthAndStencil:Bool,
										 wantsBestResolution:Bool=false):Void
	{
		// CHECK
		//enableDepthAndStencil &&= SystemUtil.supportsDepthAndStencil;
		if (enableDepthAndStencil && SystemUtil.supportsDepthAndStencil) enableDepthAndStencil = true;
		else enableDepthAndStencil = false;
		
		//var configureBackBuffer:StarlingFunction = mContext.configureBackBuffer;
		//var methodArgs:Array<Dynamic> = [width, height, antiAlias, enableDepthAndStencil];
		//if (configureBackBuffer.length > 4) methodArgs.push(wantsBestResolution);
		//trace("configureBackBuffer = " + configureBackBuffer);
		mContext.configureBackBuffer(width, height, antiAlias, enableDepthAndStencil);
	}

	private function updateNativeOverlay():Void
	{
		mNativeOverlay.x = mViewPort.x;
		mNativeOverlay.y = mViewPort.y;
		mNativeOverlay.scaleX = mViewPort.width / mStage.stageWidth;
		mNativeOverlay.scaleY = mViewPort.height / mStage.stageHeight;
	}
	
	/** Stops Starling right away and displays an error message on the native overlay.
	 *  This method will also cause Starling to dispatch a FATAL_ERROR event. */
	public function stopWithFatalError(message:String):Void
	{
		var background:Shape = new Shape();
		background.graphics.beginFill(0x0, 0.8);
		background.graphics.drawRect(0, 0, mStage.stageWidth, mStage.stageHeight);
		background.graphics.endFill();

		var textField:TextField = new TextField();
		var textFormat:TextFormat = new TextFormat("Verdana", 14, 0xFFFFFF);
		textFormat.align = TextFormatAlign.CENTER;
		textField.defaultTextFormat = textFormat;
		textField.wordWrap = true;
		textField.width = mStage.stageWidth * 0.75;
		textField.autoSize = TextFieldAutoSize.CENTER;
		textField.text = message;
		textField.x = (mStage.stageWidth  - textField.width)  / 2;
		textField.y = (mStage.stageHeight - textField.height) / 2;
		textField.background = true;
		textField.backgroundColor = 0x550000;

		updateNativeOverlay();
		nativeOverlay.addChild(background);
		nativeOverlay.addChild(textField);
		stop(true);

		trace("[Starling]", message);
		dispatchEventWith(starling.events.Event.FATAL_ERROR, false, message);
	}
	
	/** Make this Starling instance the <code>current</code> one. */
	public function makeCurrent():Void
	{
		sCurrent = this;
	}
	
	/** As soon as Starling is started, it will queue input events (keyboard/mouse/touch);   
	 *  furthermore, the method <code>nextFrame</code> will be called once per Flash Player
	 *  frame. (Except when <code>shareContext</code> is enabled: in that case, you have to
	 *  call that method manually.) */
	public function start():Void 
	{ 
		mStarted = mRendering = true;
		mLastFrameTimestamp = Lib.getTimer() / 1000.0;
	}
	
	/** Stops all logic and input processing, effectively freezing the app in its current state.
	 *  Per default, rendering will continue: that's because the classic display list
	 *  is only updated when stage3D is. (If Starling stopped rendering, conventional Flash
	 *  contents would freeze, as well.)
	 *  
	 *  <p>However, if you don't need classic Flash contents, you can stop rendering, too.
	 *  On some mobile systems (e.g. iOS), you are even required to do so if you have
	 *  activated background code execution.</p>
	 */
	public function stop(suspendRendering:Bool=false):Void
	{ 
		mStarted = false;
		mRendering = !suspendRendering;
	}
	
	// event handlers
	
	private function onStage3DError(event:ErrorEvent):Void
	{
		if (event.errorID == 3702)
		{
			var mode:String = Capabilities.playerType == "Desktop" ? "renderMode" : "wmode";
			stopWithFatalError("Context3D not available! Possible reasons: wrong " + mode +
							   " or missing device support.");
		}
		else
			stopWithFatalError("Stage3D error: " + event.text);
	}
	
	private function onContextCreated(event:Event):Void
	{
		if (!Starling.handleLostContext && mContext != null)
		{
			event.stopImmediatePropagation();
			stopWithFatalError("The application lost the device context!");
			trace("[Starling] Enable 'Starling.handleLostContext' to avoid this error.");
		}
		else
		{
			initialize();
		}
	}
	
	private function onEnterFrame(event:Event):Void
	{
		// On mobile, the native display list is only updated on stage3D draw calls.
		// Thus, we render even when Starling is paused.
		
		if (!mShareContext)
		{
			if (mStarted) nextFrame();
			else if (mRendering) render();
		}

		updateNativeOverlay();
	}
	
	private function onKey(event:openfl.events.KeyboardEvent):Void
	{
		if (mStarted == true) return;
		
		var keyEvent:starling.events.KeyboardEvent = new starling.events.KeyboardEvent(event.type, cast event.charCode, cast event.keyCode, cast event.keyLocation, event.ctrlKey, event.altKey, event.shiftKey);
		
		makeCurrent();
		mStage.broadcastEvent(keyEvent);
		
		//if (keyEvent.isDefaultPrevented()) {
			//event.preventDefault();
		//}
	}
	
	private function onResize(event:Event):Void
	{
		stageWidth  = event.target.stageWidth;
		stageHeight = event.target.stageHeight;

		if (contextValid)
			dispatchResizeEvent();
		else
			addEventListener(Event.CONTEXT3D_CREATE, dispatchResizeEvent);
	}
	
	private function dispatchResizeEvent():Void
	{
		// on Android, the context is not valid while we're resizing. To avoid problems
		// with user code, we delay the event dispatching until it becomes valid again.
		
		makeCurrent();
		removeEventListener(Event.CONTEXT3D_CREATE, dispatchResizeEvent);
		mStage.dispatchEvent(new ResizeEvent(Event.RESIZE, stageWidth, stageHeight));
	}
	
	private function onMouseLeave(event:Event):Void
	{
		mTouchProcessor.enqueueMouseLeftStage();
	}
	
	private function onTouch(event:Event):Void
	{
		if (mStarted == false) return;
		
		var globalX:Float;
		var globalY:Float;
		var touchID:Int;
		var phase:String = null;
		var pressure:Float = 1.0;
		var width:Float = 1.0;
		var height:Float = 1.0;
		
		// figure out general touch properties
		if (Std.is(event, MouseEvent))
		{
			var mouseEvent:MouseEvent = cast event;
			globalX = mouseEvent.stageX;
			globalY = mouseEvent.stageY;
			touchID = 0;
			
			// MouseEvent.buttonDown returns true for both left and right button (AIR supports
			// the right mouse button). We only want to react on the left button for now,
			// so we have to save the state for the left button manually.
			if (event.type == MouseEvent.MOUSE_DOWN)    mLeftMouseDown = true;
			else if (event.type == MouseEvent.MOUSE_UP) mLeftMouseDown = false;
		}
		else
		{
			var touchEvent:TouchEvent = cast event;
			// On a system that supports both mouse and touch input, the primary touch point
			// is dispatched as mouse event as well. Since we don't want to listen to that
			// event twice, we ignore the primary touch in that case.
			
			trace("FIX"); // update when Mouse.supportsCursor becomes available
			if (/*Mouse.supportsCursor &&*/ touchEvent.isPrimaryTouchPoint) return;
			else
			{
				globalX  = touchEvent.stageX;
				globalY  = touchEvent.stageY;
				touchID  = touchEvent.touchPointID;
				pressure = touchEvent.pressure;
				width    = touchEvent.sizeX;
				height   = touchEvent.sizeY;
			}
		}
		
		// figure out touch phase
		switch (event.type)
		{
			case TouchEvent.TOUCH_BEGIN: phase = TouchPhase.BEGAN;
			case TouchEvent.TOUCH_MOVE:  phase = TouchPhase.MOVED; 
			case TouchEvent.TOUCH_END:   phase = TouchPhase.ENDED; 
			case MouseEvent.MOUSE_DOWN:  phase = TouchPhase.BEGAN; 
			case MouseEvent.MOUSE_UP:    phase = TouchPhase.ENDED; 
			case MouseEvent.MOUSE_MOVE: 
				phase = (mLeftMouseDown ? TouchPhase.MOVED : TouchPhase.HOVER); 
		}
		
		// move position into viewport bounds
		globalX = mStage.stageWidth  * (globalX - mViewPort.x) / mViewPort.width;
		globalY = mStage.stageHeight * (globalY - mViewPort.y) / mViewPort.height;
		
		
		// enqueue touch in touch processor
		if (phase != null) mTouchProcessor.enqueue(touchID, phase, globalX, globalY, pressure, width, height);
		
		#if flash
			// allow objects that depend on mouse-over state to be updated immediately
			if (event.type == MouseEvent.MOUSE_UP) {
				mTouchProcessor.enqueue(touchID, TouchPhase.HOVER, globalX, globalY);
			}
		#end
	}
	
	private function get_touchEventTypes():Array<Dynamic>
	{
		var types = new Array<String>();
		
		if (multitouchEnabled == true) {
			types.push(TouchEvent.TOUCH_BEGIN);
			types.push(TouchEvent.TOUCH_MOVE);
			types.push(TouchEvent.TOUCH_END);
		}
		
		//if (multitouchEnabled == false /*|| Mouse.supportsCursor*/) {
			types.push(MouseEvent.MOUSE_DOWN);
			types.push(MouseEvent.MOUSE_MOVE);
			types.push(MouseEvent.MOUSE_UP);
		//}
		
		return types;
	}
	
	// program management
	
	/** Registers a compiled shader-program under a certain name.
	 *  If the name was already used, the previous program is overwritten. */
	public function registerProgram(name:String, vertexShader:GLShader, fragmentShader:GLShader):Program3D
	{
		deleteProgram(name);
		
		var program:Program3D = mContext.createProgram();
		program.upload(cast vertexShader, cast fragmentShader);
		programs[name] = program;
		return program;
	}
	
	/** Compiles a shader-program and registers it under a certain name.
	 *  If the name was already used, the previous program is overwritten. */
	public function registerProgramFromSource(name:String, vertexShader:String,
											  fragmentShader:String):Program3D
	{
		deleteProgram(name);
		
		var program:Program3D = RenderSupport.assembleAgal(vertexShader, fragmentShader);
		programs[name] = program;
		
		return program;
	}
	
	/** Deletes the vertex- and fragment-programs of a certain name. */
	public function deleteProgram(name:String):Void
	{
		var program:Program3D = getProgram(name);            
		if (program != null)
		{                
			program.dispose();
			programs.remove(name);
		}
	}
	
	/** Returns the vertex- and fragment-programs registered under a certain name. */
	public function getProgram(name:String):Program3D
	{
		return cast programs[name];
	}
	
	/** Indicates if a set of vertex- and fragment-programs is registered under a certain name. */
	public function hasProgram(name:String):Bool
	{
		return programs.exists(name);// return name in programs;
	}
	
	private function get_programs():Map<String, Program3D> { return contextData.get(PROGRAM_DATA_NAME); }
	
	// properties
	
	/** Indicates if this Starling instance is started. */
	private function get_isStarted():Bool { return mStarted; }
	
	/** The default juggler of this instance. Will be advanced once per frame. */
	private function get_juggler():Juggler { return mJuggler; }
	
	/** The render context of this instance. */
	private function get_context():Context3D { return mContext; }
	
	/** A Map that can be used to save custom data related to the current context. 
	 *  If you need to share data that is bound to a specific stage3D instance
	 *  (e.g. textures), use this Map instead of creating a static class variable.
	 *  The Map is actually bound to the stage3D instance, thus it survives a 
	 *  context loss. */
	private function get_contextData():Map<String, Dynamic>
	{
		return sContextData.get(mStage3D);
	}
	
	/** Returns the current width of the back buffer. In most cases, this value is in pixels;
	 *  however, if the app is running on an HiDPI display with an activated
	 *  'supportHighResolutions' setting, you have to multiply with 'backBufferPixelsPerPoint'
	 *  for the actual pixel count. */
	private function get_backBufferWidth():Int { return Std.int(mClippedViewPort.width); }

	/** Returns the current height of the back buffer. In most cases, this value is in pixels;
	 *  however, if the app is running on an HiDPI display with an activated
	 *  'supportHighResolutions' setting, you have to multiply with 'backBufferPixelsPerPoint'
	 *  for the actual pixel count.  */
	private function get_backBufferHeight():Int { return Std.int(mClippedViewPort.height); }

	/** The number of pixel per point returned by the 'backBufferWidth/Height' properties.
	 *  Except for desktop HiDPI displays with an activated 'supportHighResolutions' setting,
	 *  this will always return '1'. */
	private function get_backBufferPixelsPerPoint():Int
	{
		return cast mNativeStageContentScaleFactor;
	}

	/** Indicates if multitouch simulation with "Shift" and "Ctrl"/"Cmd"-keys is enabled.
	 *  @default false */
	private function get_simulateMultitouch():Bool { return mSimulateMultitouch; }
	private function set_simulateMultitouch(value:Bool):Bool
	{
		mSimulateMultitouch = value;
		if (mContext != null) mTouchProcessor.simulateMultitouch = value;
		return value;
	}
	
	/** Indicates if Stage3D render methods will report errors. Activate only when needed,
	 *  as this has a negative impact on performance. @default false */
	private function get_enableErrorChecking():Bool { return mEnableErrorChecking; }
	private function set_enableErrorChecking(value:Bool):Bool 
	{ 
		mEnableErrorChecking = value;
		if (mContext != null) mContext.enableErrorChecking = value;
		return value;
	}
	
	/** The antialiasing level. 0 - no antialasing, 16 - maximum antialiasing. @default 0 */
	private function get_antiAliasing():Int { return mAntiAliasing; }
	private function set_antiAliasing(value:Int):Int
	{
		if (mAntiAliasing != value)
		{
			mAntiAliasing = value;
			if (contextValid) updateViewPort(true);
		}
		return value;
	}
	
	/** The viewport into which Starling contents will be rendered. */
	private function get_viewPort():Rectangle { return mViewPort; }
	private function set_viewPort(value:Rectangle):Rectangle
	{
		mViewPort = value.clone();
		return value;
	}
	
	/** The ratio between viewPort width and stage width. Useful for choosing a different
	 *  set of textures depending on the display resolution. */
	private function get_contentScaleFactor():Float
	{
		return (mViewPort.width * mNativeStageContentScaleFactor) / mStage.stageWidth;
	}
	
	/** A Flash Sprite placed directly on top of the Starling content. Use it to display native
	 *  Flash components. */ 
	private function get_nativeOverlay():Sprite { return mNativeOverlay; }
	
	/** Indicates if a small statistics box (with FPS, memory usage and draw count) is
	 *  displayed.
	 *
	 *  <p>Beware that the memory usage should be taken with a grain of salt. The value is
	 *  determined via <code>System.totalMemory</code> and does not take texture memory
	 *  into account. It is recommended to use Adobe Scout for reliable and comprehensive
	 *  memory analysis.</p>
	 */
	private function get_showStats():Bool { return mStatsDisplay != null && mStatsDisplay.parent != null; }
	private function set_showStats(value:Bool):Bool
	{
		if (value == showStats) return value;
		
		if (value)
		{
			if (mStatsDisplay != null) mStage.addChild(mStatsDisplay);
			else showStatsAt();
		}
		else mStatsDisplay.removeFromParent();
		return value;
	}
	
	/** Displays the statistics box at a certain position. */
	public function showStatsAt(hAlign:HAlign=null, vAlign:VAlign=null, scale:Float=1):Void
	{
		if (hAlign == null) hAlign = HAlign.LEFT;
		if (vAlign == null) vAlign = VAlign.TOP;
		
		statsHAlign = hAlign;
		statsVAlign = vAlign;
		statsScale = scale;
		
		if (mContext == null)
		{
			// Starling is not yet ready - we postpone this until it's initialized.
			addEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
		}
		else
		{
			if (mStatsDisplay == null)
			{
				mStatsDisplay = new StatsDisplay();
				mStatsDisplay.touchable = false;
				mStage.addChild(mStatsDisplay);
			}
			
			var stageWidth:Int  = mStage.stageWidth;
			var stageHeight:Int = mStage.stageHeight;
			
			mStatsDisplay.scaleX = mStatsDisplay.scaleY = scale;
			
			if (hAlign == HAlign.LEFT) mStatsDisplay.x = 0;
			else if (hAlign == HAlign.RIGHT) mStatsDisplay.x = stageWidth - mStatsDisplay.width; 
			else mStatsDisplay.x = cast ((stageWidth - mStatsDisplay.width) / 2);
			
			if (vAlign == VAlign.TOP) mStatsDisplay.y = 0;
			else if (vAlign == VAlign.BOTTOM) mStatsDisplay.y = stageHeight - mStatsDisplay.height;
			else mStatsDisplay.y = cast ((stageHeight - mStatsDisplay.height) / 2);
		}		
	}
	
	private function onRootCreated():Void
	{
		showStatsAt(statsHAlign, statsVAlign, statsScale);
		removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
	}
	
	/** The Starling stage object, which is the root of the display tree that is rendered. */
	private function get_stage():Stage { return mStage; }

	/** The Flash Stage3D object Starling renders into. */
	private function get_stage3D():Stage3D { return mStage3D; }
	
	/** The Flash (2D) stage object Starling renders beneath. */
	private function get_nativeStage():flash.display.Stage { return mNativeStage; }
	
	/** The instance of the root class provided in the constructor. Available as soon as 
	 *  the event 'ROOT_CREATED' has been dispatched. */
	private function get_root():DisplayObject { return mRoot; }

	/** The class that will be instantiated by Starling as the 'root' display object.
	 *  Must be a subclass of 'starling.display.DisplayObject'.
	 *
	 *  <p>If you passed <code>null</code> as first parameter to the Starling constructor,
	 *  you can use this property to set the root class at a later time. As soon as the class
	 *  is instantiated, Starling will dispatch a <code>ROOT_CREATED</code> event.</p>
	 *
	 *  <p>Beware: you cannot change the root class once the root object has been
	 *  instantiated.</p>
	 */
	private function get_rootClass():Class<Dynamic> { return mRootClass; }
	private function set_rootClass(value:Class<Dynamic>):Class<Dynamic>
	{
		if (mRootClass != null && mRoot != null)
			throw new Error("Root class may not change after root has been instantiated");
		else if (mRootClass == null)
		{
			mRootClass = value;
			if (mContext != null) Timer.delay(initializeRoot, 1);
		}
		return value;
	}

	/** Indicates if the Context3D render calls are managed externally to Starling, 
	 *  to allow other frameworks to share the Stage3D instance. @default false */
	private function get_shareContext() : Bool { return mShareContext; }
	private function set_shareContext(value:Bool):Bool
	{
		mShareContext = value;
		return value;
	}
	
	/** The Context3D profile used for rendering. Beware that if you are using a shared
	 *  context in AIR 3.9 / Flash Player 11 or below, this is simply what you passed to
	 *  the Starling constructor. */
	private function get_profile():String { return mProfile; }
	
	/** Indicates that if the device supports HiDPI screens Starling will attempt to allocate
	 *  a larger back buffer than indicated via the viewPort size. Note that this is used
	 *  on Desktop only; mobile AIR apps still use the "requestedDisplayResolution" parameter
	 *  the application descriptor Xml. @default false */
	private function get_supportHighResolutions():Bool { return mSupportHighResolutions; }
	private function set_supportHighResolutions(value:Bool):Bool 
	{
		if (mSupportHighResolutions != value)
		{
			mSupportHighResolutions = value;
			if (contextValid) updateViewPort(true);
		}
		return value;
	}
	
	/** The TouchProcessor is passed all mouse and touch input and is responsible for
	 *  dispatching TouchEvents to the Starling display tree. If you want to handle these
	 *  types of input manually, pass your own custom subclass to this property. */
	private function get_touchProcessor():TouchProcessor { return mTouchProcessor; }
	private function set_touchProcessor(value:TouchProcessor):TouchProcessor
	{
		if (value != mTouchProcessor)
		{
			mTouchProcessor.dispose();
			mTouchProcessor = value;
		}
		return value;
	}
	
	/** Indicates if the Context3D object is currently valid (i.e. it hasn't been lost or
	 *  disposed). Beware that each call to this method causes a String allocation (due to
	 *  internal code Starling can't avoid), so do not call this method too often. */
	private function get_contextValid():Bool
	{
		return mContext != null && mContext.driverInfo != "Disposed";
	}

	// static properties
	
	/** The currently active Starling instance. */
	public static function get_current():Starling { return sCurrent; }

	/** All Starling instances. <p>CAUTION: not a copy, but the actual object! Do not modify!</p> */
	public static function get_all():Array<Starling> { return sAll; }
	
	/** The render context of the currently active Starling instance. */
	public static function get_Context():Context3D { return sCurrent != null ? sCurrent.context : null; }
	
	/** The default juggler of the currently active Starling instance. */
	public static function get_Juggler():Juggler { return sCurrent != null ? sCurrent.juggler : null; }
	
	/** The contentScaleFactor of the currently active Starling instance. */
	public static function get_ContentScaleFactor():Float 
	{
		return sCurrent != null ? sCurrent.contentScaleFactor : 1.0;
	}
	
	/** Indicates if multitouch input should be supported. */
	public static function get_multitouchEnabled():Bool 
	{ 
		return Multitouch.inputMode == MultitouchInputMode.TOUCH_POINT;
	}
	
	public static function set_multitouchEnabled(value:Bool):Bool
	{
		if (sCurrent != null) throw new IllegalOperationError(
			"'multitouchEnabled' must be set before Starling instance is created");
		else 
			Multitouch.inputMode = value ? MultitouchInputMode.TOUCH_POINT :
										   MultitouchInputMode.NONE;
		return value;
	}
	
	/** Indicates if Starling should automatically recover from a lost device context.
	 *  On some systems, an upcoming screensaver or entering sleep mode may 
	 *  invalidate the render context. This setting indicates if Starling should recover from 
	 *  such incidents.
	 *
	 *  <p>Beware: if used carelessly, this property may have a huge impact on memory
	 *  consumption. That's because, by default, it will make Starling keep a copy of each
	 *  texture in memory.</p>
	 *
	 *  <p>However, this downside can be avoided by using the "AssetManager" to load textures.
	 *  The AssetManager is smart enough to restore them directly from their sources. You can
	 *  also do this by setting up "root.onRestore" on your manually loaded textures.</p>
	 *
	 *  <p>A context loss can happen on almost every platform. It's very common on Windows
	 *  and Android, but rare on OS X and iOS (e.g. it may occur when opening up the camera
	 *  roll). It's recommended to always enable this property, while using the AssetManager
	 *  for texture loading.</p>
	 *  
	 *  @default false
	 *  @see starling.utils.AssetManager
	 */
	public static function get_handleLostContext():Bool { return sHandleLostContext; }
	public static function set_handleLostContext(value:Bool):Bool 
	{
		if (sCurrent != null) throw new IllegalOperationError(
			"'handleLostContext' must be set before Starling instance is created");
		else
			sHandleLostContext = value;
		return value;
	}
}

typedef StarlingFunction = Dynamic;
