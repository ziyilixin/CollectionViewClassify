//
//  ViewController.m
//  CollectionViewClassify
//
//  Created by Mac on 2021/3/23.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import "CollectionHeadView.h"
#import "FilterTerm.h"

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
    [finishButton setTitle:@"??????" forState:UIControlStateNormal];
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
    
    NSMutableArray *fieldsArray = [NSMutableArray array];
    for (NSDictionary *dict in self.fieldsArray) {
        FilterTerm *term = [[FilterTerm alloc] initWithFilterTermDictionary:dict];
        [fieldsArray addObject:term];
    }
    self.fieldsArray = fieldsArray;
    
    NSMutableArray *turnsArray = [NSMutableArray array];
    for (NSDictionary *dict in self.turnsArray) {
        FilterTerm *term = [[FilterTerm alloc] initWithFilterTermDictionary:dict];
        [turnsArray addObject:term];
    }
    self.turnsArray = turnsArray;
    
    NSMutableArray *phasesArray = [NSMutableArray array];
    for (NSDictionary *dict in self.phasesArray) {
        FilterTerm *term = [[FilterTerm alloc] initWithFilterTermDictionary:dict];
        [phasesArray addObject:term];
    }
    self.phasesArray = phasesArray;
    
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
        FilterTerm *term = self.fieldsArray[indexPath.item];
        cell.term = term;
        if (term.isSelect) {
            [cell setSelected:YES];
            [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
        return cell;
    }
    else if (filterSection == FilterInvestorAuthTurn) {
        CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
        FilterTerm *term = self.turnsArray[indexPath.item];
        cell.term = term;
        if (term.isSelect) {
            [cell setSelected:YES];
            [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
        return cell;
    }
    else if (filterSection == FilterInvestorAuthPhase) {
        CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
        FilterTerm *term = self.phasesArray[indexPath.item];
        cell.term = term;
        if (term.isSelect) {
            [cell setSelected:YES];
            [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
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
            FilterTerm *term = self.fieldsArray[indexPath.row];
            term.isSelect = YES;
            [self.fieldsSelectArray addObject:self.fieldsArray[indexPath.row]];
        }
    }
    else if (filterSection == FilterInvestorAuthTurn) {
        if (![self.turnsSelectArray containsObject:self.turnsArray[indexPath.item]]) {
            FilterTerm *term = self.turnsArray[indexPath.row];
            term.isSelect = YES;
            [self.turnsSelectArray addObject:self.turnsArray[indexPath.row]];
        }
    }
    else if (filterSection == FilterInvestorAuthPhase) {
        if (![self.phasesSelectArray containsObject:self.phasesArray[indexPath.item]]) {
            FilterTerm *term = self.phasesArray[indexPath.row];
            term.isSelect = YES;
            [self.phasesSelectArray addObject:self.phasesArray[indexPath.row]];
        }
    }
    else {}
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger filterSection = [[self sections][indexPath.section] integerValue];
    if (filterSection == FilterInvestorAuthSectionField) {
        if ([self.fieldsSelectArray containsObject:self.fieldsArray[indexPath.item]]) {
            FilterTerm *term = self.fieldsArray[indexPath.row];
            term.isSelect = NO;
            [self.fieldsSelectArray removeObject:self.fieldsArray[indexPath.row]];
        }
    }
    else if (filterSection == FilterInvestorAuthTurn) {
        if ([self.turnsSelectArray containsObject:self.turnsArray[indexPath.item]]) {
            FilterTerm *term = self.turnsArray[indexPath.row];
            term.isSelect = NO;
            [self.turnsSelectArray removeObject:self.turnsArray[indexPath.row]];
        }
    }
    else if (filterSection == FilterInvestorAuthPhase) {
        if ([self.phasesSelectArray containsObject:self.phasesArray[indexPath.item]]) {
            FilterTerm *term = self.phasesArray[indexPath.row];
            term.isSelect = NO;
            [self.phasesSelectArray removeObject:self.phasesArray[indexPath.item]];
        }
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSInteger filterSection = [[self sections][indexPath.section] integerValue];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        CollectionHeadView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headViewId forIndexPath:indexPath];
        if (filterSection == FilterInvestorAuthSectionField) {
            headView.titleLabel.text = @"????????????";
            headView.imageView.image = [UIImage imageNamed:self.imageArr[filterSection]];
            if (self.dataArray.count > 0) {
                headView.foldButton.hidden = [self.collectionHeaderMoreBtnHideBoolArray[indexPath.section] boolValue];
            }
            headView.delegate = self;
            headView.foldButton.tag = indexPath.section;
            headView.foldButton.selected = NO;
        }
        else if (filterSection == FilterInvestorAuthTurn) {
            headView.titleLabel.text = @"????????????";
            headView.imageView.image = [UIImage imageNamed:self.imageArr[filterSection]];
            if (self.dataArray.count > 0) {
                headView.foldButton.hidden = [self.collectionHeaderMoreBtnHideBoolArray[indexPath.section] boolValue];
            }
            headView.delegate = self;
            headView.foldButton.tag = indexPath.section;
            headView.foldButton.selected = NO;
        }
        else if (filterSection == FilterInvestorAuthPhase) {
            headView.titleLabel.text = @"????????????";
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
            FilterTerm *term = self.fieldsArray[indexPath.row];
            float cellWidth = [self collectionCellWidthText:term.title];
            return CGSizeMake(cellWidth, kCollectionViewCellHeight);
        } break;
        case FilterInvestorAuthTurn: {
            FilterTerm *term = self.turnsArray[indexPath.row];
            float cellWidth = [self collectionCellWidthText:term.title];
            return CGSizeMake(cellWidth, kCollectionViewCellHeight);
        } break;
        case FilterInvestorAuthPhase: {
            FilterTerm *term = self.phasesArray[indexPath.row];
            float cellWidth = [self collectionCellWidthText:term.title];
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
        NSLog(@"?????????????????????");
        return;
    }

    if (self.turnsSelectArray.count == 0) {
        NSLog(@"?????????????????????");
        return;
    }

    if (self.phasesSelectArray.count == 0) {
        NSLog(@"?????????????????????");
        return;
    }
    NSLog(@"??????");
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
        FilterTerm *term = array[i];
        NSString *text = term.title;
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
        _fieldsArray = [NSMutableArray arrayWithObjects:@{@"title":@"????????????"},@{@"title":@"??????"},
                             @{@"title":@"?????????"},@{@"title":@"????????????"},
                             @{@"title":@"????????????"},@{@"title":@"????????????"},
                             @{@"title":@"??????"},@{@"title":@"??????"},
                             @{@"title":@"??????"},@{@"title":@"??????"},
                             @{@"title":@"????????????"},@{@"title":@"??????"},
                             @{@"title":@"??????"},@{@"title":@"????????????"},
                             @{@"title":@"????????????"},@{@"title":@"????????????"},
                             @{@"title":@"????????????"},@{@"title":@"????????????"},
                             @{@"title":@"?????????"},@{@"title":@"????????????"},
                             @{@"title":@"????????????"},@{@"title":@"????????????"},
                             @{@"title":@"?????????"},@{@"title":@"????????????"},
                             @{@"title":@"????????????"},@{@"title":@"??????????????????"},
                             @{@"title":@"????????????"},@{@"title":@"?????????????????????"},
                             @{@"title":@"?????????"},@{@"title":@"???????????????????????????"},
                             @{@"title":@"?????????????????????"},@{@"title":@"????????????"},
                             @{@"title":@"?????????/?????????"},@{@"title":@"????????????"},nil];
    }
    return _fieldsArray;
}

- (NSMutableArray *)turnsArray {
    if (!_turnsArray) {
        _turnsArray = [NSMutableArray arrayWithObjects:@{@"title":@"?????????"},@{@"title":@"Pre-A"},
                             @{@"title":@"A???"},@{@"title":@"B???"},@{@"title":@"C???"},
                             @{@"title":@"D???"},@{@"title":@"E???"},@{@"title":@"F???"},
                             @{@"title":@"Pre-IPO"},@{@"title":@"PIPE"},nil];
    }
    return _turnsArray;
}

- (NSMutableArray *)phasesArray {
    if (!_phasesArray) {
        _phasesArray = [NSMutableArray arrayWithObjects:@{@"title":@"?????????"},@{@"title":@"?????????"},
                             @{@"title":@"?????????"},@{@"title":@"?????????"},nil];
    }
    return _phasesArray;
}

@end
