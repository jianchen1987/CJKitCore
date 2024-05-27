//
//  UITextView+HD.h
//  HDKitCore
//
//  Created by VanJay on 2020/1/8.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (HDKitCore)

/**
 *  convert UITextRange to NSRange, for example, [self hd_convertNSRangeFromUITextRange:self.markedTextRange]
 */
- (NSRange)hd_convertNSRangeFromUITextRange:(UITextRange *)textRange;

/**
 *  convert NSRange to UITextRange
 *  @return return nil if range is invalidate.
 */
- (nullable UITextRange *)hd_convertUITextRangeFromNSRange:(NSRange)range;

/**
 *  设置 text 会让 selectedTextRange 跳到最后一个字符，导致在中间修改文字后光标会跳到末尾，所以设置前要保存一下，设置后恢复过来
 */
- (void)hd_setTextKeepingSelectedRange:(NSString *)text;

/**
 *  设置 attributedText 会让 selectedTextRange 跳到最后一个字符，导致在中间修改文字后光标会跳到末尾，所以设置前要保存一下，设置后恢复过来
 */
- (void)hd_setAttributedTextKeepingSelectedRange:(NSAttributedString *)attributedText;

/**
 [UITextView scrollRangeToVisible:] 并不会考虑 textContainerInset.bottom，所以使用这个方法来代替

 @param range 要滚动到的文字区域，如果 range 非法则什么都不做
 */
- (void)hd_scrollRangeToVisible:(NSRange)range;

/**
 * 将光标滚到可视区域
 */
- (void)hd_scrollCaretVisibleAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
