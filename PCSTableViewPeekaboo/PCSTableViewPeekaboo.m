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
      self.rowAnimation = UITableViewRowAnimationAutomatic;
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

- (void)setupAddLogicalSection:(NSInteger)logicalSection numberOfRows:(NSInteger)numberOfRows {
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
      NSInteger logicalSection = [self logicalFromDisplayedSection:displayedSection];
      return [self.logicalRowsPerSection[logicalSection] integerValue];
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
   
   [self.tableView deleteRowsAtIndexPaths:@[ displayedIndexPath ] withRowAnimation:self.rowAnimation];
}

- (void)deleteLogicalSection:(NSInteger)logicalSection {
   if ([self.completelyHiddenLogicalSections containsIndex:logicalSection])
      return;
   
   NSInteger displayedSection = [self displayedFromLogicalSection:logicalSection];
   [self.completelyHiddenLogicalSections addIndex:logicalSection];
   [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:displayedSection] withRowAnimation:self.rowAnimation];
}

- (void)deleteLogicalSections:(NSIndexSet *)logicalSections {
   NSMutableIndexSet *displayedSections = [NSMutableIndexSet indexSet];
   
   [logicalSections enumerateIndexesUsingBlock:^(NSUInteger logicalSection, BOOL *stop) {
      if ([self.completelyHiddenLogicalSections containsIndex:logicalSection])
         return;
      
      NSInteger displayedSection = [self displayedFromLogicalSection:logicalSection];
      [displayedSections addIndex:displayedSection];
   }];
   
   [self.completelyHiddenLogicalSections addIndexes:logicalSections];
   [self.tableView deleteSections:displayedSections withRowAnimation:self.rowAnimation];
}

- (void)insertLogicalSection:(NSInteger)logicalSection {
   if (! [self.completelyHiddenLogicalSections containsIndex:logicalSection])
      return;
   
   NSInteger displayedSection = [self displayedFromLogicalSection:logicalSection];
   [self.completelyHiddenLogicalSections removeIndex:logicalSection];
   [self.tableView insertSections:[NSIndexSet indexSetWithIndex:displayedSection] withRowAnimation:self.rowAnimation];
}

- (void)insertLogicalSections:(NSIndexSet *)logicalSections {
   NSMutableIndexSet *displayedSections = [NSMutableIndexSet indexSet];
   __block NSInteger i = 0;
   
   [logicalSections enumerateIndexesUsingBlock:^(NSUInteger logicalSection, BOOL *stop) {
      if (! [self.completelyHiddenLogicalSections containsIndex:logicalSection])
         return;
      
      NSInteger displayedSection = [self displayedFromLogicalSection:logicalSection];
      NSInteger displayedSectionToInsert = displayedSection + i;
      [displayedSections addIndex:displayedSectionToInsert];
      i++;
   }];
   
   [self.completelyHiddenLogicalSections removeIndexes:logicalSections];
   [self.tableView insertSections:displayedSections withRowAnimation:self.rowAnimation];
}

- (void)insertAllHiddenCells {
   NSMutableArray *logicalIndexPaths = [NSMutableArray array];
   [self.hiddenLogicalIndexPathsBySection enumerateKeysAndObjectsUsingBlock:^(NSNumber *logicalSectionNumber, NSIndexSet *hiddenLogicalIndexPathsBySection, BOOL *stop) {
      [hiddenLogicalIndexPathsBySection enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
         [logicalIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:[logicalSectionNumber integerValue]]];
      }];
   }];
   
   [self.logicalSectionsWithSomethingHidden removeAllIndexes];
   [self.hiddenLogicalIndexPathsBySection removeAllObjects];
   [self.completelyHiddenLogicalSections removeAllIndexes];
   [self.tableView insertRowsAtIndexPaths:logicalIndexPaths withRowAnimation:self.rowAnimation];
}

//====================================================================================================
#pragma mark - Convert
//====================================================================================================

- (NSIndexPath *)logicalFromDisplayedIndexPath:(NSIndexPath *)displayedIndexPath {
   NSInteger logicalSection = [self logicalFromDisplayedSection:displayedIndexPath.section];
   NSInteger logicalRow = [self logicalIndexFromPhysicalIndex:displayedIndexPath.row hiddenIndexSet:self.hiddenLogicalIndexPathsBySection[@(logicalSection)]];
   return [NSIndexPath indexPathForRow:logicalRow inSection:logicalSection];
}

- (NSInteger)logicalFromDisplayedSection:(NSInteger)displayedSection {
   NSInteger logicalSection = [self logicalIndexFromPhysicalIndex:displayedSection hiddenIndexSet:self.completelyHiddenLogicalSections];
   return logicalSection;
}

- (NSIndexPath *)displayedFromLogicalIndexPath:(NSIndexPath *)logicalIndexPath {
   NSInteger displayedSection = [self displayedFromLogicalSection:logicalIndexPath.section];
   NSInteger displayedRow = logicalIndexPath.row;
   return [NSIndexPath indexPathForRow:displayedRow inSection:displayedSection];
}

- (NSInteger)displayedFromLogicalSection:(NSInteger)logicalSection {
   NSInteger displayedSection = [self displayedIndexFromLogicalIndex:logicalSection hiddenIndexSet:self.completelyHiddenLogicalSections];
   return displayedSection;
}

//====================================================================================================
#pragma mark - Utils
//====================================================================================================

- (NSInteger)logicalIndexFromPhysicalIndex:(NSUInteger)physicalIndex hiddenIndexSet:(NSIndexSet *)hiddenIndexSet {
   if ([hiddenIndexSet count] == 0)
      return physicalIndex;
   
   NSInteger logicalIndex = 0;
   NSInteger hiddenCount = 0;
   //for (logicalIndex=0, hiddenCount=-1; logicalIndex - hiddenCount < physicalIndex; logicalIndex++) {
   for (NSInteger logicalI=0; logicalI - hiddenCount <= physicalIndex; logicalI++) {
      logicalIndex = logicalI;
      hiddenCount = [hiddenIndexSet countOfIndexesInRange:NSMakeRange(0, logicalI + 1)];
   }
   return logicalIndex;
}

- (NSInteger)displayedIndexFromLogicalIndex:(NSUInteger)logicalIndex hiddenIndexSet:(NSIndexSet *)hiddenIndexSet {
   NSInteger numHiddenIndeces = [hiddenIndexSet countOfIndexesInRange:NSMakeRange(0, logicalIndex)];
   NSInteger displayedIndex = logicalIndex - numHiddenIndeces;
   return displayedIndex;
}

@end
