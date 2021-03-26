//
//  CollectionViewCell.h
//  CollectionViewClassify
//
//  Created by Mac on 2021/3/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FilterTerm;
@interface CollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) FilterTerm *term;
@end

NS_ASSUME_NONNULL_END
