//
//  KHViewController.h
//  KHDiscreteSlider
//
//  Created by Alexander Nazarenko on 12/28/13.
//  Copyright (c) 2013 Alexander Nazarenko. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KHDiscreteSlider.h"

@interface KHViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *minimumValueLabel;
@property (nonatomic, strong) IBOutlet UILabel *maximumValueLabel;
@property (nonatomic, strong) IBOutlet UITextField *minimumValueTextField;
@property (nonatomic, strong) IBOutlet UITextField *maximumValueTextField;
@property (nonatomic, strong) IBOutlet UITextField *stepValueTextField;
@property (nonatomic, strong) IBOutlet UILabel *currentValueLabel;
@property (nonatomic, strong) IBOutlet KHDiscreteSlider *slider;
@property (nonatomic, strong) IBOutlet UISwitch *isDiscreteSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *animatesWhenDraggedSwitch;

- (IBAction)valueChangedInSlider:(id)sender;
- (IBAction)valueChangedInSwitch:(id)sender;

@end
