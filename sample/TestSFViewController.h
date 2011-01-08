//
//  TestSFViewController.h
//  TestSF


#import <UIKit/UIKit.h>
#import "SFScene.h"
#import "SF2DContext.h"
#import "SFAlphaSprite.h"

@interface TestSFViewController : UIViewController {

	
	SFScene	*theScene;
	SFContext *theContext;
	
	
	GLfloat offset;

	SFLayer *layer;
	SFLayer *layer2;
	
}

@end

