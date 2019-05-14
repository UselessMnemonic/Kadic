//
//  kadicView.m
//  kadic
//
//  Created by Christopher Madrigal on 5/12/19.
//  Copyright © 2019 Carthage. All rights reserved.
//

#import "kadicView.h"
#import <AppKit/AppKit.h>

@implementation kadicView

//these are the RGB components of the hue below
NSColor *components;
NSColor *hue;

//these are the bg images for the device
NSImage *nightImage;
NSImage *eveningImage;
NSImage *dayImage;

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
  
  //find the images in the bundle... must use package name, as main bundle seems to be Preferences
  NSBundle *thisBundle = [NSBundle bundleWithIdentifier:@"nihil.carthage.kadic"];
  
  NSString *pathToNightImage = [thisBundle pathForResource:@"night-bg" ofType:@"png"];
  NSString *pathToEveningImage = [thisBundle pathForResource:@"evening-bg" ofType:@"png"];
  NSString *pathToDayImage = [thisBundle pathForResource:@"day-bg" ofType:@"png"];
  
  //loads the images
  nightImage = [[NSImage alloc] initWithContentsOfFile:pathToNightImage];
  eveningImage = [[NSImage alloc] initWithContentsOfFile:pathToEveningImage];
  dayImage = [[NSImage alloc] initWithContentsOfFile:pathToDayImage];
  
  //if any of the images aren't loaded, panic
  if( !nightImage || !eveningImage || !dayImage ) return nil;
  
  //calculate the proper fill-to-screen size here
  NSSize newSize;
  double ratio;
  
  //choose the larger of the two dimensions and scale to fit
  if( frame.size.width > frame.size.height ) {
    ratio = (double)frame.size.width / nightImage.size.width;
  }
  else {
    ratio = (double)frame.size.height / nightImage.size.width;
  }
  
  newSize.height = nightImage.size.height * ratio;
  newSize.width = nightImage.size.width * ratio;

  //resize the images... horribly inefficient
  [nightImage setSize:newSize];
  [eveningImage setSize:newSize];
  [dayImage setSize:newSize];
  
  self = [super initWithFrame:frame isPreview:isPreview];
  if( !self ) return nil;
  [self setAnimationTimeInterval:60]; //update the image every minute
  return self;
}

- (void)startAnimation {
  [super startAnimation];
}

- (void)stopAnimation {
  [super stopAnimation];
}

- (void)drawRect:(NSRect)rect {
  [super drawRect:rect];
  
  //overlay the images in proper combination
  if( [components redComponent] > 0.0001 ) 
      [nightImage drawInRect:rect fromRect:rect operation:NSCompositingOperationSourceOver fraction:[components redComponent]];
  
  if( [components greenComponent] > 0.0001 ) 
      [dayImage drawInRect:rect fromRect:rect operation:NSCompositingOperationSourceOver fraction:[components greenComponent]];
  
  if( [components blueComponent] > 0.0001 ) 
      [eveningImage drawInRect:rect fromRect:rect operation:NSCompositingOperationSourceOver fraction:[components blueComponent]];
}

- (void) animateOneFrame {
  
  //begin by finding the current progression of the day
  NSDate *now = [NSDate date]; //the current time
  NSCalendar *thisCalendar = [NSCalendar currentCalendar]; //needed to obtain the units below
  double progress = ( [thisCalendar component:NSCalendarUnitMinute fromDate:now] / 59.0 ); //using the range [0, 60) -> [0, 360)
  
  //now generate a mixing mode based on three channels: RGB, using HSB as the hue rotator
  NSColorSpace *csRGBA = [NSColorSpace sRGBColorSpace];
  hue = [NSColor colorWithHue:progress saturation:1.0 brightness:1.0 alpha:1.0];
  components = [hue colorUsingColorSpace:csRGBA];
  [self setNeedsDisplay:true]; //draw function after this call
  return;
}

- (BOOL)hasConfigureSheet {
  return NO;
}

- (NSWindow*)configureSheet {
  return nil;
}

@end
