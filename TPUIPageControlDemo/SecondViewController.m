//
//  SecondViewController.m
//  TPUIPageControlDemo
//
//  Created by TP on 2017/3/15.
//  Copyright © 2017年 Tendyron. All rights reserved.
//

#import "SecondViewController.h"
#import "ThirdViewController.h"


@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    // Do any additional setup after loading the view.
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(40.0, 150.0, [UIScreen mainScreen].bounds.size.width - 80.0, 300.0)];
    tipView.backgroundColor = [UIColor redColor];
    [self.view addSubview:tipView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [tipView addGestureRecognizer:tap];
///*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ThirdViewController *third = [[ThirdViewController alloc] init];
        [self.navigationController presentViewController:third animated:YES completion:nil];
    });
// */
}

- (void)tapAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

@end
