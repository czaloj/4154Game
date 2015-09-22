// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.display;

import openfl.errors.Error;
import openfl.geom.Matrix;
import openfl.geom.Matrix3D;
import openfl.geom.Point;
import openfl.geom.Vector3D;
import starling.utils.StarlingUtils;

import starling.core.RenderSupport;
import starling.events.Event;
import starling.utils.MathUtil;
import starling.utils.MatrixUtil;

/** A container that allows you to position objects in three-dimensional space.
 *
 *  <p>Starling is, at its heart, a 2D engine. However, sometimes, simple 3D effects are
 *  useful for special effects, e.g. for screen transitions or to turn playing cards
 *  realistically. This class makes it possible to create such 3D effects.</p>
 *
 *  <p><strong>Positioning objects in 3D</strong></p>
 *
 *  <p>Just like a normal sprite, you can add and remove children to this container, which
 *  allows you to group several display objects together. In addition to that, Sprite3D
 *  adds some interesting properties:</p>
 *
 *  <ul>
 *    <li>z - Moves the sprite closer to / further away from the camera.</li>
 *    <li>rotationX — Rotates the sprite around the x-axis.</li>
 *    <li>rotationY — Rotates the sprite around the y-axis.</li>
 *    <li>scaleZ - Scales the sprite along the z-axis.</li>
 *    <li>pivotZ - Moves the pivot point along the z-axis.</li>
 *  </ul>
 *
 *  <p>With the help of these properties, you can move a sprite and all its children in the
 *  3D space. By nesting several Sprite3D containers, it's even possible to construct simple
 *  volumetric objects (like a cube).</p>
 *
 *  <p>Note that Starling does not make any z-tests: visibility is solely established by the
 *  order of the children, just as with 2D objects.</p>
 *
 *  <p><strong>Setting up the camera</strong></p>
 *
 *  <p>The camera settings are found directly on the stage. Modify the 'focalLength' or
 *  'fieldOfView' properties to change the distance between stage and camera; use the
 *  'projectionOffset' to move it to a different position.</p>
 *
 *  <p><strong>Limitations</strong></p>
 *
 *  <p>A Sprite3D object cannot be flattened (although you can flatten objects <em>within</em>
 *  a Sprite3D), and it does not work with the "clipRect" property. Furthermore, a filter
 *  applied to a Sprite3D object cannot be cached.</p>
 *
 *  <p>On rendering, each Sprite3D requires its own draw call — except if the object does not
 *  contain any 3D transformations ('z', 'rotationX/Y' and 'pivotZ' are zero).</p>
 *
 */
class Sprite3D extends DisplayObjectContainer
{
	private static var E:Float = 0.00001;

	private var mRotationX:Float;
	private var mRotationY:Float;
	private var mScaleZ:Float;
	private var mPivotZ:Float;
	private var mZ:Float;

	//private var mTransformationMatrix:Matrix;
	//private var mTransformationMatrix3D:Matrix3D;
	private var mTransformationChanged:Bool;

	/** Helper objects. */
	private static var sHelperPoint:Vector3D    = new Vector3D();
	private static var sHelperPointAlt:Vector3D = new Vector3D();
	private static var sHelperMatrix:Matrix3D   = new Matrix3D();
	
	private var is2D(get, null):Bool;
	public var z(get, set):Float;
	public var pivotZ(get, set):Float;
	public var scaleZ(get, set):Float;
	public var rotationX(get, set):Float;
	public var rotationY(get, set):Float;
	public var rotationZ(get, set):Float;
	
	/** Creates an empty Sprite3D. */
	public function new()
	{
		super();
		mScaleZ = 1.0;
		mRotationX = mRotationY = mPivotZ = mZ = 0.0;
		mTransformationMatrix = new Matrix();
		mTransformationMatrix3D = new Matrix3D();
		setIs3D(true);

		addEventListener(Event.ADDED, onAddedChild);
		addEventListener(Event.REMOVED, onRemovedChild);
	}

	/** @inheritDoc */
	public override function render(support:RenderSupport, parentAlpha:Float):Void
	{
		if (is2D) super.render(support, parentAlpha);
		else
		{
			support.finishQuadBatch();
			support.pushMatrix3D();
			support.transformMatrix3D(this);

			super.render(support, parentAlpha);

			support.finishQuadBatch();
			support.popMatrix3D();
		}
	}

	/** @inheritDoc */
	public override function hitTest(localPoint:Point, forTouch:Bool=false):DisplayObject
	{
		if (is2D) return super.hitTest(localPoint, forTouch);
		else
		{
			if (forTouch && (!visible || !touchable))
				return null;

			// We calculate the interception point between the 3D plane that is spawned up
			// by this sprite3D and the straight line between the camera and the hit point.

			sHelperMatrix.copyFrom(transformationMatrix3D);
			sHelperMatrix.invert();

			stage.getCameraPosition(this, sHelperPoint);
			MatrixUtil.transformCoords3D(sHelperMatrix, localPoint.x, localPoint.y, 0, sHelperPointAlt);
			MathUtil.intersectLineWithXYPlane(sHelperPoint, sHelperPointAlt, localPoint);

			return super.hitTest(localPoint, forTouch);
		}
	}

	// helpers

	private function onAddedChild(event:Event):Void
	{
		recursivelySetIs3D(cast event.target, true);
	}

	private function onRemovedChild(event:Event):Void
	{
		recursivelySetIs3D(cast event.target, false);
	}

	private function recursivelySetIs3D(object:DisplayObject, value:Bool):Void
	{
		if (Std.is(object, Sprite3D))
			return;

		if (Std.is(object, DisplayObjectContainer))
		{
			var container:DisplayObjectContainer = cast object;
			var numChildren:Int = container.numChildren;

			for (i in 0...numChildren)
				recursivelySetIs3D(container.getChildAt(i), value);
		}

		object.setIs3D(value);
	}

	private function updateMatrices():Void
	{
		var x:Float = this.x;
		var y:Float = this.y;
		var scaleX:Float = this.scaleX;
		var scaleY:Float = this.scaleY;
		var pivotX:Float = this.pivotX;
		var pivotY:Float = this.pivotY;
		var rotationZ:Float = this.rotation;

		mTransformationMatrix3D.identity();

		if (scaleX != 1.0 || scaleY != 1.0 || mScaleZ != 1.0){
			mTransformationMatrix3D.appendScale(cast ((cast scaleX) || (cast E)) , cast ((cast scaleY) || (cast E)), cast ((cast scaleZ) || (cast E)));
		}
		if (mRotationX != 0.0)
			mTransformationMatrix3D.appendRotation(StarlingUtils.rad2deg(mRotationX), Vector3D.X_AXIS);
		if (mRotationY != 0.0)
			mTransformationMatrix3D.appendRotation(StarlingUtils.rad2deg(mRotationY), Vector3D.Y_AXIS);
		if (rotationZ != 0.0)
			mTransformationMatrix3D.appendRotation(StarlingUtils.rad2deg( rotationZ), Vector3D.Z_AXIS);
		if (x != 0.0 || y != 0.0 || mZ != 0.0)
			mTransformationMatrix3D.appendTranslation(x, y, mZ);
		if (pivotX != 0.0 || pivotY != 0.0 || mPivotZ != 0.0)
			mTransformationMatrix3D.prependTranslation(-pivotX, -pivotY, -mPivotZ);

		if (is2D) MatrixUtil.convertTo2D(mTransformationMatrix3D, mTransformationMatrix);
		else      mTransformationMatrix.identity();
	}

	/** Indicates if the object can be represented by a 2D transformation. */
	/*[Inline]*/
	private inline /*final*/ function get_is2D():Bool
	{
		return mZ > -E && mZ < E &&
			mRotationX > -E && mRotationX < E &&
			mRotationY > -E && mRotationY < E &&
			mPivotZ > -E && mPivotZ < E;
	}

	// properties

	/** The 2D transformation matrix of the object relative to its parent — if it can be
	 *  represented in such a matrix (the values of 'z', 'rotationX/Y', and 'pivotZ' are
	 *  zero). Otherwise, the identity matrix. CAUTION: not a copy, but the actual object! */
	private override function get_transformationMatrix():Matrix
	{
		if (mTransformationChanged)
		{
			updateMatrices();
			mTransformationChanged = false;
		}

		return mTransformationMatrix;
	}

	private override function set_transformationMatrix(value:Matrix):Matrix
	{
		super.transformationMatrix = value;
		mRotationX = mRotationY = mPivotZ = mZ = 0;
		mTransformationChanged = true;
		return value;
	}

	/**  The 3D transformation matrix of the object relative to its parent.
	 *   CAUTION: not a copy, but the actual object! */
	private override function get_transformationMatrix3D():Matrix3D
	{
		if (mTransformationChanged)
		{
			updateMatrices();
			mTransformationChanged = false;
		}

		return mTransformationMatrix3D;
	}

	/** @inheritDoc */
	private override function set_x(value:Float):Float
	{
		super.x = value;
		mTransformationChanged = true;
		return value;
	}

	/** @inheritDoc */
	private override function set_y(value:Float):Float
	{
		super.y = value;
		mTransformationChanged = true;
		return value;
	}

	/** The z coordinate of the object relative to the local coordinates of the parent.
	 *  The z-axis points away from the camera, i.e. positive z-values will move the object further
	 *  away from the viewer. */
	private function get_z():Float { return mZ; }
	private function set_z(value:Float):Float
	{
		mZ = value;
		mTransformationChanged = true;
		return value;
	}

	/** @inheritDoc */
	private override function set_pivotX(value:Float):Float
	{
		super.pivotX = value;
		mTransformationChanged = true;
		return value;
	}

	/** @inheritDoc */
	private override function set_pivotY(value:Float):Float
	{
		 super.pivotY = value;
		 mTransformationChanged = true;
		 return value;
	}

	/** The z coordinate of the object's origin in its own coordinate space (default: 0). */
	private function get_pivotZ():Float { return mPivotZ; }
	private function set_pivotZ(value:Float):Float
	{
		mPivotZ = value;
		mTransformationChanged = true;
		return value;
	}

	/** @inheritDoc */
	private override function set_scaleX(value:Float):Float
	{
		super.scaleX = value;
		mTransformationChanged = true;
		return value;
	}

	/** @inheritDoc */
	private override function set_scaleY(value:Float):Float
	{
		super.scaleY = value;
		mTransformationChanged = true;
		return value;
	}

	/** The depth scale factor. '1' means no scale, negative values flip the object. */
	private function get_scaleZ():Float { return mScaleZ; }
	private function set_scaleZ(value:Float):Float
	{
		mScaleZ = value;
		mTransformationChanged = true;
		return value;
	}

	/** @private */
	private override function set_skewX(value:Float):Float
	{
		throw new Error("3D objects do not support skewing");

		// super.skewX = value;
		// mOrientationChanged = true;
		return value;
	}

	/** @private */
	private override function set_skewY(value:Float):Float
	{
		throw new Error("3D objects do not support skewing");

		// super.skewY = value;
		// mOrientationChanged = true;
		return value;
	}

	/** The rotation of the object about the z axis, in radians.
	 *  (In Starling, all angles are measured in radians.) */
	private override function set_rotation(value:Float):Float
	{
		super.rotation = value;
		mTransformationChanged = true;
		return value;
	}

	/** The rotation of the object about the x axis, in radians.
	 *  (In Starling, all angles are measured in radians.) */
	private function get_rotationX():Float { return mRotationX; }
	private function set_rotationX(value:Float):Float
	{
		mRotationX = MathUtil.normalizeAngle(value);
		mTransformationChanged = true;
		return value;
	}

	/** The rotation of the object about the y axis, in radians.
	 *  (In Starling, all angles are measured in radians.) */
	private function get_rotationY():Float { return mRotationY; }
	private function set_rotationY(value:Float):Float
	{
		mRotationY = MathUtil.normalizeAngle(value);
		mTransformationChanged = true;
		return value;
	}

	/** The rotation of the object about the z axis, in radians.
	 *  (In Starling, all angles are measured in radians.) */
	private function get_rotationZ():Float { return rotation; }
	private function set_rotationZ(value:Float):Float
	{
		rotation = value;
		return value;
	}
}