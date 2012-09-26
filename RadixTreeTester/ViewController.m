//
//  ViewController.m
//  RadixTreeTester
//
//  Created by Shay Erlichmen on 26/09/12.
//  Copyright (c) 2012 erlichmen. All rights reserved.
//

#import "ViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "RadixTree.h"
#import "ContactsTableViewCell.h"

@interface ViewController () {
    RadixTree *_contactsTree;
    NSArray *_contactsArray;
    NSArray *_contactsArrayFiltered;
    BOOL _isFiltered;
    ABAddressBookRef _notificationAddressBook;
}
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

- (void)loadAddressBook;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (ABAddressBookCreateWithOptions != NULL) {
        _notificationAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(_notificationAddressBook, ^(bool granted, CFErrorRef error) {
                [self registerAddressBook];
                [self loadAddressBook];
            });
        } else if (status == kABAuthorizationStatusAuthorized) {
            [self registerAddressBook];
            [self loadAddressBook];
        } else  {
            CFRelease(_notificationAddressBook);
            _notificationAddressBook = NULL;
        }
    }
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    else {
        notificationAddressBook = ABAddressBookCreate();
        [self registerAddressBook];
        [self loadAddressBook];
    }
#endif
    
    self.searchBar.delegate = (id)self;
}

- (void)viewDidUnload {
    self.searchBar.delegate = nil;
    self.searchBar = nil;
    [super viewDidUnload];
}

- (void)registerAddressBook {
    ABAddressBookRegisterExternalChangeCallback(_notificationAddressBook, addressBookChanged, (__bridge void *)(self));
}

- (void)unregisterAddressBook {
	ABAddressBookUnregisterExternalChangeCallback(_notificationAddressBook, addressBookChanged, (__bridge void *)(self));
}

void addressBookChanged(ABAddressBookRef addressBook,
                        CFDictionaryRef dictionary,
                        void *context)
{
    ViewController *viewController = (__bridge ViewController*)context;
    [viewController loadAddressBook];
    UITableView *tableView = viewController.tableView;
    [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void)indexValue:(NSString*)key value:(NSDictionary*)value {
    key = [key lowercaseString];
    NSMutableArray *contacts = [_contactsTree find:key];
    
    if (contacts == nil) {
        contacts = [[NSMutableArray alloc] init];
    }
    
    [contacts addObject:value];
    
    [_contactsTree insert:key value:contacts];
}

- (void)loadAddressBook {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
    ABAddressBookRef tmpAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
#else
    ABAddressBookRef tmpAddressBook = ABAddressBookCreate();
#endif
    
    ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(tmpAddressBook);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(tmpAddressBook,
                                                                                     defaultSource,
                                                                                     kABPersonSortByLastName);
    CFIndex nPeople = CFArrayGetCount(allPeople);
    
    NSMutableOrderedSet *phones = [[NSMutableOrderedSet alloc] initWithCapacity:nPeople];
    
    NSMutableArray *localContactsArray = [[NSMutableArray alloc] initWithCapacity:nPeople];
    
    _contactsTree = [[RadixTree alloc] init];
    
    for ( unsigned i = 0; i < nPeople; i++ )
    {
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName= CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        
        NSString *fullName;
        
        if ([firstName isEqualToString:@"(null)"]) {
            firstName = nil;
        }
        if ([lastName isEqualToString:@"(null)"]) {
            lastName = nil;
        }
        
        if (firstName && lastName)
            fullName = [NSString stringWithFormat:@"%@, %@",
                        firstName,
                        lastName];
        else if (firstName && !lastName)
            fullName = firstName;
        else if (!firstName && lastName)
            fullName = lastName;
        else
            continue;
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        for(CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
            NSString *phone = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
            
            if ([phones containsObject:phone]) {
                continue;
            }
            
            [phones addObject:phone];
            
            NSDictionary *contact = @{
                @"name": fullName,
                @"phone": phone
            };
            
            [self indexValue:firstName value:contact];
            [self indexValue:lastName value:contact];
            [self indexValue:phone value:contact];
            
            [localContactsArray addObject:contact];
        }
        
        CFRelease(phoneNumbers);
    }
    
    _contactsArray = localContactsArray;
    
    CFRelease(defaultSource);
    CFRelease(allPeople);
    CFRelease(tmpAddressBook);    
}

#pragma mark - search bar

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text {
    _isFiltered = text.length > 0;
    
    if (_isFiltered)
    {
        NSArray *contactsItems = [_contactsTree searchPrefix:[[text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] recordLimit:-1];
        
        NSMutableArray *tempContactsArrayFiltered = [[NSMutableArray alloc] init];
        
        for (NSArray *contacts in contactsItems) {
            for (NSDictionary *contact in contacts) {
                [tempContactsArrayFiltered addObject:contact];
            }
        }
        
        _contactsArrayFiltered = tempContactsArrayFiltered;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSArray*)displayContacts {
    if (_isFiltered) {
        return _contactsArrayFiltered;
    } else {
        return _contactsArray;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"contactsTableCell";
    
    ContactsTableViewCell *contactCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *contact = self.displayContacts[indexPath.row];
    contactCell.nameLabel.text = contact[@"name"];
    contactCell.phoneLabel.text = contact[@"phone"];
    
    return contactCell;
}

@end
