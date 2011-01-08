//
//  SFAlphaSprite.m
//  TestSF
//
//  Created by Justin Van Eaton on 10/21/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import "SFAlphaSprite.h"


@implementation SFAlphaSprite

- (id)initWithFilename:(NSString *)inFilename andCharacterSize:(CGSize)size
{
	if (self = [super initWithFilename:inFilename])
	{
		[self createAnimatedStrip:size];
	}
	
	return self;
}

- (void)setText:(NSString *)str
{
	curText = [str retain];
	[self setCollideRect:CGSizeMake([str length]*animatedFrameSize.width, animatedFrameSize.height)];
}

- (NSString *)getText
{
	return curText;
}

- (void)drawWithVersion:(SFOpenGLVersion)version
{
	unichar chars[[curText length]];
	[[curText uppercaseString] getCharacters:chars];
	
	GLfloat saveX = self.xPos;
	GLfloat saveY = self.yPos;
	
	SFVertex vert = [transformMatrix multiplyVertex:SFVertexMake(1, 0, 0)];
	
	for (int i = 0; i < [curText length]; i++) {
		if (chars[i] != 32) // space
		{
			[self setAnimationFrame:chars[i] - 65];
			self.xPos = saveX + (i * animatedFrameSize.width - (animatedFrameSize.width * ([curText length] - 1))/2.) * self.xScale * vert.x;
			self.yPos = saveY + (i * animatedFrameSize.width - (animatedFrameSize.width * ([curText length] - 1))/2.) * self.xScale * vert.y;
			[super drawWithVersion:version];
		}
	}
	
	self.xPos = saveX;
	self.yPos = saveY;
}

- (BOOL)collideSphereWithSphere:(SFObject *)object
{
	float r1 = collideRadius * MAX(xScale, yScale);
	float r2 = object.collideRadius * MAX(object.xScale, object.yScale);
	
	BOOL inside;
	
	GLfloat saveX = self.xPos;
	GLfloat saveY = self.yPos;
	
	SFVertex vert = [transformMatrix multiplyVertex:SFVertexMake(1, 0, 0)];
	
	for (int i = 0; i < [curText length]; i++) {
			self.xPos = saveX + (i * animatedFrameSize.width - (animatedFrameSize.width * ([curText length] - 1))/2.) * self.xScale * vert.x;
			self.yPos = saveY + (i * animatedFrameSize.width - (animatedFrameSize.width * ([curText length] - 1))/2.) * self.xScale * vert.y;
			
			inside = ((r1 + r2) * (r1 + r2)) > ((xPos - object.xPos) * (xPos - object.xPos) + (yPos - object.yPos) * (yPos - object.yPos));
			if (inside) {
				self.xPos = saveX;
				self.yPos = saveY;
				[self processCollisionWithObject:object];
				return inside;
			}
	}
	
	self.xPos = saveX;
	self.yPos = saveY;
	
	return inside;
}

@end
