//
//  HoleFunctionChangeView.m
//  xygolf
//
//  Created by LiuC on 16/4/21.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import "HoleFunctionChangeView.h"

@interface HoleFunctionChangeView ()
{
    UIView *contentView;
}

@property (assign, nonatomic) BOOL      isShowingHoleFunctionView;

@end

@implementation HoleFunctionChangeView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) {
        return self;
    }
    //init the view
    [self internalHoleFunctionView];
    //
//    CourseStateViewController *courseVC = [[CourseStateViewController alloc] init];
//    _delegate = (id)courseVC;
    
    
    return self;
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
//{
//    if ([keyPath isEqualToString:@"bounds"]) {
//        contentView.frame = self.bounds;
//    }
//}

- (void)internalHoleFunctionView
{
    //add observer for size change
//    [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    //constraint the the size and width based on the initial frame
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    for (NSString *constraintString in @[@"V:[self(==height)]",@"H:[self(==width)]"]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:@{@"width":@(width),@"height":@(height)} views:NSDictionaryOfVariableBindings(self)];
        [self addConstraints:constraints];
    }
    
    //init the contentView for auto layout
    contentView = [[UIView alloc] initWithFrame:self.bounds];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:contentView];
    
    //add layer style
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    
    //create holerun tableviewcell
    UITableViewCell *holeRunCell = [[UITableViewCell alloc] init];
    holeRunCell.backgroundColor = [UIColor whiteColor];
    holeRunCell.translatesAutoresizingMaskIntoConstraints = NO;
    holeRunCell.imageView.image = [UIImage imageNamed:@"enableHole.png"];
    holeRunCell.textLabel.text = @"球洞运行";
    UISwitch *holeRunCellSwitch = [[UISwitch alloc] init];
    holeRunCellSwitch.on = YES;
    [holeRunCellSwitch addTarget:self action:@selector(holeRunSwitch) forControlEvents:UIControlEventValueChanged];
    holeRunCell.accessoryView = holeRunCellSwitch;
    
    [contentView addSubview:holeRunCell];
    
    //the Separator view
    UIView *fvseparatorView = [[UIView alloc] init];
    fvseparatorView.backgroundColor = [UIColor lightGrayColor];
    fvseparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:fvseparatorView];
    
    //second tableviewCell
    UITableViewCell *startHoleCell = [[UITableViewCell alloc] init];
    startHoleCell.backgroundColor = [UIColor whiteColor];
    startHoleCell.imageView.image = [UIImage imageNamed:@"startHole.png"];
    startHoleCell.textLabel.text = @"始发球洞";
    startHoleCell.translatesAutoresizingMaskIntoConstraints = NO;
    UISwitch *startHoleSwitch = [[UISwitch alloc] init];
    [startHoleSwitch addTarget:self action:@selector(startHoleSwitch) forControlEvents:UIControlEventValueChanged];
    startHoleCell.accessoryView = startHoleSwitch;
    
    [contentView addSubview:startHoleCell];
    
    //create second separator view
    UIView *svseparatorView = [[UIView alloc] init];
    svseparatorView.backgroundColor = [UIColor lightGrayColor];
    svseparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:svseparatorView];
    
    //create confirm button
    UIButton *confirmButton = [[UIButton alloc] init];
    [confirmButton setBackgroundColor:[UIColor colorWithRed:48/255.0 green:193/255.0 blue:124/255.0 alpha:1.0]];
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    confirmButton.layer.cornerRadius = 10;
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    
//    [confirmButton.titleLabel setText:@"确定"];
    
    
//    [confirmButton setTitleColor:[UIColor colorWithRed:48/255.0 green:193/255.0 blue:124/255.0 alpha:1.0] forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmHoleChange) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:confirmButton];
    
    
    //add constraints
    for (NSString *constraintString in @[@"V:|-7-[holeRunCell(startHoleCell)]-0-[fvseparatorView(svseparatorView)]-0-[startHoleCell]-0-[svseparatorView]-[confirmButton]-|",@"V:[startHoleCell(48)]",@"V:[holeRunCell(48)]",@"V:[fvseparatorView(1)]",@"V:[svseparatorView(1)]",@"H:|-0-[holeRunCell]-0-|",@"H:|-0-[startHoleCell]-0-|",@"H:|-0-[fvseparatorView]-0-|",@"H:|-0-[svseparatorView]-0-|",@"H:|-40-[confirmButton]-40-|"]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:NSDictionaryOfVariableBindings(holeRunCell,fvseparatorView,startHoleCell,svseparatorView,confirmButton)];
        [contentView addConstraints:constraints];
    }
    
}

- (void)holeRunSwitch
{
    NSLog(@"holeRunSwitch");
    
}

- (void)startHoleSwitch
{
    NSLog(@"startHoleSwitch");
    
    
    
}

- (void)confirmHoleChange
{
    NSLog(@"confirm change");
    [self holeFunctionViewDismiss];
    //
    if ([_delegate respondsToSelector:@selector(removeTheGraphics)]) {
        [_delegate removeTheGraphics];
    }
}

- (BOOL)holeFunctionViewisShowing
{
    return _isShowingHoleFunctionView;
}

- (void)centerTheHoleFunctionView
{
    if (self.superview == nil) {
        NSLog(@"there's no super view");
        return;
    }
    //
    NSArray *constraintArray = [self.superview.constraints copy];
    for (NSLayoutConstraint *constraint in constraintArray)
    {
        if ((constraint.firstItem == self) || (constraint.secondItem == self))
            [self.superview removeConstraint:constraint];
    }
    
    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem: self attribute: NSLayoutAttributeCenterX relatedBy: NSLayoutRelationEqual toItem: [self superview] attribute: NSLayoutAttributeCenterX multiplier: 1.0f constant: 0.0f];
    NSLayoutConstraint *constraintCenterY = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:[self superview] attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:90.0f];
    
    [self.superview addConstraints:@[constraintCenterX,constraintCenterY]];
    
}


- (void)holeFunctionViewShow
{
    //
    _isShowingHoleFunctionView = YES;
    //
    [self centerTheHoleFunctionView];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        self.transform = CGAffineTransformIdentity;
    }];
    
}

- (void)holeFunctionViewDismiss
{
    _isShowingHoleFunctionView = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        self.alpha = 0.0;
    }];
    
}

@end
