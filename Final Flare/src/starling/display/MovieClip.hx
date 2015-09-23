// =================================================================================================
//
//    Starling Framework
//    Copyright 2011-2014 Gamua. All Rights Reserved.
//
//    This program is free software. You can redistribute and/or modify it
//    in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.display;

import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.media.Sound;
import openfl.media.SoundTransform;
import openfl.Vector;

import starling.animation.IAnimatable;
import starling.events.Event;
import starling.textures.Texture;

/** Dispatched whenever the movie has displayed its last frame. */
@:meta(Event(name='complete', type='starling.events.Event'))

/** A MovieClip is a simple way to display an animation depicted by a list of textures.
 *  
 *  <p>Pass the frames of the movie in a vector of textures to the constructor. The movie clip 
 *  will have the width and height of the first frame. If you group your frames with the help 
 *  of a texture atlas (which is recommended), use the <code>getTextures</code>-method of the 
 *  atlas to receive the textures in the correct (alphabetic) order.</p> 
 *  
 *  <p>You can specify the desired framerate via the constructor. You can, however, manually 
 *  give each frame a custom duration. You can also play a sound whenever a certain frame 
 *  appears.</p>
 *  
 *  <p>The methods <code>play</code> and <code>pause</code> control playback of the movie. You
 *  will receive an event of type <code>Event.COMPLETE</code> when the movie finished
 *  playback. If the movie is looping, the event is dispatched once per loop.</p>
 *  
 *  <p>As any animated object, a movie clip has to be added to a juggler (or have its 
 *  <code>advanceTime</code> method called regularly) to run. The movie will dispatch 
 *  an event of type "Event.COMPLETE" whenever it has displayed its last frame.</p>
 *  
 *  @see starling.textures.TextureAtlas
 */    
class MovieClip extends Image implements IAnimatable
{
    private var mTextures:Array<Texture>;
    private var mSounds:Array<Sound>;
    private var mDurations:Array<Float>;
    private var mStartTimes:Array<Float>;

    private var mDefaultFrameDuration:Float;
    private var mCurrentTime:Float;
    private var mCurrentFrame:Int;
    private var mLoop:Bool;
    private var mPlaying:Bool;
    private var mMuted:Bool;
    private var mSoundTransform:SoundTransform = null;
    
    public var totalTime(get, null):Float;
    public var currentTime(get, null):Float;
    public var numFrames(get, null):Int;
    public var loop(get, set):Bool;
    public var muted(get, set):Bool;
    public var soundTransform(get, set):SoundTransform;
    public var currentFrame(get, set):Int;
    public var fps(get, set):Float;
    public var isPlaying(get, null):Bool;
    public var isComplete(get, null):Bool;
    
    /** Creates a movie clip from the provided textures and with the specified default framerate.
     *  The movie will have the size of the first frame. */  
    public function new(textures:Vector<Texture>, fps:Float=12)
    {
        if (textures.length > 0)
        {
            super(textures[0]);
            init(textures, fps);
        }
        else
        {
            throw new ArgumentError("Empty texture array");
        }
    }
    
    private function init(textures:Array<Texture>, fps:Float):Void
    {
        if (fps <= 0) throw new ArgumentError("Invalid fps: " + fps);
        var numFrames:Int = textures.length;
        
        mDefaultFrameDuration = 1.0 / fps;
        mLoop = true;
        mPlaying = true;
        mCurrentTime = 0.0;
        mCurrentFrame = 0;
        mTextures = textures.concat(new Array<Texture>());
        //trace("CHECK INIT LENGTH IS NOT NEEDED");
        mSounds = new Array<Sound>(/*numFrames*/);
        mDurations = new Array<Float>(/*numFrames*/);
        mStartTimes = new Array<Float>(/*numFrames*/);
        
        for (i in 0...numFrames)
        {
            mDurations[i] = mDefaultFrameDuration;
            mStartTimes[i] = i * mDefaultFrameDuration;
        }
    }
    
    // frame manipulation
    
    /** Adds an additional frame, optionally with a sound and a custom duration. If the 
     *  duration is omitted, the default framerate is used (as specified in the constructor). */   
    public function addFrame(texture:Texture, sound:Sound=null, duration:Float=-1):Void
    {
        addFrameAt(numFrames, texture, sound, duration);
    }
    
    /** Adds a frame at a certain index, optionally with a sound and a custom duration. */
    public function addFrameAt(frameID:Int, texture:Texture, sound:Sound=null, 
                               duration:Float=-1):Void
    {
        if (frameID < 0 || frameID > numFrames) throw new ArgumentError("Invalid frame id");
        if (duration < 0) duration = mDefaultFrameDuration;
        
        
        mTextures.insert(frameID, texture); //mTextures.splice(frameID, 0, texture);
        mSounds.insert(frameID, sound); //mSounds.splice(frameID, 0, sound);
        mDurations.insert(frameID, duration); // mDurations.splice(frameID, 0, duration);
        
        if (frameID > 0 && frameID == numFrames) 
            mStartTimes[frameID] = mStartTimes[Std.int(frameID-1)] + mDurations[Std.int(frameID-1)];
        else
            updateStartTimes();
    }
    
    /** Removes the frame at a certain ID. The successors will move down. */
    public function removeFrameAt(frameID:Int):Void
    {
        if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
        if (numFrames == 1) throw new IllegalOperationError("Movie clip must not be empty");
        
        mTextures.splice(frameID, 1);
        mSounds.splice(frameID, 1);
        mDurations.splice(frameID, 1);
        
        updateStartTimes();
    }
    
    /** Returns the texture of a certain frame. */
    public function getFrameTexture(frameID:Int):Texture
    {
        if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
        return mTextures[frameID];
    }
    
    /** Sets the texture of a certain frame. */
    public function setFrameTexture(frameID:Int, texture:Texture):Void
    {
        if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
        mTextures[frameID] = texture;
    }
    
    /** Returns the sound of a certain frame. */
    public function getFrameSound(frameID:Int):Sound
    {
        if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
        return mSounds[frameID];
    }
    
    /** Sets the sound of a certain frame. The sound will be played whenever the frame 
     *  is displayed. */
    public function setFrameSound(frameID:Int, sound:Sound):Void
    {
        if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
        mSounds[frameID] = sound;
    }
    
    /** Returns the duration of a certain frame (in seconds). */
    public function getFrameDuration(frameID:Int):Float
    {
        if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
        return mDurations[frameID];
    }
    
    /** Sets the duration of a certain frame (in seconds). */
    public function setFrameDuration(frameID:Int, duration:Float):Void
    {
        if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
        mDurations[frameID] = duration;
        updateStartTimes();
    }
    
    // playback methods
    
    /** Starts playback. Beware that the clip has to be added to a juggler, too! */
    public function play():Void
    {
        mPlaying = true;
    }
    
    /** Pauses playback. */
    public function pause():Void
    {
        mPlaying = false;
    }
    
    /** Stops playback, resetting "currentFrame" to zero. */
    public function stop():Void
    {
        mPlaying = false;
        currentFrame = 0;
    }
    
    // helpers
    
    private function updateStartTimes():Void
    {
        var numFrames:Int = this.numFrames;
        
        mStartTimes = [];
        mStartTimes[0] = 0;
        
        for (i in 1...numFrames)
            mStartTimes[i] = mStartTimes[Std.int(i-1)] + mDurations[Std.int(i-1)];
    }
    
    // IAnimatable
    
    /** @inheritDoc */
    public function advanceTime(passedTime:Float):Void
    {
        if (!mPlaying || passedTime <= 0.0) return;
        
        var finalFrame:Int;
        var previousFrame:Int = mCurrentFrame;
        var restTime:Float = 0.0;
        var breakAfterFrame:Bool = false;
        var dispatchCompleteEvent:Bool = false;
        var totalTime:Float = this.totalTime;
        
        if (mLoop && mCurrentTime >= totalTime)
        { 
            mCurrentTime = 0.0; 
            mCurrentFrame = 0; 
        }
        
        if (mCurrentTime < totalTime)
        {
            mCurrentTime += passedTime;
            finalFrame = mTextures.length - 1;
            
            while (mCurrentTime > mStartTimes[mCurrentFrame] + mDurations[mCurrentFrame])
            {
                if (mCurrentFrame == finalFrame)
                {
                    if (mLoop && !hasEventListener(Event.COMPLETE))
                    {
                        mCurrentTime -= totalTime;
                        mCurrentFrame = 0;
                    }
                    else
                    {
                        breakAfterFrame = true;
                        restTime = mCurrentTime - totalTime;
                        dispatchCompleteEvent = true;
                        mCurrentFrame = finalFrame;
                        mCurrentTime = totalTime;
                    }
                }
                else
                {
                    mCurrentFrame++;
                }
                
                var sound:Sound = mSounds[mCurrentFrame];
                if (sound != null && !mMuted) sound.play(0, 0, mSoundTransform);
                if (breakAfterFrame) break;
            }
            
            // special case when we reach *exactly* the total time.
            if (mCurrentFrame == finalFrame && mCurrentTime == totalTime)
                dispatchCompleteEvent = true;
        }
        
        if (mCurrentFrame != previousFrame) {
            texture = mTextures[mCurrentFrame];
        }
        
        if (dispatchCompleteEvent)
            dispatchEventWith(Event.COMPLETE);
        
        if (mLoop && restTime > 0.0)
            advanceTime(restTime);
    }
    
    // properties  
    
    /** The total duration of the clip in seconds. */
    private function get_totalTime():Float 
    {
        var numFrames:Int = mTextures.length;
        return mStartTimes[Std.int(numFrames-1)] + mDurations[Std.int(numFrames-1)];
    }
    
    /** The time that has passed since the clip was started (each loop starts at zero). */
    private function get_currentTime():Float { return mCurrentTime; }
    
    /** The total number of frames. */
    private function get_numFrames():Int { return mTextures.length; }
    
    /** Indicates if the clip should loop. */
    private function get_loop():Bool { return mLoop; }
    private function set_loop(value:Bool):Bool
    {
        mLoop = value;
        return value;
    }
    
    /** If enabled, no new sounds will be started during playback. Sounds that are already
     *  playing are not affected. */
    private function get_muted():Bool { return mMuted; }
    private function set_muted(value:Bool):Bool
    {
        mMuted = value;
        return value;
    }

    /** The SoundTransform object used for playback of all frame sounds. @default null */
    private function get_soundTransform():SoundTransform { return mSoundTransform; }
    private function set_soundTransform(value:SoundTransform):SoundTransform
    {
        mSoundTransform = value; 
        return value;
    }

    /** The index of the frame that is currently displayed. */
    private function get_currentFrame():Int { return mCurrentFrame; }
    private function set_currentFrame(value:Int):Int
    {
        mCurrentFrame = value;
        mCurrentTime = 0.0;
        
        for (i in 0...value)
            mCurrentTime += getFrameDuration(i);
        
        texture = mTextures[mCurrentFrame];
        if (!mMuted && mSounds[mCurrentFrame] != null) mSounds[mCurrentFrame].play();
        return value;
    }
    
    /** The default number of frames per second. Individual frames can have different 
     *  durations. If you change the fps, the durations of all frames will be scaled 
     *  relatively to the previous value. */
    private function get_fps():Float { return 1.0 / mDefaultFrameDuration; }
    private function set_fps(value:Float):Float
    {
        if (value <= 0) throw new ArgumentError("Invalid fps: " + value);
        
        var newFrameDuration:Float = 1.0 / value;
        var acceleration:Float = newFrameDuration / mDefaultFrameDuration;
        mCurrentTime *= acceleration;
        mDefaultFrameDuration = newFrameDuration;
        
        for (i in 0...numFrames) 
            mDurations[i] *= acceleration;

        updateStartTimes();
        return value;
    }
    
    /** Indicates if the clip is still playing. Returns <code>false</code> when the end 
     *  is reached. */
    private function get_isPlaying():Bool 
    {
        if (mPlaying)
            return mLoop || mCurrentTime < totalTime;
        else
            return false;
    }

    /** Indicates if a (non-looping) movie has come to its end. */
    private function get_isComplete():Bool
    {
        return !mLoop && mCurrentTime >= totalTime;
    }
}