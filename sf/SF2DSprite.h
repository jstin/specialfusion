//
//  SF2DSprite.h
//  GLES
//
//  Created by Justin Van Eaton on 9/27/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFCommon.h"
#import "SFObject.h"
#import "SFMesh.h"

@interface SF2DSprite : SFObject {
	CGSize	animatedFrameSize;
	CGSize	collisionRect;
	GLint	numFrames;
	GLint	curFrame;
	BOOL	animateForward;
	
	SFAnimationDirection	animationDirection;
	SFAnimationAdvanceType	animationAdvance;
}

@property CGSize		animatedFrameSize;
@property CGSize		collisionRect;
@property GLint		numFrames;
@property GLint		curFrame;


+ (id)clone:(id)object;
- (void)clone:(SF2DSprite *)object;
- (id)initWithFilename:(NSString *)inFilename;
- (void)setDefaultMesh;
- (void)setMeshToTexture;
- (void)setSize:(CGSize)theSize;
- (void)setTextureRegion:(CGRect)theRect;
- (void)setCollideRect:(CGSize)theSize;

- (void)createAnimatedStrip:(CGSize)theSize;
- (void)setAnimationFrame:(GLint)frame;
- (GLint)getAnimationFrame;
- (void)advanceAnimation;
- (void)setAnimationAdvanceType:(SFAnimationAdvanceType)advanceType;

- (BOOL)pointInRect:(CGPoint)point;

@end
