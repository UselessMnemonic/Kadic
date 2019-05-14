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

NSColor *components;
NSColor *hue;

NSImage *nightImage;
NSImage *eveningImage;
NSImage *dayImage;

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
  //find the images
  NSBundle *thisBundle = [NSBundle bundleWithIdentifier:@"nihil.carthage.kadic"];
  NSString *pathToNightImage = [thisBundle pathForResource:@"night-bg" ofType:@"png"];
  NSString *pathToEveningImage = [thisBundle pathForResource:@"evening-bg" ofType:@"png"];
  NSString *pathToDayImage = [thisBundle pathForResource:@"day-bg" ofType:@"png"];
  
  //load the images
  nightImage = [[NSImage alloc] initWithContentsOfFile:pathToNightImage];
  eveningImage = [[NSImage alloc] initWithContentsOfFile:pathToEveningImage];
  dayImage = [[NSImage alloc] initWithContentsOfFile:pathToDayImage];
  
  if( !nightImage || !eveningImage || !dayImage ) return nil;
  
  //calculate the proper fill-to-screen size
  NSSize newSize;
  double ratio;
  
  if( frame.size.width > frame.size.height ) {
    ratio = (double)frame.size.width / nightImage.size.width;
  }
  else {
    ratio = (double)frame.size.height / nightImage.size.width;
  }
  
  newSize.height = nightImage.size.height * ratio;
  newSize.width = nightImage.size.width * ratio;

  //set the image sizes
  [nightImage setSize:newSize];
  [eveningImage setSize:newSize];
  [dayImage setSize:newSize];

  self = [super initWithFrame:frame isPreview:isPreview];

  if( !self ) return nil;
  
  [self setAnimationTimeInterval:60];
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
  
  //reset the rectangle with a black BG
  [[NSColor blackColor] set];
  NSRectFill(rect);
  
  //overlay the images in proper combination
  if( [components redComponent] > 0.000001 ) 
      [nightImage drawInRect:rect fromRect:rect operation:NSCompositingOperationSourceOver fraction:[components redComponent]];
  
  if( [components greenComponent] > 0.000001 ) 
      [dayImage drawInRect:rect fromRect:rect operation:NSCompositingOperationSourceOver fraction:[components greenComponent]];
  
  if( [components blueComponent] > 0.000001 ) 
      [eveningImage drawInRect:rect fromRect:rect operation:NSCompositingOperationSourceOver fraction:[components blueComponent]];
}

- (void) animateOneFrame {
  
  //begin by finding the current progression of the day
  NSDate *now = [NSDate date];
  NSCalendar *thisCalendar = [NSCalendar currentCalendar];
  double progress = ( [thisCalendar component:NSCalendarUnitMinute fromDate:now] / 59.0 );
  //now generate a mixing mode based on three channels: RGB, using HSB as the hue rotator
  NSColorSpace *csRGBA = [NSColorSpace sRGBColorSpace];
  hue = [NSColor colorWithHue:progress saturation:1.0 brightness:1.0 alpha:1.0];
  components = [hue colorUsingColorSpace:csRGBA];
  [self setNeedsDisplay:true];
  return;
}

- (BOOL)hasConfigureSheet {
  return NO;
}

- (NSWindow*)configureSheet {
  return nil;
}

@end
