//
//  MHTextField.h
//
//  Created by Mehfuz Hossain on 4/11/13.
//  Copyright (c) 2013 Mehfuz Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^deleteBackwardBlock)(id);

@interface MHTextField : UITextField

@property (nonatomic) BOOL required;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, readonly) NSDate *selectedDate;
@property (nonatomic, strong) NSString *dateFormat;
@property (nonatomic, strong) NSDate *maximumDate;

@property (nonatomic, setter = setEmailField:) BOOL isEmailField;
@property (nonatomic, setter = setDateField:) BOOL isDateField;
@property (nonatomic, setter = setTimeField:) BOOL isTimeField;
@property (nonatomic, readonly) BOOL isValid;

@property (nonatomic, strong) NSArray *orderedTextFieldsResponder;

@property (nonatomic, copy) void (^barButtonDisplayedBlock)(UIBarButtonItem*, UIBarButtonItem*);
@property (nonatomic, copy) void (^deleteBackwardBlock)(MHTextField *);

- (BOOL) validate;
- (void) setDateFieldWithFormat:(NSString *)dateFormat;

/*
 Invoked when text field is disabled or input is invalid. Override to set your own tint or background color.
 */
- (void) setNeedsAppearance:(id)sender;

/**
 * Methods for set Previous/Next activation.
 */

- (void)setKeyboardPreviousButtonEnable:(BOOL)val;
- (void)setKeyboardNextButtonEnable:(BOOL)val;

@end
