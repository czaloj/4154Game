// =================================================================================================
//
//    Starling Framework
//    Copyright 2011-2014 Gamua. All Rights Reserved.
//
//    This program is free software. You can redistribute and/or modify it
//    in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.events;

import openfl.errors.Error;
import openfl.geom.Point;
import openfl.Vector;
import starling.display.DisplayObject;
import starling.display.Stage;


/** The TouchProcessor is used to convert mouse and touch events of the conventional
 *  Flash stage to Starling's TouchEvents.
 *  
 *  <p>The Starling instance listens to mouse and touch events on the native stage. The
 *  attributes of those events are enqueued (right as they are happening) in the
 *  TouchProcessor.</p>
 *  
 *  <p>Once per frame, the "advanceTime" method is called. It analyzes the touch queue and
 *  figures out which touches are active at that moment; the properties of all touch objects
 *  are updated accordingly.</p>
 *  
 *  <p>Once the list of touches has been finalized, the "processTouches" method is called
 *  (that might happen several times in one "advanceTime" execution; no information is
 *  discarded). It's responsible for dispatching the actual touch events to the Starling
 *  display tree.</p>
 *  
 *  <strong>Subclassing TouchProcessor</strong>
 *  
 *  <p>You can extend the TouchProcessor if you need to have more control over touch and
 *  mouse input. For example, you could filter the touches by overriding the "processTouches"
 *  method, throwing away any touches you're not interested in and passing the rest to the
 *  super implementation.</p>
 *  
 *  <p>To use your custom TouchProcessor, assign it to the "Starling.touchProcessor"
 *  property.</p>
 *  
 *  <p>Note that you should not dispatch TouchEvents yourself, since they are
 *  much more complex to handle than conventional events (e.g. it must be made sure that an
 *  object receives a TouchEvent only once, even if it's manipulated with several fingers).
 *  Always use the base implementation of "processTouches" to let them be dispatched. That
 *  said: you can always dispatch your own custom events, of course.</p>
 */
class TouchProcessor
{
    private var mStage:Stage;
    private var mRoot:DisplayObject;
    private var mElapsedTime:Float;
    private var mTouchMarker:TouchMarker;
    private var mLastTaps:Array<Touch>;
    private var mShiftDown:Bool = false;
    private var mCtrlDown:Bool  = false;
    private var mMultitapTime:Float = 0.3;
    private var mMultitapDistance:Float = 25;
    
    /** A vector of arrays with the arguments that were passed to the "enqueue"
     *  method (the oldest being at the end of the vector). */
    private var mQueue:Vector<Array<Dynamic>>;
    
    /** The list of all currently active touches. */
    private var mCurrentTouches:Vector<Touch> = new Vector<Touch>();
    
    /** Helper objects. */
    private static var sUpdatedTouches = new Vector<Touch>();
    private static var sHoveringTouchData = new Vector<Dynamic>();
    private static var sHelperPoint = new Point();
    
    public var simulateMultitouch(get, set):Bool;
    public var multitapTime(get, set):Float;
    public var multitapDistance(get, set):Float;
    public var root(get, set):DisplayObject;
    public var stage(get, null):Stage;
    public var numCurrentTouches(get, null):Int;
    
    
    /** Creates a new TouchProcessor that will dispatch events to the given stage. */
    public function new(stage:Stage)
    {
        mRoot = mStage = stage;
        mElapsedTime = 0.0;
        
        mQueue = new Vector<Array<Dynamic>>();
        mLastTaps = new Array<Touch>();
        mCurrentTouches.length = 0;
        
        mStage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
        mStage.addEventListener(KeyboardEvent.KEY_UP,   onKey);
        monitorInterruptions(true);
    }

    /** Removes all event handlers on the stage and releases any acquired resources. */
    public function dispose():Void
    {
        monitorInterruptions(false);
        mStage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
        mStage.removeEventListener(KeyboardEvent.KEY_UP,   onKey);
        if (mTouchMarker != null) mTouchMarker.dispose();
    }
    
    /** Analyzes the current touch queue and processes the list of current touches, emptying
     *  the queue while doing so. This method is called by Starling once per frame. */
    public function advanceTime(passedTime:Float):Void
    {
        //var i:Int;
        var touch:Touch;
        
        mElapsedTime += passedTime;
        sUpdatedTouches.length = 0;
        
        // remove old taps
        /*if (mLastTaps.length > 0)
        {
            //for (i = mLastTaps.length - 1; i >= 0; --i)
            for (j in 0...mLastTaps.length) {
                var i = mLastTaps.length - j - 1;
                if (mElapsedTime - mLastTaps[i].timestamp > mMultitapTime)
                    mLastTaps.splice(i, 1);
            }
        }*/
        
        var len = mQueue.length;
        for (i in 0...len) 
        //while (mQueue.length > 0)
        {
            var j = len - 1 - i;
            var mQueueItem = mQueue[j];
            if (mQueueItem == null) {
                //mQueue.splice(i, 1);
                //mQueue = new Vector<Array<Dynamic>>();
                continue;
            }
            
            
            
            // Set touches that were new or moving to phase 'stationary'.
            for (touch in mCurrentTouches)
                if (touch.phase == TouchPhase.BEGAN || touch.phase == TouchPhase.MOVED)
                    touch.phase = TouchPhase.STATIONARY;

            // analyze new touches, but each ID only once
            //while (mQueue.length > 0 && containsTouchWithID(sUpdatedTouches, mQueue[mQueue.length-1][0]) == false)
            while (mQueue.length > 0 && containsTouchWithID(sUpdatedTouches, mQueueItem[0]) == false)
            {
                var touchArgs:Array<Dynamic> = mQueue.pop();
                
                touch = createOrUpdateTouch(
                            touchArgs[0], touchArgs[1], touchArgs[2], touchArgs[3],
                            touchArgs[4], touchArgs[5], touchArgs[6]);
                
                sUpdatedTouches[sUpdatedTouches.length] = touch; // avoiding 'push'
            }
            // process the current set of touches (i.e. dispatch touch events)
            processTouches(sUpdatedTouches, mShiftDown, mCtrlDown);

            // remove ended touches
            for (k in 0...mCurrentTouches.length) {
                var i = mCurrentTouches.length - k - 1;
                if (mCurrentTouches[i].phase == TouchPhase.ENDED)
                    mCurrentTouches.splice(i, 1);
            }
            
            sUpdatedTouches = new Vector<Touch>();//sUpdatedTouches.length = 0;
        }
        
        mQueue = new Vector<Array<Dynamic>>();
    }
    
    /** Dispatches TouchEvents to the display objects that are affected by the list of
     *  given touches. Called internally by "advanceTime". To calculate updated targets,
     *  the method will call "hitTest" on the "root" object.
     *  
     *  @param touches    a list of all touches that have changed just now.
     *  @param shiftDown  indicates if the shift key was down when the touches occurred.
     *  @param ctrlDown   indicates if the ctrl or cmd key was down when the touches occurred.
     */
    private function processTouches(touches:Vector<Touch>, shiftDown:Bool, ctrlDown:Bool):Void
    {
        sHoveringTouchData.length = 0;
        
        // the same touch event will be dispatched to all targets;
        // the 'dispatch' method will make sure each bubble target is visited only once.
        var touchEvent:TouchEvent = new TouchEvent(TouchEvent.TOUCH, mCurrentTouches, shiftDown, ctrlDown);
        var touch:Touch;
        
        // hit test our updated touches
        
        for (touch in touches)
        {
            // hovering touches need special handling (see below)
            
            if (touch.phase == TouchPhase.HOVER && touch.target != null)
                sHoveringTouchData[sHoveringTouchData.length] = {
                    touch: touch,
                    target: touch.target,
                    bubbleChain: touch.bubbleChain
                }; // avoiding 'push'
            
            if (touch.phase == TouchPhase.HOVER || touch.phase == TouchPhase.BEGAN)
            {
                sHelperPoint.setTo(touch.globalX, touch.globalY);
                touch.target = mRoot.hitTest(sHelperPoint, true);
            }
        }
        
        // if the target of a hovering touch changed, we dispatch the event to the previous
        // target to notify it that it's no longer being hovered over.
        for (touchData in sHoveringTouchData) {
            var touch:Touch = touchData.touch;
            if (touch != touchData.target)
                touchEvent.dispatch(cast touchData.bubbleChain);
        }
        
        // dispatch events for the rest of our updated touches
        for (touch in touches) {
            touch.dispatchEvent(touchEvent);
        }
    }
    
    /** Enqueues a new touch our mouse event with the given properties. */
    public function enqueue(touchID:Int, phase:String, globalX:Float, globalY:Float,
                            pressure:Float=1.0, width:Float=1.0, height:Float=1.0):Void
    {
        var arguments:Array<Dynamic> = [touchID, phase, globalX, globalY, pressure, width, height];
        mQueue.unshift(arguments); // mQueue.unshift(arguments);
        
        // multitouch simulation (only with mouse)
        if (mCtrlDown && simulateMultitouch && touchID == 0) 
        {
            mTouchMarker.moveMarker(globalX, globalY, mShiftDown);
            mQueue.unshift([1, phase, mTouchMarker.mockX, mTouchMarker.mockY]);
        }
    }
    
    /** Enqueues an artificial touch that represents the mouse leaving the stage.
     *  
     *  <p>On OS X, we get mouse events from outside the stage; on Windows, we do not.
     *  This method enqueues an artificial hover point that is just outside the stage.
     *  That way, objects listening for HOVERs over them will get notified everywhere.</p>
     */
    public function enqueueMouseLeftStage():Void
    {
        var mouse:Touch = getCurrentTouch(0);
        if (mouse == null || mouse.phase != TouchPhase.HOVER) return;
        
        var offset:Int = 1;
        var exitX:Float = mouse.globalX;
        var exitY:Float = mouse.globalY;
        var distLeft:Float = mouse.globalX;
        var distRight:Float = mStage.stageWidth - distLeft;
        var distTop:Float = mouse.globalY;
        var distBottom:Float = mStage.stageHeight - distTop;
        var minDist:Float = min([distLeft, distRight, distTop, distBottom]);
        
        // the new hover point should be just outside the stage, near the point where
        // the mouse point was last to be seen.
        
        if (minDist == distLeft)       exitX = -offset;
        else if (minDist == distRight) exitX = mStage.stageWidth + offset;
        else if (minDist == distTop)   exitY = -offset;
        else                           exitY = mStage.stageHeight + offset;
        
        enqueue(0, TouchPhase.HOVER, exitX, exitY);
    }
    
    private function min(value:Array<Float>):Float
    {
        var minValue:Float = Math.POSITIVE_INFINITY;
        var minIndex:Int = 0;
        for (i in 0...value.length) 
        {
            if (value[i] < minValue) {
                minValue = value[i];
                minIndex = i;
            }
        }
        return value[minIndex];
    }
    
    private function createOrUpdateTouch(touchID:Int, phase:String,
                                         globalX:Float, globalY:Float,
                                         pressure:Float=1.0,
                                         width:Float=1.0, height:Float=1.0):Touch
    {
        var touch:Touch = getCurrentTouch(touchID);
        
        if (touch == null)
        {
            touch = new Touch(touchID);
            addCurrentTouch(touch);
        }
        
        touch.globalX = globalX;
        touch.globalY = globalY;
        touch.phase = phase;
        touch.timestamp = mElapsedTime;
        touch.pressure = pressure;
        touch.width  = width;
        touch.height = height;

        if (phase == TouchPhase.BEGAN)
            updateTapCount(touch);

        return touch;
    }
    
    private function updateTapCount(touch:Touch):Void
    {
        var nearbyTap:Touch = null;
        var minSqDist:Float = mMultitapDistance * mMultitapDistance;
        
        for (tap in mLastTaps)
        {
            var sqDist:Float = Math.pow(tap.globalX - touch.globalX, 2) +
                                Math.pow(tap.globalY - touch.globalY, 2);
            if (sqDist <= minSqDist)
            {
                nearbyTap = tap;
                break;
            }
        }
        
        if (nearbyTap != null)
        {
            touch.tapCount = nearbyTap.tapCount + 1;
            mLastTaps.splice(mLastTaps.indexOf(nearbyTap), 1);
        }
        else
        {
            touch.tapCount = 1;
        }
        
        mLastTaps.push(touch.clone());
    }
    
    private function addCurrentTouch(touch:Touch):Void
    {
        for (j in 0...mCurrentTouches.length) {
            var i:Int = mCurrentTouches.length - j - 1;
            if (mCurrentTouches[i].id == touch.id)
                mCurrentTouches.splice(i, 1);
        }
        
        
        if (touch != null) {
            mCurrentTouches.push(touch);
        }
    }
    
    private function getCurrentTouch(touchID:Int):Touch
    {
        for (touch in mCurrentTouches)
            if (touch.id == touchID) return touch;
        
        return null;
    }
    
    private function containsTouchWithID(touches:Array<Touch>, touchID:Int):Bool
    {
        for (touch in touches)
            if (touch.id == touchID) return true;
        
        return false;
    }
    
    /** Indicates if it multitouch simulation should be activated. When the user presses
     *  ctrl/cmd (and optionally shift), he'll see a second touch curser that mimics the first.
     *  That's an easy way to develop and test multitouch when there's only a mouse available.
     */
    private function get_simulateMultitouch():Bool { return mTouchMarker != null; }
    private function set_simulateMultitouch(value:Bool):Bool
    { 
        if (simulateMultitouch == value) return value; // no change
        if (value)
        {
            mTouchMarker = new TouchMarker();
            mTouchMarker.visible = false;
            mStage.addChild(mTouchMarker);
        }
        else
        {                
            mTouchMarker.removeFromParent(true);
            mTouchMarker = null;
        }
        return value;
    }
    
    /** The time period (in seconds) in which two touches must occur to be recognized as
     *  a multitap gesture. */
    private function get_multitapTime():Float { return mMultitapTime; }
    private function set_multitapTime(value:Float):Float
    {
        mMultitapTime = value;
        return value;
    }
    
    /** The distance (in points) describing how close two touches must be to each other to
     *  be recognized as a multitap gesture. */
    private function get_multitapDistance():Float { return mMultitapDistance; }
    private function set_multitapDistance(value:Float):Float
    {
        mMultitapDistance = value;
        return value;
    }

    /** The base object that will be used for hit testing. Per default, this reference points
     *  to the stage; however, you can limit touch processing to certain parts of your game
     *  by assigning a different object. */
    private function get_root():DisplayObject { return mRoot; }
    private function set_root(value:DisplayObject):DisplayObject
    {
        mRoot = value;
        return value;
    }
    
    /** The stage object to which the touch objects are (per default) dispatched. */
    private function get_stage():Stage { return mStage; }
    
    /** Returns the number of fingers / touch points that are currently on the stage. */
    private function get_numCurrentTouches():Int { return mCurrentTouches.length; }

    // keyboard handling
    
    private function onKey(event:KeyboardEvent):Void
    {
        if (event.keyCode == 17 || event.keyCode == 15) // ctrl or cmd key
        {
            var wasCtrlDown:Bool = mCtrlDown;
            mCtrlDown = event.type == KeyboardEvent.KEY_DOWN;
            
            if (simulateMultitouch && wasCtrlDown != mCtrlDown)
            {
                mTouchMarker.visible = mCtrlDown;
                mTouchMarker.moveCenter(mStage.stageWidth/2, mStage.stageHeight/2);
                
                var mouseTouch:Touch = getCurrentTouch(0);
                var mockedTouch:Touch = getCurrentTouch(1);
                
                if (mouseTouch != null)
                    mTouchMarker.moveMarker(mouseTouch.globalX, mouseTouch.globalY);
                
                if (wasCtrlDown && mockedTouch != null && mockedTouch.phase != TouchPhase.ENDED)
                {
                    // end active touch ...
                    mQueue.unshift([1, TouchPhase.ENDED, mockedTouch.globalX, mockedTouch.globalY]);
                }
                else if (mCtrlDown && mouseTouch != null)
                {
                    // ... or start new one
                    if (mouseTouch.phase == TouchPhase.HOVER || mouseTouch.phase == TouchPhase.ENDED)
                        mQueue.unshift([1, TouchPhase.HOVER, mTouchMarker.mockX, mTouchMarker.mockY]);
                    else
                        mQueue.unshift([1, TouchPhase.BEGAN, mTouchMarker.mockX, mTouchMarker.mockY]);
                }
            }
        }
        else if (event.keyCode == 16) // shift key
        {
            mShiftDown = event.type == KeyboardEvent.KEY_DOWN;
        }
    }

    // interruption handling
    
    private function monitorInterruptions(enable:Bool):Void
    {
        // if the application moves into the background or is interrupted (e.g. through
        // an incoming phone call), we need to abort all touches.
        
        trace("ONLY RUN WHEN PUBLISHING FOR AIR");
        //try
        //{
            //trace("CHECK");
            ////var nativeAppClass:Dynamic = getDefinitionByName("flash.desktop.NativeApplication");
            //var nativeAppClass:Dynamic = Type.resolveClass("flash.desktop.NativeApplication");
            //var nativeApp:Dynamic = Reflect.getProperty(nativeAppClass, "nativeApplication");// nativeAppClass["nativeApplication"];
            //
            //if (enable != null)
                //nativeApp.addEventListener("deactivate", onInterruption, false, 0, true);
            //else
                //nativeApp.removeEventListener("deactivate", onInterruption);
        //}
        //catch (e:Error) {} // we're not running in AIR
    }
    
    private function onInterruption(event:Dynamic):Void
    {
        if (mCurrentTouches.length > 0)
        {
            // abort touches
            for (touch in mCurrentTouches)
            {
                if (touch.phase == TouchPhase.BEGAN || touch.phase == TouchPhase.MOVED ||
                    touch.phase == TouchPhase.STATIONARY)
                {
                    touch.phase = TouchPhase.ENDED;
                }
            }

            // dispatch events
            processTouches(mCurrentTouches, mShiftDown, mCtrlDown);
        }

        // purge touches
        mCurrentTouches.length = 0;
        mQueue = new Vector<Array<Dynamic>>(); // mQueue.length = 0;
    }
}