//
//  FirstViewController.m
//  LaLaApp
//
//  Created by Dejan Krstevski on 4/27/17.
//  Copyright © 2017 sp. All rights reserved.
//

#import "FirstViewController.h"
#import "LaLaAppCurrentSession.h"

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UILabel *whoLabel;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *attr = [[LaLaAppCurrentSession session] getAllAttributes];
    NSLog(@"attr: %@",attr);
//    NSLog(@"all vals:");
//    for (NSString *atrstr in [[LaLaAppCurrentSession session] getAllAttributes]) {
//        NSLog(@"%@ = %@", atrstr, [[LaLaAppCurrentSession session] getValueForAttribute:atrstr]);
//    }
    [_whoLabel setText:[NSString stringWithFormat:@"%@",[[LaLaAppCurrentSession session] getValueForAttribute:@"name"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionSignOutButton {
    
    [[LaLaAppCurrentSession session] logout];
    [self.navigationController popViewControllerAnimated:YES];
    
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
