//
//  ViewController.m
//  CollectionViewClassify
//
//  Created by Mac on 2021/3/23.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import "CollectionHeadView.h"

static float const kCollectionViewToLeftMargin                = 15;
static float const kCollectionViewToRightMargin               = 15;
static float const kCellBtnCenterToBorderMargin               = 18;
static float const kCollectionViewCellsHorizonMargin          = 12;
static float const kCollectionViewCellHeight                  = 30;

typedef void(^ISLimitWidth)(BOOL yesORNo, id data);

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,  CollectionHeadViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *contView;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong) NSMutableArray *fieldsArray;
@property (nonatomic, strong) NSMutableArray *turnsArray;
@property (nonatomic, strong) NSMutableArray *phasesArray;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableArray *fieldsSelectArray;
@property (nonatomic, strong) NSMutableArray *turnsSelectArray;
@property (nonatomic, strong) NSMutableArray *phasesSelectArray;

@property (nonatomic, strong) NSArray *imageArr;

@property (nonatomic, strong) NSArray *rowsCountPerSection;
@property (nonatomic, strong) NSMutableArray *collectionHeaderMoreBtnHideBoolArray;
@property (nonatomic, strong) NSArray *cellsCountArrayPerRowInSections;
@property (nonatomic, strong) NSMutableArray *firstRowCellCountArray;
@property (nonatomic, strong) NSMutableArray   *expandSectionArray;
@end

static NSString * const cellId = @"CollectionViewCell";
static NSString * const headViewId = @"CollectionHeadView";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addCollectionView];
}

- (void)addCollectionView {
    
    UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.allowsMultipleSelection = YES;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.alwaysBounceVertical = YES;
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:cellId];
    [self.collectionView registerClass:[CollectionHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headViewId];
    
    UIView *contView = [[UIView alloc] init];
    contView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contView];
    self.contView = contView;
    [self.contView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(70);
    }];
    
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton setTitle:@"保存" forState:UIControlStateNormal];
    [finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    finishButton.titleLabel.font = [UIFont systemFontOfSize:16];
    finishButton.backgroundColor = RGB_COLOR(@"#505866", 1.0);
    finishButton.layer.cornerRadius = 2.0;
    finishButton.layer.masksToBounds = YES;
    [finishButton addTarget:self action:@selector(onClickFinish:) forControlEvents:UIControlEventTouchUpInside];
    [self.contView addSubview:finishButton];
    self.finishButton = finishButton;
    [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contView).offset(15);
        make.right.equalTo(self.contView).offset(-15);
        make.top.equalTo(self.contView).offset(13);
        make.bottom.equalTo(self.contView).offset(-13);
    }];
    
    self.dataArray = [NSMutableArray arrayWithObjects:self.fieldsArray,self.turnsArray,self.phasesArray,nil];
    [self defaultRowCount:2];
    [self.collectionView reloadData];
}

- (void)defaultRowCount:(NSUInteger)rowCount {
    [self.rowsCountPerSection enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj integerValue] > rowCount) {
            [self.collectionHeaderMoreBtnHideBoolArray replaceObjectAtIndex:idx withObject:@NO];
        }
        else {
            [self.collectionHeaderMoreBtnHideBoolArray replaceObjectAtIndex:idx withObject:@YES];
        }
    }];
    
    [self.cellsCountArrayPerRowInSections enumerateObjectsUsingBlock:^(id  _Nonnull cellsCountArrayPerRow, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger __block sum = 0;
        [cellsCountArrayPerRow enumerateObjectsUsingBlock:^(NSNumber * _Nonnull cellsCount, NSUInteger cellsCountArrayPerRowIdx, BOOL * _Nonnull stop) {
            if (cellsCountArrayPerRowIdx < rowCount) {
                sum += [cellsCount integerValue];
            }
            else {
                *stop = YES;
                return;
            }
        }];
        [self.firstRowCellCountArray replaceObjectAtIndex:idx withObject:@(sum)];
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self sections].count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger filterSection = [[self sections][section] integerValue];
    switch (filterSection) {
        case FilterInvestorAuthSectionField: {
            for (NSNumber *i in self.expandSectionArray) {
                if (section == [i integerValue]) {
                    return self.fieldsArray.count;
                }
            }
            if (self.dataArray.count > 0) {
                return [self.firstRowCellCountArray[section] integerValue];
            }
            return 0;
        } break;
        case FilterInvestorAuthTurn: {
            for (NSNumber *i in self.expandSectionArray) {
                if (section == [i integerValue]) {
                    return self.turnsArray.count;
                }
            }
            if (self.dataArray.count > 0) {
                return [self.firstRowCellCountArray[section] integerValue];
            }
            return 0;
        } break;
        case FilterInvestorAuthPhase: {
            for (NSNumber *i in self.expandSectionArray) {
                if (section == [i integerValue]) {
                    return self.phasesArray.count;
                }
            }
            if (self.dataArray.count > 0) {
                return [self.firstRowCellCountArray[section] integerValue];
            }
            return 0;
        } break;
        default: {
            return 0;
        } break;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger filterSection = [[self sections][indexPath.section] integerValue];
    if (filterSection == FilterInvestorAuthSectionField) {
        CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
        NSDictionary *dict = self.fieldsArray[indexPath.item];
        cell.dict = dict;
        return cell;
    }
    else if (filterSection == FilterInvestorAuthTurn) {
        CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
        NSDictionary *dict = self.turnsArray[indexPath.item];
        cell.dict = dict;
        return cell;
    }
    else if (filterSection == FilterInvestorAuthPhase) {
        CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
        NSDictionary *dict = self.phasesArray[indexPath.item];
        cell.dict = dict;
        return cell;
    }
    else {
        return nil;
    }
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger filterSection = [[self sections][indexPath.section] integerValue];
    if (filterSection == FilterInvestorAuthSectionField) {
        if (![self.fieldsSelectArray containsObject:self.fieldsArray[indexPath.item]]) {
            [self.fieldsSelectArray addObject:[self.fieldsArray objectAtIndex:indexPath.item]];
        }
    }
    else if (filterSection == FilterInvestorAuthTurn) {
        if (![self.turnsSelectArray containsObject:self.turnsArray[indexPath.item]]) {
            [self.turnsSelectArray addObject:[self.turnsArray objectAtIndex:indexPath.row]];
        }
    }
    else if (filterSection == FilterInvestorAuthPhase) {
        if (![self.phasesSelectArray containsObject:self.phasesArray[indexPath.item]]) {
            [self.phasesSelectArray addObject:[self.phasesArray objectAtIndex:indexPath.item]];
        }
    }
    else {}
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger filterSection = [[self sections][indexPath.section] integerValue];
    if (filterSection == FilterInvestorAuthSectionField) {
        if ([self.fieldsSelectArray containsObject:self.fieldsArray[indexPath.item]]) {
            [self.fieldsSelectArray removeObject:self.fieldsArray[indexPath.row]];
        }
    }
    else if (filterSection == FilterInvestorAuthTurn) {
        if ([self.turnsSelectArray containsObject:self.turnsArray[indexPath.item]]) {
            [self.turnsSelectArray removeObject:self.turnsArray[indexPath.item]];
        }
    }
    else if (filterSection == FilterInvestorAuthPhase) {
        if ([self.phasesSelectArray containsObject:self.phasesArray[indexPath.item]]) {
            [self.phasesSelectArray removeObject:self.phasesArray[indexPath.item]];
        }
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSInteger filterSection = [[self sections][indexPath.section] integerValue];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        CollectionHeadView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headViewId forIndexPath:indexPath];
        if (filterSection == FilterInvestorAuthSectionField) {
            headView.titleLabel.text = @"关注领域";
            headView.imageView.image = [UIImage imageNamed:self.imageArr[filterSection]];
            if (self.dataArray.count > 0) {
                headView.foldButton.hidden = [self.collectionHeaderMoreBtnHideBoolArray[indexPath.section] boolValue];
            }
            headView.delegate = self;
            headView.foldButton.tag = indexPath.section;
            headView.foldButton.selected = NO;
        }
        else if (filterSection == FilterInvestorAuthTurn) {
            headView.titleLabel.text = @"关注轮次";
            headView.imageView.image = [UIImage imageNamed:self.imageArr[filterSection]];
            if (self.dataArray.count > 0) {
                headView.foldButton.hidden = [self.collectionHeaderMoreBtnHideBoolArray[indexPath.section] boolValue];
            }
            headView.delegate = self;
            headView.foldButton.tag = indexPath.section;
            headView.foldButton.selected = NO;
        }
        else if (filterSection == FilterInvestorAuthPhase) {
            headView.titleLabel.text = @"关注阶段";
            headView.imageView.image = [UIImage imageNamed:self.imageArr[filterSection]];
            if (self.dataArray.count > 0) {
                headView.foldButton.hidden = [self.collectionHeaderMoreBtnHideBoolArray[indexPath.section] boolValue];
            }
            headView.delegate = self;
            headView.foldButton.tag = indexPath.section;
            headView.foldButton.selected = NO;
        }
        
        for (NSNumber *i in self.expandSectionArray) {
            if (indexPath.section == [i integerValue]) {
                headView.foldButton.selected = YES;
            }
        }
        return (UICollectionReusableView *)headView;
    }
    else {
        return nil;
    }
}

#pragma mark - UICollectionViewDelegateLeftAlignedLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger filterSection = [[self sections][indexPath.section] integerValue];
    switch (filterSection) {
        case FilterInvestorAuthSectionField: {
            NSDictionary *dict = self.fieldsArray[indexPath.row];
            float cellWidth = [self collectionCellWidthText:dict[@"title"]];
            return CGSizeMake(cellWidth, kCollectionViewCellHeight);
        } break;
        case FilterInvestorAuthTurn: {
            NSDictionary *dict = self.turnsArray[indexPath.row];
            float cellWidth = [self collectionCellWidthText:dict[@"title"]];
            return CGSizeMake(cellWidth, kCollectionViewCellHeight);
        } break;
        case FilterInvestorAuthPhase: {
            NSDictionary *dict = self.phasesArray[indexPath.row];
            float cellWidth = [self collectionCellWidthText:dict[@"title"]];
            return CGSizeMake(cellWidth, kCollectionViewCellHeight);
        } break;
        default: {
            return CGSizeZero;
        } break;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kCollectionViewCellsHorizonMargin;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 35);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(13, 20, 13, 20);
}

#pragma mark - CollectionHeadViewDelegate

- (void)didTapHeadMoreBtnClicked:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        [self.expandSectionArray addObject:@(button.tag)];
    }
    else {
        [self.expandSectionArray removeObject:@(button.tag)];
    }
    NSIndexSet *section = [NSIndexSet indexSetWithIndex:button.tag];
    [self.collectionView reloadSections:section];
}

- (void)onClickFinish:(UIButton *)button {
    if (self.fieldsSelectArray.count == 0) {
        NSLog(@"请选择关注行业");
        return;
    }

    if (self.turnsSelectArray.count == 0) {
        NSLog(@"请选择关注轮次");
        return;
    }

    if (self.phasesSelectArray.count == 0) {
        NSLog(@"请选择关注阶段");
        return;
    }
    NSLog(@"保存");
}

- (NSMutableArray *)firstRowCellCountArray {
    if (!_firstRowCellCountArray) {
        _firstRowCellCountArray = [NSMutableArray arrayWithCapacity:self.dataArray.count];
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray *items = [[NSMutableArray alloc] initWithArray:obj];
            NSUInteger secondRowCellCount = [self firstRowCellCountWithArray:items];
            [self.firstRowCellCountArray addObject:@(secondRowCellCount)];
        }];
    }
    return _firstRowCellCountArray;
}

- (NSArray *)cellsCountArrayPerRowInSections {
    if (!_cellsCountArrayPerRowInSections) {
        _cellsCountArrayPerRowInSections = [[NSArray alloc] init];
        NSMutableArray *cellsCountArrayPerRowInSections = [NSMutableArray array];
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray *items = [[NSMutableArray alloc] initWithArray:obj];
            NSArray *cellsInPerRowWhenLayoutWithArray = [self cellsInPerRowWhenLayoutWithArray:items];
            [cellsCountArrayPerRowInSections addObject:cellsInPerRowWhenLayoutWithArray];
        }];
        _cellsCountArrayPerRowInSections = (NSArray *)cellsCountArrayPerRowInSections;
    }
    return _cellsCountArrayPerRowInSections;
}

- (NSMutableArray *)collectionHeaderMoreBtnHideBoolArray {
    if (!_collectionHeaderMoreBtnHideBoolArray) {
        _collectionHeaderMoreBtnHideBoolArray = [[NSMutableArray alloc] init];
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.collectionHeaderMoreBtnHideBoolArray addObject:@YES];
        }];
    }
    return _collectionHeaderMoreBtnHideBoolArray;
}

- (NSArray *)rowsCountPerSection {
    if (!_rowsCountPerSection) {
        _rowsCountPerSection = [[NSArray alloc] init];
        NSMutableArray *rowsCountPerSection = [NSMutableArray array];
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray *items = [[NSMutableArray alloc] initWithArray:obj];
            NSUInteger secondRowCellCount = [[self cellsInPerRowWhenLayoutWithArray:items] count];
            [rowsCountPerSection addObject:@(secondRowCellCount)];
        }];
        _rowsCountPerSection = (NSArray *)rowsCountPerSection;
    }
    return _rowsCountPerSection;
}

- (NSMutableArray *)cellsInPerRowWhenLayoutWithArray:(NSMutableArray *)array {
    __block NSUInteger secondRowCellCount = 0;
    NSMutableArray *items = [NSMutableArray arrayWithArray:array];
    NSUInteger firstRowCount = [self firstRowCellCountWithArray:items];
    NSMutableArray *cellCount = [NSMutableArray arrayWithObject:@(firstRowCount)];
    for (NSUInteger index = 0; index < [array count]; index++) {
        NSUInteger firstRowCount = [self firstRowCellCountWithArray:items];
        if (items.count != firstRowCount) {
            NSRange range = NSMakeRange(0, firstRowCount);
            [items removeObjectsInRange:range];
            NSUInteger secondRowCount = [self firstRowCellCountWithArray:items];
            secondRowCellCount = secondRowCount;
            [cellCount addObject:@(secondRowCount)];
        }
        else {
            return cellCount;
        }
    }
    return cellCount;
}

- (NSUInteger)firstRowCellCountWithArray:(NSArray *)array {
    CGFloat contentViewWidth = CGRectGetWidth(self.collectionView.frame) - kCollectionViewToLeftMargin - kCollectionViewToRightMargin;
    NSUInteger firstRowCellCount = 0;
    float currentCellWidthSum = 0;
    float currentCellSpace = 0;
    for (int i = 0; i < array.count; i++) {
        NSDictionary *dict = array[i];
        NSString *text = dict[@"title"];
        float cellWidth = [self collectionCellWidthText:text];
        if (cellWidth >= contentViewWidth) {
            return i == 0 ? 1 : firstRowCellCount;
        }
        else {
            currentCellWidthSum += cellWidth;
            if (i == 0) {
                firstRowCellCount++;
                continue;
            }
            currentCellSpace = (contentViewWidth - currentCellWidthSum) / firstRowCellCount;
            if (currentCellSpace <= kCollectionViewCellsHorizonMargin) {
                return firstRowCellCount;
            }
            else {
                firstRowCellCount++;
            }
        }
    }
    return firstRowCellCount;
}

- (float)collectionCellWidthText:(NSString *)text {
    float cellWidth;
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    cellWidth = ceilf(size.width) + kCellBtnCenterToBorderMargin;
    cellWidth = [self cellLimitWidth:cellWidth limitMargin:0 isLimitWidth:nil];
    return cellWidth;
}

- (float)cellLimitWidth:(float)cellWidth limitMargin:(CGFloat)limitMargin isLimitWidth:(ISLimitWidth)isLimitWidth {
    float limitWidth = (CGRectGetWidth(self.collectionView.frame) - kCollectionViewToLeftMargin - kCollectionViewToRightMargin - limitMargin);
    if (cellWidth >= limitWidth) {
        cellWidth = limitWidth;
        isLimitWidth ? isLimitWidth(YES, @(cellWidth)) : nil;
        return cellWidth;
    }
    isLimitWidth ? isLimitWidth(NO, @(cellWidth)) : nil;
    return cellWidth;
}

- (NSArray *)imageArr {
    if (!_imageArr) {
        _imageArr = @[@"Filter_industry",@"Filter_turn",@"Filter_screen"];
    }
    return _imageArr;
}

- (NSMutableArray *)fieldsSelectArray {
    if (!_fieldsSelectArray) {
        _fieldsSelectArray = [NSMutableArray array];
    }
    return _fieldsSelectArray;
}

- (NSMutableArray *)turnsSelectArray {
    if (!_turnsSelectArray) {
        _turnsSelectArray = [NSMutableArray array];
    }
    return _turnsSelectArray;
}

- (NSMutableArray *)phasesSelectArray {
    if (!_phasesSelectArray) {
        _phasesSelectArray = [NSMutableArray array];
    }
    return _phasesSelectArray;
}

- (NSArray *)sections {
    NSMutableArray *newSections = [NSMutableArray array];
    [newSections addObject:@(FilterInvestorAuthSectionField)];
    [newSections addObject:@(FilterInvestorAuthTurn)];
    [newSections addObject:@(FilterInvestorAuthPhase)];
    return [newSections copy];
}

- (NSMutableArray *)expandSectionArray {
    if (!_expandSectionArray) {
        _expandSectionArray = [[NSMutableArray alloc] init];
    }
    return _expandSectionArray;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)fieldsArray {
    if (!_fieldsArray) {
        _fieldsArray = [NSMutableArray arrayWithObjects:@{@"title":@"人工智能"},@{@"title":@"金融"},@{@"title":@"互联网"},
                             @{@"title":@"医疗服务"},@{@"title":@"文化娱乐"},
                             @{@"title":@"生活服务"},@{@"title":@"教育"},@{@"title":@"游戏"},
                             @{@"title":@"电商"},@{@"title":@"旅游"},@{@"title":@"广告营销"},
                             @{@"title":@"餐饮"},@{@"title":@"媒体"},@{@"title":@"企业服务"},
                             @{@"title":@"技术服务"},@{@"title":@"硬件设备"},
                             @{@"title":@"药品器械"},@{@"title":@"电信通讯"},
                             @{@"title":@"半导体"},@{@"title":@"住房装潢"},
                             @{@"title":@"交通出行"},@{@"title":@"购房租房"},
                             @{@"title":@"新能源"},@{@"title":@"传统软件"},
                             @{@"title":@"传统能源"},@{@"title":@"食品饮料烟酒"},
                             @{@"title":@"服装服饰"},@{@"title":@"商业和专业服务"},
                             @{@"title":@"原材料"},@{@"title":@"人力资源与就业服务"},
                             @{@"title":@"交通运输及物流"},@{@"title":@"公用事业"},
                             @{@"title":@"资本品/工业品"},@{@"title":@"机械制造"},nil];
    }
    return _fieldsArray;
}

- (NSMutableArray *)turnsArray {
    if (!_turnsArray) {
        _turnsArray = [NSMutableArray arrayWithObjects:@{@"title":@"天使轮"},@{@"title":@"Pre-A"},@{@"title":@"A轮"},
                             @{@"title":@"B轮"},@{@"title":@"C轮"},
                             @{@"title":@"D轮"},@{@"title":@"E轮"},@{@"title":@"F轮"},
                             @{@"title":@"Pre-IPO"},@{@"title":@"PIPE"},nil];
    }
    return _turnsArray;
}

- (NSMutableArray *)phasesArray {
    if (!_phasesArray) {
        _phasesArray = [NSMutableArray arrayWithObjects:@{@"title":@"天使期"},@{@"title":@"初创期"},@{@"title":@"成长期"},
                             @{@"title":@"成熟期"},nil];
    }
    return _phasesArray;
}

@end
