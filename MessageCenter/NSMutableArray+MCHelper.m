//
//  NSMutableArray+MCHelper.m
//  MessageCenter
//
//  Created by Rookie on 06/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "NSMutableArray+MCHelper.h"

@implementation NSMutableArray (MCHelper)

static inline NSUInteger indexWithBinarySort(NSArray *array, id object, NSComparator comparator) {
    if (array.count == 0) {
        return 0;
    }
    
    if (comparator(object, array.firstObject) == NSOrderedAscending) {
        return 0;
    }
    
    if (comparator(object, array.lastObject) == NSOrderedDescending) {
        return array.count;
    }
    
    NSUInteger startIndex = 0;
    NSUInteger endIndex = array.count - 1;
    NSUInteger midIndex;
    
    while (startIndex < endIndex) {
        midIndex = (startIndex + endIndex) / 2;
        id target = array[midIndex];
        if (comparator(object, target) == NSOrderedAscending) {
            endIndex = midIndex;
        } else {
            startIndex = midIndex + 1;
        }
    }
    
    return startIndex;
}

- (void)binaryInsertObjects:(NSArray *)objects withComparator:(NSComparator)comparator {
    for (id object in objects) {
        NSUInteger index = indexWithBinarySort(self, object, comparator);
        if (index == self.count) {
            [self addObject:object];
        } else {
            [self insertObject:object atIndex:index];
        }
    }
}

@end
