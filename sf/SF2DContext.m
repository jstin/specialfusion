//
//  SF2DContext.m
//  TestSF
//
//  Created by Justin Van Eaton on 10/6/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import "SF2DContext.h"


@implementation SF2DContext

- (void)setupGraphics
{
	if (glVersion == SFOpenGLES1 || glVersion == SFOpenGLMacOS)
	{
		glMatrixMode(GL_PROJECTION); 
#if TARGET_OS_IPHONE
		glOrthof(0,                                         // Left
#else
		glOrtho(0,                                          // Left
#endif
				 backingWidth,								// Right
				 0,											// Bottom
				 backingHeight,								// Top
				 0.01,                                      // Near
				 20.0);                                     // Far 
		glViewport(0, 0, backingWidth, backingHeight);  
		glMatrixMode(GL_MODELVIEW);
		
		glLoadIdentity(); 
		
		
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	else if (glVersion == SFOpenGLES2)
	{
		[SFContext setModelViewWithOrthoLeft:0 right:backingWidth bottom:0 top:backingHeight near:0.01 far:20.0];
		glViewport(0, 0, backingWidth, backingHeight);
	}
}

@end
