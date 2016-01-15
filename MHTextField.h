//
//  MHTextField.h
//
//  Created by Mehfuz Hossain on 4/11/13.
//  Copyright (c) 2013 Mehfuz Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum ControlBarAction {
  ControlBarActionUnknown,
  ControlBarActionPrevious,
  ControlBarActionNext,
  ControlBarActionDone
} ControlBarAction;

typedef void(^deleteBackwardBlock)(id);
typedef void(^pickerChangedValueBlock)(id);
typedef void(^controlBarChangedTextFieldBlock)(id, ControlBarAction);

@interface MHTextField : UITextField

@property (nonatomic) BOOL required;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, readonly) NSDate *selectedDate;
@property (nonatomic, readonly) NSString *selectedDateString;
@property (nonatomic, strong) NSString *dateFormat;
@property (nonatomic, strong) NSDate *maximumDate;
@property (nonatomic, strong) NSDate *minimumDate;

@property (nonatomic, setter = setEmailField:)      BOOL isEmailField;
@property (nonatomic, setter = setPickerField:)     BOOL isPickerField;
@property (nonatomic, setter = setDateField:)       BOOL isDateField;
@property (nonatomic, setter = setTimeField:)       BOOL isTimeField;
@property (nonatomic, setter = setCustomInputView:) UIView *customInputView;
@property (nonatomic, readonly) BOOL isValid;

@property (nonatomic, strong) NSArray *pickerDatas;
@property (nonatomic, copy) pickerChangedValueBlock pickerChangedBlock;

@property (nonatomic, strong) NSArray *orderedTextFieldsResponder;

@property (nonatomic, copy) void (^barButtonDisplayedBlock)(UIBarButtonItem*, UIBarButtonItem*);
@property (nonatomic, copy) void (^deleteBackwardBlock)(MHTextField *);

/**
 An action block perform when user tabbed on keyboard's control "Previous/Next"
 */
@property (nonatomic, copy) void (^controlBarChangedTextFieldBlock)(MHTextField *, ControlBarAction);


- (BOOL) validate;
- (void) setDateFieldWithFormat:(NSString *)dateFormat;

/**
 Get date string by Textfield's date formatter.
 
 @param date Date which want to convert to string.
 */
- (NSString *)stringFromDate:(NSDate *)date;


/*
 Invoked when text field is disabled or input is invalid. Override to set your own tint or background color.
 */
- (void) setNeedsAppearance:(id)sender;

/**
 * Methods for set Previous/Next activation.
 */

- (void)setKeyboardPreviousButtonEnable:(BOOL)val;
- (void)setKeyboardNextButtonEnable:(BOOL)val;

/**
 
 */

@property (nonatomic, copy) void (^previousBarButtonAction)(MHTextField *);
@property (nonatomic, copy) void (^nextBarButtonAction)(MHTextField *);

@end
