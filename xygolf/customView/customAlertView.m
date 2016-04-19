//
//  customAlertView.m
//  xygolf
//
//  Created by LiuC on 16/4/16.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import "customAlertView.h"

typedef void (^CustomAnimationBlock)(void);
typedef void (^CustomCompletionAnimationBlock)(BOOL finished);

@implementation customAlertView
{
    UIView *contentView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"bounds"]) {
        contentView.frame = self.bounds;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) {
        return self;
    }
    //初始化构件alert视图
    [self internalCustomAlert];
    
    
    return self;
}


- (void)internalCustomAlert
{
    //add size observer
    [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
    
    //constraint the size and width based on the initial frame
    self.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    for (NSString *constraintString in @[@"V:[self(==height)]",@"H:[self(==width)]"]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:@{@"width":@(width),@"height":@(height)} views:NSDictionaryOfVariableBindings(self)];
        [self addConstraints:constraints];
    }
    [self layoutIfNeeded];
    //add a contentview for auto layout
    contentView = [[UIView alloc] initWithFrame:self.bounds];
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //add layer style
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    
    //create back image view
    _backImageView = [[UIImageView alloc] init];
    [contentView addSubview:_backImageView];
    _backImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Create label
    _label = [[UILabel alloc] init];
    [contentView addSubview:_label];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.numberOfLines = 0;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    //create first button
    _firstbutton = [UIButton buttonWithType:UIButtonTypeSystem];
    [contentView addSubview:_firstbutton];
    _firstbutton.translatesAutoresizingMaskIntoConstraints = NO;
    [_firstbutton setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_firstbutton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_firstbutton setBackgroundColor:[UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1.0]];
    
    //create second button
    _secondbutton = [UIButton buttonWithType:UIButtonTypeSystem];
    [contentView addSubview:_secondbutton];
    _secondbutton.translatesAutoresizingMaskIntoConstraints = NO;
    [_secondbutton setTitleColor:[UIColor colorWithRed:10/255.0 green:126/255.0 blue:81/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_secondbutton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_secondbutton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    
    
    //separator view for V/H
    UIView *hseparatorView = [[UIView alloc]  initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
    hseparatorView.backgroundColor = [UIColor colorWithRed:91/255.0 green:182/255.0 blue:162/255.0 alpha:1.0];
    [contentView addSubview:hseparatorView];
    hseparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *vseparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, _firstbutton.frame.size.height)];
    vseparatorView.backgroundColor = [UIColor colorWithRed:91/255.0 green:182/255.0 blue:162/255.0 alpha:1.0];
    [contentView addSubview:vseparatorView];
    vseparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //layout on content view
    // Layout subviews on content view
    for (NSString *constraintString in @[@"V:|-0-[_backImageView]-0-[hseparatorView]-0-[_firstbutton]-0-|",@"V:|-90-[_label]-0-[hseparatorView]-0-[_firstbutton]-0-|",@"V:[hseparatorView(1)]",@"V:[_firstbutton(60)]",@"V:[_secondbutton(60)]", @"V:|-[_label]-0-[hseparatorView]-0-[vseparatorView]-0-|", @"V:|-[_label]-0-[hseparatorView]-0-[_secondbutton]-0-|", @"H:|-25-[_backImageView]-25-|", @"H:|-[_label]-|", @"H:|-0-[_firstbutton(_secondbutton)]-0-[vseparatorView]-0-[_secondbutton]-0-|", @"H:|-0-[hseparatorView]-0-|",@"[vseparatorView(1.0)]"])
    {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:NSDictionaryOfVariableBindings(_firstbutton, _label, hseparatorView,_secondbutton,vseparatorView,_backImageView)];
        [contentView addConstraints:constraints];
    }
    
    
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"bounds"];
}

- (void)centerInSuperView
{
    if (!self.superview) {
        NSLog(@"there is no superview for the alert");
        return;
    }
    
    NSArray *constraintArray = [self.superview.constraints copy];
    for (NSLayoutConstraint *constraint in constraintArray)
    {
        if ((constraint.firstItem == self) || (constraint.secondItem == self))
            [self.superview removeConstraint:constraint];
    }
    
    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem: self attribute: NSLayoutAttributeCenterX relatedBy: NSLayoutRelationEqual toItem: [self superview] attribute: NSLayoutAttributeCenterX multiplier: 1.0f constant: 0.0f];
    NSLayoutConstraint *constraintCenterY = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:[self superview] attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    
    
    [self.superview addConstraints:@[constraintCenterX,constraintCenterY]];
}


- (void)dismiss
{
    CustomAnimationBlock expandBlock = ^{self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);};
    CustomAnimationBlock shrinkBlock = ^{self.transform = CGAffineTransformMakeScale(FLT_EPSILON, FLT_EPSILON);};
    CustomCompletionAnimationBlock completionBlock = ^(BOOL done){[UIView animateWithDuration:0.3f animations:shrinkBlock];};
    
    [UIView animateWithDuration:0.5f animations:expandBlock completion:completionBlock];
}

- (void)show
{
    self.transform = CGAffineTransformMakeScale(FLT_EPSILON, FLT_EPSILON);
    [self centerInSuperView];
    
    CustomAnimationBlock expandBlock = ^{self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);};
    CustomAnimationBlock identityBlock = ^{self.transform = CGAffineTransformIdentity;};
    CustomCompletionAnimationBlock completionBlock = ^(BOOL done){[UIView animateWithDuration:0.3f animations:identityBlock];};
    [UIView animateWithDuration:0.5f animations:expandBlock completion:completionBlock];
}

@end
