//
//  FilterTerm.m
//  CollectionViewClassify
//
//  Created by Mac on 2021/3/26.
//

#import "FilterTerm.h"

@implementation FilterTerm

- (instancetype)initWithFilterTermDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _title = [dict valueForKey:@"title"];
    }
    return self;
}

@end
