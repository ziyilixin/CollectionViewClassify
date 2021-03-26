//
//  CollectionViewCell.m
//  CollectionViewClassify
//
//  Created by Mac on 2021/3/23.
//

#import "CollectionViewCell.h"
#import "FilterTerm.h"

@interface CollectionViewCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.layer.cornerRadius = 2.0;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = RGB_COLOR(@"#EBEDF0", 1.0).CGColor;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = RGB_COLOR(@"#8E9499", 1.0);
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
    }
    return self;
}

- (void)setTerm:(FilterTerm *)term {
    _term = term;
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@",_term.title];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.backgroundColor = RGB_COLOR(@"#505866", 1.0);
        self.titleLabel.textColor = [UIColor whiteColor];
    }
    else {
        self.backgroundColor = [UIColor whiteColor];
        self.titleLabel.textColor = RGB_COLOR(@"#8E9499", 1.0);
    }
}

@end
