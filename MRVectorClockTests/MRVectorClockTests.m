//
//  MRVectorClockTests.m
//  MRVectorClockTests
//
//  Created by Matteo Rattotti on 23/04/15.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "MRVectorClock.h"

@interface MRVectorClockTests : XCTestCase

@end

NSString * const Identifier_A = @"A";
NSString * const Identifier_B = @"B";
NSString * const Identifier_C = @"C";

@implementation MRVectorClockTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Object creation and defaults

- (void)testNewClock
{
    MRVectorClock *vectorClock = [MRVectorClock new];
    
    XCTAssertNotNil(vectorClock);
}

- (void) testClockInitialValueOfZero
{
    MRVectorClock *vectorClock = [MRVectorClock new];
    
    XCTAssertEqual([vectorClock clockValueForID:Identifier_A], 0);
}

- (void) testNewClockFromData
{
    MRVectorClock *vectorClock = [MRVectorClock new];
    [vectorClock updateClockValueForID:Identifier_A];

    NSData *vectorClockData = [vectorClock data];
    XCTAssertNotNil(vectorClockData);

    MRVectorClock *vectorClockFromData = [[MRVectorClock alloc] initWithData:vectorClockData];
    XCTAssertNotNil(vectorClockFromData);
    
    XCTAssertEqual([vectorClock compare:vectorClockFromData], MRVectorClockOrderedSame);
}

#pragma mark - Update

- (void)testClockUpdate
{
    // {A:2}
    MRVectorClock *vectorClock = [MRVectorClock new];
    [vectorClock updateClockValueForID:Identifier_A];
    [vectorClock updateClockValueForID:Identifier_A];
    
    XCTAssertEqual([vectorClock clockValueForID:Identifier_A], 2);
}

- (void)testClockMultipleUpdate
{
    // {A:1, B:2}
    MRVectorClock *vectorClock = [MRVectorClock new];
    [vectorClock updateClockValueForID:Identifier_A];
    [vectorClock updateClockValueForID:Identifier_B];
    [vectorClock updateClockValueForID:Identifier_B];
    
    XCTAssertEqual([vectorClock clockValueForID:Identifier_A], 1);
    XCTAssertEqual([vectorClock clockValueForID:Identifier_B], 2);
}

- (void)testClockUpdateSpecificValue
{
    // {A:69}
    MRVectorClock *vectorClock = [MRVectorClock new];
    [vectorClock updateClockValueForID:Identifier_A value:69];

    XCTAssertEqual([vectorClock clockValueForID:Identifier_A], 69);
}


#pragma mark - Merge

- (void) testClockMerge
{
    // {A:2, B:1}
    MRVectorClock *vectorClock = [MRVectorClock new];

    [vectorClock updateClockValueForID:Identifier_A];
    [vectorClock updateClockValueForID:Identifier_A];
    
    [vectorClock updateClockValueForID:Identifier_B];
    

    // {A:1, B:2, C:3}
    MRVectorClock *otherVectorClock = [MRVectorClock new];

    [otherVectorClock updateClockValueForID:Identifier_A];

    [otherVectorClock updateClockValueForID:Identifier_B];
    [otherVectorClock updateClockValueForID:Identifier_B];

    [otherVectorClock updateClockValueForID:Identifier_C];
    [otherVectorClock updateClockValueForID:Identifier_C];
    [otherVectorClock updateClockValueForID:Identifier_C];
    
    // Expected {A:2, B:2, C:3}
    MRVectorClock *mergedVectorClock = [vectorClock mergeClock:otherVectorClock];
    
    XCTAssertEqual([mergedVectorClock clockValueForID:Identifier_A], 2);
    XCTAssertEqual([mergedVectorClock clockValueForID:Identifier_B], 2);
    XCTAssertEqual([mergedVectorClock clockValueForID:Identifier_C], 3);
}


#pragma mark - Comparison

- (void) testClockCompareEqual
{
    // {A:1}
    MRVectorClock *vectorClock = [MRVectorClock new];
    [vectorClock updateClockValueForID:Identifier_A];

    XCTAssertEqual([vectorClock compare:vectorClock], MRVectorClockOrderedSame);
    
    // {A:1, B:2}
    [vectorClock updateClockValueForID:Identifier_B];
    [vectorClock updateClockValueForID:Identifier_B];

    XCTAssertEqual([vectorClock compare:vectorClock], MRVectorClockOrderedSame);
}

- (void) testClockCompareAncestor
{
    // {A:1}
    MRVectorClock *vectorClock = [MRVectorClock new];
    [vectorClock updateClockValueForID:Identifier_A];

    // {A:2}
    MRVectorClock *vectorClockUpdated = [vectorClock copy];
    [vectorClockUpdated updateClockValueForID:Identifier_A];

    // {A:2, B:1}
    MRVectorClock *vectorClockUpdatedWithAnotherID = [vectorClockUpdated copy];
    [vectorClockUpdatedWithAnotherID updateClockValueForID:Identifier_B];

    // {A:1} < {A:2}
    XCTAssertEqual([vectorClock compare:vectorClockUpdated], MRVectorClockOrderedAncestor);

    // {A:1} < {A:2, B:1}
    XCTAssertEqual([vectorClock compare:vectorClockUpdatedWithAnotherID], MRVectorClockOrderedAncestor);
    
    // {A:2} < {A:2, B:1}
    XCTAssertEqual([vectorClockUpdated compare:vectorClockUpdatedWithAnotherID], MRVectorClockOrderedAncestor);
}


- (void) testClockCompareDescendant
{
    // {A:1}
    MRVectorClock *vectorClock = [MRVectorClock new];
    [vectorClock updateClockValueForID:Identifier_A];
    
    // {A:2}
    MRVectorClock *vectorClockUpdated = [vectorClock copy];
    [vectorClockUpdated updateClockValueForID:Identifier_A];
    
    // {A:2, B:1}
    MRVectorClock *vectorClockUpdatedWithAnotherID = [vectorClockUpdated copy];
    [vectorClockUpdatedWithAnotherID updateClockValueForID:Identifier_B];
    
    // {A:2} > {A:1}
    XCTAssertEqual([vectorClockUpdated compare:vectorClock], MRVectorClockOrderedDescendant);
    
    // {A:2, B:1} > {A:1}
    XCTAssertEqual([vectorClockUpdatedWithAnotherID compare:vectorClock], MRVectorClockOrderedDescendant);
    
    // {A:2, B:1} > {A:2}
    XCTAssertEqual([vectorClockUpdatedWithAnotherID compare:vectorClockUpdated], MRVectorClockOrderedDescendant);

}

- (void) testClockCompareConcurrent
{
    // {A:1}
    MRVectorClock *vectorClock = [MRVectorClock new];
    [vectorClock updateClockValueForID:Identifier_A];

    // {B:1}
    MRVectorClock *otherVectorClock = [MRVectorClock new];
    [otherVectorClock updateClockValueForID:Identifier_B];

    XCTAssertEqual([vectorClock compare:otherVectorClock], MRVectorClockOrderedConcurrent);
    
    // {A:1, B:1, C:3}
    MRVectorClock *clock3 = [MRVectorClock new];
    [clock3 updateClockValueForID:Identifier_A value:1];
    [clock3 updateClockValueForID:Identifier_B value:1];
    [clock3 updateClockValueForID:Identifier_B value:3];
    
    // {A:2, B:1}
    MRVectorClock *clock4 = [MRVectorClock new];
    [clock4 updateClockValueForID:Identifier_A value:2];
    [clock4 updateClockValueForID:Identifier_B value:1];
    
    XCTAssertEqual([clock3 compare:clock4], MRVectorClockOrderedConcurrent);
    
}


@end
