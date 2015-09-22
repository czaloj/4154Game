// =================================================================================================
//
//  Starling Framework
//  Copyright 2011-2014 Gamua. All Rights Reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.utils;

import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.geom.Matrix;
import openfl.geom.Matrix3D;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Vector3D;
import openfl.Vector;

/** The VertexData class manages a raw list of vertex information, allowing direct upload
 *  to Stage3D vertex buffers. <em>You only have to work with this class if you create display 
 *  objects with a custom render function. If you don't plan to do that, you can safely 
 *  ignore it.</em>
 * 
 *  <p>To render objects with Stage3D, you have to organize vertex data in so-called
 *  vertex buffers. Those buffers reside in graphics memory and can be accessed very 
 *  efficiently by the GPU. Before you can move data into vertex buffers, you have to 
 *  set it up in conventional memory - that is, in a Vector object. The vector contains
 *  all vertex information (the coordinates, color, and texture coordinates) - one
 *  vertex after the other.</p>
 *  
 *  <p>To simplify creating and working with such a bulky list, the VertexData class was 
 *  created. It contains methods to specify and modify vertex data. The raw Vector managed 
 *  by the class can then easily be uploaded to a vertex buffer.</p>
 * 
 *  <strong>Premultiplied Alpha</strong>
 *  
 *  <p>The color values of the "BitmapData" object contain premultiplied alpha values, which 
 *  means that the <code>rgb</code> values were multiplied with the <code>alpha</code> value 
 *  before saving them. Since textures are created from bitmap data, they contain the values in 
 *  the same style. On rendering, it makes a difference in which way the alpha value is saved; 
 *  for that reason, the VertexData class mimics this behavior. You can choose how the alpha 
 *  values should be handled via the <code>premultipliedAlpha</code> property.</p>
 * 
 */ 
class VertexData 
{
	/** The total number of elements (Numbers) stored per vertex. */
	public static var ELEMENTS_PER_VERTEX:Int = 8;
	
	/** The offset of position data (x, y) within a vertex. */
	public static var POSITION_OFFSET:Int = 0;
	
	/** The offset of color data (r, g, b, a) within a vertex. */
	public static var COLOR_OFFSET:Int = 2;
	
	/** The offset of texture coordinates (u, v) within a vertex. */
	public static var TEXCOORD_OFFSET:Int = 6;
	
	private var mRawData:Vector<Float>;
	private var mPremultipliedAlpha:Bool;
	private var mNumVertices:Int;

	public var tinted(get, null):Bool;
	public var premultipliedAlpha(get, set):Bool;
	public var numVertices(get, set):Int;
	public var rawData(get, set):Vector<Float>;
	
	/** Helper object. */
	private static var sHelperPoint:Point = new Point();
	private static var sHelperPoint3D:Vector3D = new Vector3D();
	
	/** Create a new VertexData object with a specified number of vertices. */
	public function new(numVertices:Int, premultipliedAlpha:Bool=false)
	{
		mRawData = new Vector<Float>();
		mPremultipliedAlpha = premultipliedAlpha;
		this.numVertices = numVertices;
	}

	/** Creates a duplicate of either the complete vertex data object, or of a subset. 
	 *  To clone all vertices, set 'numVertices' to '-1'. */
	public function clone(vertexID:Int=0, numVertices:Int=-1):VertexData
	{
		if (numVertices < 0 || vertexID + numVertices > mNumVertices)
			numVertices = mNumVertices - vertexID;
		
		var clone:VertexData = new VertexData(0, mPremultipliedAlpha);
		clone.mNumVertices = numVertices;
		clone.mRawData = mRawData.slice(vertexID * VertexData.ELEMENTS_PER_VERTEX, numVertices * VertexData.ELEMENTS_PER_VERTEX);
		clone.mRawData.fixed = true;
		return clone;
	}
	
	/** Copies the vertex data (or a range of it, defined by 'vertexID' and 'numVertices') 
	 *  of this instance to another vertex data object, starting at a certain index. */
	public function copyTo(targetData:VertexData, targetVertexID:Int=0,
						   vertexID:Int=0, numVertices:Int=-1):Void
	{
		copyTransformedTo(targetData, targetVertexID, null, vertexID, numVertices);
	}
	
	/** Transforms the vertex position of this instance by a certain matrix and copies the
	 *  result to another VertexData instance. Limit the operation to a range of vertices
	 *  via the 'vertexID' and 'numVertices' parameters. */
	public function copyTransformedTo(targetData:VertexData, targetVertexID:Int=0, matrix:Matrix=null, vertexID:Int=0, numVertices:Int=-1):Void
	{
		if (numVertices < 0 || vertexID + numVertices > mNumVertices) {
			numVertices = mNumVertices - vertexID;
		}
		
		var x:Float;
		var y:Float;
		var targetRawData:Vector<Float> = targetData.mRawData;
		var targetIndex:Int = targetVertexID * VertexData.ELEMENTS_PER_VERTEX;
		var sourceIndex:Int = vertexID * VertexData.ELEMENTS_PER_VERTEX;
		var sourceEnd:Int = (vertexID + numVertices) * VertexData.ELEMENTS_PER_VERTEX;
		
		if (matrix != null)
		{
			while (sourceIndex < sourceEnd)
			{
				x = mRawData[sourceIndex++];
				y = mRawData[sourceIndex++];
				
				targetRawData[targetIndex++] = matrix.a * x + matrix.c * y + matrix.tx;
				targetRawData[targetIndex++] = matrix.d * y + matrix.b * x + matrix.ty;
				targetRawData[targetIndex++] = mRawData[sourceIndex++];
				targetRawData[targetIndex++] = mRawData[sourceIndex++];
				targetRawData[targetIndex++] = mRawData[sourceIndex++];
				targetRawData[targetIndex++] = mRawData[sourceIndex++];
				targetRawData[targetIndex++] = mRawData[sourceIndex++];
				targetRawData[targetIndex++] = mRawData[sourceIndex++];
			}
		}
		else
		{
			while (sourceIndex < sourceEnd)
				targetRawData[targetIndex++] = mRawData[sourceIndex++];
		}
	}
	
	/** Appends the vertices from another VertexData object. */
	public function append(data:VertexData):Void
	{
		mRawData.fixed = false;
		
		var targetIndex:Int = mRawData.length;
		var rawData:Vector<Float> = data.mRawData;
		var rawDataLength:Int = rawData.length;
		
		for (i in 0...rawDataLength)
			mRawData[targetIndex++] = rawData[i];
		
		mNumVertices += data.numVertices;
		mRawData.fixed = true;
	}
	
	// functions
	
	/** Updates the position values of a vertex. */
	public function setPosition(vertexID:Int, x:Float, y:Float):Void
	{
		var offset:Int = vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
		mRawData[offset] = x;
		mRawData[offset+1] = y;
	}
	
	/** Returns the position of a vertex. */
	public function getPosition(vertexID:Int, position:Point):Void
	{
		var offset:Int = vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
		position.x = mRawData[offset];
		position.y = mRawData[offset+1];
	}
	
	/** Updates the RGB color and alpha value of a vertex in one step. */
	public function setColorAndAlpha(vertexID:Int, color:UInt, alpha:Float):Void
	{
		if (alpha < 0.001)    alpha = 0.001; // zero alpha would wipe out all color data
		else if (alpha > 1.0) alpha = 1.0;
		
		var offset:Int = vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.COLOR_OFFSET;
		var multiplier:Float = mPremultipliedAlpha ? alpha : 1.0;
		
		mRawData[offset]        = ((color >> 16) & 0xff) / 255.0 * multiplier;
		mRawData[Std.int(offset+1)] = ((color >>  8) & 0xff) / 255.0 * multiplier;
		mRawData[Std.int(offset+2)] = ( color        & 0xff) / 255.0 * multiplier;
		mRawData[Std.int(offset+3)] = alpha;
	}
	
	/** Updates the RGB color values of a vertex (alpha is not changed). */
	public function setColor(vertexID:Int, color:UInt):Void
	{
		var offset:Int = vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.COLOR_OFFSET;
		var multiplier:Float = mPremultipliedAlpha ? mRawData[Std.int(offset+3)] : 1.0;
		mRawData[offset]        = ((color >> 16) & 0xff) / 255.0 * multiplier;
		mRawData[Std.int(offset+1)] = ((color >>  8) & 0xff) / 255.0 * multiplier;
		mRawData[Std.int(offset+2)] = ( color        & 0xff) / 255.0 * multiplier;
	}
	
	/** Returns the RGB color of a vertex (no alpha). */
	public function getColor(vertexID:Int):UInt
	{
		var offset:Int = vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.COLOR_OFFSET;
		var divisor:Float = mPremultipliedAlpha ? mRawData[Std.int(offset+3)] : 1.0;
		
		if (divisor == 0) return 0;
		else
		{
			var red:Float   = mRawData[offset]        / divisor;
			var green:Float = mRawData[Std.int(offset+1)] / divisor;
			var blue:Float  = mRawData[Std.int(offset+2)] / divisor;
			
			return (Std.int(red*255) << 16) | (Std.int(green*255) << 8) | Std.int(blue*255);
		}
	}
	
	/** Updates the alpha value of a vertex (range 0-1). */
	public function setAlpha(vertexID:Int, alpha:Float):Void
	{
		if (mPremultipliedAlpha)
			setColorAndAlpha(vertexID, getColor(vertexID), alpha);
		else
			mRawData[Std.int(vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.COLOR_OFFSET + 3)] = alpha;
	}
	
	/** Returns the alpha value of a vertex in the range 0-1. */
	public function getAlpha(vertexID:Int):Float
	{
		var offset:Int = vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.COLOR_OFFSET + 3;
		return mRawData[offset];
	}
	
	/** Updates the texture coordinates of a vertex (range 0-1). */
	public function setTexCoords(vertexID:Int, u:Float, v:Float):Void
	{
		var offset:Int = vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.TEXCOORD_OFFSET;
		
		mRawData[offset]        = u;
		mRawData[Std.int(offset + 1)] = v;
	}
	
	/** Returns the texture coordinates of a vertex in the range 0-1. */
	public function getTexCoords(vertexID:Int, texCoords:Point):Void
	{
		var offset:Int = vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.TEXCOORD_OFFSET;
		
		texCoords.x = Std.int(mRawData[offset]);
		texCoords.y = Std.int(mRawData[Std.int(offset + 1)]);
		
		#if js
		untyped __js__('if ("undefined" === typeof texCoords.x) texCoords.x = 0;');
		untyped __js__('if ("undefined" === typeof texCoords.y) texCoords.y = 0;');
		#end
		
		//if (texCoords.x == undefined) texCoords.x = 0;
		//if (texCoords.y == undefined) texCoords.y = 0;
		
	}
	
	// utility functions
	
	/** Translate the position of a vertex by a certain offset. */
	public function translateVertex(vertexID:Int, deltaX:Float, deltaY:Float):Void
	{
		var offset:Int = vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
		mRawData[offset]        += deltaX;
		mRawData[Std.int(offset+1)] += deltaY;
	}

	/** Transforms the position of subsequent vertices by multiplication with a 
	 *  transformation matrix. */
	public function transformVertex(vertexID:Int, matrix:Matrix, numVertices:Int=1):Void
	{
		var x:Float, y:Float;
		var offset:Int = vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
		
		for (i in 0...numVertices)
		{
			x = mRawData[offset];
			y = mRawData[Std.int(offset+1)];
			
			mRawData[offset]        = matrix.a * x + matrix.c * y + matrix.tx;
			mRawData[Std.int(offset+1)] = matrix.d * y + matrix.b * x + matrix.ty;
			
			offset += VertexData.ELEMENTS_PER_VERTEX;
		}
	}
	
	/** Sets all vertices of the object to the same color values. */
	public function setUniformColor(color:UInt):Void
	{
		for (i in 0...mNumVertices)
			setColor(i, color);
	}
	
	/** Sets all vertices of the object to the same alpha values. */
	public function setUniformAlpha(alpha:Float):Void
	{
		for (i in 0...mNumVertices)
			setAlpha(i, alpha);
	}
	
	/** Multiplies the alpha value of subsequent vertices with a certain factor. */
	public function scaleAlpha(vertexID:Int, factor:Float, numVertices:Int=1):Void
	{
		if (factor == 1.0) return;
		if (numVertices < 0 || vertexID + numVertices > mNumVertices)
			numVertices = mNumVertices - vertexID;
		 
		var i:Int;
		
		if (mPremultipliedAlpha)
		{
			for (i in 0...numVertices)
				setAlpha(vertexID+i, getAlpha(vertexID+i) * factor);
		}
		else
		{
			var offset:Int = vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.COLOR_OFFSET + 3;
			for (i in 0...numVertices)
				mRawData[Std.int(offset + i*VertexData.ELEMENTS_PER_VERTEX)] *= factor;
		}
	}
	
	/** Calculates the bounds of the vertices, which are optionally transformed by a matrix. 
	 *  If you pass a 'resultRect', the result will be stored in this rectangle 
	 *  instead of creating a new object. To use all vertices for the calculation, set
	 *  'numVertices' to '-1'. */
	public function getBounds(transformationMatrix:Matrix=null, 
							  vertexID:Int=0, numVertices:Int=-1,
							  resultRect:Rectangle=null):Rectangle
	{
		if (resultRect == null) resultRect = new Rectangle();
		if (numVertices < 0 || vertexID + numVertices > mNumVertices)
			numVertices = mNumVertices - vertexID;
		
		if (numVertices == 0)
		{
			if (transformationMatrix == null)
				resultRect.setEmpty();
			else
			{
				MatrixUtil.transformCoords(transformationMatrix, 0, 0, sHelperPoint);
				resultRect.setTo(sHelperPoint.x, sHelperPoint.y, 0, 0);
			}
		}
		else
		{
			var minX:Float = Math.POSITIVE_INFINITY;
			var maxX:Float = Math.NEGATIVE_INFINITY;
			var minY:Float = Math.POSITIVE_INFINITY;
			var maxY:Float = Math.NEGATIVE_INFINITY;
			var offset:Int = vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
			var x:Float, y:Float, i:Int;
			
			if (transformationMatrix == null)
			{
				for (i in 0...numVertices)
				{
					x = mRawData[offset];
					y = mRawData[Std.int(offset+1)];
					offset += VertexData.ELEMENTS_PER_VERTEX;
					
					if (minX > x) minX = x;
					if (maxX < x) maxX = x;
					if (minY > y) minY = y;
					if (maxY < y) maxY = y;
				}
			}
			else
			{
				for (i in 0...numVertices)
				{
					x = mRawData[offset];
					y = mRawData[Std.int(offset+1)];
					offset += VertexData.ELEMENTS_PER_VERTEX;
					
					MatrixUtil.transformCoords(transformationMatrix, x, y, sHelperPoint);
					
					if (minX > sHelperPoint.x) minX = sHelperPoint.x;
					if (maxX < sHelperPoint.x) maxX = sHelperPoint.x;
					if (minY > sHelperPoint.y) minY = sHelperPoint.y;
					if (maxY < sHelperPoint.y) maxY = sHelperPoint.y;
				}
			}
			
			resultRect.setTo(minX, minY, maxX - minX, maxY - minY);
		}
		
		return resultRect;
	}
	
	/** Calculates the bounds of the vertices, projected into the XY-plane of a certain
	 *  3D space as they appear from a certain camera position. Note that 'camPos' is expected
	 *  in the target coordinate system (the same that the XY-plane lies in).
	 *  If you pass a 'resultRectangle', the result will be stored in this rectangle
	 *  instead of creating a new object. To use all vertices for the calculation, set
	 *  'numVertices' to '-1'. */
	public function getBoundsProjected(transformationMatrix:Matrix3D, camPos:Vector3D,
									   vertexID:Int=0, numVertices:Int=-1,
									   resultRect:Rectangle=null):Rectangle
	{
		if (camPos == null) throw new ArgumentError("camPos must not be null");
		if (resultRect == null) resultRect = new Rectangle();
		if (numVertices < 0 || vertexID + numVertices > mNumVertices)
			numVertices = mNumVertices - vertexID;

		if (numVertices == 0)
		{
			if (transformationMatrix != null)
				MatrixUtil.transformCoords3D(transformationMatrix, 0, 0, 0, sHelperPoint3D);
			else
				sHelperPoint3D.setTo(0, 0, 0);

			MathUtil.intersectLineWithXYPlane(camPos, sHelperPoint3D, sHelperPoint);
			resultRect.setTo(sHelperPoint.x, sHelperPoint.y, 0, 0);
		}
		else
		{
			var minX:Float = Math.POSITIVE_INFINITY;
			var maxX:Float = Math.NEGATIVE_INFINITY;
			var minY:Float = Math.POSITIVE_INFINITY;
			var maxY:Float = Math.NEGATIVE_INFINITY;
			var offset:Int = vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
			var x:Float, y:Float, i:Int;

			for (i in 0...numVertices)
			{
				x = mRawData[offset];
				y = mRawData[Std.int(offset+1)];
				offset += VertexData.ELEMENTS_PER_VERTEX;

				if (transformationMatrix != null)
					MatrixUtil.transformCoords3D(transformationMatrix, x, y, 0, sHelperPoint3D);
				else
					sHelperPoint3D.setTo(x, y, 0);

				MathUtil.intersectLineWithXYPlane(camPos, sHelperPoint3D, sHelperPoint);

				if (minX > sHelperPoint.x) minX = sHelperPoint.x;
				if (maxX < sHelperPoint.x) maxX = sHelperPoint.x;
				if (minY > sHelperPoint.y) minY = sHelperPoint.y;
				if (maxY < sHelperPoint.y) maxY = sHelperPoint.y;
			}
			resultRect.setTo(minX, minY, maxX - minX, maxY - minY);
		}
		return resultRect;
	}

	/** Creates a string that contains the values of all included vertices. */
	public function toString():String
	{
		var result:String = "[VertexData \n";
		var position:Point = new Point();
		var texCoords:Point = new Point();
		
		for (i in 0...numVertices)
		{
			getPosition(i, position);
			
			getTexCoords(i, texCoords);
			
/*			result += "  [Vertex " + i + ": " +
				"x="   + position.x.toFixed(1)    + ", " +
				"y="   + position.y.toFixed(1)    + ", " +
				"rgb=" + getColor(i).toString(16) + ", " +
				"a="   + getAlpha(i).toFixed(2)   + ", " +
				"u="   + texCoords.x.toFixed(4)   + ", " +
				"v="   + texCoords.y.toFixed(4)   + "]"  +
				(i == numVertices - 1 ? "\n" : ",\n");*/
			
			result += "  [Vertex " + i + ": " +
				"x="   + Math.floor(position.x)    + ", " +
				"y="   + Math.floor(position.y)    + ", " +
				//"rgb=" + getColor(i).toString(16) + ", " +
				"a="   + cast(Math.floor(getAlpha(i) * 10) / 10, Float)   + ", " +
				"u="   + cast(Math.floor(texCoords.x * 1000) / 1000, Float) + ", " +
				"v="   + cast(Math.floor(texCoords.y * 1000) / 1000, Float) + "]"  +
				(i == numVertices-1 ? "\n" : ",\n");
		}
		
		result += "]";
		return result;
	}
	
	// properties
	
	/** Indicates if any vertices have a non-white color or are not fully opaque. */
	private function get_tinted():Bool
	{
		var offset:Int = VertexData.COLOR_OFFSET;
		
		for (i in 0...mNumVertices)
		{
			for (j in 0...4)
				if (mRawData[Std.int(offset+j)] != 1.0) return true;

			offset += VertexData.ELEMENTS_PER_VERTEX;
		}
		
		return false;
	}
	
	/** Changes the way alpha and color values are stored. Optionally updates all exisiting 
	 *  vertices. */
	public function setPremultipliedAlpha(value:Bool, updateData:Bool=true):Void
	{
		if (value == mPremultipliedAlpha) return;
		
		if (updateData)
		{
			var dataLength:Int = mNumVertices * VertexData.ELEMENTS_PER_VERTEX;
			
			var i = VertexData.COLOR_OFFSET;
			while (i < dataLength)
			{
				var alpha:Float = mRawData[Std.int(i+3)];
				var divisor:Float = mPremultipliedAlpha ? alpha : 1.0;
				var multiplier:Float = value ? alpha : 1.0;
				
				if (divisor != 0)
				{
					mRawData[i]        = mRawData[i]        / divisor * multiplier;
					mRawData[Std.int(i+1)] = mRawData[Std.int(i+1)] / divisor * multiplier;
					mRawData[Std.int(i+2)] = mRawData[Std.int(i+2)] / divisor * multiplier;
				}
				i += ELEMENTS_PER_VERTEX;
			}
		}
		
		mPremultipliedAlpha = value;
	}
	
   /** Indicates if the rgb values are stored premultiplied with the alpha value.
	*  If you change this value, the color data is updated accordingly. If you don't want
	*  that, use the 'setPremultipliedAlpha' method instead. */
	private function get_premultipliedAlpha():Bool { return mPremultipliedAlpha; }
	private function set_premultipliedAlpha(value:Bool):Bool
	{
		setPremultipliedAlpha(value);
		return value;
	}
	
	/** The total number of vertices. */
	private function get_numVertices():Int { return mNumVertices; }
	private function set_numVertices(value:Int):Int
	{
		mRawData.fixed = false;
		
		#if js
			//OPTIMIZE;
			// js hack to init values to 0
			var currentLength:Int = 0;
			mRawData.length = value * VertexData.ELEMENTS_PER_VERTEX;
			if (mRawData.length > currentLength) {
				for (j in 0...mRawData.length) 
				{
					untyped __js__('if ("undefined" === typeof this.mRawData.data[j]) this.mRawData.data[j] = 0;');
				}
			}
		#else
			mRawData.length = value * VertexData.ELEMENTS_PER_VERTEX;
		#end
		
		
		var startIndex:Int = (mNumVertices * VertexData.ELEMENTS_PER_VERTEX) + VertexData.COLOR_OFFSET + 3;
		var endIndex:Int = mRawData.length;
		
		var i = startIndex;
		while( i < endIndex)
        {
            mRawData[i] = 1.0; // alpha should be '1' per default
			i += VertexData.ELEMENTS_PER_VERTEX;
        }
		
		mNumVertices = value;
		mRawData.fixed = true;
		
		return value;
	}
	
	/** The raw vertex data; not a copy! */
	private function get_rawData():Vector<Float> { return mRawData; }
	
	private function set_rawData(value:Vector<Float>):Vector<Float>
	{
		mRawData = value;
		return value;
	}
}
