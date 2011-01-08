//
//  SFQauternion.m
//  GLES
//
//  Created by Justin Van Eaton on 9/28/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import "SFQuaternion.h"


@implementation SFQuaternion


- (void)indentity
{
	x = 0.0f;
	y = 0.0f;
	z = 0.0f;
	w = 1.0f;
}

- (GLfloat)norm
{
	return sqrt(x*x + y*y + z*z + w*w);
}

- (void)normalize
{
	GLfloat norm = [self norm];
	
	//assert(!FLOAT_EQ(0.0f, (float)norm));		// norm should never be close to 0
	
	x = (x / norm);
	y = (y / norm);
	z = (z / norm);
	w = (w / norm);
	
	//assert(FLOAT_EQ(1.0f, (float)Norm()));		// must be normalized, safe
	
	w = LIMIT_RANGE(-1.0f, w, 1.0f);
	x = LIMIT_RANGE(-1.0f, x, 1.0f);
	y = LIMIT_RANGE(-1.0f, y, 1.0f);
	z = LIMIT_RANGE(-1.0f, z, 1.0f);
}

- (void)eulerToQuaternionWithX:(GLfloat)inX andY:(GLfloat)inY andZ:(GLfloat)inZ
{
	GLfloat	ex, ey, ez;					// temp half euler angles
	GLfloat	cr, cp, cy, sr, sp, sy, cpcy, spsy;		// temp vars in roll,pitch yaw
	
	ex = (DEGTORAD(inX) / 2.0);					// convert to rads and half them
	ey = (DEGTORAD(inY) / 2.0);
	ez = (DEGTORAD(inZ) / 2.0);
	
	cr = cos(ex);
	cp = cos(ey);
	cy = cos(ez);
	
	sr = sin(ex);
	sp = sin(ey);
	sy = sin(ez);
	
	cpcy = cp * cy;
	spsy = sp * sy;
	
	w = (cr * cpcy + sr * spsy);
	
	x = (sr * cpcy - cr * spsy);
	y = (cr * sp * cy + sr * cp * sy);
	z = (cr * cp * sy - sr * sp * cy);
	
	[self normalize];
}

- (void)getMatrix:(SFMatrix *)matrix
{
	GLfloat x2, y2, z2, w2, xy, xz, yz, wx, wy, wz;
	//GLfloat *m;
	
	//m = calloc(16, sizeof(GLfloat));
	for (int i = 0; i < 16; i ++)						// clear matrix
		matrix.m[i] = 0;
	matrix.m[15] = 1.0;
	
	x2 = (x * x);	
	y2 = (y * y); 
	z2 = (z * z);	
	w2 = (w * w);
	
	xy = x * y;
	xz = x * z;
	yz = y * z;
	wx = w * x;
	wy = w * y;
	wz = w * z;
	
	
	matrix.m[0] = (1 - 2*(y2 + z2));
	matrix.m[1] = (2 * (xy + wz));
	matrix.m[2] = (2 * (xz - wy));
	
	matrix.m[4] = (2 * (xy - wz));
	matrix.m[5] = (1 - 2*(x2 + z2));
	matrix.m[6] = (2 * (yz + wx));
	
	matrix.m[8] = (2 * (xz + wy));
	matrix.m[9] = (2 * (yz - wx));
	matrix.m[10] = (1 - 2*(x2 + y2));
}

@end
