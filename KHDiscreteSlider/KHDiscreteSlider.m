// KHDiscreteSlider.m
//
// Copyright (c) 2013 Alexander Nazarenko
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "KHDiscreteSlider.h"

static void * __KHDiscreteSliderKVOContext = (void *)&__KHDiscreteSliderKVOContext;
static const NSTimeInterval kStepAnimationDuration = 0.2;

@interface KHDiscreteSlider ()

@property (nonatomic, assign) float backedUpMaximumValue;
@property (nonatomic, assign) float backedUpMinimumValue;
@property (nonatomic, assign, getter = isBeingDragged) BOOL beingDragged;

@end

@implementation KHDiscreteSlider

#pragma mark - Lifecycle (KVO Setup)

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self addObserver:self forKeyPath:@"discrete" options:0 context:__KHDiscreteSliderKVOContext];
        [self addObserver:self forKeyPath:@"discreteStepValue" options:0 context:__KHDiscreteSliderKVOContext];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self addObserver:self forKeyPath:@"discrete" options:0 context:__KHDiscreteSliderKVOContext];
    [self addObserver:self forKeyPath:@"discreteStepValue" options:0 context:__KHDiscreteSliderKVOContext];
    self.backedUpMaximumValue = self.maximumValue;
    self.backedUpMinimumValue = self.minimumValue;
    
    // trigger discrete-related KVO operation to handle minimum, maximum, current and step values correctly
    [self willChangeValueForKey:@"discrete"];
    [self didChangeValueForKey:@"discrete"];
    [self willChangeValueForKey:@"discreteStepValue"];
    [self didChangeValueForKey:@"discreteStepValue"];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"discrete" context:__KHDiscreteSliderKVOContext];
    [self removeObserver:self forKeyPath:@"discreteStepValue" context:__KHDiscreteSliderKVOContext];
}

#pragma mark - Accessory KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != __KHDiscreteSliderKVOContext)
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    float newMaximumValue = self.maximumValue;
    float newMinimumValue = self.minimumValue;
    
    if ([keyPath isEqualToString:@"discrete"])
    {
        if (self.isDiscrete)
        {
            // clip maximum and minimum values while backing up the originals
            self.backedUpMaximumValue = newMaximumValue;
            self.backedUpMinimumValue = newMinimumValue;
            newMaximumValue = floorf(newMaximumValue / self.discreteStepValue) * self.discreteStepValue;
            newMinimumValue = ceilf(newMinimumValue / self.discreteStepValue) * self.discreteStepValue;
            
            // also round the current value
            self.value = roundf(self.value / self.discreteStepValue) * self.discreteStepValue;
        }
        else
        {
            // restore backed up unclipped minimum and maximum
            newMaximumValue = self.backedUpMaximumValue;
            newMinimumValue = self.backedUpMinimumValue;
        }
    }
    else if ([keyPath isEqualToString:@"discreteStepValue"])
    {
        if (self.isDiscrete)
        {
            newMaximumValue = self.backedUpMaximumValue;
            newMinimumValue = self.backedUpMinimumValue;
            
            newMaximumValue = floorf(newMaximumValue / self.discreteStepValue) * self.discreteStepValue;
            newMinimumValue = ceilf(newMinimumValue / self.discreteStepValue) * self.discreteStepValue;
            
            // also round the current value
            self.value = roundf(self.value / self.discreteStepValue) * self.discreteStepValue;
        }
    }
    
    super.maximumValue = newMaximumValue;
    super.minimumValue = newMinimumValue;
}

#pragma mark - UISlider methods overrides

- (void)setValue:(float)value animated:(BOOL)animated
{
    if (self.isDiscrete)
    {
        value = round(value / self.discreteStepValue) * self.discreteStepValue;
        if (self.value != value)
        {
            // have to distinguish setValue: called from the UI and from the user code
            animated = !self.isBeingDragged ? animated : self.animatesWhenDraggedInDiscrete;
            
            if(animated)
            {
                [UIView animateWithDuration:kStepAnimationDuration animations:^{
                    [super setValue:value animated:YES];
                }];
            }
            else
            {
                [super setValue:value animated:NO];
            }
        }
    }
    else
    {
        [super setValue:value animated:animated];
    }
}

- (void)setMinimumValue:(float)minimumValue
{
    if (self.isDiscrete)
    {
        self.backedUpMinimumValue = minimumValue;
        minimumValue = ceil(minimumValue / self.discreteStepValue) * self.discreteStepValue;
    }
    
    super.minimumValue = minimumValue;
}

- (void)setMaximumValue:(float)maximumValue
{
    if (self.isDiscrete)
    {
        self.backedUpMaximumValue = maximumValue;
        maximumValue = floor(maximumValue / self.discreteStepValue) * self.discreteStepValue;
    }
    
    super.maximumValue = maximumValue;
}

#pragma mark - Accessory UIView touch-related methods overrides

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    self.beingDragged = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    self.beingDragged = NO;
}

@end
