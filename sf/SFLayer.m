//
//  SFLayer.m
//  GLES
//
//  Created by Justin Van Eaton on 10/3/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import "SFLayer.h"


@implementation SFLayer

- (id)init
{
	if (self = [super init])
	{
		objects = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)drawWithVersion:(SFOpenGLVersion)version
{
	NSEnumerator *enumerator = [objects objectEnumerator];
	SFObject *object;
	while( object = [enumerator nextObject] )
	{
		[object drawWithVersion:version];
	}
}

- (void)moveObjects
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableArray *arr = [NSMutableArray arrayWithArray:objects];
	NSEnumerator *enumerator = [arr objectEnumerator];
	SFObject *object;
	while( object = [enumerator nextObject] )
	{
		[object processMovement];
	}
	
	[pool drain];
}

- (void)collideObjects
{
	[self collideWithLayer:collideLayer];
}

- (void)collideWithLayer:(SFLayer *)layer
{
	if (!layer)
		return;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableArray *arr = [NSMutableArray arrayWithArray:objects];
	NSEnumerator *enumerator = [arr objectEnumerator];
	SFObject *object;
	while( object = [enumerator nextObject] )
	{
		NSMutableArray *arr2 = [NSMutableArray arrayWithArray:[layer getObjects]];
		NSEnumerator *enumerator2 = [arr2 objectEnumerator];
		SFObject *object2;
		while( object2 = [enumerator2 nextObject] )
		{
			if (object != object2)
				[object collideWithObject:object2];
		}
	}
	
	[pool drain];
}

- (void)addObject:(SFObject *)inObject
{
	[objects addObject:inObject];
}

- (void)removeObject:(SFObject *)inObject
{
	[objects removeObject:inObject];
}

- (void)addCollideLayer:(SFLayer *)layer
{
	collideLayer = layer;
}

- (NSArray *)getObjects
{
	return objects;
}



@end
