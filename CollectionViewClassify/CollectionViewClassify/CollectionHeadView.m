//
//  CollectionHeadView.m
//  CollectionViewClassify
//
//  Created by Mac on 2021/3/25.
//

#import "CollectionHeadView.h"

static float const kImageToTextMargin = 5;
static float const kFoldButtonWidth  = 72;

@interface CollectionHeadView ()

@end

@implementation CollectionHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        self.imageView = imageView;
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(13, 13));
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = RGB_COLOR(@"#2F3E4D", 1.0);
        titleLabel.font = [UIFont systemFontOfSize:13.0];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imageView.mas_right).offset(5);
            make.centerY.equalTo(self.imageView);
        }];
        
        UIButton *foldButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [foldButton setTitle:@"全部" forState:UIControlStateNormal];
        [foldButton setTitle:@"收起" forState:UIControlStateSelected];
        [foldButton setTitleColor:RGB_COLOR(@"#515C66", 1.0) forState:UIControlStateNormal];
        [foldButton setTitleColor:RGB_COLOR(@"#515C66", 1.0) forState:UIControlStateSelected];
        foldButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [foldButton setImage:[UIImage imageNamed:@"Filter_spread"] forState:UIControlStateNormal];
        [foldButton setImage:[UIImage imageNamed:@"Filter_switch"] forState:UIControlStateSelected];
        foldButton.titleEdgeInsets = UIEdgeInsetsMake(0, -20 -kImageToTextMargin, 0, 20);
        foldButton.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, -20);
        foldButton.frame = CGRectMake(ScreenWidth - 6 - kFoldButtonWidth, 0, kFoldButtonWidth, 35);
        foldButton.hidden = YES;
//        foldButton.backgroundColor = [UIColor redColor];
        [foldButton addTarget:self action:@selector(onClickFold:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:foldButton];
        self.foldButton = foldButton;
        
    }
    return self;
}

- (void)onClickFold:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(didTapHeadMoreBtnClicked:)]) {
        [self.delegate didTapHeadMoreBtnClicked:self.foldButton];
    }
}

@end
