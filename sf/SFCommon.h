//
//  SFCommon.h
//  GLES
//
//  Created by Justin Van Eaton on 9/27/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#else 
#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#endif

typedef struct {
    GLfloat x;
    GLfloat y;
    GLfloat z;
} SFVertex;

static inline SFVertex SFVertexMake(GLfloat x, GLfloat y, GLfloat z)
{
    SFVertex vert;
    vert.x = x;
    vert.y = y;
    vert.z = z;
    return vert;
}

static inline void SFVertexSet(SFVertex *vertex, GLfloat inX, GLfloat inY, GLfloat inZ)
{
    vertex->x = inX;
    vertex->y = inY;
    vertex->z = inZ;
}

typedef struct {
    SFVertex v1;
    SFVertex v2;
    SFVertex v3;
} SFTriangle;

static inline SFTriangle SFTriangleMake(SFVertex vert1, SFVertex vert2, SFVertex vert3)
{
	SFTriangle triangle;
	triangle.v1 = vert1;
	triangle.v2 = vert2;
	triangle.v3 = vert3;
	return triangle;
}

typedef enum {
	SFOpenGLES1,
	SFOpenGLES2,
	SFOpenGLMacOS
} SFOpenGLVersion;

typedef enum {
	SFAnimationHorizontal,
	SFAnimationVertical 
} SFAnimationDirection;

typedef enum {
	SFAnimationAdvanceTypeWrap,
	SFAnimationAdvanceTypeBackAndForth 
} SFAnimationAdvanceType;

typedef enum {
	SFCollisionTypeRadial,
	SFCollisionTypeRectangular 
} SFCollisionType;


#define EPSILON 0.0001
#define FLOAT_EQ(x,v) (((v - EPSILON) < x) && (x <( v + EPSILON)))

#define DEGTORAD(val) ( val * 0.0174532925f )

#define LIMIT_RANGE(v,l,h) ({				\
__typeof__( ( v ) ) __v;					\
__typeof__( ( l ) ) __l;					\
__typeof__( ( h ) ) __h;					\
__v = ( v );								\
__l = ( l );								\
__h = ( h );								\
__v < __l ? __l : __v > __h ? __h : __v; })

