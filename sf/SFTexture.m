//
//  SFTexture.m
//  GLES
//
//  Created by Justin Van Eaton on 9/27/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import "SFTexture.h"


@implementation SFTexture


- (id)initWithFilename:(NSString *)inFilename
{
	if (self = [super init])
	{
		glEnable(GL_TEXTURE_2D);
		
		//glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);  
		glGenTextures(1, &texture[0]);
		glBindTexture(GL_TEXTURE_2D, texture[0]);
		//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
		//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		
		NSString *extension = [inFilename pathExtension];
		NSString *baseFilenameWithExtension = [inFilename lastPathComponent];
		NSString *baseFilename = [baseFilenameWithExtension substringToIndex:[baseFilenameWithExtension length] - [extension length] - 1];
		
		NSString *path = [[NSBundle mainBundle] pathForResource:baseFilename ofType:extension];
		NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
		
		// Assumes pvr4 is RGB not RGBA, which is how texturetool generates them
		//if ([extension isEqualToString:@"pvr4"])
			//glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, inWidth, inHeight, 0, (inWidth * inHeight) / 2, [texData bytes]);
		//else if ([extension isEqualToString:@"pvr2"])
			//glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG, inWidth, inHeight, 0, (inWidth * inHeight) / 2, [texData bytes]);
		//else
	//	{
#if TARGET_OS_IPHONE
			UIImage *uimage = [[UIImage alloc] initWithData:texData];
		
			if (uimage == nil)
				return nil;
		
			CGImageRef image = uimage.CGImage;
#else
			NSURL					*url = nil;
			CGImageSourceRef		src;
			CGImageRef				image;
			url = [NSURL fileURLWithPath: path];
			src = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
			
			if (!src) {
				NSLog(@"No image");
				return nil;
			}
			
			image = CGImageSourceCreateImageAtIndex(src, 0, NULL);
#endif
			
			width = CGImageGetWidth(image);
			height = CGImageGetHeight(image);
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
			void *imageData = malloc( height * width * 4 );
			CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
			CGColorSpaceRelease( colorSpace );
			CGContextTranslateCTM (context, 0, height);
			CGContextScaleCTM (context, 1.0, -1.0);
			CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
			CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image );
			
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
			//GLuint errorcode = glGetError();
			CGContextRelease(context);
			
			free(imageData);
#if TARGET_OS_IPHONE
			[uimage release];
#endif
	//	}
		glEnable(GL_BLEND);
		
		coords = malloc(sizeof(GLfloat) * 8);
		[self defaultCoords];
	}
	return self;
}

- (void)bind
{
	glBindTexture(GL_TEXTURE_2D, texture[0]);
}

- (void)defaultCoords
{
	coords[0] = 0.0; coords[1] = 1.0;
	coords[2] = 0.0; coords[3] = 0.0;
	coords[4] = 1.0; coords[5] = 1.0;
	coords[6] = 1.0; coords[7] = 0.0;
}

- (void)setCoords:(CGRect)theRect
{
	coords[0] = theRect.origin.x; coords[1] = theRect.size.height;
	coords[2] = theRect.origin.x; coords[3] = theRect.origin.y;
	coords[4] = theRect.size.width; coords[5] = theRect.size.height;
	coords[6] = theRect.size.width; coords[7] = theRect.origin.y;
}

- (void)drawWithVersion:(SFOpenGLVersion)version
{
	if (version == SFOpenGLES1)
	{
		[self bind];
		glTexCoordPointer(2, GL_FLOAT, 0, coords);
	}
}

- (GLuint)getWidth
{
	return width;
}

- (GLuint)getHeight
{
	return height;
}

- (GLfloat *)getCoords
{
	return coords;
}

- (void)dealloc
{
	free(coords);
	glDeleteTextures(1, &texture[0]);
	[super dealloc];
}

@end
