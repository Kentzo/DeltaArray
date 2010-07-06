#import <Foundation/Foundation.h>


@protocol DeltaArraysDelegate

@optional
- (void)deleteOldObject:(id)object;
- (void)insertNewObject:(id)object;
- (void)updateObject:(id)oldObject withObject:(id)newObject;

@end


@interface DeltaArrays : NSObject {
    NSObject<DeltaArraysDelegate> *_delegate;
    NSArray *_sortDescriptors;
}

@property (nonatomic, assign) NSObject<DeltaArraysDelegate> *delegate;
@property (nonatomic, retain) NSArray *sortDescriptors;

- (id)initWithSortDescriptors:(NSArray *)sortDescriptors;
- (void)deltaBetweenOldArray:(NSArray *)aArray andNewArray:(NSArray *)bArray;

@end
