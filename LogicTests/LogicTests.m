//
//  LogicTests.m
//  LogicTests
//
//  Created by Stamenkovic Florijan on 2012 07 6.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "LogicTests.h"

#import "TFStone.h"
#import "TFGrid.h"
#import "TFStoneOnGrid.h"
#import "TFGravity.h"
#import "TFStoneGenerator.h"

@implementation LogicTests

- (void)setUp
{
    [super setUp];
    
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
	NSString *testingStonesPath = [mainBundle pathForResource:@"TestingStones" ofType:@"tfstones"];
	testingStones = [[NSKeyedUnarchiver unarchiveObjectWithFile:testingStonesPath] retain];
}

- (void)tearDown
{
    [testingStones release];
	testingStones = nil;
    
    [super tearDown];
}

-(void)testSquareIntersectionLogic
{
	TFSquare s1;
	TFSquare s2;
	
	s1.x = 10;
	s1.y = 100;
	s1.w = 30;
	s1.h = 20;
	
	s2.x = 5;
	s2.y = 95;
	s2.w = 10;
	s2.h = 10;
	
	STAssertTrue(TFSquaresIntersect(s1, s2), @"Square intersect 1");
	
	s2.x = 40;
	STAssertFalse(TFSquaresIntersect(s1, s2), @"Square intersect 2");
}

- (void)testGridStones
{
	//	check succesful loading of stones
	STAssertNotNil(testingStones, @"GridStonesTest1");
	if([testingStones count] == 0)
		STFail(@"GridStonesTest2");
	
	//	the first stone
	TFStone *aStone = [testingStones objectAtIndex:0];
	
	//	can an empty grid add a stone?
	TFGrid *testGrid = [[[TFGrid alloc] initWithWidth:10 height:10] autorelease];
	STAssertTrue([testGrid canPlaceStone:aStone atX:3 andY:5], @"GridStonesTest3");
	
	//	add the stone
	[testGrid addStone:aStone fixed:NO atX:3 andY:5];
	
	//	can the grid add a stone on an occupied location?
	STAssertFalse([testGrid canPlaceStone:aStone atX:3 andY:5],  @"GridStonesTest4");
	
	//	is the same grid returning the stone we placed on it?
	STAssertEqualObjects([testGrid stoneCoveringX:3 andY:5].stone, aStone, @"GridStonesTest5");
	
	//	now do some stone detection checking
	//	this is the 1x3 stone anchored leftmost
	aStone = [testingStones objectAtIndex:3];
	[testGrid addStone:aStone fixed:NO atX:0 andY:2];
	//	now a stone that is 3x1 stone anchored bottommost
	aStone = [testingStones objectAtIndex:4];
	STAssertFalse([testGrid canPlaceStone:aStone atX:2 andY:0], @"GridStonesTest6");
	STAssertTrue([testGrid canPlaceStone:aStone atX:3 andY:0], @"GridStonesTest7");
	[testGrid addStone:aStone fixed:NO atX:3 andY:0];
	
	//	and add one more fixed stone
	aStone = [testingStones objectAtIndex:4];
	[testGrid addStone:aStone fixed:YES atX:7 andY:2];
	
	//	now test move-capability testing
	TFStoneOnGrid* gridStone = [testGrid stoneCoveringX:1 andY:2];
	STAssertEqualObjects(gridStone.stone, [testingStones objectAtIndex:3], @"GridStonesTest8");
	STAssertFalse([testGrid canMoveStone:gridStone toPosX:0 andPosY:2 withOffX:20 andOffY:0], @"GridStonesTest9");
	STAssertTrue([testGrid canMoveStone:gridStone toPosX:4 andPosY:2 withOffX:0 andOffY:0], @"GridStonesTest10");
	STAssertFalse([testGrid canMoveStone:gridStone toPosX:4 andPosY:2 withOffX:20 andOffY:0], @"GridStonesTest11");
	STAssertTrue([testGrid canMoveStone:gridStone toPosX:4 andPosY:7 withOffX:20 andOffY:20], @"GridStonesTest12");
	
	[testGrid moveStone:gridStone toPosX:4 andPosY:7 withOffX:20 andOffY:20];
	gridStone = [testGrid stoneCoveringX:3 andY:5];
	STAssertEqualObjects(gridStone.stone, [testingStones objectAtIndex:0], @"GridStonesTest13");
	STAssertTrue([testGrid canMoveStone:gridStone toPosX:3 andPosY:7 withOffX:20 andOffY:0], @"GridStonesTest14");
	STAssertFalse([testGrid canMoveStone:gridStone toPosX:3 andPosY:6 withOffX:30 andOffY:30], @"GridStonesTest15");
	STAssertFalse([testGrid canMoveStone:gridStone toPosX:7 andPosY:8 withOffX:0 andOffY:0], @"GridStonesTest16");
	STAssertTrue([testGrid canMoveStone:gridStone toPosX:8 andPosY:7 withOffX:-20 andOffY:0], @"GridStonesTest17");
	
	STAssertTrue([testGrid canMoveStone:gridStone toPosX:1 andPosY:2 withOffX:20 andOffY:0], @"GridStonesTest18");
	STAssertFalse([testGrid canMoveStone:gridStone toPosX:2 andPosY:2 withOffX:20 andOffY:0], @"GridStonesTest19");
	
	//	ensure there are no offset stones on the grid
	gridStone = [testGrid stoneCoveringX:4 andY:7];
	STAssertEqualObjects(gridStone.stone, [testingStones objectAtIndex:3],  @"GridStonesTest20");
	[testGrid moveStone:gridStone toPosX:4 andPosY:7 withOffX:0 andOffY:0];
	
	//	 now gravity testing
	TFGravity *grav = [[TFGravity new] autorelease];
	for(int i = 1 ; i <= 2 * TF_PACKER_GRAV_ANIMATION_STEPS ; i++)
		[grav performStepOnGrid:testGrid];
	STAssertEqualObjects([testGrid stoneCoveringX:3 andY:3].stone, [testingStones objectAtIndex:0], @"GridStonesTest21");
	STAssertTrue([testGrid canPlaceStone:[testingStones objectAtIndex:0] atX:3 andY:4],  @"GridStonesTest22");
	[testGrid addStone:[testingStones objectAtIndex:0] fixed:NO atX:3 andY:4];
	gridStone = [testGrid stoneCoveringX:3 andY:4];
	STAssertTrue([testGrid canMoveStone:gridStone toPosX:3 andPosY:4 withOffX:30 andOffY:0],  @"GridStonesTest23");
	[testGrid moveStone:gridStone toPosX:3 andPosY:4 withOffX:30 andOffY:0];
	for(int i = 1 ; i <=  TF_PACKER_GRAV_ANIMATION_STEPS ; i++)
		[grav performStepOnGrid:testGrid];
	STAssertEqualObjects([testGrid stoneCoveringX:4 andY:5].stone, [testingStones objectAtIndex:3], @"GridStonesTest24");
	
	//	random stone generation testing
	NSInteger beforeRandomGenCount = testGrid.stones.count;
	TFStoneGenerator* generator = [[TFStoneGenerator new] autorelease];
	[generator setProbability:[NSNumber numberWithInt:20] forStone:[testingStones objectAtIndex:0]];
	[generator setProbability:[NSNumber numberWithInt:15] forStone:[testingStones objectAtIndex:2]];
	[generator setProbability:[NSNumber numberWithInt:10] forStone:[testingStones objectAtIndex:4]];
	for(int i = 0 ; i < 10 ; i++)
		[generator attemptGenerationOnGrid:testGrid withGravityDirection:grav.direction];
	STAssertTrue(testGrid.stones.count == beforeRandomGenCount + 10, @"GridStonesTest25");
	
}

@end
