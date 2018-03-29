//
//  ThirdViewController.m
//  TPUIPageControlDemo
//
//  Created by TP on 2017/3/15.
//  Copyright © 2017年 Tendyron. All rights reserved.
//

#import "ThirdViewController.h"

@interface ThirdViewController ()

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    // Do any additional setup after loading the view.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"%@, %@, %@, %@", self.presentationController, self.presentedViewController, self.presentingViewController, self.navigationController.popoverPresentationController);
        [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
            [((UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController) popToRootViewControllerAnimated:YES];
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
