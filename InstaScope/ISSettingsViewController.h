//
//  ISLocationSettings.h
//  InstaScope
//
//  Created by Javier Luraschi on 9/17/14.
//  Copyright (c) 2014 Javier Luraschi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ISSettingsViewController : UIViewController<UITextFieldDelegate>
{

}

@property (weak, nonatomic) IBOutlet UITextField* searchTextField;
@property (weak, nonatomic) IBOutlet UIButton* addLocationButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;

@end
