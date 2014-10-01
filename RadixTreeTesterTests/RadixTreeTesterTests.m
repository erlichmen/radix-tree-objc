//
//  RadixTreeTesterTests.m
//  RadixTreeTesterTests
//
//  Created by Shay Erlichmen on 26/09/12.
//  Copyright (c) 2012 erlichmen. All rights reserved.
//

#import "RadixTreeTesterTests.h"
#import "RadixTree.h"

@interface RadixTreeTesterTests() {
    RadixTree *trie;
}
@end

@implementation RadixTreeTesterTests

- (void)setUp {
    [super setUp];
    
    trie = [[RadixTree alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

-(void)testSearchForPartialParentAndLeafKeyWhenOverlapExists {
    [trie insert:@"abcd" value:@"abcd"];
    [trie insert:@"abce" value:@"abce"];
    
    [self assertArray:[trie searchPrefix:@"abe" recordLimit:10] hasSize:0];
    [self assertArray:[trie searchPrefix:@"abd" recordLimit:10] hasSize:0];
}

-(void)testSearchForLeafNodesWhenOverlapExists {
    [trie insert:@"abcd" value:@"abcd"];
    [trie insert:@"abce" value:@"abce"];
    
    [self assertArray:[trie searchPrefix:@"abcd" recordLimit:10] hasSize:1];
    [self assertArray:[trie searchPrefix:@"abce" recordLimit:10] hasSize:1];
}

-(void)testSearchForStringSmallerThanSharedParentWhenOverlapExists {
    [trie insert:@"abcd" value:@"abcd"];
    [trie insert:@"abce" value:@"abce"];
    
    [self assertArray:[trie searchPrefix:@"ab" recordLimit:10] hasSize:2];
    [self assertArray:[trie searchPrefix:@"a" recordLimit:10] hasSize:2];
}

-(void)testSearchForStringEqualToSharedParentWhenOverlapExists {
    [trie insert:@"abcd" value:@"abcd"];
    [trie insert:@"abce" value:@"abce"];
    
    [self assertArray:[trie searchPrefix:@"abc" recordLimit:10] hasSize:2];
}

-(void)testInsert {
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"bat" value:@"bat"];
    [trie insert:@"ape" value:@"ape"];
    [trie insert:@"bath" value:@"bath"];
    [trie insert:@"banana" value:@"banana"];
    
    STAssertEqualObjects([trie find:@"apple"], @"apple", @"");
    STAssertEqualObjects([trie find:@"bat"], @"bat", @"");
    STAssertEqualObjects([trie find:@"ape"], @"ape", @"");
    STAssertEqualObjects([trie find:@"bath"], @"bath", @"");
    STAssertEqualObjects([trie find:@"banana"], @"banana", @"");
}

-(void)testInsertExistingUnrealNodeConvertsItToReal {
    [trie insert:@"applepie" value:@"applepie"];
    [trie insert:@"applecrisp" value:@"applecrisp"];
    
    STAssertFalse([trie contains:@"apple"], @"");
    
    [trie insert:@"apple" value:@"apple"];
    
    STAssertTrue([trie contains:@"apple"], @"");
}

-(void)testDuplicatesNotAllowed {
    [trie insert:@"apple" value:@"apple"];
    
    STAssertTrue([trie insert:@"apple" value:@"apple2"], @"Duplicate should not have been allowed");
}

-(void)testInsertWithRepeatingPatternsInKey {
    [trie insert:@"xbox 360" value:@"xbox 360"];
    [trie insert:@"xbox" value:@"xbox"];
    [trie insert:@"xbox 360 games" value:@"xbox 360 games"];
    [trie insert:@"xbox games" value:@"xbox games"];
    [trie insert:@"xbox xbox 360" value:@"xbox xbox 360"];
    [trie insert:@"xbox xbox" value:@"xbox xbox"];
    [trie insert:@"xbox 360 xbox games" value:@"xbox 360 xbox games"];
    [trie insert:@"xbox games 360" value:@"xbox games 360"];
    [trie insert:@"xbox 360 360" value:@"xbox 360 360"];
    [trie insert:@"xbox 360 xbox 360" value:@"xbox 360 xbox 360"];
    [trie insert:@"360 xbox games 360" value:@"360 xbox games 360"];
    [trie insert:@"xbox xbox 361" value:@"xbox xbox 361"];

    STAssertTrue(trie.count == 12, @"");
}

-(void)testDeleteNodeWithNoChildren {
    [trie insert:@"apple" value:@"apple"];
    STAssertTrue([trie delete:@"apple"], @"");
}

-(void)testDeleteNodeWithOneChild {
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"applepie" value:@"applepie"];
    STAssertTrue([trie delete:@"apple"], @"");
    STAssertTrue([trie contains:@"applepie"], @"");
    STAssertFalse([trie contains:@"apple" ], @"");
}

-(void)testDeleteNodeWithMultipleChildren {
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"applepie" value:@"applepie"];
    [trie insert:@"applecrisp" value:@"applecrisp"];
    STAssertTrue([trie delete:@"apple"], @"");
    STAssertTrue([trie contains:@"applepie"], @"");
    STAssertTrue([trie contains:@"applecrisp"], @"");
    STAssertFalse([trie contains:@"apple"], @"");
}

-(void)testCantDeleteSomethingThatDoesntExist {
    STAssertFalse([trie delete:@"apple"], @"");
}

-(void)testCantDeleteSomethingThatWasAlreadyDeleted {
    [trie insert:@"apple" value:@"apple"];
    [trie delete:@"apple"];
    STAssertFalse([trie delete:@"apple"], @"");
}

-(void)testChildrenNotAffectedWhenOneIsDeleted {
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"appleshack" value:@"appleshack"];
    [trie insert:@"applepie" value:@"applepie"];
    [trie insert:@"ape" value:@"ape"];
    
    [trie delete:@"apple"];
    
    STAssertTrue([trie contains:@"appleshack"], @"");
    STAssertTrue([trie contains:@"applepie"], @"");
    STAssertTrue([trie contains:@"ape"], @"");
    STAssertFalse([trie contains:@"apple"], @"");
}

-(void)testSiblingsNotAffectedWhenOneIsDeleted {
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"ball" value:@"ball"];
    
    [trie delete:@"apple"];
    
    STAssertTrue([trie contains:@"ball"], @"");
}

-(void)testCantDeleteUnrealNode {
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"ape" value:@"ape"];
    
    STAssertFalse([trie delete:@"ap"], @"");
}

-(void)testCantFindRootNode {
    STAssertNil([trie find:@""], @"");
}

-(void)testFindSimpleInsert {
    [trie insert:@"apple" value:@"apple"];
    STAssertNotNil([trie find:@"apple"], @"");
}

-(void)testContainsSimpleInsert {
    [trie insert:@"apple" value:@"apple"];
    STAssertTrue([trie contains:@"apple"], @"");
}

-(void)testFindChildInsert {
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"ape" value:@"ape"];
    [trie insert:@"appletree" value:@"appletree"];
    [trie insert:@"appleshackcream" value:@"appleshackcream"];
    STAssertNotNil([trie find:@"appletree"], @"");
    STAssertNotNil([trie find:@"appleshackcream"], @"");
    STAssertTrue([trie contains:@"ape"], @"");
}

-(void)testContainsChildInsert {
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"ape" value:@"ape"];
    [trie insert:@"appletree" value:@"appletree"];
    [trie insert:@"appleshackcream" value:@"appleshackcream"];
    STAssertTrue([trie contains:@"appletree"], @"");
    STAssertTrue([trie contains:@"appleshackcream"], @"");
    STAssertTrue([trie contains:@"ape"], @"");
}

-(void)testCantFindNonexistantNode {
    STAssertNil([trie find:@"apple"], @"");
}


-(void)testDoesntContainNonexistantNode {
    STAssertFalse([trie contains:@"apple"], @"");
}

-(void)testCantFindUnrealNode {
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"ape" value:@"ape"];
    STAssertNil([trie find:@"ap"], @"");
}

-(void)testDoesntContainUnrealNode {
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"ape" value:@"ape"];
    STAssertFalse([trie contains:@"ap"], @"");
}

-(void)testSearchPrefix_LimitGreaterThanPossibleResults {
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"appleshack" value:@"appleshack"];
    [trie insert:@"appleshackcream" value:@"appleshackcream"];
    [trie insert:@"applepie" value:@"applepie"];
    [trie insert:@"ape" value:@"ape"];
    
    NSArray *result = [trie searchPrefix:@"app" recordLimit:10];
    [self assertArray:result hasSize:4];
    
    STAssertTrue([result indexOfObject:@"appleshack"] != NSNotFound, @"");
    STAssertTrue([result indexOfObject:@"appleshackcream"] != NSNotFound, @"");
    STAssertTrue([result indexOfObject:@"applepie"] != NSNotFound, @"");
    STAssertTrue([result indexOfObject:@"apple"] != NSNotFound, @"");
}

-(void)testSearchPrefix_LimitLessThanPossibleResults {
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"appleshack" value:@"appleshack"];
    [trie insert:@"appleshackcream" value:@"appleshackcream"];
    [trie insert:@"applepie" value:@"applepie"];
    [trie insert:@"ape" value:@"ape"];
    
    NSArray *result = [trie searchPrefix:@"appl" recordLimit:3];
    [self assertArray:result hasSize:3];
    
    STAssertTrue([result indexOfObject:@"appleshack"] !=  NSNotFound, @"");
    STAssertTrue([result indexOfObject:@"applepie"] !=  NSNotFound, @"");
    STAssertTrue([result indexOfObject:@"apple"] != NSNotFound, @"");
}

-(void)testcount {
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"appleshack" value:@"appleshack"];
    [trie insert:@"appleshackcream" value:@"appleshackcream"];
    [trie insert:@"applepie" value:@"applepie"];
    [trie insert:@"ape" value:@"ape"];
    
    STAssertTrue(trie.count == 5, @"");
}

-(void)testDeleteReducesSize {
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"appleshack" value:@"appleshack"];
    
    [trie delete:@"appleshack"];
    
    STAssertTrue(trie.count == 1, @"");
}

- (void)assertArray:(NSArray *)results hasSize:(NSUInteger)size
{
    STAssertTrue([results count] == size, @"");
}

- (void)testFindWithVariousValuesForSingleKey
{
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"apple" value:@"pie"];
    [self assertArray:[trie find:@"apple"] hasSize:2];
}

- (void)testPrefixWithVariousValuesForSingleKey
{
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"apple" value:@"pie"];
    [self assertArray:[trie searchPrefix:@"ap" recordLimit:10] hasSize:2];
}

-(void)testComplete {
    [trie insert:@"apple" value:@"apple"];
    [trie insert:@"appleshack" value:@"appleshack"];
    [trie insert:@"applepie" value:@"applepie"];
    [trie insert:@"applegold" value:@"applegold"];
    [trie insert:@"applegood" value:@"applegood"];
    
    STAssertEqualObjects(@"", [trie complete:@"z"], @"");
    STAssertEqualObjects(@"apple", [trie complete:@"a"], @"");
    STAssertEqualObjects(@"apple", [trie complete:@"app"], @"");
    STAssertEqualObjects(@"appleshack", [trie complete:@"apples"], @"");
    STAssertEqualObjects(@"applego", [trie complete:@"appleg"], @"");
}
@end
