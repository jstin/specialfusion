//
//  SFTexture.h
//  GLES
//
//  Created by Justin Van Eaton on 9/27/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFCommon.h"


@interface SFTexture : NSObject {
	GLuint			texture[1];
	GLfloat			*coords;
	GLuint			width;
	GLuint			height;
}

- (id)initWithFilename:(NSString *)inFilename;
- (void)bind;
- (void)defaultCoords;
- (void)drawWithVersion:(SFOpenGLVersion)version;

- (GLuint)getHeight;
- (GLuint)getWidth;
- (GLfloat *)getCoords;

- (void)setCoords:(CGRect)theRect;

@end
