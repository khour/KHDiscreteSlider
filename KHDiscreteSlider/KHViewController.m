//
//  KHViewController.m
//  KHDiscreteSlider
//
//  Created by Alexander Nazarenko on 12/28/13.
//  Copyright (c) 2013 Alexander Nazarenko. All rights reserved.
//

#import "KHViewController.h"

@interface KHViewController () <UITextFieldDelegate>

@end

@implementation KHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _processInputFromMinimumValueTextField:self.minimumValueTextField];
    [self _processInputFromMinimumValueTextField:self.maximumValueTextField];
    [self _processInputFromMinimumValueTextField:self.stepValueTextField];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)valueChangedInSlider:(id)sender
{
    [self _updateUIWithSliderState];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self _processInputFromMinimumValueTextField:textField];
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)valueChangedInSwitch:(id)sender
{
    if (sender == self.isDiscreteSwitch)
    {
        // works both with property and KVO
//        [self.slider setValue:[NSNumber numberWithBool:self.isDiscreteSwitch.on] forKeyPath:@"discrete"];
        self.slider.discrete = self.isDiscreteSwitch.on;
    }
    else if (sender == self.animatesWhenDraggedSwitch)
    {
        self.slider.animatesWhenDraggedInDiscrete = self.animatesWhenDraggedSwitch.on;
    }
    
    [self _updateUIWithSliderState];
}

- (void)_updateUIWithSliderState
{
    self.minimumValueLabel.text = [NSString stringWithFormat:@"%f", self.slider.minimumValue];
    self.maximumValueLabel.text = [NSString stringWithFormat:@"%f", self.slider.maximumValue];
    self.currentValueLabel.text = [NSString stringWithFormat:@"%f", self.slider.value];
    self.isDiscreteSwitch.on = self.slider.isDiscrete;
    self.animatesWhenDraggedSwitch.on = self.slider.animatesWhenDraggedInDiscrete;
}

- (void)_processInputFromMinimumValueTextField:(UITextField *)textField
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *value = [formatter numberFromString:textField.text];
    
    if (value == nil)
    {
        textField.text = @"0.0";
        value = @0.0;
    }
    
    float floatValue = [value floatValue];
    
    if (textField == self.minimumValueTextField)
    {
        self.slider.minimumValue = floatValue;
    }
    else if (textField == self.maximumValueTextField)
    {
        self.slider.maximumValue = floatValue;
    }
    else if (textField == self.stepValueTextField)
    {
        self.slider.discreteStepValue = floatValue;
    }
    
    [self _updateUIWithSliderState];
}

@end
