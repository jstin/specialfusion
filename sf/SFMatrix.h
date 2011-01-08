//
//  SFMatrix.h
//  GLES
//
//  Created by Justin Van Eaton on 9/28/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFCommon.h"

@interface SFMatrix : NSObject {
	GLfloat		*m;
}

@property (nonatomic) GLfloat	*m;

- (id)init;
- (void)identity;
- (void)setOrthoLeft:(GLfloat)left right:(GLfloat)right bottom:(GLfloat)bottom top:(GLfloat)top  near:(GLfloat)near  far:(GLfloat)far;
- (void)setScaleWithX:(GLfloat)xScale andY:(GLfloat)yScale andZ:(GLfloat)zScale;
- (void)setTranslateWithX:(GLfloat)xTranslate andY:(GLfloat)yTranslate andZ:(GLfloat)zTranslate;

- (SFVertex)multiplyVertex:(SFVertex)vertex;
- (SFVertex)inverseMultiplyVertex:(SFVertex)vertex;

+ (SFMatrix *)add:(SFMatrix *)a with:(SFMatrix *)b;
+ (SFMatrix *)multiply:(SFMatrix *)a with:(SFMatrix *)b;

@end
