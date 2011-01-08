//
//  SFContext.h
//  GLES
//
//  Created by Justin Van Eaton on 10/6/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGLDrawable.h>
#endif
#import <QuartzCore/QuartzCore.h>
#import "SFCommon.h"
#import "SFScene.h"

@class SFScene;

#if TARGET_OS_IPHONE
@interface SFContext : UIView {	
#else
	@interface SFContext : NSOpenGLView {	
#endif
	GLint backingWidth;
    GLint backingHeight;
	
#if TARGET_OS_IPHONE
	EAGLContext *context;  
#else
	NSOpenGLContext *context;
	NSOpenGLPixelFormat *pixelFormat;
#endif
	
	GLuint viewRenderbuffer, viewFramebuffer;
    GLuint depthRenderbuffer;
	
	SFOpenGLVersion	glVersion;
}

- (id)init;
- (id)initWithVersion:(SFOpenGLVersion)version;
- (id)initWithVersion:(SFOpenGLVersion)version andFrame:(CGRect)frame;

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
- (void)drawScene:(SFScene *)scene;

- (void)setupGraphics;

+ (void)setModelViewWithOrthoLeft:(GLfloat)left right:(GLfloat)right bottom:(GLfloat)bottom top:(GLfloat)top  near:(GLfloat)near  far:(GLfloat)far;
+ (SFMatrix *)getModelView;

@end
