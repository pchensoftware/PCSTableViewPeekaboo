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
- (void)setupAddLogicalSection:(NSInteger)logicalSection numberOfRows:(NSInteger)numberOfRows;
- (NSInteger)numberOfDisplayedSections;
- (NSInteger)numberOfDisplayedRowsInSection:(NSInteger)displayedSection;

// Insert and delete
- (void)deleteDisplayedIndexPath:(NSIndexPath *)displayedIndexPath;
- (void)deleteLogicalSection:(NSInteger)logicalSection;
- (void)deleteLogicalSections:(NSIndexSet *)logicalSections;
- (void)insertLogicalSection:(NSInteger)logicalSection;
- (void)insertLogicalSections:(NSIndexSet *)logicalSections;
- (void)insertAllHiddenCells;

// Convert
- (NSIndexPath *)logicalFromDisplayedIndexPath:(NSIndexPath *)displayedIndexPath;
- (NSInteger)logicalFromDisplayedSection:(NSInteger)displayedSection;
- (NSIndexPath *)displayedFromLogicalIndexPath:(NSIndexPath *)logicalIndexPath;
- (NSInteger)displayedFromLogicalSection:(NSInteger)logicalSection;

@end
