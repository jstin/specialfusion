//
//  TestSFViewController.m
//  TestSF

#import "TestSFViewController.h"
#import "SFCommon.h"
#import "SF2DSprite.h"

@implementation TestSFViewController



- (void) render
{	
	[theContext drawScene:theScene];
	[layer2 collideWithLayer:layer];
}


- (void)moveMe:(SF2DSprite *)sp
{	
	offset -= 0.02;
	[sp offsetWithX:0.0 andY:offset andZ:0.0];
}

- (void)collidMe:(SFCollisionObject *)sp
{	
	offset *= -1;
	[sp.selfObject offsetWithX:0.0 andY:offset andZ:0.0];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Create the Context or View we will be drawing to
	theContext = [[SF2DContext alloc] initWithVersion:SFOpenGLES1 andFrame:CGRectMake(0, 0, 320, 480)];
	self.view = theContext;
	
	// A Scene manages everything from drawing to layers to collisions
	theScene = [[SFScene alloc] init];
	
	
	// We can have as many layers as we want, in a 2D context, layers will be drawn in order
	layer = [[SFLayer alloc] init];
	[theScene addLayer:layer];
	
	layer2 = [[SFLayer alloc] init];
	[theScene addLayer:layer2];
	
	[layer addCollideLayer:layer2];
	
	
	// Create the drawn objects
	SF2DSprite *ball = [[SF2DSprite alloc] initWithFilename:@"ball.png"];
	[layer addObject:ball];
	[ball setLocationWithX:150 andY:380 andZ:0.0];
	[ball setCollisionCallback:@selector(collidMe:) withDelegate:self];
	[ball setMovementCallback:@selector(moveMe:) withDelegate:self];
	
	SF2DSprite *awesomeCrate = [[SF2DSprite alloc] initWithFilename:@"crate.jpg"];
	[layer2 addObject:awesomeCrate];
	[awesomeCrate setLocationWithX:150 andY:130 andZ:0.0];      
	[awesomeCrate setScaleWithX:0.5 andY: 0.5 andZ:1.0];
	
	// A timer that calls our render method
	[NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(render) userInfo:nil repeats:YES];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
