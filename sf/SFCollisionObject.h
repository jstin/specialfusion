//
//  SFCollisionObject.h
//  TestSF
//
//  Created by Justin Van Eaton on 10/18/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFCommon.h"
#import "SFObject.h"

@class SFObject;

@interface SFCollisionObject : NSObject {
	SFObject *selfObject;
	SFObject *foundObject;
}

@property (nonatomic, retain) SFObject *selfObject;
@property (nonatomic, retain) SFObject *foundObject;


@end
