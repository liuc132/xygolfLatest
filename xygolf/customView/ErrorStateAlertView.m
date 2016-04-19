//
//  ErrorStateAlertView.m
//  xygolf
//
//  Created by LiuC on 16/4/19.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import "ErrorStateAlertView.h"

typedef void(^CustomAnimationBlock)(void);
typedef void(^CustomCompletionAnimationBlock)(BOOL finised);

@interface ErrorStateAlertView ()
{
    UIView *contentView;
}

@end



@implementation ErrorStateAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) {
        return self;
    }
    //调用构造简单的视图的方法
    [self internalInitErrorAlertView];
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"bounds"]) {
        contentView.frame = self.bounds;
    }
}

- (void)internalInitErrorAlertView
{
    //add observer for size
    [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
    
    //constraint the size and width based on the initial frame
    self.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    for (NSString *constraintString in @[@"V:[self(==height)]",@"H:[self(==width)]"]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:@{@"width":@(width),@"height":@(height)} views:NSDictionaryOfVariableBindings(self)];
        [self addConstraints:constraints];
    }
    
    //add a contentview for auto layout bcolor:3b3b3b
    contentView = [[UIView alloc] initWithFrame:self.bounds];
    [contentView setBackgroundColor:[UIColor colorWithRed:59/255.0 green:59/255.0 blue:59/255.0 alpha:1.0]];
    [self addSubview:contentView];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.layer.cornerRadius = 12;
    self.clipsToBounds = YES;
    
    //setting the label
    _errStateLabel = [[UILabel alloc] init];
    [contentView addSubview:_errStateLabel];
    _errStateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _errStateLabel.textAlignment = NSTextAlignmentCenter;
    
    for (NSString *constraintSting in @[@"V:|-[_errStateLabel]-|",@"H:|-[_errStateLabel]-|"]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintSting options:0 metrics:0 views:NSDictionaryOfVariableBindings(_errStateLabel)];
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


- (void)showErrorStateAlertDuration
{
    __weak typeof(self) weakSelf = self;
    
    self.transform = CGAffineTransformMakeScale(FLT_EPSILON, FLT_EPSILON);
    [self centerInSuperView];
    
    CustomAnimationBlock showBlock = ^{
        //self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.transform = CGAffineTransformIdentity;
        }];
    };
    CustomAnimationBlock shrinkBlock = ^{weakSelf.transform = CGAffineTransformMakeScale(FLT_EPSILON, FLT_EPSILON);};
    CustomCompletionAnimationBlock completionBlock = ^(BOOL done){
        [UIView animateWithDuration:5.0f animations:shrinkBlock];
        
    };
    
    [UIView animateWithDuration:0.2 animations:showBlock completion:completionBlock];
    
    //[UIView animateWithDuration:0.5f delay:1 options:UIViewAnimationOptionCurveEaseIn animations:expandBlock completion:completionBlock];
    
}


@end
