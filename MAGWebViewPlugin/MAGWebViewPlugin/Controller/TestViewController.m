//
//  TestViewController.m
//  MAGWebViewPlugin
//
//  Created by appl on 2019/5/5.
//  Copyright © 2019 lyeah. All rights reserved.
//

#import "TestViewController.h"
#import "MAGWebClientViewController.h"
#import <Masonry/Masonry.h>

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *webButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [webButton setTitle:@"MAGWebView" forState:UIControlStateNormal];
    [webButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [webButton addTarget:self action:@selector(webButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:webButton];
    [webButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(100.0f);
        make.size.mas_equalTo(CGSizeMake(200, 44));
    }];
}

- (void)webButtonPressed:(UIButton *)button
{
    MAGWebClientViewController *clientVC = [[MAGWebClientViewController alloc] init];
    [self.navigationController pushViewController:clientVC animated:YES];
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
