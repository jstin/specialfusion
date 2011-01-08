//
//  SFAlphaSprite.h
//  TestSF
//
//  Created by Justin Van Eaton on 10/21/10.
//  Copyright 2010 Stinware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFCommon.h"
#import "SF2DSprite.h"
#import "SFMesh.h"

@interface SFAlphaSprite : SF2DSprite {
	NSString *curText;
}

- (id)initWithFilename:(NSString *)inFilename andCharacterSize:(CGSize)size;
- (void)setText:(NSString *)str;
- (NSString *)getText;

@end
