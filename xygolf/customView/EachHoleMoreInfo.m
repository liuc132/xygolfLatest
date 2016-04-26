//
//  EachHoleMoreInfo.m
//  xygolf
//
//  Created by LiuC on 16/4/17.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import "EachHoleMoreInfo.h"

typedef void (^CustomAnimationBlock)(void);
typedef void (^CustomCompletionAnimationBlock)(BOOL finished);

@interface EachHoleMoreInfo ()<UIGestureRecognizerDelegate>

//@property (nonatomic, assign) BOOL  moreHandleEnable;

@property (strong, nonatomic) UIView    *moreHanleView;

@end

@implementation EachHoleMoreInfo
{
    UIView *contentView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
//    self.moreHandleEnable = NO;
    //
    if (!(self = [super initWithFrame:frame])) {
        return self;
    }
    //初始化构建视图
    [self internalCustomDetailInfo];
    
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"bounds"]) {
        contentView.frame = self.bounds;
    }
}

/**
 *  根据需要的视图数量来绘制cell的数量
 */
- (void)internalCustomDetailInfo
{
    //add size observer
    [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
    //
    [self layoutIfNeeded];
    //add a contentview for auto layout
    contentView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, self.frame.size.width - 10, self.frame.size.height-2)];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.layer.cornerRadius = 5.0;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:1.0];
    
    //create the first table cell
    UITableViewCell *firstTableCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, 44)];
    [firstTableCell setFrame:CGRectMake(0, 0, contentView.frame.size.width, 44)];
    firstTableCell.imageView.image = [UIImage imageNamed:@"vipGroup_mapDis.png"];
    firstTableCell.textLabel.text = @"严重拥堵";
    firstTableCell.textLabel.textColor = [UIColor colorWithRed:239/255.0 green:75/255.0 blue:75/255.0 alpha:1.0];
    UIButton *firstmessgeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [firstmessgeButton setImage:[UIImage imageNamed:@"messege_mapData.png"] forState:UIControlStateNormal];
    firstTableCell.accessoryView = firstmessgeButton;
    
    [firstTableCell setSelected:NO animated:YES];
    //为tablecell 添加手势
    UITapGestureRecognizer *firstCellGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(firstCellGestureAction:)];
    firstCellGesture.numberOfTapsRequired = 1;
    firstCellGesture.delegate = self;
    [firstTableCell addGestureRecognizer:firstCellGesture];
    
    
    [contentView addSubview:firstTableCell];
    firstTableCell.backgroundColor = [UIColor whiteColor];
    //first separator view
    UIView *fhseparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, contentView.frame.size.width, 1)];
    [contentView addSubview:fhseparatorView];
    fhseparatorView.backgroundColor = [UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:1.0];

    //create the second table cell
    UITableViewCell *secondTableCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 45, contentView.frame.size.width, 44)];
    [secondTableCell setFrame:CGRectMake(0, 45, contentView.frame.size.width, 44)];
    [contentView addSubview:secondTableCell];
    secondTableCell.imageView.image = [UIImage imageNamed:@"trainGroup_mapDis.png"];
    secondTableCell.backgroundColor = [UIColor whiteColor];
//    secondTableCell.translatesAutoresizingMaskIntoConstraints = NO;
    secondTableCell.textLabel.textColor = [UIColor colorWithRed:1.0 green:180/255.0 blue:0.0 alpha:1.0];
    secondTableCell.textLabel.text = @"缓慢";
    //
    UIButton *secondmessgeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [secondmessgeButton setImage:[UIImage imageNamed:@"messege_mapData.png"] forState:UIControlStateNormal];
    secondTableCell.accessoryView = secondmessgeButton;
    
    [secondTableCell setSelected:NO animated:YES];
    //为tablecell 添加手势
    UITapGestureRecognizer *secondCellGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(secondCellGestureAction:)];
    secondCellGesture.numberOfTapsRequired = 1;
    secondCellGesture.delegate = self;
    [secondTableCell addGestureRecognizer:secondCellGesture];
    
    //second separator view
    UIView *shseparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 90, contentView.frame.size.width, 1)];
    [contentView addSubview:shseparatorView];
    shseparatorView.backgroundColor = [UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:1.0];
    
    //create the third table cell
    UITableViewCell *thirdTableCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 45, contentView.frame.size.width, 44)];
    [thirdTableCell setFrame:CGRectMake(0, 90, contentView.frame.size.width, 44)];
    [contentView addSubview:thirdTableCell];
    thirdTableCell.imageView.image = [UIImage imageNamed:@"tour_mapDis.png"];
    thirdTableCell.backgroundColor = [UIColor whiteColor];
    thirdTableCell.textLabel.textColor = [UIColor colorWithRed:48/255.0 green:193/255.0 blue:124/255.0 alpha:1.0];
    thirdTableCell.textLabel.text = @"正常";
    //
    UIButton *thirdmessgeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [thirdmessgeButton setImage:[UIImage imageNamed:@"messege_mapData.png"] forState:UIControlStateNormal];
    thirdTableCell.accessoryView = thirdmessgeButton;
    
    [thirdTableCell setSelected:NO animated:YES];
    //为tablecell 添加手势
    UITapGestureRecognizer *thirdCellGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thirdCellGestureAction:)];
    thirdCellGesture.numberOfTapsRequired = 1;
    thirdCellGesture.delegate = self;
    [thirdTableCell addGestureRecognizer:thirdCellGesture];
    
    
    
    
    
}

- (void)addMoreHandeViewIntoContent
{
    //判断是否要添加更多的按钮
    CGFloat offseteachButton = (self.frame.size.width - 26 - 32*7)/7 + 40;
//    CGFloat originY = thirdTableCell.frame.origin.y + thirdTableCell.frame.size.height + 11;
    CGFloat originY = contentView.frame.origin.y + contentView.frame.size.height - 50;
    
    _moreHanleView = [[UIView alloc] initWithFrame:CGRectMake(0, originY - 11, contentView.frame.size.width, 71)];
    //
    for (int8_t buttonCount = 0; buttonCount < 6; buttonCount++) {
        UIButton *eachButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 22)];
        [eachButton setFrame:CGRectMake(0, 0, 32, 22)];
        
//        [eachButton setImage:[UIImage imageNamed:@"jumpHole_normal.png"] forState:UIControlStateNormal];
        UILabel *eachLabel = [[UILabel alloc] init];
        [eachLabel setFrame:CGRectMake(0, 22, 32, 22)];
        eachLabel.font = [UIFont systemFontOfSize:10];
        eachLabel.textAlignment = NSTextAlignmentCenter;
//        eachLabel.text = @"跳洞";
        
        //
        switch (buttonCount) {
            case 0:
                [eachButton setImage:[UIImage imageNamed:@"jumpHole_normal.png"] forState:UIControlStateNormal];
                eachLabel.text = @"跳洞";
                break;
                
            case 1:
                [eachButton setImage:[UIImage imageNamed:@"mend_normal.png"] forState:UIControlStateNormal];
                eachLabel.text = @"补洞";
                break;
                
            case 2:
                [eachButton setImage:[UIImage imageNamed:@"changeCaddy_normal.png"] forState:UIControlStateNormal];
                eachLabel.text = @"换球童";
                break;
                
            case 3:
                [eachButton setImage:[UIImage imageNamed:@"changeBuggy_Selected.png"] forState:UIControlStateNormal];
                eachLabel.text = @"换球车";
                break;
                
            case 4:
                [eachButton setImage:[UIImage imageNamed:@"pause_normal.png"] forState:UIControlStateNormal];
                eachLabel.text = @"暂停";
                break;
                
            case 5:
                [eachButton setImage:[UIImage imageNamed:@"terninal_normal.png"] forState:UIControlStateNormal];
                eachLabel.text = @"终止";
                break;
                
                
            default:
                break;
        }
        
        UIView *eachView = [[UIView alloc] initWithFrame:CGRectMake(13 + offseteachButton*buttonCount, 6, 32, 44)];
        [eachView addSubview:eachButton];
        [eachView addSubview:eachLabel];
//        eachView.backgroundColor = [UIColor redColor];
        [_moreHanleView addSubview:eachView];
    }
    
    NSLog(@"subviewCount:%ld",(unsigned long)_moreHanleView.subviews.count);
    //
    [contentView addSubview:_moreHanleView];
}

- (void)removeTheHandleView
{
    [_moreHanleView removeFromSuperview];
}

- (void)firstCellGestureAction:(UITapGestureRecognizer *)sender
{
    NSLog(@"firstCell");
    __weak typeof(self) weakSelf = self;
    UITableViewCell *firstCellView = (UITableViewCell *)sender.view;
    if (firstCellView.selected) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.moreHandleEnable = NO;
            
            [firstCellView setSelected:NO animated:YES];
            weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y, weakSelf.frame.size.width, 150);
            
            [weakSelf removeTheHandleView];
            //
            [weakSelf layoutIfNeeded];
            
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.moreHandleEnable = YES;
            
            [firstCellView setSelected:YES animated:YES];
            weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y, weakSelf.frame.size.width, 200);
            [weakSelf removeTheHandleView];
            [weakSelf addMoreHandeViewIntoContent];
            
            [weakSelf layoutIfNeeded];
            
        });
    }
    
}

- (void)secondCellGestureAction:(UITapGestureRecognizer *)sender
{
    NSLog(@"secondCell");
    __weak typeof(self) weakSelf = self;
    UITableViewCell *secondCellView = (UITableViewCell *)sender.view;
    if (secondCellView.selected) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.moreHandleEnable = NO;
            [secondCellView setSelected:NO animated:YES];
            weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y, weakSelf.frame.size.width, 150);
            
            [weakSelf removeTheHandleView];
            //
            [weakSelf layoutIfNeeded];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.moreHandleEnable = YES;
            
            [secondCellView setSelected:YES animated:YES];
            weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y, weakSelf.frame.size.width, 200);
            [weakSelf removeTheHandleView];
            [weakSelf addMoreHandeViewIntoContent];
            //
            [weakSelf layoutIfNeeded];
        });
    }
    
}

- (void)thirdCellGestureAction:(UITapGestureRecognizer *)sender
{
    NSLog(@"thirdCell");
    __weak typeof(self) weakSelf = self;
    UITableViewCell *thirdCellView = (UITableViewCell *)sender.view;
    if (thirdCellView.selected) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.moreHandleEnable = NO;
            
            [thirdCellView setSelected:NO animated:YES];
            weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y, weakSelf.frame.size.width, 150);
            
            [weakSelf removeTheHandleView];
            //
            [weakSelf layoutIfNeeded];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.moreHandleEnable = YES;
            
            [thirdCellView setSelected:YES animated:YES];
            weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y, weakSelf.frame.size.width, 200);
            [weakSelf removeTheHandleView];
            [weakSelf addMoreHandeViewIntoContent];
            //
            [weakSelf layoutIfNeeded];
        });
    }
    
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"bounds"];
}

- (void)holeDetailShow
{
    NSLog(@"show the view");
    //
    CustomAnimationBlock expandBlock = ^{self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);};
    CustomAnimationBlock identityBlock = ^{self.transform = CGAffineTransformIdentity;};
    CustomCompletionAnimationBlock completionBlock = ^(BOOL done){[UIView animateWithDuration:0.3f animations:identityBlock];};
    [UIView animateWithDuration:0.5f animations:expandBlock completion:completionBlock];
    
}

- (void)holeDetailDismiss
{
    NSLog(@"hide the view");
    
//    self.moreHandleEnable = NO;
    CustomAnimationBlock expandBlock = ^{self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);};
    CustomAnimationBlock shrinkBlock = ^{self.transform = CGAffineTransformMakeScale(FLT_EPSILON, FLT_EPSILON);};
    CustomCompletionAnimationBlock completionBlock = ^(BOOL done){[UIView animateWithDuration:0.3f animations:shrinkBlock];};
    
    [UIView animateWithDuration:0.5f animations:expandBlock completion:completionBlock];
    
}











@end
