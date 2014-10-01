/**
 * A simple standard implementation for a {@link visitor}.
 * 
 * @author Dennis Heidsiek 
 * @param <T,R>
 */

#import "Visitor.h"

@interface Visitor() {
    VisitBlock _visitBlock;
}

@property (nonatomic, strong) NSMutableArray *visitorResults;

@end

@implementation Visitor

-(id)initWithBlock:(VisitBlock)visitBlock {
    self = [super init];
    
    if (self) {
        _visitBlock = visitBlock;
    }
    
    return self;
}

-(void)visit:(NSString *)key parent:(RadixTreeNode *)parent node:(RadixTreeNode *)node {
    if (_visitBlock) {
        _visitBlock(self, key, parent, node);
    }
}

- (void)addResult:(id)result
{
    [self.visitorResults addObject:result];
}

- (void)setResults:(NSArray *)results
{
    _visitorResults = [results mutableCopy];
}

- (NSMutableArray *)results
{
    if ([self.visitorResults count] == 0)
    {
        return nil;
    }
    else
    {
        return [self.visitorResults mutableCopy];
    }
}

- (NSMutableArray *)visitorResults
{
    if (!_visitorResults)
    {
        _visitorResults = [NSMutableArray new];
    }
    return _visitorResults;
}

@end
