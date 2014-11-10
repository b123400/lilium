//
//  AboutViewController.m
//  perSecond
//
//  Created by b123400 on 29/1/13.
//
//

#import "AboutViewController.h"
#import "NSAttributedString+Attributes.h"
#import "OHASBasicMarkupParser.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

-(instancetype)init{
    return [self initWithNibName:@"AboutViewController" bundle:nil];
}
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.appNameLabel.font=[UIFont fontWithName:@"QuicksandBold-Regular" size:self.appNameLabel.font.pointSize];
    self.versonLabel.font=[UIFont fontWithName:@"QuicksandBold-Regular" size:self.versonLabel.font.pointSize];
    self.versonLabel.text=[NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];;
    
    self.descriptionLabel.textColor=[UIColor blackColor];
    self.descriptionLabel.linkColor=[UIColor blackColor];
    self.descriptionLabel.font=[UIFont fontWithName:@"Helvetica" size:13];
    NSMutableAttributedString *description=[[[NSMutableAttributedString alloc] init]autorelease];
    
    [description appendAttributedString:[OHASBasicMarkupParser attributedStringByProcessingMarkupInString:
                                         @"Developed by: [b123400](http://b123400.net)\n"]];
    [description appendAttributedString:[OHASBasicMarkupParser attributedStringByProcessingMarkupInString:
                                         @"Icon designed by: [Linkzero](http://about.me/Linkzero)\n"]];
    [description setFontName:@"Helvetica" size:15];
    
    NSMutableAttributedString *yuri=[NSMutableAttributedString attributedStringWithString:@"Thanks koyyuri\n\n"];
    [description appendAttributedString:yuri];
    
    [description appendAttributedString:[NSAttributedString attributedStringWithAttributedString:[OHASBasicMarkupParser attributedStringByProcessingMarkupInString:@"Includes OHAttributedLabel by [AliSoftware](https://github.com/AliSoftware/OHAttributedLabel)\n"]]];
    
    [description appendAttributedString:[NSAttributedString attributedStringWithAttributedString:[OHASBasicMarkupParser attributedStringByProcessingMarkupInString:@"Includes OLImageView by [Onda Labs](https://github.com/ondalabs/OLImageView), lincesed under MIT license.\n"]]];
    
    [description appendAttributedString:[NSAttributedString attributedStringWithAttributedString:[OHASBasicMarkupParser attributedStringByProcessingMarkupInString:@"Includes OAuthConsumer by [Google](http://code.google.com/p/oauthconsumer/), licensed under MIT License.\n"]]];
    
    [description appendAttributedString:[NSAttributedString attributedStringWithAttributedString:[OHASBasicMarkupParser attributedStringByProcessingMarkupInString:@"Includes ASIHTTPRequest by [All-Seeing Interactive](https://github.com/pokeb/asi-http-request/), licensed under BSD license.\n"]]];
    
    [description appendAttributedString:[NSAttributedString attributedStringWithAttributedString:[OHASBasicMarkupParser attributedStringByProcessingMarkupInString:@"Includes [Facebook iOS SDK](https://developers.facebook.com/ios/) by Facebook, licensed under Apache License.\n"]]];
    
    [description appendAttributedString:[NSAttributedString attributedStringWithAttributedString:[OHASBasicMarkupParser attributedStringByProcessingMarkupInString:@"Includes TouchJSON by [Touch Code](https://github.com/TouchCode/TouchJSON), licensed under BSD license.\n"]]];
    
    [description appendAttributedString:[NSAttributedString attributedStringWithAttributedString:[OHASBasicMarkupParser attributedStringByProcessingMarkupInString:@"Includes RegexKitLite by [John Engelhart](http://regexkit.sourceforge.net/RegexKitLite/), licensed under BSD license.\n"]]];
    
    [description appendAttributedString:[NSAttributedString attributedStringWithAttributedString:[OHASBasicMarkupParser attributedStringByProcessingMarkupInString:@"Includes SDWebImage by [Olivier Poitrey](https://github.com/rs/SDWebImage/), licensed under MIT license.\n"]]];
    
    [description appendAttributedString:[NSAttributedString attributedStringWithAttributedString:[OHASBasicMarkupParser attributedStringByProcessingMarkupInString:@"Includes Quicksand by [Andrew Paglinawan](http://www.typophile.com/node/50437), licensed under SIL Open Font License.\n"]]];
    
    [description appendAttributedString:[NSAttributedString attributedStringWithAttributedString:[OHASBasicMarkupParser attributedStringByProcessingMarkupInString:@"Includes [Google analytics for iOS](https://developers.google.com/analytics/devguides/collection/ios/).\n"]]];
    
    [description appendAttributedString:[NSAttributedString attributedStringWithAttributedString:[OHASBasicMarkupParser attributedStringByProcessingMarkupInString:@"Sound effects from [freeSFX](http://www.freesfx.co.uk/).\n"]]];
    
    self.descriptionLabel.attributedText=description;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (BOOL)shouldAutorotate {
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    //decide number of origination tob supported by Viewcontroller.
    return UIInterfaceOrientationMaskPortrait;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_appNameLabel release];
    [_versonLabel release];
    [_licenceButton release];
    [_descriptionLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setAppNameLabel:nil];
    [self setVersonLabel:nil];
    [self setLicenceButton:nil];
    [self setDescriptionLabel:nil];
    [super viewDidUnload];
}
@end
