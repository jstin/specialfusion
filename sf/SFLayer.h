//
//  SFLayer.h
//  GLES
//
//  Created by Justin Van Eaton on 10/3/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFCommon.h"
#import "SFObject.h"

@class SFObject;

@interface SFLayer : NSObject {
	NSMutableArray		*objects;
	
	SFLayer				*collideLayer;
}

- (id)init;

- (void)drawWithVersion:(SFOpenGLVersion)version;
- (void)moveObjects;

- (void)addObject:(SFObject *)inObject;
- (void)removeObject:(SFObject *)inObject;
- (void)addCollideLayer:(SFLayer *)layer;
- (void)collideObjects;
- (void)collideWithLayer:(SFLayer *)layer;

- (NSArray *)getObjects;


@end
