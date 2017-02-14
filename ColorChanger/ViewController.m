//
//  ViewController.m
//  ColorChanger
//
//  Created by Olivier on 14/02/2017.
//  Copyright © 2017 Olivier. All rights reserved.
//

#import "ViewController.h"

#define APP_NAME            @"ReactLayouts"
#define TEMPLATE_FILE       @"MainButtonTemplate"
#define SOURCE_FILE         @"MainButton.js"
#define COLOR_STR           @"$BUTTON_COLOR"
#define SCRIPT_FILE         @"push_staging.sh"

#define NODE_PATH           @"/usr/local/bin/node"
#define CODEPUSH_CLI_PATH   @"/usr/local/lib/node_modules/code-push-cli/script/cli.js"


@implementation ViewController

- (IBAction)onApplyClicked:(id)sender {
    
    [[self btApply] setEnabled:NO];
    [[self piWaiting] startAnimation:nil];
    [[self piWaiting] setHidden:NO];
    
    // get template, change color value, copy to source file
    
#ifdef DEBUG
    NSString * path = @"/Users/olivier/dev/mobirider/reactnative/ReactLayouts";
#else
    NSString * path = [NSString stringWithFormat:@"%@/..", [[NSBundle mainBundle] bundlePath]];
#endif
    
    NSString * c = [NSString stringWithFormat:@"rgba(%d, %d, %d, 255)",
                    (int)([[self color] redComponent] * 255),
                    (int)([[self color] greenComponent] * 255),
                    (int)([[self color] blueComponent] * 255)];
    
    NSString * template = [NSString stringWithFormat:@"%@/app/%@", path, TEMPLATE_FILE];
    NSString * code = [NSString stringWithFormat:@"%@/app/%@", path, SOURCE_FILE];
    

    NSData * data = [[NSFileManager defaultManager] contentsAtPath:template];
    
    NSString * datastr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    datastr = [datastr stringByReplacingOccurrencesOfString:COLOR_STR withString:c];
    
    [[NSFileManager defaultManager] createFileAtPath:code contents:[datastr dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    
//    NSString * script = [NSString stringWithFormat:@"%@/../%@", [[NSBundle mainBundle] bundlePath], SCRIPT_FILE];
//    [self runScript:@"/Users/olivier/dev/mobirider/reactnative/ReactLayouts/push_staging.sh"];
    
    
//    NSTask * t = [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObject:@"/usr/local/bin/node"]];
//    NSString * app = APP_NAME;

    
    // generate script
    NSString * scriptfile = [NSString stringWithFormat:@"%@/push.sh", path];
    NSString *script = @"\
        cd $_PATH_ \n\
        APP_NAME=${PWD##*/} \n\
        echo \"======== Pushing $APP_NAME-ios to Staging... ========\" \n\
        code-push release-react $APP_NAME-ios ios -d Staging \n\
        echo \"======== Pushing $APP_NAME-android to Staging... ====\" \n\
        code-push release-react $APP_NAME-android android -d Staging \n\
        exit";
    
    script = [script stringByReplacingOccurrencesOfString:@"$_PATH_" withString:path];
    
    
    [[NSFileManager defaultManager] createFileAtPath:scriptfile contents:[script dataUsingEncoding:NSUTF8StringEncoding] attributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithShort:0x777] forKey:NSFilePosixPermissions]];
    
    
        // launch script
    NSTask *task = [[NSTask alloc]init];
        task.launchPath = @"/usr/bin/open";
        task.currentDirectoryPath = @"~";
    task.arguments = @[@"-a", @"Terminal.app", scriptfile];
        [task launch];
    
    
    [[self btApply] setEnabled:YES];
    [[self piWaiting] stopAnimation:nil];
    [[self piWaiting] setHidden:YES];
}





- (NSColorPanel *) colorPanel {
    return [NSColorPanel sharedColorPanel];
}


- (NSApplication *) sharedApplication{
    return [NSApplication sharedApplication];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.colorPanel.delegate = self;
//    self.colorPanel.isFloatingPanel=YES;
    self.colorPanel.hidesOnDeactivate = false;
    self.colorPanel.showsAlpha = true;
    [self.colorPanel setTitle: @"Color Panel"];
    [self.colorPanel makeKeyAndOrderFront:nil];
    
    
    [self.colorPanel setTarget:self];
    [self.colorPanel setAction:@selector(colorUpdate:)];
    
    
    [[self btApply] setEnabled:NO];
    [[self piWaiting] setHidden:YES];


}

-(void)colorUpdate:(NSColorPanel*)colorPanel{
    [self setColor: colorPanel.color];
    [[[self view] layer] setBackgroundColor:self.color.CGColor];
    [[self btApply] setEnabled:YES];
}



- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)windowWillClose:(NSNotification *)notification {
    [[self sharedApplication] terminate:nil];
}

@end
