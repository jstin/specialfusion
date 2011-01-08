//
//  SFScene.m
//  GLES
//
//  Created by Justin Van Eaton on 9/27/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import "SFScene.h"

@implementation SFScene

- (id)init
{
	if (self = [super init])
	{
		layers = [[NSMutableArray alloc] init];
		
		backgroundRed = 0.7;
		backgroundGreen = 0.7;
		backgroundBlue = 0.7;
	}
	return self;
}

- (void)drawWithVersion:(SFOpenGLVersion)version
{
	glClearColor(backgroundRed, backgroundGreen, backgroundBlue, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	NSEnumerator *enumerator = [layers objectEnumerator];
	SFLayer *layer;
	while( layer = [enumerator nextObject] )
	{
		[layer moveObjects];
	}
	
	enumerator = [layers objectEnumerator];
	while( layer = [enumerator nextObject] )
	{
		[layer collideObjects];
	}

	enumerator = [layers objectEnumerator];
	while( layer = [enumerator nextObject] )
	{
		[layer drawWithVersion:version];
	}	
}

- (void)addLayer:(SFLayer *)inObject
{
	[layers addObject:inObject];
}

- (void)removeLayer:(SFLayer *)inObject;
{	
	[layers removeObject:inObject];
}

- (void)setBackgroundColorWithRed:(GLfloat)red andGreen:(GLfloat)green andBlue:(GLfloat)blue
{
	backgroundRed = red;
	backgroundGreen = green;
	backgroundBlue = blue;
}

@end
