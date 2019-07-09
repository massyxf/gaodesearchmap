//
//  ViewController.m
//  GDDemo
//
//  Created by yxf on 2019/7/3.
//  Copyright © 2019 k_yan. All rights reserved.
//

#import "ViewController.h"
#import "GDDemo-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
}

- (IBAction)jump:(id)sender {
    UIViewController *mapVc = [KMapViewController mapVc];
    [self presentViewController:mapVc animated:YES completion:nil];
}

@end
