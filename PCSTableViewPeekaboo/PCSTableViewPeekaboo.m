//====================================================================================================
// Author: Peter Chen
// Created: 5/31/14
// Copyright 2014 Peter Chen
//====================================================================================================

#import "PCSTableViewPeekaboo.h"

@interface PCSTableViewPeekaboo()

@property (nonatomic, strong) NSMutableArray *rowsPerSection;

@end

@implementation PCSTableViewPeekaboo

- (id)init {
   if ((self = [super init])) {
      self.rowsPerSection = [NSMutableArray array];
   }
   return self;
}

- (void)addLogicalSection:(NSInteger)section numberOfRows:(NSInteger)numberOfRows {
   [self.rowsPerSection addObject:@(numberOfRows)];
}

- (NSInteger)numberOfDisplayedSections {
   return [self.rowsPerSection count];
}

- (NSInteger)numberOfDisplayedRowsInSection:(NSInteger)section {
   return [self.rowsPerSection[section] integerValue];
}

- (NSIndexPath *)logicalFromDisplayedIndexPath:(NSIndexPath *)displayedIndexPath {
   return displayedIndexPath;
}

- (NSInteger)logicalFromDisplayedSection:(NSInteger)displayedSection {
   return displayedSection;
}

- (NSIndexPath *)displayedFromLogicalIndexPath:(NSIndexPath *)displayedIndexPath {
   return displayedIndexPath;
}

- (NSInteger)displayedFromLogicalSection:(NSInteger)displayedSection {
   return displayedSection;
}

@end
