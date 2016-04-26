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
#import "HoleFunctionChangeView.h"
#import "CustomTableViewCell.h"

#define CLIENT_ID   @"gKbc4lH2K27McsAe"

@interface CourseStateViewController ()<AGSQueryTaskDelegate,AGSLayerDelegate,AGSCalloutDelegate,AGSMapViewLayerDelegate,AGSFeatureLayerQueryDelegate,AGSMapViewTouchDelegate,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,CourseStateViewControllerDelegate>
{
    EachHoleMoreInfo *holeDetailView;
    //
    NSMutableArray *holeNameArray;
    NSMutableArray *holeStateArray;
    NSMutableArray *holeCountArray;
    NSMutableArray *holeStateNumArray;
    NSMutableArray *groupPositionMarkArray;
    
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
//@property (strong, nonatomic) AGSGraphicsLayer       *selectHoleGraphicLayer;
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
//
//@property (strong, nonatomic) NSMutableArray         *



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
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCourseHoleStateResponse:) name:@"showTheHoleFunction" object:self];
    //
    [self creatNavBarItem];
    //构建数据（模拟一下）
    [self settingTheData];
    
}

- (void)settingTheData
{
    holeNameArray = [[NSMutableArray alloc] initWithObjects:@"01洞" ,@"02洞" ,@"03洞" ,@"04洞" ,@"05洞" ,@"06洞" , @"07洞" ,@"08洞" ,@"09洞" ,@"10洞" ,@"11洞" ,@"12洞" ,@"13洞" ,@"14洞" ,@"15洞" ,@"16洞" ,@"17洞" ,@"18洞" , nil];
    holeStateArray = [[NSMutableArray alloc] initWithObjects:@"缓堵",@"正常",@"非常拥堵",@"无人",@"缓堵",@"正常",@"非常拥堵",@"无人",@"缓堵",@"正常",@"非常拥堵",@"无人",@"缓堵",@"正常",@"非常拥堵",@"无人",@"缓堵",@"正常", nil];
    holeCountArray = [[NSMutableArray alloc] initWithObjects:@"3组球队",@"2组球队",@"3组球队",@"0组球队",@"3组球队",@"2组球队",@"3组球队",@"0组球队",@"3组球队",@"2组球队",@"3组球队",@"0组球队",@"3组球队",@"2组球队",@"3组球队",@"0组球队",@"3组球队",@"2组球队", nil];
    /*
     *0:无人 ;1:正常 ;2:缓堵 ;3:非常拥堵
     *
     */
    holeStateNumArray = [[NSMutableArray alloc] initWithObjects:@"2",@"1",@"3",@"0",@"2",@"1",@"3",@"0",@"2",@"1",@"3",@"0",@"2",@"1",@"3",@"0",@"2",@"1", nil];
    
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

/**
 *  调用该代理方法,实现查询到所点击的位置是否在某个球洞范围类,同时根据查询到的结果显示出更改球洞状态的视图
 *
 *  @param callout  callout
 *  @param feature  feature 点击到的位置的特征属性
 *  @param layer    layer 点击的图层
 *  @param mapPoint mapPoint 点击点
 *
 *  @return return value 返回NO,为了不显示callout视图
 */
- (BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint
{
    //
    NSDictionary *featureAttr = [feature allAttributes];
    
    NSString *querySQL;
    querySQL = [NSString stringWithFormat:@"QCM = '%ld'",[featureAttr[@"QCM"] integerValue]];
    self.query = [AGSQuery query];
    self.query.whereClause = querySQL;
    
    if (featureAttr[@"leixing"] == nil)
    {
        [_localHoleFeatureTable queryResultsWithParameters:_query completion:^(NSArray *results, NSError *error) {
            if (results.count) {
                AGSGDBFeature *curFeatrue = results[0];
                NSDictionary *curDic = [curFeatrue allAttributes];
                //将选择的球洞放大到屏幕中央
                [_CoursemapView zoomToGeometry:curDic[@"Shape"] withPadding:120 animated:YES];
                //
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showTheHoleFunction" object:self userInfo:nil];
                    
                });
                
            }
            
        }];
    }
    
//    NSLog(@"featureDic:%@",featureAttr);
    
    return NO;
}

- (void)removeTheGraphics
{
//    [_graphicLayer removeAllGraphics];
}


#pragma -mark mapViewDidLoad
/**
 *  mapViewDidLoad
 *
 *  @param mapView current mapView
 */
-(void)mapViewDidLoad:(AGSMapView *)mapView
{
    __weak typeof(self) weakSelf = self;
    //
    [self.CoursemapView.locationDisplay startDataSource];
    self.CoursemapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
    self.CoursemapView.locationDisplay.wanderExtentFactor = 0.75;
    //setting the geometry of the gps sketch layer to polyline.
    self.gpsSketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:self.CoursemapView.spatialReference];
    
    //set the midvertex symbol to nil to avoid the default circle symbol appearing in between vertices
    self.gpsSketchLayer.midVertexSymbol = nil;
    
    //
    NSString *querySQL;
    querySQL = [NSString stringWithFormat:@"QCM"];
    self.query = [AGSQuery query];
    self.query.whereClause = querySQL;
    
    [_localHoleFeatureTable queryResultsWithParameters:_query completion:^(NSArray *results, NSError *error) {
        for (AGSGDBFeature *eachFeature in results) {
            AGSGDBFeature *curFeatrue = eachFeature;
            NSDictionary *curDic = [curFeatrue allAttributes];
            
            //Create the AGSSimpleFillSymbol and set it’s color
            AGSSimpleFillSymbol* myFillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
            myFillSymbol.color = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:0.15];
            
            //Create the AGSSimpleLineSymbol used for the outline
            AGSSimpleLineSymbol* myOutlineSymbol = [AGSSimpleLineSymbol simpleLineSymbol];
            myOutlineSymbol.color = [UIColor yellowColor];
            myOutlineSymbol.width = 3;
            
            //set the outline property to myOutlineSymbol
            myFillSymbol.outline = myOutlineSymbol;
            
            
            AGSGraphic *holeGraphic = [[AGSGraphic alloc] initWithGeometry:curDic[@"Shape"] symbol:myFillSymbol attributes:nil];
            [weakSelf.graphicLayer addGraphic:holeGraphic];
        }
        
    }];
    //
//    [self displayAlltheGroupPosition];
    
}
/**
 *  构建模拟的球组GPS定位点
 *  获取到的数据还得通过循环给组装起来
 */
- (void)constructThePosition
{
//    groupPositionMarkArray
    groupPositionMarkArray = [[NSMutableArray alloc] initWithObjects:[[AGSPoint alloc] initWithX:106.28256131500 y:29.49389984490 spatialReference:[AGSSpatialReference wgs84SpatialReference]],[[AGSPoint alloc] initWithX:106.28256669700 y:29.49432700910 spatialReference:[AGSSpatialReference wgs84SpatialReference]],[[AGSPoint alloc] initWithX:106.28281553500 y:29.49458953090 spatialReference:[AGSSpatialReference wgs84SpatialReference]],[[AGSPoint alloc] initWithX:106.28296532100 y:29.49592164420 spatialReference:[AGSSpatialReference wgs84SpatialReference]],[[AGSPoint alloc] initWithX:106.28165696300 y:29.49617591050 spatialReference:[AGSSpatialReference wgs84SpatialReference]],[[AGSPoint alloc] initWithX:106.28128793600 y:29.49595571510 spatialReference:[AGSSpatialReference wgs84SpatialReference]],[[AGSPoint alloc] initWithX:106.28060691900 y:29.49565737550 spatialReference:[AGSSpatialReference wgs84SpatialReference]],[[AGSPoint alloc] initWithX:106.27988107400 y:29.49521089300 spatialReference:[AGSSpatialReference wgs84SpatialReference]], nil];
    
}
/**
 *  在graphicLayer上边绘制GPS模拟的球组所在的GPS定位点
 *  当从服务器上获取到的GPS实时数据时,更新GPS显示点,步骤是先把graphicLayer的所有图层给移除掉,之后再根据所获取到的数据来进行球洞状态对应的球洞的图层的刷新（即是重新添加当前的graphic到graphicLayer上）
 */
- (void)displayAllTheGroupPosition
{
    //create a marker symbol to be used by our Graphic
    AGSSimpleMarkerSymbol *myMarkerSymbol =
    [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    myMarkerSymbol.color = [UIColor redColor];
    
    AGSGeometryEngine *geoEngine = [[AGSGeometryEngine alloc] init];
    //构建几个模拟的位置
    [self constructThePosition];
    
    //
    for (AGSPoint *currentPoint in groupPositionMarkArray) {
        AGSPoint *markPoint = (AGSPoint *)[geoEngine projectGeometry:currentPoint toSpatialReference:self.CoursemapView.spatialReference];
        
        AGSGraphic* myGraphic =
        [AGSGraphic graphicWithGeometry:markPoint
                                 symbol:myMarkerSymbol
                             attributes:nil];
        
        //Add the graphic to the Graphics layer
        [_graphicLayer addGraphic:myGraphic];
    }
    
}

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
    NSLog(@"mappoint:%@",mappoint);
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
    
}

/**
 *  显示出所点击球洞的修改球洞功能(是否为起始球洞,球洞运行与否)的视图
 */
- (void)createCourseStateViews
{
    HoleFunctionChangeView *holeFunctionView;
    
    if ([holeFunctionView holeFunctionViewisShowing]) {
        NSLog(@"...holeHasentered...");
        return;
    }
    
    holeFunctionView = [[HoleFunctionChangeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 20, 157)];
    holeFunctionView.delegate = self;
    holeFunctionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:holeFunctionView];
    
    [holeFunctionView holeFunctionViewShow];
    
}

/**
 *  点击了球洞之后,通过通知中心来处理创建修改球洞功能的视图，通过判断通知的名称来创建相应的视图
 *
 *  @param notification notification 相应的通知
 */
- (void)changeCourseHoleStateResponse:(NSNotification *)notification
{
    if ([notification.name isEqualToString:@"showTheHoleFunction"]) {
        NSLog(@"...we have set confirm...");
        
        [self createCourseStateViews];
    }
    
}

/**
 *  隐藏视图
 */
- (void)dismissCourseStateViews
{
    
    NSLog(@"...we have set confirm...");
    
    [_backHalfAplphaView removeFromSuperview];
    
    for (UIView *theSubView in self.view.subviews) {
        if ([theSubView isKindOfClass:[HoleFunctionChangeView class]]) {
            [theSubView removeFromSuperview];
            
            HoleFunctionChangeView *holeView = (HoleFunctionChangeView *)theSubView;
            
            [holeView holeFunctionViewDismiss];
            
            
        }
    }
    
//    [holeFunctionView removeFromSuperview];
    
    _backHalfAplphaView.hidden = YES;
    _backHalfAplphaView = nil;
//    __weak typeof(self) weakSelf = self;
//    
//    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        [weakSelf.backHalfAplphaView removeFromSuperview];
//        [weakSelf.selectCourseStateView removeFromSuperview];
//        
//        
//        
//    } completion:^(BOOL finished) {
//        //
//        weakSelf.backHalfAplphaView = nil;
//        weakSelf.selectCourseStateView = nil;
//        
//        [weakSelf.backHalfAplphaView setValue:@"hide" forKey:@"courseState"];
//    }];
    
//    [self.backHalfAplphaView removeFromSuperview];
//    [self.selectCourseStateView removeFromSuperview];
    
    
    
}

/**
 *  建组按钮,此处是用来添加模拟的所有球组的GPS位置点
 *
 *  @param sender sender description
 */
- (IBAction)SubFunctionSelectFuntion:(UIButton *)sender {
    
//    [self createCourseStateViews];
    [self displayAllTheGroupPosition];
    
}


#pragma --mark  courseData tableView
/**
 *  数据界面的tableview的设置
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return holeNameArray.count;
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

/**
 *  该方法现在没有用
 *
 *  @param state        state description
 *  @param contentFrame contentFrame description
 *
 *  @return return value description
 */
- (UIView *)contentViewSetting:(NSInteger)state andFrame:(CGRect)contentFrame
{
    UIView *InContentView = [[UIView alloc] initWithFrame:CGRectMake(100, contentFrame.origin.y, 80, contentFrame.size.height)];
    
    UILabel *groupStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(InContentView.frame.origin.x, 0, 20, 44)];
    UILabel *groupCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(InContentView.frame.origin.x  + 40, 0, 35, 44)];
    //
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
//    static NSString *customTableIdentifier = @"customIdentifierCell";
    
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    
    cell.holeName.font = [UIFont systemFontOfSize:10];
    
    NSString *holeNameStr = holeNameArray[indexPath.section];
    cell.holeName.text = holeNameStr;
    
    NSString *string = holeNameStr;
    const CGFloat fontSize = 29.0;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    //    NSUInteger length = [string length];
    //设置字体
    UIFont *baseFont = [UIFont systemFontOfSize:fontSize];
    [attrString addAttribute:NSFontAttributeName value:baseFont range:NSMakeRange(0, 2)];//设置球洞号的字体大小
    cell.holeName.attributedText = attrString;
    
    cell.holeState.text = holeStateArray[indexPath.section];
    
    //
    NSString *holeCountStr = holeCountArray[indexPath.section];
    cell.holeCount.text = holeCountStr;
    const CGFloat fontSizee = 24.0;
    NSMutableAttributedString *attrStringg = [[NSMutableAttributedString alloc] initWithString:holeCountStr];
    //    NSUInteger length = [string length];
    //设置字体
    UIFont *baseFontt = [UIFont systemFontOfSize:fontSizee];
    [attrStringg addAttribute:NSFontAttributeName value:baseFontt range:NSMakeRange(0, 1)];//设置第一个字符的字体
    cell.holeCount.attributedText = attrStringg;
    
    //设置cell的颜色 0:无人 ;1:正常 ;2:缓堵 ;3:非常拥堵
    UIView *selectedBackView = [[UIView alloc] init];
    [selectedBackView setFrame:cell.frame];
    
    switch ([holeStateNumArray[indexPath.section] integerValue]) {
        case 0://no group
            [cell setBackgroundColor:[UIColor colorWithRed:181/255.0 green:181/255.0 blue:181/255.0 alpha:1.0]];
            [selectedBackView setBackgroundColor:[UIColor colorWithRed:181/255.0 green:181/255.0 blue:181/255.0 alpha:1.0]];
            cell.selectedBackgroundView = selectedBackView;
            
            break;
            
        case 1://正常
            cell.backgroundColor = [UIColor colorWithRed:86/255.0 green:219/255.0 blue:109/255.0 alpha:1.0];
            [selectedBackView setBackgroundColor:[UIColor colorWithRed:86/255.0 green:219/255.0 blue:109/255.0 alpha:1.0]];
            cell.selectedBackgroundView = selectedBackView;
            
            break;
            
        case 2://缓堵
            cell.backgroundColor = [UIColor colorWithRed:1.0 green:181/255.0 blue:1/255.0 alpha:1.0];
            [selectedBackView setBackgroundColor:[UIColor colorWithRed:1.0 green:181/255.0 blue:1/255.0 alpha:1.0]];
            cell.selectedBackgroundView = selectedBackView;
            
            break;
            
        case 3://非常拥堵
            cell.backgroundColor = [UIColor colorWithRed:238/255.0 green:76/255.0 blue:109/255.0 alpha:1.0];
            [selectedBackView setBackgroundColor:[UIColor colorWithRed:238/255.0 green:76/255.0 blue:109/255.0 alpha:1.0]];
            cell.selectedBackgroundView = selectedBackView;
            
            
            
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    //
    static NSIndexPath *oldIndexPath;
    
//    NSLog(@"did select indexPath.row:%ld",(long)indexPath.row);
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
//    NSLog(@"cell.frame.origin.y:%f  and size.height:%f",selectedCell.frame.origin.y,selectedCell.frame.size.height);
    //
    if (oldIndexPath == nil) {
        oldIndexPath = indexPath;
        //
        [self createAndDisEachHoleInfo:selectedCell.frame];
        //
//        selectedCell.accessoryView = nil;
//        UIButton *accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//        [accessoryButton setImage:[UIImage imageNamed:@"back_mapData.png"] forState:UIControlStateNormal];
//        selectedCell.accessoryView = accessoryButton;
        
    }
    else
    {
        if (indexPath == oldIndexPath) {
            oldIndexPath = nil;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            //
            [self dismissTheEachHoleInfoView];
            //
//            UITableViewCell *oldselectedCell = [tableView cellForRowAtIndexPath:indexPath];
//            oldselectedCell.accessoryView = nil;
//            UIButton *oldaccessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//            [oldaccessoryButton setImage:[UIImage imageNamed:@"more_mapData.png"] forState:UIControlStateNormal];
//            oldselectedCell.accessoryView = oldaccessoryButton;
            
        }
        else
        {
//            UITableViewCell *oldselectedCell = [tableView cellForRowAtIndexPath:oldIndexPath];
//            oldselectedCell.accessoryView = nil;
//            UIButton *oldaccessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//            [oldaccessoryButton setImage:[UIImage imageNamed:@"more_mapData.png"] forState:UIControlStateNormal];
//            oldselectedCell.accessoryView = oldaccessoryButton;
            //
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

/**
 *  给tableview调整整个可以滚动的高度
 *
 *  @param scrollView scrollView description
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _courseDataDisTable.contentSize = CGSizeMake(_courseDataDisTable.frame.size.width, 1560);
}

/**
 *  创建点击球洞的各个组的子视图
 *
 *  @param theFrame theFrame 获取到当前cell的frame,从而获取到子视图的位置
 */
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

/**
 *  隐藏掉各个球洞的球组的子视图
 */
- (void)dismissTheEachHoleInfoView
{
    [holeDetailView holeDetailDismiss];
}

/**
 *  创建导航栏右侧的按钮（搜索按钮）
 */
- (void)creatNavBarItem
{
    _rightItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleDone target:self action:@selector(changeDisforRightBar)];
    _rightItem.image = [UIImage imageNamed:@"search_mapData.png"];
    _rightItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = _rightItem;
}

/**
 *  球场状态的数据页的一些设置
 */
- (void)mapdataTypeSetting
{
    //hide mapview
    _CoursemapView.hidden = YES;
    //show data tableview
    _courseDataDisTable.hidden = NO;
    //
    _addGroupButton.enabled = NO;
    
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
    
//    _courseDataDisTable.contentSize = CGSizeMake(self.view.frame.size.width, 1596);
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
//            self.navigationItem.rightBarButtonItem = nil;
//            self.navigationItem.titleView = nil;
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
