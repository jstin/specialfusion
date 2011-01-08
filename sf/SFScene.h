//
//  SFScene.h
//  GLES
//
//  Created by Justin Van Eaton on 9/27/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFCommon.h"
#import "SFLayer.h"

@class SFLayer;

@interface SFScene : NSObject {
	NSMutableArray		*layers;
	GLfloat				backgroundRed;
	GLfloat				backgroundGreen;
	GLfloat				backgroundBlue;
	
}

- (id)init;

- (void)drawWithVersion:(SFOpenGLVersion)version;
- (void)addLayer:(SFLayer *)inObject;
- (void)removeLayer:(SFLayer *)inObject;

- (void)setBackgroundColorWithRed:(GLfloat)red andGreen:(GLfloat)green andBlue:(GLfloat)blue;

@end
