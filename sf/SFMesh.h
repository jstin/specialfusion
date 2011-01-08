//
//  SFMesh.h
//  GLES
//
//  Created by Justin Van Eaton on 9/27/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFCommon.h"
#import "SFTexture.h"

@class SFTexture;

@interface SFMesh : NSObject {
	SFTexture		*texture;
	SFTriangle		*triangles;
	SFVertex		*vertices;
	
	int				triangleCount;
	int				vertexCount;
	BOOL			useTriangleStrips;
}

@property (nonatomic, retain) SFTexture *texture;


- (id)initWithTriangleCount:(int)count;
- (id)initWithVertexCount:(int)count;

- (void)loadTexture:(NSString *)filename;

- (void)drawWithVersion:(SFOpenGLVersion)version;
- (void)drawWithShaderVertex:(GLint)vertexShader andFrag:(GLint)fragementShader;

- (void)setVertexPointWithIndex:(int)index andX:(GLfloat)x andY:(GLfloat)y andZ:(GLfloat)z;

- (SFVertex *)getVertices;

@end
