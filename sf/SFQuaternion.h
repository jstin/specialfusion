//
//  SFQauternion.h
//  GLES
//
//  Created by Justin Van Eaton on 9/28/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFCommon.h"
#import "SFMatrix.h"

@interface SFQuaternion : NSObject {
	GLfloat	x;
	GLfloat	y;
	GLfloat	z;
	GLfloat	w;
}

- (void)indentity;
- (GLfloat)norm;
- (void)normalize;
- (void)eulerToQuaternionWithX:(GLfloat)inX andY:(GLfloat)inY andZ:(GLfloat)inZ;
- (void)getMatrix:(SFMatrix *)matrix;

@end
