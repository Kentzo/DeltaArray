#import "DeltaArrays.h"


@interface DeltaArrays (PrivateMethods)

- (NSComparisonResult)compareObject:(id)objectA toObject:(id)objectB;

@end

@implementation DeltaArrays
@synthesize delegate = _delegate;
@synthesize sortDescriptors = _sortDescriptors;

- (id)initWithSortDescriptors:(NSArray *)sortDescriptors {
    if (self == [super init]) {
        self.sortDescriptors = sortDescriptors;
    }
    return self;
}

- (void)dealloc {
    _delegate = nil;
    [_sortDescriptors release];
    [super dealloc];
}

- (NSComparisonResult)compareObject:(id)objectA toObject:(id)objectB {
    NSComparisonResult result = NSOrderedSame;
    for (NSSortDescriptor *descriptor in _sortDescriptors) {
        result = [descriptor compareObject:objectA toObject:objectB];
        if(result != NSOrderedSame) {
            if ([descriptor ascending] == NO) { // If sort isn't ascending, invert result
                result *= -1;
            }
            break;
        }
    }
    return result;
}

- (void)deltaBetweenOldArray:(NSArray *)oldArray andNewArray:(NSArray *)newArray {
    if ([oldArray count] == 0) { // If oldArray is empty than we have to insert all objects from newArray
        for (id object in newArray) {
            if ([_delegate respondsToSelector:@selector(insertNewObject:)]) {
                [_delegate insertNewObject:object];
            }
        }
        return;
    }
    else if ([newArray count] == 0) { // If newArray is empty than we have to delete all objects from oldArray
        for (id object in oldArray) {
            if ([_delegate respondsToSelector:@selector(deleteOldObject:)]) {
                [_delegate deleteOldObject:object];
            }
        }
        return;
    }
    
    NSUInteger old_curpos = 0, old_size = [oldArray count];
    NSUInteger new_curpos = 0, new_size = [newArray count];
    for (;old_curpos<old_size && new_curpos<new_size;) {
        id oldObject = [oldArray objectAtIndex:old_curpos];
        id newObject = [newArray objectAtIndex:new_curpos];
        
        NSComparisonResult result = [self compareObject:oldObject toObject:newObject];
        if (result == NSOrderedAscending) {
            if ([_delegate respondsToSelector:@selector(deleteOldObject:)]) {
                [_delegate deleteOldObject:oldObject];
            }
            ++old_curpos;
        }
        else if (result == NSOrderedSame) {
            if ([_delegate respondsToSelector:@selector(updateObject:withObject:)]) {
                [_delegate updateObject:oldObject withObject:newObject];
            }
            ++old_curpos, ++new_curpos;
        }
        else {
            if ([_delegate respondsToSelector:@selector(insertNewObject:)]) {
                [_delegate insertNewObject:newObject];
            }
            ++new_curpos;
        }
    }
    
    if (old_size < new_size && [_delegate respondsToSelector:@selector(insertObject:)]) {
        for (; new_curpos<new_size; ++new_curpos) {
            if ([_delegate respondsToSelector:@selector(insertNewObject:)]) {
                [_delegate insertNewObject:[newArray objectAtIndex:new_curpos]];
            }
        }
    }
    else if (old_size > new_size && [_delegate respondsToSelector:@selector(deleteObject:)]) {
        for (; old_curpos<old_size; ++old_curpos) {
            if ([_delegate respondsToSelector:@selector(deleteOldObject:)]) {
                [_delegate deleteOldObject:[oldArray objectAtIndex:old_curpos]];
            }
        }
    }
}

@end
