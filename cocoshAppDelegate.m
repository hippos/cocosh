//
//  cocoshAppDelegate.m
//  cocosh
//
//  Created by hippos on 10/04/16.
//  Copyright 2010 hippos-lab.com. All rights reserved.
//

#import "cocoshAppDelegate.h"

@implementation cocoshAppDelegate

@synthesize window;
@synthesize matrix;
@synthesize exepath;
@synthesize scriptdescription,outputdescription;
@synthesize scripts;
@synthesize buttonEnabled;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
  [self appSetup];
}

#pragma mark ACTION

- (IBAction)performClick:(id)sender
{
  [self willChangeValueForKey:@"buttonEnabled"];
  if ([[matrix selectedCell] tag] == 0)
  {
    buttonEnabled = YES;
    [exepath setStringValue:NSLocalizedString(@"select execute directory",@"")];
    [self setPath:@""];
  }
  else
  {
    [self setAppSupportDirectory];
    buttonEnabled = NO;
  }
  [self didChangeValueForKey:@"buttonEnabled"];
}

- (IBAction)selectExecutePath:(id)sender
{
  NSOpenPanel *opanel = [NSOpenPanel openPanel];
  
  [opanel setCanChooseFiles:NO];
  [opanel setCanChooseDirectories:YES];
  [opanel setCanCreateDirectories:NO];
  
  [opanel beginSheetForDirectory:NSHomeDirectory() file:nil
                  modalForWindow:[NSApp mainWindow]  modalDelegate:self
                  didEndSelector:@selector(selectRunPathSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)selectRunPathSheetDidEnd:(NSOpenPanel *)openpanel returnCode:(int)returnCode contextInfo:(id)inf
{
  if (returnCode == NSCancelButton)
  {
    return;
  }
  
  [self setPath:[openpanel filename]];
  [exepath setStringValue:path];
  return;
}

- (IBAction)changeScript:(id)sender
{
  NSError  *err = nil;
  NSString *scriptText;
  
  switch ([scripts indexOfSelectedItem])
  {
    case 0:
      scriptText =
      [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cocosh" ofType:@"sh"] encoding:
       NSASCIIStringEncoding error:&err];
      break;
    case 1:
      scriptText =
      [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cocosh" ofType:@"pl"] encoding:
       NSASCIIStringEncoding error:&err];
      break;
    case 2:
      scriptText =
      [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cocosh" ofType:@"rb"] encoding:
       NSASCIIStringEncoding error:&err];
      break;
    case 3:
      scriptText =
      [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cocosh" ofType:@"py"] encoding:
       NSASCIIStringEncoding error:&err];
      break;
    default:
      scriptText =
      [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cocosh" ofType:@"sh"] encoding:
       NSASCIIStringEncoding error:&err];
      break;
  }
  if (err)
  {
    NSAlert *alert = [NSAlert alertWithError:err];
    [alert runModal];
  }
  else
  {
    NSAttributedString* scrpt = [[[NSAttributedString alloc] initWithString:scriptText] autorelease];
    [[scriptdescription textStorage] beginEditing];
    [[scriptdescription textStorage] setAttributedString:scrpt];
    [[scriptdescription textStorage] endEditing];
  }
}

- (IBAction)clearOutput:(id)sender
{
  [[outputdescription textStorage] beginEditing];
  [[outputdescription textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:@""] autorelease]];
  [[outputdescription textStorage] endEditing];  
}


- (IBAction)runCocosh:(id)sender
{
  if (!path || [[NSFileManager defaultManager] fileExistsAtPath:path] == NO)
  {
    NSAlert *alert =
      [NSAlert alertWithMessageText:NSLocalizedString(@"running path",
                                                      @"") defaultButton:@"OK" alternateButton:nil otherButton:nil
       informativeTextWithFormat:NSLocalizedString(@"running path not exists", @"")];
    [alert runModal];
    return;
  }

  NSError  *error  = nil;
  NSString *launch = [[scripts selectedItem] title];
  NSString *ext;
  switch([scripts indexOfSelectedItem])
  {
    case 0:
      ext = [NSString stringWithString:@"sh"];
      break;
    case 1:
      ext = [NSString stringWithString:@"pl"];
      break;
    case 2:
      ext = [NSString stringWithString:@"rb"];
      break;
    case 3:
      ext = [NSString stringWithString:@"py"];
      break;
  }
  
  NSString *dest   =
    [[path stringByAppendingPathComponent:@"cocosh"] stringByAppendingPathExtension:ext];

  if ([[NSFileManager defaultManager] fileExistsAtPath:dest] == YES)
  {
    [[NSFileManager defaultManager] removeItemAtPath:dest error:&error];
    if (error)
    {
      NSAlert *alert = [NSAlert alertWithError:error];
      [alert runModal];
      return;
    }
  }

  error = nil;
  [[scriptdescription string] writeToFile:dest atomically:YES encoding:NSASCIIStringEncoding error:&error];
  if (error)
  {
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert runModal];
    return;
  }

  NSTask *shell  = [[NSTask alloc] init];
  NSPipe *pipstd = [NSPipe pipe];
  NSPipe *piperr = [NSPipe pipe];

  [shell setStandardOutput:pipstd];
  [shell setStandardError:piperr];
  [shell setLaunchPath:launch];
  [shell setArguments:[NSArray arrayWithObject:dest]];
  [shell setCurrentDirectoryPath:path];
  [shell launch];
  [shell waitUntilExit];

  NSData *epipe = [[piperr fileHandleForReading] readDataToEndOfFile];
  char* buffer;
  if ([epipe length] > 0)
  {
    buffer = calloc([epipe length]+1, sizeof(char));
    [epipe getBytes:buffer length:[epipe length]];
    NSString *edesc = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    NSAlert  *alert =
      [NSAlert alertWithMessageText:NSLocalizedString(@"run error",
                                                      @"") defaultButton:@"OK" alternateButton:nil otherButton:nil
       informativeTextWithFormat:[edesc description]];
    [alert runModal];
    free(buffer);
    return;
  }

  NSData   *spipe      = [[pipstd fileHandleForReading] readDataToEndOfFile];
  buffer = calloc([spipe length]+1, sizeof(char));
  [spipe getBytes:buffer length:[spipe length]];
  NSString *resultText = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];

  [outputdescription selectAll:nil];
  NSRange start = [outputdescription selectedRange];
  NSRange end   = NSMakeRange(start.length, 0);
  [outputdescription setSelectedRange:end];
  [outputdescription insertText:resultText];
  free(buffer);
}

#pragma mark PROPERTY

- (NSString *)path
{
  return path;
}

- (void)setPath:(NSString *)value
{
  [self willChangeValueForKey:@"path"];
  [path release];
  path = nil;
  if ([value length] != 0)
  {
    path = [value copy];
  }
  
  [self didChangeValueForKey:@"path"];
}

#pragma mark OWNMETHOD

- (BOOL)appSetup
{
	buttonEnabled = NO;
  [scripts insertItemWithTitle:@"/bin/sh" atIndex:0];
  [scripts insertItemWithTitle:@"/usr/bin/perl" atIndex:1];
  [scripts insertItemWithTitle:@"/usr/bin/ruby" atIndex:2];
  [scripts insertItemWithTitle:@"/usr/bin/python" atIndex:3];
  [self changeScript:self];
  [self setAppSupportDirectory];
  return YES;
}

- (void)setAppSupportDirectory
{
  if ([self applicationSupporDirectory])
  {
    [self setPath:appPath];
    [exepath setStringValue:appPath];
  }
}

- (BOOL)applicationSupporDirectory
{
  NSArray  *paths    = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSString *temppath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
  appPath = [temppath stringByAppendingPathComponent:@"cocosh"];

  if (![[NSFileManager defaultManager] fileExistsAtPath:appPath isDirectory:NULL])
  {
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:appPath withIntermediateDirectories:YES attributes:nil error:&error])
    {
      NSAlert *alert = [NSAlert alertWithError:error];
      [alert runModal];
      return NO;
    }
  }
  return YES;
}

@end
