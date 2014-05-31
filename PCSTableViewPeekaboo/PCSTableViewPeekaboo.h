//====================================================================================================
// Author: Peter Chen
// Created: 5/31/14
// Copyright 2014 Peter Chen
//====================================================================================================

#import <UIKit/UIKit.h>


@interface PCSTableViewPeekaboo : NSObject

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, assign) UITableViewRowAnimation rowAnimation; // defaults to UITableViewRowAnimationAutomatic

// Setup
- (void)addLogicalSection:(NSInteger)logicalSection numberOfRows:(NSInteger)numberOfRows;
- (NSInteger)numberOfDisplayedSections;
- (NSInteger)numberOfDisplayedRowsInSection:(NSInteger)displayedSection;

// Insert and delete
- (void)deleteDisplayedIndexPath:(NSIndexPath *)logicalIndexPath;
- (void)insertAllHiddenCells;

// Convert
- (NSIndexPath *)logicalFromDisplayedIndexPath:(NSIndexPath *)displayedIndexPath;
- (NSInteger)logicalFromDisplayedSection:(NSInteger)displayedSection;
- (NSIndexPath *)displayedFromLogicalIndexPath:(NSIndexPath *)displayedIndexPath;
- (NSInteger)displayedFromLogicalSection:(NSInteger)displayedSection;

@end
