//
//  MHTextField.m
//
//  Created by Mehfuz Hossain on 4/11/13.
//  Copyright (c) 2013 Mehfuz Hossain. All rights reserved.
//

#import "MHTextField.h"

@interface MHTextField() <UIPickerViewDataSource, UIPickerViewDelegate>
{
    UITextField *_textField;
    BOOL _disabled;
    BOOL _enabled;
  
  BOOL _previousButtonState;
  BOOL _nextButtonState;
}

@property (nonatomic) BOOL keyboardIsShown;
@property (nonatomic) CGSize keyboardSize;
@property (nonatomic) BOOL hasScrollView;
@property (nonatomic) BOOL invalid;

@property (nonatomic, setter = setToolbarCommand:) BOOL isToolBarCommand;
@property (nonatomic, setter = setDoneCommand:) BOOL isDoneCommand;

@property (nonatomic , strong) UIBarButtonItem *previousBarButton;
@property (nonatomic , strong) UIBarButtonItem *nextBarButton;

@property (weak) id keyboardDidShowNotificationObserver;
@property (weak) id keyboardWillHideNotificationObserver;

- (void) selectInputView:(UITextField *)textField;

@end

@implementation MHTextField

@synthesize required;
@synthesize scrollView;
@synthesize toolbar;
@synthesize keyboardIsShown;
@synthesize keyboardSize;
@synthesize invalid;

- (void) awakeFromNib{
    [super awakeFromNib];
    [self setup];
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self){
        [self setup];
    }
    
    return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  if (self.orderedTextFieldsResponder.count == 0) {
    [self markTextFieldsWithTagInView:self.superview];
  }
  
  _enabled = YES;
}

- (void)setup{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:self];
    
    
    toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.window.frame.size.width, 44);
    // set style
    [toolbar setBarStyle:UIBarStyleDefault];
    
    self.previousBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Previous", @"Previous") style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonIsClicked:)];
    self.previousBarButton.enabled = _previousButtonState;
    self.nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"Next") style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonIsClicked:)];
    self.nextBarButton.enabled = _nextButtonState;
  
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonIsClicked:)];
    
    NSArray *barButtonItems = @[self.previousBarButton, self.nextBarButton, flexBarButton, doneBarButton];
    
    toolbar.items = barButtonItems;
    
    self.orderedTextFieldsResponder = [[NSMutableArray alloc]init];
}

- (void)markTextFieldsWithTagInView:(UIView*)view{
  NSMutableArray *mutatedTextfieldsArray = [NSMutableArray arrayWithCapacity:0];
    int index = 0;
    if ([self.orderedTextFieldsResponder count] == 0){
        for(UIView *subView in view.subviews){
            if ([subView isKindOfClass:[MHTextField class]]){
                MHTextField *textField = (MHTextField*)subView;
                textField.tag = index;
                [mutatedTextfieldsArray addObject:textField];
                index++;
            }
        }
      self.orderedTextFieldsResponder = [NSArray arrayWithArray:mutatedTextfieldsArray];
    }
}

- (void) doneButtonIsClicked:(id)sender{
    [self setDoneCommand:YES];
    [self resignFirstResponder];
    [self setToolbarCommand:YES];
}

- (void) nextButtonIsClicked:(id)sender{
    NSInteger tagIndex = self.tag;
    MHTextField *textField =  [self.orderedTextFieldsResponder objectAtIndex:++tagIndex];
    
    while (!textField.isEnabled && tagIndex < [self.orderedTextFieldsResponder count])
        textField = [self.orderedTextFieldsResponder objectAtIndex:++tagIndex];
    
    [self becomeActive:textField];
}

- (void) previousButtonIsClicked:(id)sender{
    NSInteger tagIndex = self.tag;
    
    MHTextField *textField =  [self.orderedTextFieldsResponder objectAtIndex:--tagIndex];
    
    while (!textField.isEnabled && tagIndex < [self.orderedTextFieldsResponder count])
        textField = [self.orderedTextFieldsResponder objectAtIndex:--tagIndex];
    
    [self becomeActive:textField];
}

- (void)becomeActive:(UITextField*)textField{
    [self setToolbarCommand:YES];
    [self resignFirstResponder];
    [textField becomeFirstResponder];
}

- (void)setBarButtonNeedsDisplayAtTag:(NSInteger)tag{
    BOOL previousBarButtonEnabled = NO;
    BOOL nexBarButtonEnabled = NO;
    
    for (int index = 0; index < [self.orderedTextFieldsResponder count]; index++) {
        
        UITextField *textField = [self.orderedTextFieldsResponder objectAtIndex:index];
        
        if (index < tag)
            previousBarButtonEnabled |= textField.isEnabled;
        else if (index > tag)
            nexBarButtonEnabled |= textField.isEnabled;
    }
    
    self.previousBarButton.enabled = previousBarButtonEnabled;
    self.nextBarButton.enabled = nexBarButtonEnabled;
  
  if (self.barButtonDisplayedBlock) {
    self.barButtonDisplayedBlock(self.previousBarButton, self.nextBarButton);
  }
}

- (void) selectInputView:(UITextField *)textField{
    if (_isDateField || _isTimeField){
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        if (_isDateField)
            datePicker.datePickerMode = UIDatePickerModeDate;
        else
            datePicker.datePickerMode = UIDatePickerModeTime;
      
        datePicker.maximumDate = self.maximumDate;
        datePicker.minimumDate = self.minimumDate;
        [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        if (![textField.text isEqualToString:@""]){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            if (self.dateFormat) {
                [dateFormatter setDateFormat:self.dateFormat];
            } else {
                [dateFormatter setDateFormat:@"MM/dd/YY"];
            }
            
            [dateFormatter setTimeStyle: NSDateFormatterShortStyle];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            
            if (self.selectedDate != nil)
                [datePicker setDate:self.selectedDate];
        }
        [textField setInputView:datePicker];
    }
    else if (_isPickerField) {
      UIPickerView *pickerView = [[UIPickerView alloc] init];
      pickerView.dataSource = self;
      pickerView.delegate = self;
      
      NSUInteger selectedIdx = [self.pickerDatas indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [self.text isEqualToString:obj];
      }];
      
      selectedIdx = (selectedIdx == NSNotFound) ? 0 : selectedIdx;
      [self pickerView:pickerView didSelectRow:selectedIdx inComponent:0];
      [pickerView selectRow:selectedIdx inComponent:0 animated:YES];
      
      [textField setInputView:pickerView];
    }
}

- (void)datePickerValueChanged:(id)sender{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    
    NSDate *selectedDate = datePicker.date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (self.dateFormat) {
        [dateFormatter setDateFormat:self.dateFormat];
    } else {
        [dateFormatter setDateFormat:@"MM/dd/YY"];
    }
    
    [_textField setText:[dateFormatter stringFromDate:selectedDate]];
    
    [self validate];
}

- (void)scrollToField
{
    CGRect textFieldRect = [[_textField superview] convertRect:_textField.frame toView:self.window];
    CGRect aRect = self.window.bounds;
    
    aRect.origin.y = -scrollView.contentOffset.y;
    aRect.size.height -= keyboardSize.height + self.toolbar.frame.size.height + 22;
    
    CGPoint textRectBoundary = CGPointMake(textFieldRect.origin.x, textFieldRect.origin.y + textFieldRect.size.height);
    
    if (!CGRectContainsPoint(aRect, textRectBoundary) || scrollView.contentOffset.y > 0) {
        CGPoint scrollPoint = CGPointMake(0.0, self.superview.frame.origin.y + _textField.frame.origin.y + _textField.frame.size.height - aRect.size.height);
        
        if (scrollPoint.y < 0) scrollPoint.y = 0;
        
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (BOOL) validate{
    
    _isValid = YES;
    
    if (required && [self.text isEqualToString:@""]){
        _isValid = NO;
    }
    else if (_isEmailField){
        NSString *emailRegEx =
        @"(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}"
        @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
        @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[A-Za-"
        @"z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5"
        @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
        @"9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
        @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
        
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        
        if (![emailTest evaluateWithObject:self.text]){
            _isValid = NO;
        }
    }
    
    [self setNeedsAppearance:self];
    
    return _isValid;
}

- (NSDate *)selectedDate
{
  if (!self.isDateField) {
    return nil;
  }
  
  static NSDateFormatter *dateFormatter;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [NSCalendar currentCalendar];
  });
  
  dateFormatter.dateFormat = self.dateFormat;
  
  return [dateFormatter dateFromString:self.text];
}

- (void)setDateFieldWithFormat:(NSString *)dateFormat
{
    self.isDateField = YES;
    self.dateFormat = dateFormat;
}

- (void)setEnabled:(BOOL)enabled{
    [super setEnabled:enabled];
    
    _enabled = enabled;
    
    [self setNeedsAppearance:self];
}

- (void)setNeedsAppearance:(id)sender
{
    // override in child class.
}

#pragma mark - UIKeyboard notifications

- (void) keyboardDidShow:(NSNotification *) notification{
    if (_textField== nil) return;
    if (keyboardIsShown) return;
    if (![_textField isKindOfClass:[MHTextField class]]) return;
    
    NSDictionary* info = [notification userInfo];
    
    NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardSize = [aValue CGRectValue].size;
    
    [self scrollToField];
    
    self.keyboardIsShown = YES;
}

- (void) keyboardWillHide:(NSNotification *) notification{
    NSTimeInterval duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        if (_isDoneCommand){
            [self.scrollView setContentOffset:CGPointMake(0, -scrollView.contentInset.top) animated:NO];
        }
    }];
    
    keyboardIsShown = NO;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self.keyboardDidShowNotificationObserver];
    [[NSNotificationCenter defaultCenter]removeObserver:self.keyboardWillHideNotificationObserver];
}

#pragma mark - UITextField notifications

- (void)textFieldDidBeginEditing:(NSNotification *) notification{
    UITextField *textField = (UITextField*)[notification object];
    
    _textField = textField;
    
    [self setKeyboardDidShowNotificationObserver:[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification *notification){
        [self keyboardDidShow:notification];
    }]];
    
    [self setKeyboardWillHideNotificationObserver:[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *notification){
        [self keyboardWillHide:notification];
    }]];
    
    [self setBarButtonNeedsDisplayAtTag:textField.tag];
    
    if ([self.superview isKindOfClass:[UIScrollView class]] && self.scrollView == nil){
        self.scrollView = (UIScrollView*)self.superview;
    }
    
    [self selectInputView:textField];
    [self setInputAccessoryView:toolbar];
    
    [self setToolbarCommand:NO];
}

- (void)textFieldDidEndEditing:(NSNotification *) notification{
    UITextField *textField = (UITextField*)[notification object];
    
    if ((_isDateField || _isTimeField) && [textField.text isEqualToString:@""] && _isDoneCommand){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        if (self.dateFormat) {
            [dateFormatter setDateFormat:self.dateFormat];
        } else {
            [dateFormatter setDateFormat:@"MM/dd/YY"];
        }
        
        [textField setText:[dateFormatter stringFromDate:[NSDate date]]];
    }
    
    [self validate];
    
    [self setDoneCommand:NO];
    
    _textField = nil;
}

#pragma mark - Keyboard next responder config methods

- (void)setKeyboardPreviousButtonEnable:(BOOL)val
{
  self.previousBarButton.enabled = val;
}

- (void)setKeyboardNextButtonEnable:(BOOL)val
{
  self.nextBarButton.enabled = val;
}

#pragma mark - UIPickerView required methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  NSInteger count = 0;
  if (self.pickerDatas != nil) {
    count = [self.pickerDatas count];
  }
  return count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
  NSString *title = @"";
  if (self.pickerDatas != nil) {
    title = self.pickerDatas[row];
  }
  return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  NSString *selectedTitle = self.pickerDatas[row];
  if (self.pickerDatas != nil) {
    self.text = selectedTitle;
    
    if (self.pickerChangedBlock) {
      self.pickerChangedBlock(pickerView);
    }
  }
}

@end

#pragma mark - UIKeyInput

@interface MHTextField (UIKeyInputIntegrate) <UIKeyInput>

@end

@implementation MHTextField (UIKeyInputIntegrate)

- (void)insertText:(NSString *)text
{
  [super insertText:text];
}

- (void)deleteBackward
{
  [super deleteBackward];
  if (self.deleteBackwardBlock) {
    self.deleteBackwardBlock(self);
  }
}

- (BOOL)hasText
{
  return [super hasText];
}

@end