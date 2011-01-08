//
//  SFContext.m
//  GLES
//
//  Created by Justin Van Eaton on 10/6/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import "SFContext.h"


@implementation SFContext

static SFMatrix	*modelView;

#if TARGET_OS_IPHONE
+ (Class)layerClass 
{
    return [CAEAGLLayer class];
}
#endif

- (id)init 
{
    if ((self = [super init])) {
#if TARGET_OS_IPHONE

        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], 
										kEAGLDrawablePropertyRetainedBacking, 
										kEAGLColorFormatRGBA8, 
										kEAGLDrawablePropertyColorFormat, nil];		
#endif
		
    }
    return self;
}

- (id)initWithVersion:(SFOpenGLVersion)version
{
	if ((self = [self init])) {
#if TARGET_OS_IPHONE
		
		if (version == SFOpenGLES2) {
			context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
			if (!context || ![EAGLContext setCurrentContext:context])
			{
				context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
			
				if (!context || ![EAGLContext setCurrentContext:context]) {
					[self release];
					return nil;
				}
				else {
					glVersion = SFOpenGLES1;
				}
			}
			else {
				glVersion = SFOpenGLES2;
			}
		}
		else {
			context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
            
            if (!context || ![EAGLContext setCurrentContext:context]) {
                [self release];
                return nil;
            }
			else {
				glVersion = SFOpenGLES1;
			}

        }
#else
		glVersion = SFOpenGLMacOS;
#endif        
    }
    return self;
}

- (id)initWithVersion:(SFOpenGLVersion)version andFrame:(CGRect)frame
{
#if TARGET_OS_IPHONE
	if ((self = [self initWithVersion:version])) {

        self.frame = frame;
#else
		NSOpenGLPixelFormatAttribute attribs[] =
		{
			kCGLPFAAccelerated,
			kCGLPFANoRecovery,
			kCGLPFADoubleBuffer,
			kCGLPFAColorSize, 24,
			kCGLPFADepthSize, 16,
			0
		};
		
		pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
		
		if (!pixelFormat)
			NSLog(@"No OpenGL pixel format");
		
		
		
	if ((self = [super initWithFrame:frame pixelFormat:pixelFormat])) {
			context = [self openGLContext];
		
		
			[context makeCurrentContext];
			
			// Synchronize buffer swaps with vertical refresh rate
			GLint swapInt = 1;
			[context setValues:&swapInt forParameter:NSOpenGLCPSwapInterval]; 
			
					
		backingWidth = frame.size.width;
		backingHeight = frame.size.height;
			glVersion = SFOpenGLES1;
			[self setupGraphics];
		
#endif
		
    }
    return self;
}

- (void)drawScene:(SFScene *)scene 
{
#if TARGET_OS_IPHONE

    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	[scene drawWithVersion:glVersion];
	
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
#else
	CGLLockContext([context CGLContextObj]);
	
	// Make sure we draw to the right context
	[context makeCurrentContext];
	
	[scene drawWithVersion:glVersion];
	[context flushBuffer];
	
	CGLUnlockContext([context CGLContextObj]);
#endif
}

#if TARGET_OS_IPHONE
- (void)layoutSubviews 
{
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
}

- (BOOL)createFramebuffer 
{
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (0) 
    {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) 
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }

	[self setupGraphics];
	
    return YES;
}

- (void)destroyFramebuffer 
{
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) 
    {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}
#else
- (BOOL)createFramebuffer
{
	return false;
}
	
- (void)destroyFramebuffer 
{
}
#endif

- (void)dealloc 
{   
#if TARGET_OS_IPHONE
    if ([EAGLContext currentContext] == context) 
        [EAGLContext setCurrentContext:nil];
#endif
    
    [context release];  
    [super dealloc];
}

- (void)setupGraphics
{
	
}

+ (void)setModelViewWithOrthoLeft:(GLfloat)left right:(GLfloat)right bottom:(GLfloat)bottom top:(GLfloat)top  near:(GLfloat)near  far:(GLfloat)far
{
	modelView = [[SFMatrix alloc] init];
	[modelView setOrthoLeft:left right:right bottom:bottom top:top near:near far:far];
}

+ (SFMatrix *)getModelView
{
	return modelView;
}

@end
