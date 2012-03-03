//
//  ISRecordsViewController.m
//  iSignal
//
//  Created by Patrick Deng on 11-9-1.
//  Copyright 2011年 CodeBeaver. All rights reserved.
//

#import "ISRecordsViewController.h"

@implementation ISRecordsViewController

// Manual Codes Begin

@synthesize leftBarButton = _leftBarButton;
@synthesize rightBarButton = _rightBarButton;

@synthesize deleteEnabled = _deleteEnabled;
@synthesize multiselectEnabled = _multiselectEnabled;

@synthesize tableView = _tableView;

@synthesize deletingRecords = _deletingRecords;
@synthesize fetchedResultsController = _fetchedResultsController;

-(void) setDeleteEnabled:(BOOL) flag
{
    _deleteEnabled = flag;
    [_rightBarButton setEnabled:_deleteEnabled];
}

- (void)initTabBarItem
{
    //    UIImage* itemImage = [UIImage imageNamed:@"MyViewControllerImage.png"];
    UIImage* itemImage = nil;
    UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"STR_TAB_RECORDS", nil) image:itemImage tag:TAG_RECORDSVIEW];
    self.tabBarItem = theItem;
    [theItem release];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
        [self initTabBarItem];
    }
    return self;
}

- (void)dealloc 
{  
    [_fetchedResultsController release];
    
    [_tableView release];
    [_rightBarButton release];
    [_leftBarButton release];
    [_deletingRecords release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _deletingRecords = [[NSMutableDictionary alloc] init];

    [self setDeleteEnabled:FALSE];
    _multiselectEnabled = FALSE;
}

- (void)viewDidUnload
{
    _fetchedResultsController = nil;
    
    _tableView = nil;
    _rightBarButton = nil;
    _leftBarButton = nil;
    _deletingRecords = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// Method of UIViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Attach object reference of NSFetchedResultsController
    iSignalAppDelegate* appDelegate = (iSignalAppDelegate*) [CBUIUtils getAppDelegate];
    _fetchedResultsController = [appDelegate.coreDataModule obtainFetchedResultsController:gFetchedResultsControllerIdentifier_signalRecord];
    // Inject delegate(self) to NSFetchedResultsController object
    _fetchedResultsController.delegate = self;    
}

// Method of UIViewController
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

// Method of UIViewController
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

// Method of UIViewController
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [_fetchedResultsController objectAtIndexPath:indexPath];
    SignalRecord *record = (SignalRecord*)managedObject;
    NSDate *time = record.time;
    NSString *timeString = [CBDateUtils dateStringInLocalTimeZoneWithStandardFormat:time];
    cell.textLabel.text = timeString;
}

// Method of UITableViewController
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray* sectionArray = [_fetchedResultsController sections];
    return [sectionArray count];
}

// Method of UITableViewController
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* sectionArray = [_fetchedResultsController sections];
    id <NSFetchedResultsSectionInfo> sectionInfo = [sectionArray objectAtIndex:section];
    NSInteger numberOfObjects = [sectionInfo numberOfObjects];
    return numberOfObjects;
}

// Method of UITableViewController
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = KEY_CELL_IDENTIFIER;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

// Method of UITableViewController
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
        [context deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

// Method of UITableViewController
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

// Method of UITableViewDelegate protocol
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */

    if (_multiselectEnabled)
    {
        [_deletingRecords setObject:indexPath forKey:indexPath];
        if (0 < _deletingRecords.count) 
        {
            [self setDeleteEnabled:TRUE];
        }
        else 
        {
            [self setDeleteEnabled:FALSE];
        }
	}
}

// Method of UITableViewDelegate protocol
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_multiselectEnabled)
    {
        [_deletingRecords removeObjectForKey:indexPath];
        if (0 < _deletingRecords.count) 
        {
            [self setDeleteEnabled:TRUE];
        }
        else 
        {
            [self setDeleteEnabled:FALSE];
        }
	}   
}

// Method of UITableViewDelegate protocol
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert; 
} 

// Method of NSFetchedResultsControllerDelegate protocol
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

// Method of NSFetchedResultsControllerDelegate protocol
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

// Method of NSFetchedResultsControllerDelegate protocol
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    if (tableView.editing) 
    {
        [tableView setEditing:FALSE animated:FALSE];
        
        [_deletingRecords removeAllObjects];
        [self setDeleteEnabled:FALSE];
        _multiselectEnabled = FALSE;
    }
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        {
            NSArray* newObjectArray = [NSArray arrayWithObject:newIndexPath];
            [tableView insertRowsAtIndexPaths:newObjectArray withRowAnimation:UITableViewRowAnimationFade];
            break;
        }   
        case NSFetchedResultsChangeDelete:
        {
            NSArray* existObjectArray = [NSArray arrayWithObject:indexPath];
            [tableView deleteRowsAtIndexPaths:existObjectArray withRowAnimation:UITableViewRowAnimationFade];
            break;
        }   
        case NSFetchedResultsChangeUpdate:
        {
            UITableViewCell* updateCell = [tableView cellForRowAtIndexPath:indexPath];
            [self configureCell:updateCell atIndexPath:indexPath];
            break;
        }   
        case NSFetchedResultsChangeMove:
        {
            NSArray* existObjectArray = [NSArray arrayWithObject:indexPath];
            [tableView deleteRowsAtIndexPaths:existObjectArray withRowAnimation:UITableViewRowAnimationFade];
            NSArray* newObjectArray = [NSArray arrayWithObject:newIndexPath];
            [tableView insertRowsAtIndexPaths:newObjectArray withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

// Method of NSFetchedResultsControllerDelegate protocol
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    
    // Once update sent from data resource, below condition need to be reset.
    [_deletingRecords removeAllObjects];
    [self setDeleteEnabled:FALSE];
    _multiselectEnabled = FALSE;
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
// In the simplest, most efficient, case, reload the table view.
//    [self.tableView reloadData];
}

- (IBAction)selectRecords:(id)sender
{
    [_deletingRecords removeAllObjects];
    
    [self setDeleteEnabled:FALSE];
    
    if (_multiselectEnabled)
    {
		[_tableView setEditing:NO animated:YES];
        _multiselectEnabled = FALSE;
	}
	else 
    {
		[_tableView setEditing:YES animated:YES];
        _multiselectEnabled = TRUE;        
	}    
}

- (IBAction)deleteRecords:(id)sender
{
    NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    NSArray* deletingRecordIndexPathes = [_deletingRecords allValues];
    for (NSInteger i = 0; i < deletingRecordIndexPathes.count; i++) 
    {
        NSIndexPath* indexPath = [deletingRecordIndexPathes objectAtIndex:i];
        [context deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];    
    }
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
        
    [_deletingRecords removeAllObjects];
    
    [self setDeleteEnabled:FALSE];
    _multiselectEnabled = FALSE;
}

// Manual Codes End

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
