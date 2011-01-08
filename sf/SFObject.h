//
//  SFObject.h
//  GLES
//
//  Created by Justin Van Eaton on 9/27/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFCommon.h"
#import "SFMatrix.h"
#import "SFQuaternion.h"
#import "SFMesh.h"
#import "SFContext.h"
#import "SFCollisionObject.h"

@class SFMesh;
@class SFMatrix;
@class SFQuaternion;

@interface SFObject : NSObject {
	SFMesh				*mesh;
	GLfloat				xPos;
	GLfloat				yPos;
	GLfloat				zPos;
	
	GLfloat				xRot;
	GLfloat				yRot;
	GLfloat				zRot;
	
	GLfloat				xScale;
	GLfloat				yScale;
	GLfloat				zScale;
	
	GLfloat				xOffset;
	GLfloat				yOffset;
	GLfloat				zOffset;
	
	GLfloat				alpha;
	
	SFMatrix			*transformMatrix;
	SFQuaternion		*quaternion;
	
	SEL					moveCallback;
	SEL					collideCallback;
	
	NSObject			*moveCallbackTarget;
	NSObject			*collideCallbackTarget;
	
	// ES 2
	
	GLuint programObject;
	
	GLint  positionLoc;
	GLint  texCoordLoc;
	
	GLint samplerLoc;
	GLint alphaLoc;
	
	GLint matrixHandle;
	
	// Collision
	GLfloat collideRadius;
	
	SFCollisionType	collisionType;
}

@property GLfloat	collideRadius;

@property GLfloat	xPos;
@property GLfloat	yPos;
@property GLfloat	zPos;

@property GLfloat	xScale;
@property GLfloat	yScale;
@property GLfloat	zScale;

@property GLfloat	xOffset;
@property GLfloat	yOffset;
@property GLfloat	zOffset;

@property GLuint	programObject;
@property GLint		positionLoc;
@property GLint		texCoordLoc;
@property GLint		samplerLoc;
@property GLint		alphaLoc;
@property GLint		matrixHandle;

@property SFCollisionType		collisionType;



- (id)init;
+ (SFObject *)clone:(SFObject *)object;
- (void)clone:(SFObject *)object;


- (void)drawWithVersion:(SFOpenGLVersion)version;

- (void)offsetWithX:(GLfloat)x andY:(GLfloat)y andZ:(GLfloat)z;
- (void)rotateWithX:(GLfloat)x andY:(GLfloat)y andZ:(GLfloat)z;

- (void)setLocationWithX:(GLfloat)x andY:(GLfloat)y andZ:(GLfloat)z;
- (void)setRotationWithX:(GLfloat)x andY:(GLfloat)y andZ:(GLfloat)z;

- (void)setScaleWithX:(GLfloat)x andY:(GLfloat)y andZ:(GLfloat)z;

- (void)setAlpha:(GLfloat)value;

- (void)setMovementCallback:(SEL)callback withDelegate:(NSObject *)target;
- (void)setCollisionCallback:(SEL)callback withDelegate:(NSObject *)target;

- (void)processMovement;
- (void)processCollisionWithObject:(SFObject *)object;

- (BOOL)collideWithObject:(SFObject *)object;
- (BOOL)collideSphereWithSphere:(SFObject *)object;
- (BOOL)collideRectWithRect:(SFObject *)object;
- (BOOL)collideRectWithSphere:(SFObject *)object;


- (GLuint)loadProgramWithVert:(const char *)vertShaderSrc andFrag:(const char *)fragShaderSrc;
- (GLuint)loadShaderWithType:(GLenum)type andShader:(const char *)shaderSrc;

- (SFMesh *)getMesh;
- (SFMatrix *)getTransformMatrix;

@end
