//
//  CollectionHeadView.h
//  CollectionViewClassify
//
//  Created by Mac on 2021/3/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CollectionHeadView;
@protocol CollectionHeadViewDelegate <NSObject>
- (void)didTapHeadMoreBtnClicked:(UIButton *)button;
@end

@interface CollectionHeadView : UICollectionReusableView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *foldButton;
@property (nonatomic, weak) id <CollectionHeadViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
