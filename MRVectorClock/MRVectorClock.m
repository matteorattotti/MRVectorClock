//
//  MRVectorClock.m
//  MRVectorClock
//
//  Created by Matteo Rattotti on 23/04/15.
//
//

#import "MRVectorClock.h"

@interface MRVectorClock ()

@property (nonatomic, strong) NSMutableDictionary* clockValues;

@end

@implementation MRVectorClock

- (instancetype)init
{
    self = [super init];
    if (self) {
        _clockValues = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        if (data == nil) {
            _clockValues = [NSMutableDictionary dictionary];
        }
        else {
            NSError *error = nil;
            _clockValues = [NSPropertyListSerialization propertyListWithData:data options:kCFPropertyListMutableContainers format:NULL error:&error];
            if (error != nil || _clockValues == nil) {
                return nil;
            }
        }

    }
    return self;
}

- (NSData *) data
{
    NSError *error;
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList: _clockValues format: NSPropertyListBinaryFormat_v1_0 options: 0 error: &error];
    
    return plistData;
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    typeof(self) clock = [[[self class] alloc] init];
    clock.clockValues = [self.clockValues mutableCopy];
    
    return clock;
}


#pragma mark - Comparing

- (MRVectorClockComparisonResult) compare: (MRVectorClock *) otherVectorClock
{
    __block BOOL greater = NO;
    __block BOOL smaller = NO;
    
    NSMutableSet *keys = [NSMutableSet setWithArray:[_clockValues allKeys]];
    [keys addObjectsFromArray:[otherVectorClock.clockValues allKeys]];
    
    for (NSString *key in keys) {
        NSUInteger number = [self clockValueForID:key];
        NSUInteger otherNumber = [otherVectorClock clockValueForID:key];
        
        NSInteger diff = number - otherNumber;
        
        if(diff > 0) greater = YES;
        if(diff < 0) smaller = YES;
    }
    
    if(greater && smaller) return MRVectorClockOrderedConcurrent;
    if(smaller) return MRVectorClockOrderedAncestor;
    if(greater) return MRVectorClockOrderedDescendant;
    return MRVectorClockOrderedSame;
}

#pragma mark - Updating

- (void) updateClockValueForID: (id) identifier
{
    @synchronized(self)
    {
        NSNumber* clockValue = _clockValues[identifier];
        _clockValues[identifier] = clockValue ? @([clockValue unsignedLongLongValue] + 1) : @1;
        
    }
}

- (void) updateClockValueForID: (id) identifier value: (NSUInteger) value
{
    @synchronized(self)
    {
        _clockValues[identifier] = @(value);
    }
}

#pragma mark - Merging

- (instancetype) mergeClock: (MRVectorClock*) otherVectorClock
{
    typeof(self) clock = [[[self class] alloc] init];
    __block NSMutableDictionary* clockValues = clock.clockValues;
    
    [[_clockValues allKeys] enumerateObjectsUsingBlock:^(NSNumber* obj, NSUInteger idx, BOOL* stop) {
        clockValues[obj] = _clockValues[obj];
    }];
    
    [[otherVectorClock.clockValues allKeys] enumerateObjectsUsingBlock:^(NSNumber* obj, NSUInteger idx, BOOL* stop) {
        if(clockValues[obj] == nil || [clockValues[obj] unsignedLongLongValue] < [otherVectorClock.clockValues[obj] unsignedLongLongValue])
        {
            clockValues[obj] = otherVectorClock.clockValues[obj];
        }
    }];
    
    return clock;

}

#pragma mark - Clock values

- (NSUInteger) clockValueForID:(id)identifier
{
    return [_clockValues[identifier] unsignedLongLongValue];
}

#pragma mark - Utils

- (NSArray*) orderedIDs
{
    return [[_clockValues allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSString *) stringRepresentation
{
    NSMutableString *representation = [NSMutableString string];
    NSArray *orderedIdentifiers = [self orderedIDs];
    
    [representation appendString:@"("];
    
    [orderedIdentifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *value = _clockValues[obj];
        [representation appendFormat:@"%@:%@", obj, value];
        if (idx != [orderedIdentifiers count]-1) {
            [representation appendString:@", "];
        }
    }];
    
    [representation appendString:@")"];

    return [representation copy];
}

- (NSString *) description
{
    NSString *description = [NSString stringWithFormat:@"%@ %@", [super description], [self stringRepresentation]];
    
    return description;
}


@end
