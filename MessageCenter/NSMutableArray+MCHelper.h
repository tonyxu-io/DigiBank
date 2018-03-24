//
//  NSMutableArray+MCHelper.h
//  MessageCenter
//
//  Created by Rookie on 06/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (MCHelper)

- (void)binaryInsertObjects:(NSArray *)objects withComparator:(NSComparator)comparator;

@end
