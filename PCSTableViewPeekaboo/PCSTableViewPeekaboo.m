//====================================================================================================
// Author: Peter Chen
// Created: 5/31/14
// Copyright 2014 Peter Chen
//====================================================================================================

#import "PCSTableViewPeekaboo.h"

@interface PCSTableViewPeekaboo()

@property (nonatomic, strong) NSMutableArray *logicalRowsPerSection;
@property (nonatomic, strong) NSMutableIndexSet *logicalSectionsWithSomethingHidden;
@property (nonatomic, strong) NSMutableDictionary *hiddenLogicalIndexPathsBySection; // key=@(section), value=NSMutableIndexSet
@property (nonatomic, strong) NSMutableIndexSet *completelyHiddenLogicalSections;

@end

@implementation PCSTableViewPeekaboo

- (id)init {
   if ((self = [super init])) {
      self.logicalRowsPerSection = [NSMutableArray array];
      self.logicalSectionsWithSomethingHidden = [NSMutableIndexSet indexSet];
      self.hiddenLogicalIndexPathsBySection = [NSMutableDictionary dictionary];
      self.completelyHiddenLogicalSections = [NSMutableIndexSet indexSet];
   }
   return self;
}

//====================================================================================================
#pragma mark - Setup
//====================================================================================================

- (void)addLogicalSection:(NSInteger)logicalSection numberOfRows:(NSInteger)numberOfRows {
   [self.logicalRowsPerSection addObject:@(numberOfRows)];
}

- (NSInteger)numberOfDisplayedSections {
   return [self.logicalRowsPerSection count] - [self.completelyHiddenLogicalSections count];
}

- (NSInteger)numberOfDisplayedRowsInSection:(NSInteger)displayedSection {
   if ([self.logicalSectionsWithSomethingHidden containsIndex:displayedSection]) {
      NSUInteger logicalSection = [self logicalIndexFromPhysicalIndex:displayedSection hiddenIndexSet:self.completelyHiddenLogicalSections];
      NSMutableIndexSet *hiddenLogicalIndexPaths = self.hiddenLogicalIndexPathsBySection[@(logicalSection)];
      return [self.logicalRowsPerSection[logicalSection] integerValue] - [hiddenLogicalIndexPaths count];
   }
   else {
      return [self.logicalRowsPerSection[displayedSection] integerValue];
   }
}

//====================================================================================================
#pragma mark - Insert and delete
//====================================================================================================

- (void)deleteDisplayedIndexPath:(NSIndexPath *)displayedIndexPath {
   NSIndexPath *logicalIndexPath = [self logicalFromDisplayedIndexPath:displayedIndexPath];
   
   if (! [self.logicalSectionsWithSomethingHidden containsIndex:logicalIndexPath.section]) {
      [self.logicalSectionsWithSomethingHidden addIndex:logicalIndexPath.section];
      self.hiddenLogicalIndexPathsBySection[@(logicalIndexPath.section)] = [NSMutableIndexSet indexSet];
   }
   
   NSMutableIndexSet *hiddenLogicalIndexPaths = self.hiddenLogicalIndexPathsBySection[@(logicalIndexPath.section)];
   [hiddenLogicalIndexPaths addIndex:logicalIndexPath.row];
   
   [self.tableView deleteRowsAtIndexPaths:@[ displayedIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)insertAllHiddenCells {
   
}

//====================================================================================================
#pragma mark - Convert
//====================================================================================================

- (NSIndexPath *)logicalFromDisplayedIndexPath:(NSIndexPath *)displayedIndexPath {
   NSUInteger logicalSection = [self logicalIndexFromPhysicalIndex:displayedIndexPath.section hiddenIndexSet:self.completelyHiddenLogicalSections];
   NSUInteger logicalRow = [self logicalIndexFromPhysicalIndex:displayedIndexPath.row hiddenIndexSet:self.hiddenLogicalIndexPathsBySection[@(logicalSection)]];
   return [NSIndexPath indexPathForRow:logicalRow inSection:logicalSection];
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

//====================================================================================================
#pragma mark - Utils
//====================================================================================================

- (NSInteger)logicalIndexFromPhysicalIndex:(NSUInteger)physicalIndex hiddenIndexSet:(NSIndexSet *)indexSet {
   if ([indexSet count] == 0)
      return physicalIndex;
   
   NSInteger logicalIndex = 0;
   NSInteger hiddenCount = 0;
   //for (logicalIndex=0, hiddenCount=-1; logicalIndex - hiddenCount < physicalIndex; logicalIndex++) {
   for (NSInteger logicalI=0; logicalI - hiddenCount <= physicalIndex; logicalI++) {
      logicalIndex = logicalI;
      hiddenCount = [indexSet countOfIndexesInRange:NSMakeRange(0, logicalI + 1)];
   }
   return logicalIndex;
}

@end
