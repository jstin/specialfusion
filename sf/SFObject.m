//
//  SFObject.m
//  GLES
//
//  Created by Justin Van Eaton on 9/27/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import "SFObject.h"

@implementation SFObject

@synthesize	collideRadius;
@synthesize	xPos;
@synthesize	yPos;
@synthesize	zPos;

@synthesize	xScale;
@synthesize	yScale;
@synthesize	zScale;

@synthesize	xOffset;
@synthesize	yOffset;
@synthesize	zOffset;

@synthesize	programObject;
@synthesize	positionLoc;
@synthesize	texCoordLoc;
@synthesize	samplerLoc;
@synthesize	alphaLoc;
@synthesize	matrixHandle;

@synthesize collisionType;


+ (SFObject *)clone:(SFObject *)object
{
	SFObject *newObject = [[SFObject alloc] init];
	
	[newObject clone:object];
	
	return newObject;
}

- (void)clone:(SFObject *)object
{
	mesh = [object getMesh];
}

- (id)init
{
	if (self = [super init])
	{
		transformMatrix = [[SFMatrix alloc] init];
		quaternion = [[SFQuaternion alloc] init];
		
		xScale = 1.0;
		yScale = 1.0;
		zScale = 1.0;
		
		alpha = 1.0;
		
		collisionType = SFCollisionTypeRectangular;
	}
	return self;
}

- (void)drawWithVersion:(SFOpenGLVersion)version
{
	if (version == SFOpenGLES1) {
		glLoadIdentity();
		glTranslatef(xPos, yPos, zPos);
		glMultMatrixf(transformMatrix.m);
		glScalef(xScale, yScale, zScale);
		glColor4f(1.0, 1.0, 1.0, alpha);
	}
	else if (version == SFOpenGLES2)
	{
		glUseProgram(programObject);
				
		glUniform1i(samplerLoc, 0);
		
		SFMatrix *modelView = [SFContext getModelView];
		SFMatrix *scaleMatrix = [[SFMatrix alloc] init];
		SFMatrix *modelViewWithRot;
		
		
		[scaleMatrix setScaleWithX:xScale andY:yScale andZ:zScale];
		
		modelViewWithRot = [SFMatrix multiply:modelView with:scaleMatrix];
		modelViewWithRot = [SFMatrix multiply:transformMatrix with:modelViewWithRot];
		
		
		[scaleMatrix setTranslateWithX:xPos - 0 andY:yPos - 0 andZ:zPos];
		scaleMatrix = [SFMatrix multiply:scaleMatrix with:modelView];
		
		modelViewWithRot.m[12] = scaleMatrix.m[12];
		modelViewWithRot.m[13] = scaleMatrix.m[13];
		modelViewWithRot.m[14] = scaleMatrix.m[14];
		
		glUniformMatrix4fv(matrixHandle, 1, GL_FALSE, modelViewWithRot.m );
		glUniform1f (alphaLoc, alpha);
		
		[mesh drawWithShaderVertex:positionLoc andFrag:texCoordLoc];
	}
	
	[mesh drawWithVersion:version];
}

- (void)offsetWithX:(GLfloat)x andY:(GLfloat)y andZ:(GLfloat)z
{
	xPos += x;
	yPos += y;
	zPos += z;
}

- (void)rotateWithX:(GLfloat)x andY:(GLfloat)y andZ:(GLfloat)z
{
	xRot += x;												// Store the rotations
	yRot += y;
	zRot += z;
	
	[quaternion	eulerToQuaternionWithX:xRot andY:yRot andZ:zRot];	// Convert the new offset to a Quat
	
	[quaternion getMatrix:transformMatrix];
}

- (void)setLocationWithX:(GLfloat)x andY:(GLfloat)y andZ:(GLfloat)z
{
	xPos = x;
	yPos = y;
	zPos = z;
}

- (void)setRotationWithX:(GLfloat)x andY:(GLfloat)y andZ:(GLfloat)z
{
	xRot = x;												// Store the rotations
	yRot = y;
	zRot = z;
	
	[quaternion	eulerToQuaternionWithX:xRot andY:yRot andZ:zRot];	// Convert the new offset to a Quat
	
	[quaternion getMatrix:transformMatrix];
}

- (void)setScaleWithX:(GLfloat)x andY:(GLfloat)y andZ:(GLfloat)z
{
	xScale = x;												
	yScale = y;
	zScale = z;
}

- (void)setAlpha:(GLfloat)value
{
	alpha = value;
}

- (void)setMovementCallback:(SEL)callback withDelegate:(NSObject *)target
{
	moveCallback = callback;
	moveCallbackTarget = target;
}

- (void)setCollisionCallback:(SEL)callback withDelegate:(NSObject *)target
{
	collideCallback = callback;
	collideCallbackTarget = target;
}

- (void)processMovement
{
	if( moveCallbackTarget && moveCallback)
	{
		if ([moveCallbackTarget respondsToSelector:moveCallback])
		{
			[moveCallbackTarget performSelectorOnMainThread:moveCallback withObject:self waitUntilDone:YES];
		}
	}
}

- (void)processCollisionWithObject:(SFObject *)object
{
	if( collideCallbackTarget && collideCallback)
	{
		if ([collideCallbackTarget respondsToSelector:collideCallback])
		{
			SFCollisionObject *colObject = [[SFCollisionObject alloc] init];
			colObject.selfObject = self;
			colObject.foundObject = object;
			[collideCallbackTarget performSelectorOnMainThread:collideCallback withObject:colObject waitUntilDone:YES];
		}
	}
}

- (GLuint)loadProgramWithVert:(const char *)vertShaderSrc andFrag:(const char *)fragShaderSrc
{
	GLuint vertexShader;
	GLuint fragmentShader;
	GLuint pbject;
	GLint linked;
	
	// Load the vertex/fragment shaders
	vertexShader = [self loadShaderWithType:GL_VERTEX_SHADER andShader:vertShaderSrc];
	if ( vertexShader == 0 )
		return 0;
	
	fragmentShader = [self loadShaderWithType:GL_FRAGMENT_SHADER andShader:fragShaderSrc];
	if ( fragmentShader == 0 )
	{
		glDeleteShader( vertexShader );
		return 0;
	}
	
	// Create the program object
	pbject = glCreateProgram ( );
	
	if ( pbject == 0 )
		return 0;
	
	glAttachShader ( pbject, vertexShader );
	glAttachShader ( pbject, fragmentShader );
	
	// Link the program
	glLinkProgram ( pbject );
	
	// Check the link status
	glGetProgramiv ( pbject, GL_LINK_STATUS, &linked );
	
	if ( !linked ) 
	{
		GLint infoLen = 0;
		
		glGetProgramiv ( pbject, GL_INFO_LOG_LENGTH, &infoLen );
		
		if ( infoLen > 1 )
		{
			void* infoLog = malloc (sizeof(char) * infoLen );
			
			//glGetProgramInfoLog ( pbject, infoLen, NULL, infoLog );
			//esLogMessage ( "Error linking program:\n%s\n", infoLog );            
			
			free ( infoLog );
		}
		
		glDeleteProgram ( pbject );
		return 0;
	}
	
	// Free up no longer needed shader resources
	glDeleteShader ( vertexShader );
	glDeleteShader ( fragmentShader );
	
	return pbject;
}

- (GLuint)loadShaderWithType:(GLenum)type andShader:(const char *)shaderSrc
{
	GLuint shader;
	GLint compiled;
	
	// Create the shader object
	shader = glCreateShader( type );
	
	if ( shader == 0 )
		return 0;
	
	// Load the shader source
	glShaderSource ( shader, 1, &shaderSrc, NULL );
	
	// Compile the shader
	glCompileShader ( shader );
	
	// Check the compile status
	glGetShaderiv ( shader, GL_COMPILE_STATUS, &compiled );
	
	if ( !compiled ) 
	{
		GLint infoLen = 0;
		
		glGetShaderiv ( shader, GL_INFO_LOG_LENGTH, &infoLen );
		
		if ( infoLen > 1 )
		{
			void* infoLog = malloc (sizeof(char) * infoLen );
			
			//glGetShaderInfoLog ( shader, infoLen, NULL, infoLog );
			//esLogMessage ( "Error compiling shader:\n%s\n", infoLog );            
			
			free ( infoLog );
		}
		
		glDeleteShader ( shader );
		return 0;
	}
	
	return shader;
	
}

- (BOOL)collideWithObject:(SFObject *)object
{
	return false;
}

- (BOOL)collideSphereWithSphere:(SFObject *)object
{
	return false;
}

- (BOOL)collideRectWithRect:(SFObject *)object
{
	return false;
}

- (BOOL)collideRectWithSphere:(SFObject *)object;
{
	return false;
}

- (SFMesh *)getMesh
{
	return mesh;
}

- (SFMatrix *)getTransformMatrix
{
	return transformMatrix;
}

@end
