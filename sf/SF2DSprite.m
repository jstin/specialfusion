//
//  SF2DSprite.m
//  GLES
//
//  Created by Justin Van Eaton on 9/27/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import "SF2DSprite.h"


@implementation SF2DSprite

@synthesize animatedFrameSize;
@synthesize collisionRect;
@synthesize curFrame;
@synthesize numFrames;

+ (id)clone:(id)object
{
	SF2DSprite *newObject = [[[object class] alloc] init];
	
	[newObject clone:object];
		
	return newObject;
}

- (void)clone:(SF2DSprite *)object
{
	mesh = [object getMesh];
	
	programObject = object.programObject;
	positionLoc = object.positionLoc;
	texCoordLoc = object.texCoordLoc;
	samplerLoc = object.samplerLoc;
	matrixHandle = object.matrixHandle;
	alphaLoc = object.alphaLoc;
	
	animatedFrameSize = object.animatedFrameSize;
	collisionRect = object.collisionRect;
	numFrames = object.numFrames;
	curFrame = object.curFrame;
}

- (id)initWithFilename:(NSString *)inFilename
{
	if (self = [super init])
	{
		mesh = [[SFMesh alloc] initWithVertexCount:4];
		[mesh loadTexture:inFilename];
		
#if TARGET_OS_IPHONE

		EAGLContext *c = [EAGLContext currentContext];
		
		if (c.API == kEAGLRenderingAPIOpenGLES2)
		{
			GLbyte vShaderStr[] =  
			"uniform mat4 u_mvpMatrix;                  \n"
			"attribute vec4 a_position;	                \n"
			"attribute vec2 a_texCoord;                 \n"
			"uniform float u_alpha;                     \n"
			"varying vec2 v_texCoord;                   \n"
			"varying float v_alpha;						\n"
			"void main()                                \n"
			"{                                          \n"
			"   gl_Position = u_mvpMatrix * a_position; \n"
			"   v_texCoord = a_texCoord;                \n"
			"   v_alpha = u_alpha;						\n"
			"}                                          \n";
			
			GLbyte fShaderStr[] =  
			"precision mediump float;                            \n"
			"varying vec2 v_texCoord;                            \n"
			"uniform sampler2D s_texture;                        \n"
			"varying float v_alpha;                              \n"
			"void main()                                         \n"
			"{                                                   \n"
			"  gl_FragColor = texture2D( s_texture, v_texCoord );\n"
			"  gl_FragColor[3] *= min(v_alpha, 1.0);			 \n"
			"}                                                   \n";
			
			programObject =  [self loadProgramWithVert:vShaderStr andFrag:fShaderStr];
			positionLoc = glGetAttribLocation ( programObject, "a_position" );
			texCoordLoc = glGetAttribLocation ( programObject, "a_texCoord" );
			samplerLoc = glGetUniformLocation ( programObject, "s_texture" );
			matrixHandle = glGetUniformLocation( programObject, "u_mvpMatrix");
			alphaLoc = glGetUniformLocation( programObject, "u_alpha");
		}
#endif				
		[self setMeshToTexture];
	}
	return self;
}

- (void)setDefaultMesh
{
	[mesh setVertexPointWithIndex:0 andX:-0.5 andY:0.5 andZ:-1.0];
	[mesh setVertexPointWithIndex:1 andX:-0.5 andY:-0.5 andZ:-1.0];
	[mesh setVertexPointWithIndex:2 andX:0.5 andY:0.5 andZ:-1.0];
	[mesh setVertexPointWithIndex:3 andX:0.5 andY:-0.5 andZ:-1.0];
	
	collideRadius = sqrt(2)/2.;
}

- (void)setMeshToTexture
{
	[self setSize:CGSizeMake([mesh.texture getWidth], [mesh.texture getHeight])];
}

- (void)setSize:(CGSize)theSize
{
	[mesh setVertexPointWithIndex:0 andX:-(theSize.width/2.0)  andY:(theSize.height/2.0) andZ:-1.0];
	[mesh setVertexPointWithIndex:1 andX:-(theSize.width/2.0)  andY:-(theSize.height/2.0) andZ:-1.0];
	[mesh setVertexPointWithIndex:2 andX:(theSize.width/2.0)  andY:(theSize.height/2.0) andZ:-1.0];
	[mesh setVertexPointWithIndex:3 andX:(theSize.width/2.0)  andY:-(theSize.height/2.0) andZ:-1.0];
	
	collideRadius = sqrt(theSize.width * theSize.width + theSize.height * theSize.height)/2.;
}

- (void)setCollideRect:(CGSize)theSize
{
	collisionRect = theSize;
}

- (void)setTextureRegion:(CGRect)theRect
{
	[mesh.texture setCoords:CGRectMake(theRect.origin.x/[mesh.texture getWidth], 
									   1.0 - (theRect.origin.y + theRect.size.height)/[mesh.texture getHeight], 
									   (theRect.origin.x + theRect.size.width)/[mesh.texture getWidth], 
									   1.0 - theRect.origin.y/[mesh.texture getHeight])];
	[self setSize:CGSizeMake(theRect.size.width, theRect.size.height)];
}

- (void)createAnimatedStrip:(CGSize)theSize
{
	animatedFrameSize = theSize;
	[self setTextureRegion:CGRectMake(0, 0, animatedFrameSize.width, animatedFrameSize.height)];
	
	if ([mesh.texture getWidth] > [mesh.texture getHeight])
	{
		numFrames = (GLint)(([mesh.texture getWidth] / theSize.width) - 0.5);
		animationDirection = SFAnimationHorizontal;
	}
	else 
	{
		numFrames = (GLint)(([mesh.texture getHeight] / theSize.height) - 0.5);
		animationDirection = SFAnimationVertical;
	}
	
	animationAdvance = SFAnimationAdvanceTypeWrap;
	animateForward = YES;
	curFrame = 0;
}

- (void)advanceAnimation
{
	if (animationAdvance == SFAnimationAdvanceTypeWrap)
	{
		curFrame++;
		if (curFrame > numFrames)
			curFrame = 0;
	}
	else if (animationAdvance == SFAnimationAdvanceTypeBackAndForth)
	{
		if (animateForward) {
			curFrame++;
			if (curFrame > numFrames)
			{
				curFrame = numFrames - 1;
				animateForward = NO;
			}
		}
		else {
			curFrame--;
			if (curFrame < 0)
			{
				curFrame = 1;
				animateForward = YES;
			}
		}
	}
	
	[self setAnimationFrame:curFrame];
}

- (GLint)getAnimationFrame
{
	return curFrame;
}

- (void)setAnimationFrame:(GLint)frame
{
	if (frame > numFrames)
		curFrame = numFrames;
	else if (frame < 0)
		curFrame = 0;
	else
		curFrame = frame;
	
	if (animationDirection == SFAnimationHorizontal)
		[self setTextureRegion:CGRectMake(animatedFrameSize.width * curFrame, 0, animatedFrameSize.width, animatedFrameSize.height)];
	if (animationDirection == SFAnimationVertical)
		[self setTextureRegion:CGRectMake(0, animatedFrameSize.height * curFrame, animatedFrameSize.width, animatedFrameSize.height)];
}

- (void)setAnimationAdvanceType:(SFAnimationAdvanceType)advanceType
{
	animationAdvance = advanceType;
}

- (BOOL)collideWithObject:(SFObject *)object
{
	BOOL collision = false;
	
	if (collisionType == SFCollisionTypeRectangular && object.collisionType == SFCollisionTypeRectangular)
		collision = [self collideRectWithRect:object];
	else if (collisionType == SFCollisionTypeRadial && object.collisionType == SFCollisionTypeRadial)
		collision = [self collideSphereWithSphere:object];
	else if (collisionType == SFCollisionTypeRectangular && object.collisionType == SFCollisionTypeRadial)
		collision = [self collideRectWithSphere:object];
	
	
	if (collision)
		[self processCollisionWithObject:object];
	
	return collision;
}

- (BOOL)collideSphereWithSphere:(SFObject *)object
{
	float r1 = collideRadius * MAX(xScale, yScale);
	float r2 = object.collideRadius * MAX(object.xScale, object.yScale);
	return ((r1 + r2) * (r1 + r2)) > ((xPos - object.xPos) * (xPos - object.xPos) + (yPos - object.yPos) * (yPos - object.yPos));
}

- (BOOL)collideRectWithSphere:(SFObject *)object;
{
	SFVertex *verts = [mesh getVertices];
	float width = (verts[2].x - verts[0].x) * xScale / 2.;
	float height = (verts[0].y - verts[1].y) * yScale / 2.;
	
	SFVertex vert = [transformMatrix inverseMultiplyVertex:SFVertexMake(object.xPos - xPos, object.yPos - yPos, 0)];
	if ([self class] != [SF2DSprite class])
	{	
		width = collisionRect.width * xScale / 2.;
		height = collisionRect.height * yScale / 2.;
	}
	float radius = object.collideRadius * MAX(object.xScale, object.yScale);
	float circleDistanceX = abs(vert.x);
    float circleDistanceY = abs(vert.y);
	
    if (circleDistanceX > (width + radius)) 
		return false;
    if (circleDistanceY > (height + radius))
		return false;
	
    if (circleDistanceX <= width)
		return true;
    if (circleDistanceY <= height)
		return true;
	
    float cornerDistance_sq = (circleDistanceX - width) * (circleDistanceX - width) +
	(circleDistanceY - height) * (circleDistanceY - height);
	
    return (cornerDistance_sq <= radius * radius);
}

- (BOOL)subcollideRectWithRect:(SFObject *)object
{
	SFVertex *verts = [mesh getVertices];
	SFVertex *verts2 = [[object getMesh] getVertices];
	SFVertex v1, v2, v3, v4, v5, v6, v7, v8, v9;
	GLfloat	vecX, vecY, mag;
	GLfloat max3, max4, max5, max6, max7, max8;
	
	GLfloat vecMag, vecXX, vecYY;
	
	
	SFMatrix *scaleMatrix = [[SFMatrix alloc] init];
	SFMatrix *modelViewWithRot;
	
	[scaleMatrix setScaleWithX:xScale andY:yScale andZ:zScale];
	
	modelViewWithRot = [SFMatrix multiply:transformMatrix with:scaleMatrix];
	
	
	modelViewWithRot.m[12] = xPos;
	modelViewWithRot.m[13] = yPos;
	modelViewWithRot.m[14] = zPos;
	
	
	v1 = [modelViewWithRot multiplyVertex:verts[0]];
	v2 = [modelViewWithRot multiplyVertex:verts[2]];
	
	v7 = [modelViewWithRot multiplyVertex:verts[3]];
	v8 = [modelViewWithRot multiplyVertex:verts[1]];
	v9 = [modelViewWithRot multiplyVertex:verts[2]];
	
	
	[modelViewWithRot identity];
	[scaleMatrix identity];
	
	[scaleMatrix setScaleWithX:object.xScale andY:object.yScale andZ:object.zScale];
	modelViewWithRot = [SFMatrix multiply:[object getTransformMatrix] with:scaleMatrix];
	
	modelViewWithRot.m[12] = object.xPos;
	modelViewWithRot.m[13] = object.yPos;
	modelViewWithRot.m[14] = object.zPos;
	
	v3 = [modelViewWithRot multiplyVertex:verts2[0]];
	v4 = [modelViewWithRot multiplyVertex:verts2[1]];
	v5 = [modelViewWithRot multiplyVertex:verts2[2]];
	v6 = [modelViewWithRot multiplyVertex:verts2[3]];
	
	
	
	
	vecX = (v1.x - v2.x);
	vecY = (v1.y - v2.y);
	
	vecMag = vecX * vecX + vecY * vecY;
	
	vecXX = vecX * vecX;
	vecYY = vecY * vecY;
	
	
	mag = (v7.x * vecX + v7.y * vecY) / (vecMag);
	max7 = mag * vecXX + mag * vecYY;
	
	mag = (v8.x * vecX + v8.y * vecY) / (vecMag);
	max8 = mag * vecXX + mag * vecYY;
	
	mag = (v3.x * vecX + v3.y * vecY) / (vecMag);
	max3 = mag * vecXX + mag * vecYY;
	
	mag = (v4.x * vecX + v4.y * vecY) / (vecMag);
	max4 = mag * vecXX + mag * vecYY;
	
	mag = (v5.x * vecX + v5.y * vecY) / (vecMag);
	max5 = mag * vecXX + mag * vecYY;
	
	mag = (v6.x * vecX + v6.y * vecY) / (vecMag);
	max6 = mag * vecXX + mag * vecYY;
	
	if (MAX(MAX(max3, max4),MAX(max5, max6)) <= MIN(max7, max8))
		return false;
	if (MIN(MIN(max3, max4),MIN(max5, max6)) >= MAX(max7, max8))
		return false;
	
	
	v2.x = v8.x;
	v2.y = v8.y;
	
	
	v8.x = v9.x;
	v8.y = v9.y;
	
	vecX = (v1.x - v2.x);
	vecY = (v1.y - v2.y);
	
	vecMag = vecX * vecX + vecY * vecY;
	vecXX = vecX * vecX;
	vecYY = vecY * vecY;
	
	
	mag = (v7.x * vecX + v7.y * vecY) / (vecMag);
	max7 = mag * vecXX + mag * vecYY;
	
	mag = (v8.x * vecX + v8.y * vecY) / (vecMag);
	max8 = mag * vecXX + mag * vecYY;
	
	mag = (v3.x * vecX + v3.y * vecY) / (vecMag);
	max3 = mag * vecXX + mag * vecYY;
	
	mag = (v4.x * vecX + v4.y * vecY) / (vecMag);
	max4 = mag * vecXX + mag * vecYY;
	
	mag = (v5.x * vecX + v5.y * vecY) / (vecMag);
	max5 = mag * vecXX + mag * vecYY;
	
	mag = (v6.x * vecX + v6.y * vecY) / (vecMag);
	max6 = mag * vecXX + mag * vecYY;
	
	if (MAX(MAX(max3, max4),MAX(max5, max6)) <= MIN(max7, max8))
		return false;
	if (MIN(MIN(max3, max4),MIN(max5, max6)) >= MAX(max7, max8))
		return false;
	
	return true;
}

- (BOOL)collideRectWithRect:(SFObject *)object
{
	BOOL ender;
	
	ender = [self subcollideRectWithRect:object];
	if (ender)
		ender = [(SF2DSprite *)object subcollideRectWithRect:self];
	
	return ender;
}

- (BOOL)pointInRect:(CGPoint)point
{
	SFVertex *verts = [mesh getVertices];
	SFVertex v1, v2, v7, v8, v9;
	GLfloat	vecX, vecY, mag;
	GLfloat max6, max7, max8;
	
	GLfloat vecMag, vecXX, vecYY;
	
	
	SFMatrix *scaleMatrix = [[SFMatrix alloc] init];
	SFMatrix *modelViewWithRot;
	
	[scaleMatrix setScaleWithX:xScale andY:yScale andZ:zScale];
	
	modelViewWithRot = [SFMatrix multiply:transformMatrix with:scaleMatrix];
	
	
	modelViewWithRot.m[12] = xPos;
	modelViewWithRot.m[13] = yPos;
	modelViewWithRot.m[14] = zPos;
	
	
	v1 = [modelViewWithRot multiplyVertex:verts[0]];
	v2 = [modelViewWithRot multiplyVertex:verts[2]];
	
	v7 = [modelViewWithRot multiplyVertex:verts[3]];
	v8 = [modelViewWithRot multiplyVertex:verts[1]];
	v9 = [modelViewWithRot multiplyVertex:verts[2]];
	
	
	
	
	vecX = (v1.x - v2.x);
	vecY = (v1.y - v2.y);
	
	vecXX = vecX * vecX;
	vecYY = vecY * vecY;
	
	vecMag = vecX * vecX + vecY * vecY;
	
	
	mag = (v7.x * vecX + v7.y * vecY) / (vecMag);
	max7 = mag * vecXX + mag * vecYY;
	
	mag = (v8.x * vecX + v8.y * vecY) / (vecMag);
	max8 = mag * vecXX + mag * vecYY;
	
	mag = (point.x * vecX + point.y * vecY) / (vecMag);
	max6 = mag * vecXX + mag * vecYY;
	
	if (max6 <= MIN(max7, max8))
		return false;
	if (max6 >= MAX(max7, max8))
		return false;
	
	
	v2.x = v8.x;
	v2.y = v8.y;
	
	
	v8.x = v9.x;
	v8.y = v9.y;
	
	vecX = (v1.x - v2.x);
	vecY = (v1.y - v2.y);
	
	vecMag = vecX * vecX + vecY * vecY;
	vecXX = vecX * vecX;
	vecYY = vecY * vecY;
	
	
	mag = (v7.x * vecX + v7.y * vecY) / (vecMag);
	max7 = mag * vecXX + mag * vecYY;
	
	mag = (v8.x * vecX + v8.y * vecY) / (vecMag);
	max8 = mag * vecXX + mag * vecYY;
	
	mag = (point.x * vecX + point.y * vecY) / (vecMag);
	max6 = mag * vecXX + mag * vecYY;
	
	if (max6 <= MIN(max7, max8))
		return false;
	if (max6 >= MAX(max7, max8))
		return false;
	
	return true;
}

@end
