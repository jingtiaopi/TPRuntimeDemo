//
//  NewChangePinViewController.m
//  iOSToken
//
//  Created by TP on 2017/2/15.
//  Copyright © 2017年 lujun. All rights reserved.
//

#import "NewChangePinViewController.h"


#define MIN_LIMIT 6
#define MAX_LIMIT 30
#define kScreenWidth (CGRectGetWidth([UIScreen mainScreen].bounds))

//状态栏高度
#define STATUSBAR_HEIGHT            20
#define NAVIGATIONBAR_HEIGHT        44

@interface NewChangePinViewController () //<UITableViewDelegate, UITableViewDataSource>
{
    //防止暴力点击
    BOOL buttonPressInUsing;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *sectionArrays;
@property (nonatomic, retain) NSArray *rowsArrays;
@property (nonatomic, retain) NSArray *placeholderArrays;
@property (nonatomic, retain) UIImageView *navBgImageView;
@property (nonatomic, retain) UIColor *navTitleColor;
@property (nonatomic, retain) UIView *backView;

@end

@implementation NewChangePinViewController

//- (instancetype)init
//{
//    self = [super init];
//    if (self)
//    {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iOSDevicePlugIn:) name:kTDRAudioPlugInNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iOSDevicePlugOut:) name:kTDRAudioPlugOutNotification object:nil];
//    }
//    return self;
//}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
//    [self checkDeviceExist:YES showAlert:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.backView removeFromSuperview];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    CGRect frame = CGRectMake(0, 0, kScreenWidth, STATUSBAR_HEIGHT + NAVIGATIONBAR_HEIGHT);
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:frame];
    UIColor *navigationTintColor = [UIColor blueColor];
    [navBar setTintColor:navigationTintColor];
    UINavigationItem *navigationTitle = [[UINavigationItem alloc] init];
    [navBar pushNavigationItem:navigationTitle animated:NO];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(70, CGRectGetMinY(frame), CGRectGetWidth(frame) - 140, CGRectGetHeight(frame))];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:18.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = navigationTintColor;
    navigationTitle.titleView = label;
    label.text = @"大夫说了富华大厦返回来";//[[TDRLanguage sharedTDRLanguage] stringForKey:@"changePin"];
    [navBar addSubview:label];
//    [navigationTitle release];
//    [label release];
    [self.view addSubview:navBar];
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
/*
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    UIColor *navigationTintColor = [UIColor colorFromHexRGB:@"607483"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:38.0 * ProportionOfFont], NSForegroundColorAttributeName:navigationTintColor}];
    [self.navigationController.navigationBar setTintColor:navigationTintColor];
    self.navigationItem.title = [[TDRLanguage sharedTDRLanguage] stringForKey:@"changePin"];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
*/
    CGFloat backViewHeight = 25.0;
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(14.0 / 2, (CGRectGetHeight(navBar.frame) - 8.0 - backViewHeight)/*(64.0 - backViewHeight) / 2*/, 60.0, backViewHeight)];
//    UIImage *normalImage = [UIImage imageWithData:[NSData dataFromBase64String:kNavigationBackNormalImage]];
    UIImage *normalImage = [UIImage imageNamed:@"newback"];
    CGFloat imageHeight = 20.0;//CGRectGetHeight(backView.frame);
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, (CGRectGetHeight(self.backView.frame) - imageHeight) / 2, normalImage.size.width * imageHeight / normalImage.size.height, imageHeight)];
    backImageView.image = normalImage;
    backImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toBackAction)];
    self.backView.backgroundColor = [UIColor clearColor];
    [backImageView addGestureRecognizer:backTap];
//    [backTap release];
    [self.backView addSubview:backImageView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backButton.frame = CGRectMake(CGRectGetMaxX(backImageView.frame), 0, CGRectGetWidth(self.backView.frame) - CGRectGetWidth(backImageView.frame), CGRectGetHeight(self.backView.frame));
    backButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [backButton addTarget:self action:@selector(toBackAction) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [self.backView addSubview:backButton];
//    [backImageView release];
//    self.navigationController.navigationBar.topItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backView] autorelease];
    [navBar addSubview:self.backView];
//    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backView] autorelease];
/*使用UIButton创建带返回箭头的返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 85.0, 30.0);
    [backButton setTitle:[[TDRLanguage sharedTDRLanguage] stringForKey:@"back"] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [backButton setTitleColor:[UIColor colorWithRed:97.0 / 255.0 green:116.0 / 255.0 blue:131.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    UIImage *normalImage = [UIImage imageWithData:[NSData dataFromBase64String:kNavigationBackNormalImage]];
    UIImage *highlightedImage = [UIImage imageWithData:[NSData dataFromBase64String:kNavigationBackHighlightedImage]];
    [backButton setImage:normalImage forState:UIControlStateNormal];
    [backButton setImage:highlightedImage forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(toBackAction) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, -CGRectGetMaxX(backButton.imageView.frame) + 25.0, 0, CGRectGetMaxX(backButton.imageView.frame));
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -CGRectGetWidth(backButton.titleLabel.frame) + 20.0, 0, CGRectGetWidth(backButton.titleLabel.frame));
    self.navigationController.navigationBar.topItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
*/
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    //导航栏下边线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(navBar.frame) - 0.5, CGRectGetWidth(self.view.frame), 0.5)];
    lineView.backgroundColor = [UIColor colorWithRed:212.0 / 255.0 green:223.0 / 255.0 blue:229.0 / 255.0 alpha:1.0];
    [navBar addSubview:lineView];
//    [lineView release];
//    [navBar release];
    self.sectionArrays = @[
                           @"原密码",
                           @"新密码"
                           ];
    self.rowsArrays = @[
                        @[
                            @"通用U盾原密码"
                         ],
                        @[
                            @"通用U盾新密码",
                            @"再次输入U盾新密码"
                         ]
                        ];
    self.placeholderArrays = @[
                               @[
                                   @"请输入"
                                   ],
                               @[
                                   @"6-30位数字或字母",
                                   @"6-30位数字或字母"
                                   ]
                               ];
    CGRect tableViewRect = CGRectMake(0, CGRectGetMaxY(navBar.frame), kScreenWidth, CGRectGetHeight(self.view.frame) - CGRectGetMaxY(navBar.frame));
    self.tableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStylePlain];
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSafeKeyboard)];
    [self.view addGestureRecognizer:tap];
//    [tap release];
}

- (void)toBackAction
{
//    [self hideSafeKeyboard];
    if (self.presentingViewController)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)hideSafeKeyboard
{
    [self.view endEditing:YES];
}

@end
