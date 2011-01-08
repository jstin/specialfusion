//
//  SFMatrix.m
//  GLES
//
//  Created by Justin Van Eaton on 9/28/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import "SFMatrix.h"


@implementation SFMatrix

@synthesize m;

- (id)init
{
	if (self = [super init])
	{
		m = malloc(sizeof(GLfloat) * 16);
		[self identity];
	}
	return self;
}

- (void)identity
{
	m[0] = 1;  m[4] = 0;   m[8] = 0;  m[12] = 0;	// Set matrix to identity matrix
	m[1] = 0;  m[5] = 1;   m[9] = 0;  m[13] = 0;
	m[2] = 0;  m[6] = 0;  m[10] = 1;  m[14] = 0;
	m[3] = 0;  m[7] = 0;  m[11] = 0;  m[15] = 1;
}

- (void)dealloc
{
	free(m);
	[super dealloc];
}

- (void)setOrthoLeft:(GLfloat)left right:(GLfloat)right bottom:(GLfloat)bottom top:(GLfloat)top  near:(GLfloat)near  far:(GLfloat)far
{	
	m[0] = 2.0f/(right-left);
	m[1] = 0;
	m[2] = 0;
	m[3] = 0;
	
	m[4] = 0;
	m[5] = 2.0f/(top-bottom);
	m[6] = 0;
	m[7] = 0;
	
	m[8] = 0;
	m[9] = 0;
	m[10] = -2.0/(far-near);
	m[11] = 0;
	
	m[12] = (1.0f/(right-left))*(left-right);
	m[13] = (1.0f/(top-bottom))*(bottom-top);
	m[14] = 0;
	m[15] = 1;
}

- (void)setScaleWithX:(GLfloat)xScale andY:(GLfloat)yScale andZ:(GLfloat)zScale
{
	m[1] = m[2] = m[3] = m[4] = 0.0;
    m[6] = m[7] = m[8] = m[9] = 0.0;
    m[11] = m[12] = m[13] = m[14] = 0.0;
    m[0] = xScale;
    m[5] = yScale;
    m[10] = zScale;
    m[15] = 1.0;
}

- (void)setTranslateWithX:(GLfloat)xTranslate andY:(GLfloat)yTranslate andZ:(GLfloat)zTranslate
{
	m[0] = m[5] =  m[10] = m[15] = 1.0;
    m[1] = m[2] = m[3] = m[4] = 0.0;
    m[6] = m[7] = m[8] = m[9] = 0.0;    
    m[11] = 0.0;
    m[12] = xTranslate;
    m[13] = yTranslate;
    m[14] = zTranslate;
}

- (SFVertex)multiplyVertex:(SFVertex)vertex
{
	SFVertex newVert = SFVertexMake(0, 0, 0);
	newVert.x = vertex.x * m[0] + vertex.y * (-m[1]) + vertex.z * m[2] + m[12];
	newVert.y = vertex.x * (-m[4]) + vertex.y * m[5] + vertex.z * m[6] + m[13];
	newVert.z = vertex.x * m[8] + vertex.y * m[9] + vertex.z * m[10] + m[14];
	return newVert;
}

- (SFVertex)inverseMultiplyVertex:(SFVertex)vertex
{
	SFVertex newVert = SFVertexMake(0, 0, 0);
	newVert.x = vertex.x * m[0] + vertex.y * (m[1]) + vertex.z * m[2] + m[12];
	newVert.y = vertex.x * (m[4]) + vertex.y * m[5] + vertex.z * m[6] + m[13];
	newVert.z = vertex.x * m[8] + vertex.y * m[9] + vertex.z * m[10] + m[14];
	return newVert;
}

+ (SFMatrix *)multiply:(SFMatrix *)a with:(SFMatrix *)b
{
	SFMatrix *m = [[SFMatrix alloc] init];
	
	m.m[0] = a.m[0]*b.m[0] + a.m[1]*b.m[4] + a.m[2]*b.m[8] + a.m[3]*b.m[12];
	m.m[1] = a.m[0]*b.m[1] + a.m[1]*b.m[5] + a.m[2]*b.m[9] + a.m[3]*b.m[13];
	m.m[2] = a.m[0]*b.m[2] + a.m[1]*b.m[6] + a.m[2]*b.m[10] + a.m[3]*b.m[14];
	m.m[3] = a.m[0]*b.m[3] + a.m[1]*b.m[7] + a.m[2]*b.m[11] + a.m[3]*b.m[15];
	
	m.m[4] = a.m[4]*b.m[0] + a.m[5]*b.m[4] + a.m[6]*b.m[8] + a.m[7]*b.m[12];
	m.m[5] = a.m[4]*b.m[1] + a.m[5]*b.m[5] + a.m[6]*b.m[9] + a.m[7]*b.m[13];
	m.m[6] = a.m[4]*b.m[2] + a.m[5]*b.m[6] + a.m[6]*b.m[10] + a.m[7]*b.m[14];
	m.m[7] = a.m[4]*b.m[3] + a.m[5]*b.m[7] + a.m[6]*b.m[11] + a.m[7]*b.m[15];
	
	m.m[8] = a.m[8]*b.m[0] + a.m[9]*b.m[4] + a.m[10]*b.m[8] + a.m[11]*b.m[12];
	m.m[9] = a.m[8]*b.m[1] + a.m[9]*b.m[5] + a.m[10]*b.m[9] + a.m[11]*b.m[13];
	m.m[10] = a.m[8]*b.m[2] + a.m[9]*b.m[6] + a.m[10]*b.m[10] + a.m[11]*b.m[14];
	m.m[11] = a.m[8]*b.m[3] + a.m[9]*b.m[7] + a.m[10]*b.m[11] + a.m[11]*b.m[15];
	
	m.m[12] = a.m[12]*b.m[0] + a.m[13]*b.m[4] + a.m[14]*b.m[8] + a.m[15]*b.m[12];
	m.m[13] = a.m[12]*b.m[1] + a.m[13]*b.m[5] + a.m[14]*b.m[9] + a.m[15]*b.m[13];
	m.m[14] = a.m[12]*b.m[2] + a.m[13]*b.m[6] + a.m[14]*b.m[10] + a.m[15]*b.m[14];
	m.m[15] = a.m[12]*b.m[3] + a.m[13]*b.m[7] + a.m[14]*b.m[11] + a.m[15]*b.m[15];
	
	return m;
}

+ (SFMatrix *)add:(SFMatrix *)a with:(SFMatrix *)b
{
	SFMatrix *m = [[SFMatrix alloc] init];
	
	m.m[0] = a.m[0]+b.m[0];
	m.m[1] = a.m[1]+b.m[1];
	m.m[2] = a.m[2]+b.m[2];
	m.m[3] = a.m[3]+b.m[3];
	
	m.m[4] = a.m[4]+b.m[4];
	m.m[5] = a.m[5]+b.m[5];
	m.m[6] = a.m[6]+b.m[6];
	m.m[7] = a.m[7]+b.m[7];

	m.m[8] = a.m[8]+b.m[8];
	m.m[9] = a.m[9]+b.m[9];
	m.m[10] = a.m[10]+b.m[10];
	m.m[11] = a.m[11]+b.m[11];
	
	m.m[12] = a.m[12]+b.m[12];
	m.m[13] = a.m[13]+b.m[13];
	m.m[14] = a.m[14]+b.m[14];
	m.m[15] = a.m[15]+b.m[15];
	
	return m;
}

/*
 printf("%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n\n\n", modelViewWithRot.m[0],
 modelViewWithRot.m[4],
 modelViewWithRot.m[8],
 modelViewWithRot.m[12],
 modelViewWithRot.m[1],
 modelViewWithRot.m[5],
 modelViewWithRot.m[9],
 modelViewWithRot.m[13],
 modelViewWithRot.m[2],
 modelViewWithRot.m[6],
 modelViewWithRot.m[10],
 modelViewWithRot.m[14],
 modelViewWithRot.m[3],
 modelViewWithRot.m[7],
 modelViewWithRot.m[11],
 modelViewWithRot.m[15]);
 
 */

@end
