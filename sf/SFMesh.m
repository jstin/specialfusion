//
//  SFMesh.m
//  GLES
//
//  Created by Justin Van Eaton on 9/27/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import "SFMesh.h"


@implementation SFMesh

@synthesize texture;

- (id)initWithTriangleCount:(int)count
{
	if (self = [super init])
	{
		triangles = malloc(sizeof(SFTriangle) * count);
		useTriangleStrips = NO;
		
		triangleCount = count;
		vertexCount = 0;
	}
	return self;
}

- (id)initWithVertexCount:(int)count
{
	if ((self = [super init]))
	{
		vertices = malloc(sizeof(SFVertex) * count);
		useTriangleStrips = YES;
		
		vertexCount = count;
		triangleCount = 0;
	}
	return self;
}

- (void)loadTexture:(NSString *)filename
{
	texture = [[SFTexture alloc] initWithFilename:filename];
}

- (void)setVertexPointWithIndex:(int)index andX:(GLfloat)x andY:(GLfloat)y andZ:(GLfloat)z
{
	if (index >= vertexCount) //assert
		return;
	
	vertices[index].x = x;
	vertices[index].y = y;
	vertices[index].z = z;
}

- (void)drawWithVersion:(SFOpenGLVersion)version
{	
	[texture drawWithVersion:version];
	
	if (version == SFOpenGLES1)
	{
		if (!useTriangleStrips) {
			glVertexPointer(3, GL_FLOAT, 0, triangles);
			glDrawArrays(GL_TRIANGLES, 0, triangleCount*3);
		}
		else {
			glVertexPointer(3, GL_FLOAT, 0, vertices);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexCount);
		}
	}
}

- (void)drawWithShaderVertex:(GLint)vertexShader andFrag:(GLint)fragementShader
{	
	glVertexAttribPointer(vertexShader, 3, GL_FLOAT, GL_FALSE, 0, vertices);
	glVertexAttribPointer(fragementShader, 2, GL_FLOAT, GL_FALSE, 0, [texture getCoords]);
	
	glEnableVertexAttribArray(vertexShader);
	glEnableVertexAttribArray(fragementShader);
	
	[texture bind];
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexCount);
}

- (SFVertex *)getVertices
{
	return vertices;
}

- (void)dealloc
{
	free(vertices);
	free(triangles);
	[super dealloc];
}

@end
