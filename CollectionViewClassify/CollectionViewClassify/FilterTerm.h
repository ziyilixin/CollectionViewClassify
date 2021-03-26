//
//  FilterTerm.h
//  CollectionViewClassify
//
//  Created by Mac on 2021/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilterTerm : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL isSelect;

- (instancetype)initWithFilterTermDictionary:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
