### Introducing Special Fusion (aka The Scenic Framework)

For complete documentation see [click here](http://special-fusion.com/documentation).

1. **OpenGL ES version agnostic**
	1. The same code can be used with an OpenGL ES 2.x or 1.x context. This means that you can target both versions
without the need to change your code. The same code will also run in MacOS X.
2. **Collision Detection**
2. **Animated Sprites**
3. **Simple Objective-C Style Development**

To show you just how simple this is to use, I will show you the source to create a ball that bounces on a crate. Simply make a blank view based iPhone application in Xcode, and add the following to your `viewDidLoad` method.

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

Now all we need to do is create our callbacks. We have one called `render` which renders the scene. This is super simple. 
Check it out.

	- (void) render
	{		
		[theContext drawScene:theScene];
		[layer2 collideWithLayer:layer];
	}
	
All we need to worry about here is maintaing our pointer to the `SF2DContext` and `SFScene` objects that were created in `viewDidLoad`.
We also need a callback for our collision and movement processes. If you look back at the code above you will see the following two lines

	[ball setCollisionCallback:@selector(collidMe:) withDelegate:self];
	[ball setMovementCallback:@selector(moveMe:) withDelegate:self];
	
The movement callback gets invoked every time the scene is rendered to the screen. This is how you manage movement of objects. The
collision callback gets called when an object has a collision. Let's look at the movement callback.

	- (void)moveMe:(SF2DSprite *)sp
	{
		offset -= 0.02;
		[sp offsetWithX:0.0 andY:offset andZ:0.0];
	}

All this does is accelerate the ball downward. We maintain a float value called `offset` which will store the current velocity. Now, since the ball
is located above the crate in our scene, as it comes down, it will eventually run into the crate. Since we have enabled collision between the 
two layers (`[layer addCollideLayer:layer2];`), we will be notified of this collision and can take action. Behold the collision callback.

	- (void)collidMe:(SFCollisionObject *)collision
	{	
		offset *= -1;
	}
	
All this does is reverse the direction of the acceleration. In this case, from downward to upward. Eventually the ball will fall back down, only to hit the crate
again.

You'll notice that the both the movement callback take a single parameter in this case an `SF2DSprite` . This is a subclass of the more general
`SFObject` model, which can be used for 3D applications or anything really. If you are more advanced you can subclass this model and create your own super cool
effects or what not.

For example, when we created or context we called

	initWithVersion:SFOpenGLES1
	
We can also call

	initWithVersion:SFOpenGLES2
	
Which, by default will do the exact same thing as before. We don't have to change a line of code to make this work. However, we could subclass `SF2DSprite`
and create a custom shader with sweet effects. This is really easy to do and makes this framework super powerful.

######Concepts


SpecialFusion is made of a Context, Scenes, Layers, and Objects. In general, you will have one context object (`SFContext`, `SF2DContext`), one or more scenes (`SFScene`), multiple layers (`SFLayer`), and multiple objects (`SFObject`, `SF2DSprite`, `SFAlphaSprite`).

###Contexts

A context is basically just a view that you draw to. You can create a context for OpenGL on Mac OS X, iPhone, or iPad, with the same line of code, SpecialFusion takes care of all the nitty gritty details. Look how simple this is. For Mac OS X.

	SF2DContext *context = [[SF2DContext alloc] initWithVersion:SFOpenGLMacOS andFrame:CGRectMake(0, 0, 100, 100)];	
	[window.contentView addSubview:context];

For iOS it is the same thing:
	
	SF2DContext *context = [[SF2DContext alloc] initWithVersion:SFOpenGLES1 andFrame:CGRectMake(0, 0, 100, 100)];
	self.view = context;
	
###Scenes

A scene is just a list of layers, with some additional options. You can think of a scene as a level. Although you can make a game with many levels and one scene. A scene simply manages all the layering and objects in your app. To make and draw a scene simply do:

	SFScene *scene = [[SFScene alloc] init];
	[context drawScene:scene];
	
That will draw one frame of the scene. In general you call the `drawScene` object many times per second. In this case, nothing will draw but the background, since we have no layers or objects.

###Layers

Layers have a few purposes. The obvious one is to separate objects. For 2D contexts, the layer order will determine the draw order of objects. You can also put certain objects in a scroll layer.

A less obvious, but powerful reason for layers is to separate collision work. Collision detection is handled in SpecialFusion on the layer level. If you have a lot of sprites that don't require collision, put them in a separate layer, so that they won't use up valuable processor time. If you have one 'hero' and a few bad guys, put the bad guys in one layer, and the 'hero' in another. That way the baddies are not tested against each other, only the hero.

	SFLayer *layer = [[SFLayer alloc] init];
	[scene addLayerToScene:layer];
	
	SFLayer *layer2 = [[SFLayer alloc] init];
	[scene addLayerToScene:layer2];
	
Now we can test for collision between the layers:
	
	[layer collideWithLayer:layer2];
	
You can also text a layer against itself:

	[layer collideWithLayer:layer];
	
Any objects that collide will have their collide callback called.

###Objects

The initial release of SpecialFusion deals with 2D sprites. It is easy to create one:

	SF2DSprite *sprite = [[SF2DSprite alloc] initWithFilename:@"sweetGraphic.png"];
	[layer addObjectToLayer:sprite];
	
Two interesting callbacks occur on an object -- collision and movement.

	[sprite setCollisionCallback:@selector(collidMe:) withDelegate:self];
	[sprite setMovementCallback:@selector(moveMe:) withDelegate:self];
	
The movement callback is called every time you call `context drawScene:`. The collision is called in case of a collision. The methods you implement for the callback look like this:

	- (void)moveMe:(SF2DSprite *)sprite
	- (void)collidMe:(SFCollisionObject *)collideObject
	
The `SFCollisionObject` is a simple structure that contains the collision point(s) and both objects.

###That's all there is to it

The rest is just manipulating your objects. There are plenty of methods to do that. Included are matrix routines, quaternion routines, ways to offset, move, rotate, scale, and plenty of other sweet features.