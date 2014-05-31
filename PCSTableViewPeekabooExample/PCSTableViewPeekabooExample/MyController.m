//====================================================================================================
// Author: Peter Chen
// Created: 5/31/14
// Copyright 2014 Peter Chen
//====================================================================================================

#import "MyController.h"
#import "PCSTableViewPeekaboo.h"

typedef NS_ENUM(int, Sections) {
   Section_One,
   Section_Two,
   Section_Three,
   Section_Count
};

@interface MyController()

@property (nonatomic, strong) PCSTableViewPeekaboo *peekaboo;

@end

@implementation MyController

- (id)init {
   if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
      self.peekaboo = [[PCSTableViewPeekaboo alloc] init];
   }
   return self;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   self.title = @"Peekaboo";
   self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Show All" style:UIBarButtonItemStyleDone target:self action:@selector(_showAllButtonTapped)];
   
   self.peekaboo.tableView = self.tableView;
   [self.peekaboo addLogicalSection:Section_One numberOfRows:1];
   [self.peekaboo addLogicalSection:Section_Two numberOfRows:2];
   [self.peekaboo addLogicalSection:Section_Three numberOfRows:3];
}

//====================================================================================================
#pragma mark - Table view
//====================================================================================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return [self.peekaboo numberOfDisplayedSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [self.peekaboo numberOfDisplayedRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   static NSString *CellIdentifier = @"Cell";
   NSIndexPath *logicalIndexPath = [self.peekaboo logicalFromDisplayedIndexPath:indexPath];
   
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
   }
   
   cell.textLabel.text = [NSString stringWithFormat:@"%d %d", logicalIndexPath.section, logicalIndexPath.row];
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   [self.peekaboo deleteDisplayedIndexPath:indexPath];
   [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//====================================================================================================
#pragma mark - Events
//====================================================================================================

- (void)_showAllButtonTapped {
   [self.peekaboo insertAllHiddenCells];
}

@end
