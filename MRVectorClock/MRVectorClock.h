//
//  MRVectorClock.h
//  MRVectorClock
//
//  Created by Matteo Rattotti on 23/04/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MRVectorClockComparisonResult)
{
    MRVectorClockOrderedAncestor = -1L,
    MRVectorClockOrderedSame,
    MRVectorClockOrderedDescendant,
    MRVectorClockOrderedConcurrent,
};

@interface MRVectorClock : NSObject <NSCopying>

- (instancetype) initWithData: (NSData *) data;
- (NSData *) data;

- (MRVectorClockComparisonResult) compare: (MRVectorClock *) otherVectorClock;

- (void) updateClockValueForID: (id) identifier;
- (void) updateClockValueForID: (id) identifier value: (NSUInteger) value;
- (instancetype)mergeClock: (MRVectorClock*) otherVectorClock;

- (NSUInteger)clockValueForID:(id)identifier;

@end
