//
//  CourseViewController.m
//  xygolf
//
//  Created by LiuC on 16/3/30.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import "CourseStateViewController.h"
#import "EachHoleMoreInfo.h"
#import "xygolfmacroHeader.h"

#define CLIENT_ID   @"gKbc4lH2K27McsAe"

@interface CourseStateViewController ()<AGSQueryTaskDelegate,AGSLayerDelegate,AGSCalloutDelegate,AGSMapViewLayerDelegate,AGSFeatureLayerQueryDelegate,AGSMapViewTouchDelegate,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    EachHoleMoreInfo *holeDetailView;
    
}

@property (weak, nonatomic) IBOutlet AGSMapView *CoursemapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SelectedDataTypeSegement;
@property (weak, nonatomic) IBOutlet UITableView *courseDataDisTable;

@property (weak, nonatomic) IBOutlet UIView *segmentBackView;

@property (weak, nonatomic) IBOutlet UIButton *addGroupButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *exchangeMapDataDisType;







- (IBAction)ChangeDataDisType:(UISegmentedControl *)sender;

- (IBAction)searchHoleInfo:(UIBarButtonItem *)sender;



//- (IBAction)SubFunctionSelectButton:(UIButton *)sender;

//自定义的一些实体变量
@property (strong, nonatomic) AGSLocalTiledLayer     *backGroundLayer;
@property (strong, nonatomic) AGSGDBFeatureTable     *localFeatureTable;
@property (strong, nonatomic) AGSFeatureTableLayer   *localFeatureTableLayer;
@property (strong, nonatomic) AGSGDBFeatureTable     *localHoleFeatureTable;
@property (strong, nonatomic) AGSFeatureTableLayer   *localHoleFeatureTableLayer;
@property (strong, nonatomic) AGSGraphicsLayer       *graphicLayer;
@property (strong, nonatomic) AGSQuery               *query;
@property (strong, nonatomic) AGSQueryTask           *queryTask;
@property (strong, nonatomic) AGSSketchGraphicsLayer *mySketchLayer;
@property (strong, nonatomic) AGSSketchGraphicsLayer *gpsSketchLayer;
@property (strong, nonatomic) AGSGeometryEngine      *geometryEngineLocal;

//球场状态选框
@property (strong, nonatomic) UIView                 *backHalfAplphaView;
@property (strong, nonatomic) UIView                 *selectCourseStateView;

//

@property (strong, nonatomic) UIView                 *detailInfoView;
//
@property (strong, nonatomic) UIBarButtonItem        *rightItem;



@end



@implementation CourseStateViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    //
    NSError *error;
    [AGSRuntimeEnvironment setClientID:CLIENT_ID error:&error];
    if(error){
        NSLog(@"Error using client ID:%@",[error localizedDescription]);
    }
    //enable standard level functionality in your app using your license code 这句话是将eris的logo给去掉
    AGSLicenseResult result = [[AGSRuntimeEnvironment license] setLicenseCode:@"runtimestandard,101,rux00000,none,gKbc4lH2K27McsAe"];
    NSLog(@"%ld",(long)result);
    //
    [self loadTheArcGISMapView];
    _courseDataDisTable.hidden = YES;
    //设置次属性是为了避免因为navigationcontroller与自定义的tableview添加的顺序问题而造成的视图来回切换时出现的tableview顶部出现空白（高度为64，navigationbar+statusbar）的bug
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    self.navigationItem.rightBarButtonItem = nil;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_graphicLayer removeAllGraphics];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [_courseDataDisTable reloadData];
}

- (void)dealloc
{
    [_CoursemapView removeObserver:self forKeyPath:@"location"];
}


- (void)loadTheArcGISMapView
{
    //add tiled layer  step1
    NSString *path = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapData.bundle/xunying.tpk"];
    self.backGroundLayer = [AGSLocalTiledLayer localTiledLayerWithPath:path];
    //如果层被合适的初始化了之后，添加到地图
    if(self.backGroundLayer != nil && !self.backGroundLayer.error)
    {
        [self.CoursemapView addMapLayer:self.backGroundLayer withName:@"Local Tiled Layer"];
    }
    else
    {
        [[[UIAlertView alloc]initWithTitle:@"could not load tile package" message:[self.backGroundLayer.error localizedDescription] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil]show];
        
    }
    //南场地图范围
    AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:3857];
    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:12692586.4426853
                                                ymin:4146662.07537442
                                                xmax:12694951.2828384
                                                ymax:4144356.7327446
                                    spatialReference:sr];
    
    
    [self.CoursemapView zoomToEnvelope:env animated:YES];
    //
    NSError *hole_error;
    NSString *holePath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapData.bundle/xunying_hole.geodatabase"];
    AGSGDBGeodatabase *gdbXunyinHole = [AGSGDBGeodatabase geodatabaseWithPath:holePath error:&hole_error];
    if(hole_error){
        NSLog(@"fail to open hole.geodatabase");
    }
    else{
        self.localHoleFeatureTable = [[gdbXunyinHole featureTables] objectAtIndex:0];
        self.localHoleFeatureTableLayer = [[AGSFeatureTableLayer alloc] initWithFeatureTable:self.localHoleFeatureTable];
        self.localHoleFeatureTableLayer.delegate = self;
        [self.CoursemapView addMapLayer:self.localHoleFeatureTableLayer withName:@"Hole Feature Layer"];
    }
    //xunying.geodatabase
    NSError *xunyingError;
    NSString *xunyingPath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapData.bundle/xunying.geodatabase"];
    AGSGDBGeodatabase *gdb_xunying = [[AGSGDBGeodatabase alloc]initWithPath:xunyingPath error:&xunyingError];
    //
    if(xunyingError)
    {
        NSLog(@"open elements.geodatabase error:%@",[xunyingError localizedDescription]);
    }
    else{
        //NSLog(@"open the geodatabase successfully");
        self.localFeatureTable = [[gdb_xunying featureTables] objectAtIndex:0];
        self.localFeatureTableLayer = [[AGSFeatureTableLayer alloc]initWithFeatureTable:self.localFeatureTable];
        self.localFeatureTableLayer.delegate = self;
        self.localFeatureTableLayer.opacity = 1;
        
        [self.CoursemapView addMapLayer:self.localFeatureTableLayer withName:@"Xunying Fearue Layer"];
    }
    //add graphicLayer
    self.graphicLayer = [AGSGraphicsLayer graphicsLayer];
    [self.CoursemapView addMapLayer:self.graphicLayer withName:@"graphic Layer"];
    
    self.queryTask = [[AGSQueryTask alloc] init];
    self.queryTask.delegate = self;
    //
    self.CoursemapView.touchDelegate = self;
    
    //初始化地图中的公共部分
    //地图中的当前GPS定位点的位置信息点的显示
    [self.CoursemapView.locationDisplay addObserver:self forKeyPath:@"autoPanMode" options:(NSKeyValueObservingOptionNew) context:NULL];
    //Listen to KVO notifications for map scale property
    [self.CoursemapView addObserver:self
                   forKeyPath:@"location"
                      options:(NSKeyValueObservingOptionNew)
                      context:NULL];
    
    //callout的代理设置
    self.CoursemapView.callout.delegate = self;
    //
    self.geometryEngineLocal = [[AGSGeometryEngine alloc] init];
    //
    //set the layer delegate to self to check when the layers are loaded. Required to start the gps.
    self.CoursemapView.layerDelegate = self;
    
    //preparing the gps sketch layer.
    self.gpsSketchLayer = [[AGSSketchGraphicsLayer alloc] initWithGeometry:nil];
    [self.CoursemapView addMapLayer:self.gpsSketchLayer withName:@"Sketch layer"];
    
    
    self.CoursemapView.touchDelegate = self.mySketchLayer;
    self.mySketchLayer = [[AGSSketchGraphicsLayer alloc] initWithGeometry:nil];
    [self.CoursemapView addMapLayer:self.mySketchLayer];
    
    self.mySketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:self.CoursemapView.spatialReference];
    
    
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"location"]) {
        NSLog(@"");
        
        
    }
    if ([keyPath isEqualToString:@"courseState"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createCourseStateViews];
        });
    }
    
}

- (BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint
{
    __weak typeof(self) weakSelf = self;
    //
    [_graphicLayer removeAllGraphics];
    //
    NSDictionary *featureAttr = [feature allAttributes];
    
    NSString *querySQL;
    querySQL = [NSString stringWithFormat:@"QCM = '%ld'",[featureAttr[@"QCM"] integerValue]];
    self.query = [AGSQuery query];
    self.query.whereClause = querySQL;
    
    [_localHoleFeatureTable queryResultsWithParameters:_query completion:^(NSArray *results, NSError *error) {
        if (results.count) {
            AGSGDBFeature *curFeatrue = results[0];
            NSDictionary *curDic = [curFeatrue allAttributes];
            
            AGSSimpleFillSymbol *fillSymbolView = [[AGSSimpleFillSymbol alloc] initWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.15] outlineColor:[UIColor blueColor]];
            AGSGraphic *holeGraphic = [[AGSGraphic alloc] initWithGeometry:curDic[@"Shape"] symbol:fillSymbolView attributes:nil];
            [weakSelf.graphicLayer addGraphic:holeGraphic];
            //将选择的球洞放大到屏幕中央
            [_CoursemapView zoomToGeometry:curDic[@"Shape"] withPadding:120 animated:YES];
            //
            [UIView animateWithDuration:0.2 delay:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                AGSSimpleFillSymbol *fillSymbolView = [[AGSSimpleFillSymbol alloc] initWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.15] outlineColor:[UIColor blueColor]];
                AGSGraphic *holeGraphic = [[AGSGraphic alloc] initWithGeometry:curDic[@"Shape"] symbol:fillSymbolView attributes:nil];
                [weakSelf.graphicLayer addGraphic:holeGraphic];
                //将选择的球洞放大到屏幕中央
                [_CoursemapView zoomToGeometry:curDic[@"Shape"] withPadding:120 animated:YES];
            } completion:^(BOOL finished) {
                
                
                
            }];
            
            
        }
        
    }];
    
    
    NSLog(@"featureDic:%@",featureAttr);
    
    return NO;
}

#pragma -mark mapViewDidLoad
/**
 *  mapViewDidLoad
 *
 *  @param mapView current mapView
 */
-(void)mapViewDidLoad:(AGSMapView *)mapView
{
    [self.CoursemapView.locationDisplay startDataSource];
    self.CoursemapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
    self.CoursemapView.locationDisplay.wanderExtentFactor = 0.75;
    //setting the geometry of the gps sketch layer to polyline.
    self.gpsSketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:self.CoursemapView.spatialReference];
    
    //set the midvertex symbol to nil to avoid the default circle symbol appearing in between vertices
    self.gpsSketchLayer.midVertexSymbol = nil;
    
}

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
    NSLog(@"mappoint:%@",mappoint);
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
    
}


- (void)createCourseStateViews
{
    _backHalfAplphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _backHalfAplphaView.backgroundColor = [UIColor whiteColor];
    _backHalfAplphaView.alpha = 0.25;
    [self.view addSubview:_backHalfAplphaView];
    
    //选框背景
    _selectCourseStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth - 40, 168)];
    _selectCourseStateView.backgroundColor = [UIColor whiteColor];
    _selectCourseStateView.frame = CGRectMake(0, 0, ScreenWidth - 40, 169);
    _selectCourseStateView.center = CGPointMake(ScreenWidth/2, ScreenHeight - 184);
    _selectCourseStateView.layer.cornerRadius = 5;
    //添加第一行的图片
    UITableViewCell *holeRun = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 5, 40, 54)];
    [holeRun setFrame:CGRectMake(0, 5, _selectCourseStateView.frame.size.width, 54)];
    
    holeRun.selectionStyle = UITableViewCellSelectionStyleNone;
    holeRun.imageView.image = [UIImage imageNamed:@"score.png"];
    holeRun.textLabel.text = @"球洞运行";
    holeRun.backgroundColor = [UIColor whiteColor];
//    holeRun.accessoryType = UITableViewCellAccessoryDetailButton;
    
    UISwitch *holeRunSwitch = [[UISwitch alloc] init];
    
    holeRun.accessoryView = holeRunSwitch;
    
    
//    holeRun.
    
    [_selectCourseStateView addSubview:holeRun];
    //添加分割线1
    UIView *firstSeparetorView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, _selectCourseStateView.frame.size.width, 1.0f)];
    firstSeparetorView.backgroundColor = [UIColor lightGrayColor];
    [_selectCourseStateView addSubview:firstSeparetorView];
    //添加第二行的图片
    UITableViewCell *holeStart = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 40, 54)];
    [holeStart setFrame:CGRectMake(0, 62, _selectCourseStateView.frame.size.width, 54)];
    
    holeStart.selectionStyle = UITableViewCellSelectionStyleNone;
    holeStart.imageView.image = [UIImage imageNamed:@"score.png"];
    holeStart.textLabel.text = @"始发球洞";
    holeStart.backgroundColor = [UIColor whiteColor];
    UISwitch *holeStartSwitch = [[UISwitch alloc] init];
    
    holeStart.accessoryView = holeStartSwitch;
    
    [_selectCourseStateView addSubview:holeStart];
    //添加分割线2
    UIView *secondSeparetorView = [[UIView alloc] initWithFrame:CGRectMake(0, 117, _selectCourseStateView.frame.size.width, 1.0f)];
    secondSeparetorView.backgroundColor = [UIColor lightGrayColor];
    [_selectCourseStateView addSubview:secondSeparetorView];
    
    [self.view addSubview:_selectCourseStateView];
    //添加确定按键
    UIButton *confirmChangeStateButton = [[UIButton alloc] init];
    [confirmChangeStateButton setFrame:CGRectMake(0, 0, _selectCourseStateView.frame.size.width - 120, 36)];
    confirmChangeStateButton.center = CGPointMake(_selectCourseStateView.frame.size.width/2, 143);
    
    [confirmChangeStateButton setTitle:@"确定" forState:UIControlStateNormal];
    
    confirmChangeStateButton.titleLabel.font = [UIFont systemFontOfSize:17];
//    confirmChangeStateButton.titleLabel.textColor = [UIColor blackColor];
    confirmChangeStateButton.backgroundColor = [UIColor greenColor];//[UIColor colorWithRed:44 green:184 blue:106 alpha:1.0];
    confirmChangeStateButton.layer.cornerRadius = 12;
    confirmChangeStateButton.userInteractionEnabled = YES;
    [confirmChangeStateButton addTarget:self action:@selector(changeCourseHoleStateResponse) forControlEvents:UIControlEventTouchUpInside];
    
    
    [_selectCourseStateView addSubview:confirmChangeStateButton];
    
    //为主背景图视图添加点击手势
    UITapGestureRecognizer *tapDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCourseStateViews)];
    tapDismiss.delegate = self;
    tapDismiss.numberOfTapsRequired = 1;
    
    [_backHalfAplphaView addGestureRecognizer:tapDismiss];
    
}

- (void)changeCourseHoleStateResponse
{
    NSLog(@"...we have set confirm...");
    [self dismissCourseStateViews];
}

- (void)dismissCourseStateViews
{
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [weakSelf.backHalfAplphaView removeFromSuperview];
        [weakSelf.selectCourseStateView removeFromSuperview];
        
        
        
    } completion:^(BOOL finished) {
        //
        weakSelf.backHalfAplphaView = nil;
        weakSelf.selectCourseStateView = nil;
        
        [weakSelf.backHalfAplphaView setValue:@"hide" forKey:@"courseState"];
    }];
    
    
}


- (IBAction)SubFunctionSelectFuntion:(UIButton *)sender {
    
    [self createCourseStateViews];
    
}


#pragma --mark  courseData tableView
/**
 *  数据界面的tableview的设置
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 18;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 8.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (UIView *)contentViewSetting:(NSInteger)state andFrame:(CGRect)contentFrame
{
    UIView *InContentView = [[UIView alloc] initWithFrame:CGRectMake(100, contentFrame.origin.y, 80, contentFrame.size.height)];
//    InContentView.backgroundColor = [UIColor blackColor];
    UILabel *groupStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(InContentView.frame.origin.x, 0, 20, 44)];
    UILabel *groupCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(InContentView.frame.origin.x  + 40, 0, 35, 44)];
    //
    groupStateLabel.font = [UIFont systemFontOfSize:14.0];
    groupStateLabel.textColor = [UIColor whiteColor];
    
    groupCountLabel.font = [UIFont systemFontOfSize:10];
    groupCountLabel.textColor = [UIColor whiteColor];
    const CGFloat fontSize = 24.0;
    NSMutableAttributedString *attrString;
    NSString *groupCountStr = [[NSString alloc] init];
    
    
    switch (state) {
        case 0:
            groupStateLabel.text = @"缓堵";
            //
            groupCountStr = @"3组球队";
            attrString = [[NSMutableAttributedString alloc] initWithString:groupCountStr];
            
            
            break;
            //
        case 1:
            groupStateLabel.text = @"正常";
            //
            groupCountStr = @"2组球队";
            attrString = [[NSMutableAttributedString alloc] initWithString:groupCountStr];
            
            
            break;
            //
        case 2:
            groupStateLabel.text = @"非常拥堵";
            //
            groupCountStr = @"3组球队";
            attrString = [[NSMutableAttributedString alloc] initWithString:groupCountStr];
            
            
            break;
            //
        case 3:
            groupStateLabel.text = @"无人";
            //
            groupCountStr = @"0组球队";
            attrString = [[NSMutableAttributedString alloc] initWithString:groupCountStr];
            
            
            break;
            //
        case 4:
            
            break;
            
            
        default:
            break;
    }
    //
    //设置字体
    UIFont *baseFont = [UIFont systemFontOfSize:fontSize];
    [attrString addAttribute:NSFontAttributeName value:baseFont range:NSMakeRange(0, 2)];//设置第一个字符的字体
    groupCountLabel.attributedText = attrString;
    
    
    return InContentView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionNumber;
    sectionNumber = indexPath.section;
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell%ld",sectionNumber];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UITableViewCell *eachCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (eachCell == nil) {
        eachCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //
    if (indexPath.section%5 == 0) {
        eachCell.backgroundColor = [UIColor colorWithRed:1.0 green:181/255.0 blue:1/255.0 alpha:1.0];
        //
        eachCell.selectedBackgroundView = [[UIView alloc] initWithFrame:eachCell.frame];
        eachCell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:1.0 green:181/255.0 blue:1/255.0 alpha:1.0];
        
    }
    //
    if (indexPath.section%5 == 1) {
        eachCell.backgroundColor = [UIColor colorWithRed:86/255.0 green:219/255.0 blue:109/255.0 alpha:1.0];
        //
        eachCell.selectedBackgroundView = [[UIView alloc] initWithFrame:eachCell.frame];
        eachCell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:86/255.0 green:219/255.0 blue:109/255.0 alpha:1.0];
        
    }
    //
    if (indexPath.section%5 == 2) {
        eachCell.backgroundColor = [UIColor colorWithRed:238/255.0 green:76/255.0 blue:109/255.0 alpha:1.0];
        //
        eachCell.selectedBackgroundView = [[UIView alloc] initWithFrame:eachCell.frame];
        eachCell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:238/255.0 green:76/255.0 blue:109/255.0 alpha:1.0];
        
    }
    //
    if (indexPath.section%5 == 3) {
        eachCell.backgroundColor = [UIColor colorWithRed:181/255.0 green:181/255.0 blue:181/255.0 alpha:1.0];
        //
        eachCell.selectedBackgroundView = [[UIView alloc] initWithFrame:eachCell.frame];
        eachCell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:181/255.0 green:181/255.0 blue:181/255.0 alpha:1.0];
        
    }
    //
    if (indexPath.section%5 == 4) {
        eachCell.backgroundColor = [UIColor colorWithRed:86/255.0 green:219/255.0 blue:109/255.0 alpha:1.0];
        //
        eachCell.selectedBackgroundView = [[UIView alloc] initWithFrame:eachCell.frame];
        eachCell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:86/255.0 green:219/255.0 blue:109/255.0 alpha:1.0];
        
    }
    //
    NSInteger sectionNum = indexPath.section + 1;
    NSString *holeNameStr = [NSString stringWithFormat:@"%2ld洞",(long)sectionNum];
    eachCell.layer.cornerRadius = 5;
    
    eachCell.textLabel.text = holeNameStr;
    eachCell.textLabel.textColor = [UIColor whiteColor];
    eachCell.textLabel.font = [UIFont systemFontOfSize:10];
//    cell.textLabel.attributedText
    NSString *string = holeNameStr;
    const CGFloat fontSize = 29.0;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
//    NSUInteger length = [string length];
    //设置字体
    UIFont *baseFont = [UIFont systemFontOfSize:fontSize];
    [attrString addAttribute:NSFontAttributeName value:baseFont range:NSMakeRange(0, 2)];//设置第一个字符的字体
    eachCell.textLabel.attributedText = attrString;
    
    //
    UIButton *accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    accessoryButton.imageView.image = [UIImage imageNamed:@"messege_mapData.png"];
    [accessoryButton setImage:[UIImage imageNamed:@"more_mapData.png"] forState:UIControlStateNormal];
    eachCell.accessoryView = accessoryButton;//[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more_mapData.png"]];
    
    //
//    for (UIView *subView in cell.contentView.subviews) {
//        [subView removeFromSuperview];
//    }
    //
    UILabel *groupState = [[UILabel alloc] initWithFrame:CGRectMake(100, eachCell.frame.origin.y, 40, eachCell.frame.size.height)];
    groupState.center = CGPointMake(120, eachCell.frame.origin.y + eachCell.frame.size.height/2);
    groupState.font = [UIFont systemFontOfSize:14.0];
    
    groupState.text = @"缓堵";
    groupState.textAlignment = NSTextAlignmentCenter;
    
    groupState.textColor = [UIColor whiteColor];
    //
    UILabel *groupCount = [[UILabel alloc] initWithFrame:CGRectMake(191, eachCell.frame.origin.y, 80, eachCell.frame.size.height)];
    groupCount.center = CGPointMake(231, eachCell.frame.origin.y + eachCell.frame.size.height/2);
    groupCount.font = [UIFont systemFontOfSize:14.0];
    
    NSString *groupCountStr = @"3组球队";
    groupCount.text = groupCountStr;
    groupCount.textAlignment = NSTextAlignmentCenter;
    
    groupCount.textColor = [UIColor whiteColor];
    //
    const CGFloat fontSizee = 24.0;
    NSMutableAttributedString *attrStringg = [[NSMutableAttributedString alloc] initWithString:groupCountStr];
    //    NSUInteger length = [string length];
    //设置字体
    UIFont *baseFontt = [UIFont systemFontOfSize:fontSizee];
    [attrStringg addAttribute:NSFontAttributeName value:baseFontt range:NSMakeRange(0, 1)];//设置第一个字符的字体
    groupCount.attributedText = attrStringg;
    
    
    [eachCell.contentView addSubview:groupCount];
    [eachCell.contentView addSubview:groupState];
    
    
    
    return eachCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    //
    static NSIndexPath *oldIndexPath;
    
    NSLog(@"did select indexPath.row:%ld",(long)indexPath.row);
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSLog(@"cell.frame.origin.y:%f  and size.height:%f",selectedCell.frame.origin.y,selectedCell.frame.size.height);
    //
    if (oldIndexPath == nil) {
        oldIndexPath = indexPath;
        //
        [self createAndDisEachHoleInfo:selectedCell.frame];
        //
        selectedCell.accessoryView = nil;
        UIButton *accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [accessoryButton setImage:[UIImage imageNamed:@"back_mapData.png"] forState:UIControlStateNormal];
        selectedCell.accessoryView = accessoryButton;
        
    }
    else
    {
        if (indexPath == oldIndexPath) {
            oldIndexPath = nil;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            //
            [self dismissTheEachHoleInfoView];
            //
            UITableViewCell *oldselectedCell = [tableView cellForRowAtIndexPath:indexPath];
            oldselectedCell.accessoryView = nil;
            UIButton *oldaccessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            [oldaccessoryButton setImage:[UIImage imageNamed:@"more_mapData.png"] forState:UIControlStateNormal];
            oldselectedCell.accessoryView = oldaccessoryButton;
            
        }
        else
        {
            oldIndexPath = indexPath;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [weakSelf dismissTheEachHoleInfoView];
                
            } completion:^(BOOL finished) {
                if (finished) {
                    [weakSelf createAndDisEachHoleInfo:selectedCell.frame];
                    //
                    selectedCell.accessoryView = nil;
                    UIButton *accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
                    [accessoryButton setImage:[UIImage imageNamed:@"back_mapData.png"] forState:UIControlStateNormal];
                    selectedCell.accessoryView = accessoryButton;
                }
                
            }];
            
        }
    }

    
    
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"...didDeselect...");
    
    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (currentCell.selected) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}


//将分割线铺满整个窗口
- (void)viewWillLayoutSubviews
{
    if ([self.courseDataDisTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.courseDataDisTable setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.courseDataDisTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.courseDataDisTable setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (void)createAndDisEachHoleInfo:(CGRect)theFrame
{
//    __weak typeof(self) weakSelf = self;
    //
    CGFloat fatherCellViewOriginX = theFrame.origin.x;
    CGFloat fatherCellViewOriginY = theFrame.origin.y;
    CGFloat fatherCellViewSizeW   = theFrame.size.width;
    CGFloat fatherCellViewSizeH   = theFrame.size.height;
    //
    holeDetailView = [[EachHoleMoreInfo alloc] initWithFrame:CGRectMake(fatherCellViewOriginX, fatherCellViewOriginY + fatherCellViewSizeH + 1, fatherCellViewSizeW, 150)];
    holeDetailView.backgroundColor = [UIColor blackColor];
    [holeDetailView holeDetailShow];
    [_courseDataDisTable addSubview:holeDetailView];
    
}

- (void)dismissTheEachHoleInfoView
{
    [holeDetailView holeDetailDismiss];
}

- (void)creatNavBarItem
{
    _rightItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleDone target:self action:@selector(changeDisforRightBar)];
    _rightItem.image = [UIImage imageNamed:@"search_mapData.png"];
    _rightItem.tintColor = [UIColor whiteColor];
}

- (void)mapdataTypeSetting
{
    //hide mapview
    _CoursemapView.hidden = YES;
    //show data tableview
    _courseDataDisTable.hidden = NO;
    //
    _addGroupButton.enabled = NO;
    //
    [self creatNavBarItem];
    
    self.navigationItem.rightBarButtonItem = _rightItem;
    
}

- (void)HoleDataDisInit
{
    //
    self.courseDataDisTable.delegate = self;
    self.courseDataDisTable.dataSource = self;
    _courseDataDisTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    //
    UIView *theview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _courseDataDisTable.frame.size.width, 8)];
    CGRect theframe = theview.frame;
    [theview setFrame:CGRectMake(theframe.origin.x, theframe.origin.y, theframe.size.width, 8)];
    _courseDataDisTable.tableHeaderView = theview;
    
//    _courseDataDisTable.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);//上移64
}

- (IBAction)ChangeDataDisType:(UISegmentedControl *)sender {
    NSInteger mapViewIdex = 0;
    NSInteger mapDataTableIdex = 0;
    
    
    for (int8_t i = 0; i < self.view.subviews.count; i++) {
        id thesubView = self.view.subviews[i];
        if ([thesubView isKindOfClass:[AGSMapView class]]) {
            mapViewIdex = i;
        }
        else if ([thesubView isKindOfClass:[UITableView class]])
        {
            mapDataTableIdex = i;
        }
    }
    
    
    
    switch (sender.selectedSegmentIndex) {
        //mapMode
        case 0:
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.titleView = nil;
            //
            _CoursemapView.hidden = NO;
            self.segmentBackView.alpha = 0.3;
            _addGroupButton.enabled = YES;
            
            _courseDataDisTable.hidden = YES;
            [self.view exchangeSubviewAtIndex:mapDataTableIdex withSubviewAtIndex:mapViewIdex];
            
            
            break;
        //data tableView Mode
        case 1:
            //
            [self mapdataTypeSetting];
            //
            [self.view exchangeSubviewAtIndex:mapDataTableIdex withSubviewAtIndex:mapViewIdex];
            
            self.segmentBackView.alpha = 1.0;
            
            //
            [self HoleDataDisInit];
            [_courseDataDisTable reloadData];
            
            break;
            
        default:
            break;
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBar:%@",searchBar);
}

- (void)changeDisforRightBar
{
    if (self.navigationItem.rightBarButtonItem.image) {
        self.navigationItem.rightBarButtonItem.image = nil;
        //
        self.navigationItem.rightBarButtonItem.title = @"取消";
        //导航条的搜索条
        UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f,0.0f,250.0f,28.0f)];
        searchBar.delegate = self;
        [searchBar setPlaceholder:@"搜索"];
        searchBar.layer.cornerRadius = 15;
        searchBar.backgroundColor = [UIColor clearColor];
        
        //将搜索条放在一个UIView上
        UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 768, 28)];
        searchView.backgroundColor = [UIColor clearColor];
        [searchView addSubview:searchBar];
        self.navigationItem.titleView = searchView;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = nil;
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"search_mapData.png"];
        
        self.navigationItem.titleView = nil;
    }

}



- (IBAction)searchHoleInfo:(UIBarButtonItem *)sender {
    if (self.navigationItem.rightBarButtonItem.image) {
        self.navigationItem.rightBarButtonItem.image = nil;
        //
        self.navigationItem.rightBarButtonItem.title = @"取消";
        //导航条的搜索条
        UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f,0.0f,250.0f,28.0f)];
        searchBar.delegate = self;
        [searchBar setPlaceholder:@"搜索"];
        searchBar.layer.cornerRadius = 15;
        searchBar.backgroundColor = [UIColor clearColor];
        
        //将搜索条放在一个UIView上
        UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 768, 28)];
        searchView.backgroundColor = [UIColor clearColor];
        [searchView addSubview:searchBar];
        self.navigationItem.titleView = searchView;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = nil;
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"search_mapData.png"];
        
        self.navigationItem.titleView = nil;
    }
    
}

@end
