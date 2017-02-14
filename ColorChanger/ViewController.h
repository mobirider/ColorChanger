//
//  ViewController.h
//  ColorChanger
//
//  Created by Olivier on 14/02/2017.
//  Copyright © 2017 Olivier. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController <NSWindowDelegate>

@property (weak) IBOutlet NSButtonCell *btApply;
@property (weak) IBOutlet NSProgressIndicator *piWaiting;

@property (strong, nonatomic) NSColor * color;

@end

