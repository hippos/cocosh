//
//  cocoshAppDelegate.h
//  cocosh
//
//  Created by hippos on 10/04/16.
//  Copyright 2010 hippos-lab.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface cocoshAppDelegate : NSObject <NSApplicationDelegate> 
{
  NSWindow      *window;
  NSMatrix      *matrix;
  NSTextField   *exepath;
  NSTextView    *scriptdescription;
  NSTextView    *outputdescription;
  NSPopUpButton *scripts;
  NSString      *path;
  BOOL          buttonEnabled;
@private
  NSString      *appPath;
}

- (IBAction) runCocosh:(id)sender;
- (IBAction) selectExecutePath:(id)sender;
- (IBAction) performClick:(id)sender;
- (IBAction) changeScript:(id)sender;
- (IBAction) clearOutput:(id)sender;

- (BOOL)      appSetup;
- (void)      setAppSupportDirectory;

- (BOOL)      applicationSupporDirectory;
- (void)      setPath:(NSString *)value;
- (NSString *)path;

@property (assign) IBOutlet NSWindow      *window;
@property (assign) IBOutlet NSMatrix      *matrix;
@property (assign) IBOutlet NSTextField   *exepath;
@property (assign) IBOutlet NSTextView    *scriptdescription;
@property (assign) IBOutlet NSTextView    *outputdescription;
@property (assign) IBOutlet NSPopUpButton *scripts;
@property (assign) BOOL                   buttonEnabled;

@end
