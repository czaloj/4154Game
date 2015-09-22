// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.errors;

import openfl.errors.Error;

/** A MissingContextError is thrown when a Context3D object is required but not (yet) 
 *  available. */
class MissingContextError extends Error
{
	/** Creates a new MissingContextError object. */
	public function new(message:Dynamic="Starling context is missing", id:Dynamic=0)
	{
		super(message, id);
	}
}