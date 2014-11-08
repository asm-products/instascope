//
//  ISPageModelController.m
//  InstaScope
//
//  Created by Javier Luraschi on 9/17/14.
//  Copyright (c) 2014 Javier Luraschi. All rights reserved.
//


#import "ISPageModelController.h"
#import "ISViewController.h"

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


@interface ISPageModelController ()

@property (readonly, strong, nonatomic) NSMutableArray *pageData;
@end

@implementation ISPageModelController

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create the data model.
        NSString* jsonData = @""
        "["
        "   {"
        "      \"name\": \"San Francisco\", "
        "      \"latitude\": 37.808526, "
        "      \"longitude\": -122.409780 "
        "   },"
        "   {"
        "      \"name\": \"New York\", "
        "      \"latitude\": 40.758600, "
        "      \"longitude\": -73.985099 "
        "   },"
        "   {"
        "      \"name\": \"Paris\", "
        "      \"latitude\": 48.858205, "
        "      \"longitude\": 2.294686 "
        "   },"
        "   {"
        "      \"name\": \"Tokyo\", "
        "      \"latitude\": 35.626399, "
        "      \"longitude\": 139.782034 "
        "   },"
        "   {"
        "      \"name\": \"Sidney\", "
        "      \"latitude\": -33.865170, "
        "      \"longitude\": 151.192973 "
        "   },"
        "   {"
        "      \"name\": \"Mumbai\", "
        "      \"latitude\": 18.940172, "
        "      \"longitude\": 72.834757 "
        "   },"
        "   {"
        "      \"name\": \"Beijing\", "
        "      \"latitude\": 39.904746, "
        "      \"longitude\": 116.389675 "
        "   }"
        "]"
        "";
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSArray* locations = [defaults objectForKey:@"locations"];
        
        if (locations == nil) {
            NSError* error = nil;
            _pageData = [NSJSONSerialization
                JSONObjectWithData:[jsonData dataUsingEncoding:NSUTF8StringEncoding]
                options:NSJSONReadingAllowFragments
                error:&error];
            
            [defaults setObject:_pageData forKey:@"locations"];
            [defaults synchronize];
        }
        else {
            _pageData = [[NSMutableArray alloc] init];
            [_pageData addObjectsFromArray:locations];
        }
        
    }
    return self;
}

- (ISViewController*) viewControllerAtIndex: (NSUInteger)index storyboard: (UIStoryboard *)storyboard {
    // Return the data view controller for the given index.
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    ISViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"ISViewController"];
    dataViewController.dataObject = self.pageData[index];
    dataViewController.locationsIndex = index;
    return dataViewController;
}

- (NSUInteger)indexOfViewController: (ISViewController*)viewController {
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    return [self.pageData indexOfObject:viewController.dataObject];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController: (ISViewController*)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController*) pageViewController: (UIPageViewController*)pageViewController viewControllerAfterViewController: (UIViewController*)viewController
{
    NSUInteger index = [self indexOfViewController: (ISViewController*) viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageData count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
