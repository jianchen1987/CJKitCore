//
//  UILabel+HDKitCore.m
//  HDKitCore
//
//  Created by VanJay on 2020/4/2.
//

#import "HDAssociatedObjectHelper.h"
#import "NSObject+HD_Swizzle.h"
#import "UILabel+HDKitCore.h"

@implementation UILabel (HDKitCore)
+ (void)load {
    hd_swizzleInstanceMethod(self, @selector(setText:), @selector(setHDHasLineSpaceText:));
}

HDSynthesizeDoubleProperty(hd_lineSpace, setHd_lineSpace);

- (void)setHDHasLineSpaceText:(NSString *)text {

    if (!text.length || self.hd_lineSpace == 0) {
        [self setHDHasLineSpaceText:text];
        return;
    }

    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = self.hd_lineSpace;
    style.lineBreakMode = self.lineBreakMode;
    style.alignment = self.textAlignment;

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    self.attributedText = attrString;
}
@end
