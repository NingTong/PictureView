//
//  AppDelegate.h
//  PictureView
//
//  Created by admin on 2020/07/13.
//  Copyright © 2020 tn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

