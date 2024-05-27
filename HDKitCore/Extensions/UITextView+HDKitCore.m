//
//  UITextView+HD.m
//  HDKitCore
//
//  Created by VanJay on 2020/1/8.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "HDCommonDefines.h"
#import "UITextView+HDKitCore.h"

@implementation UITextView (HDKitCore)

- (NSRange)hd_convertNSRangeFromUITextRange:(UITextRange *)textRange {
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:textRange.start];
    NSInteger length = [self offsetFromPosition:textRange.start toPosition:textRange.end];
    return NSMakeRange(location, length);
}

- (UITextRange *)hd_convertUITextRangeFromNSRange:(NSRange)range {
    if (range.location == NSNotFound || NSMaxRange(range) > self.text.length) {
        return nil;
    }
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    return [self textRangeFromPosition:startPosition toPosition:endPosition];
}

- (void)hd_setTextKeepingSelectedRange:(NSString *)text {
    UITextRange *selectedTextRange = self.selectedTextRange;
    self.text = text;
    self.selectedTextRange = selectedTextRange;
}

- (void)hd_setAttributedTextKeepingSelectedRange:(NSAttributedString *)attributedText {
    UITextRange *selectedTextRange = self.selectedTextRange;
    self.attributedText = attributedText;
    self.selectedTextRange = selectedTextRange;
}

- (void)hd_scrollRangeToVisible:(NSRange)range {
    if (CGRectIsEmpty(self.bounds)) return;

    UITextRange *textRange = [self hd_convertUITextRangeFromNSRange:range];
    if (!textRange) return;

    NSArray<UITextSelectionRect *> *selectionRects = [self selectionRectsForRange:textRange];
    CGRect rect = CGRectZero;
    for (UITextSelectionRect *selectionRect in selectionRects) {
        if (!CGRectIsEmpty(selectionRect.rect)) {
            if (CGRectIsEmpty(rect)) {
                rect = selectionRect.rect;
            } else {
                rect = CGRectUnion(rect, selectionRect.rect);
            }
        }
    }
    if (!CGRectIsEmpty(rect)) {
        rect = [self convertRect:rect fromView:self.textInputView];
        [self _scrollRectToVisible:rect animated:YES];
    }
}

- (void)hd_scrollCaretVisibleAnimated:(BOOL)animated {
    if (CGRectIsEmpty(self.bounds)) return;

    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.end];
    [self _scrollRectToVisible:caretRect animated:animated];
}

- (void)_scrollRectToVisible:(CGRect)rect animated:(BOOL)animated {
    if (!CGRectIsValidated(rect)) {
        return;
    }

    CGFloat contentOffsetY = self.contentOffset.y;

    if (CGRectGetMinY(rect) == self.contentOffset.y + self.textContainerInset.top) {
        // 命中这个条件说明已经不用调整了，直接 return，避免继续走下面的判断，会重复调整，导致光标跳动
        return;
    }

    if (CGRectGetMinY(rect) < self.contentOffset.y + self.textContainerInset.top) {
        // 光标在可视区域上方，往下滚动
        contentOffsetY = CGRectGetMinY(rect) - self.textContainerInset.top - self.contentInset.top;
    } else if (CGRectGetMaxY(rect) > self.contentOffset.y + CGRectGetHeight(self.bounds) - self.textContainerInset.bottom - self.contentInset.bottom) {
        // 光标在可视区域下方，往上滚动
        contentOffsetY = CGRectGetMaxY(rect) - CGRectGetHeight(self.bounds) + self.textContainerInset.bottom + self.contentInset.bottom;
    } else {
        // 光标在可视区域内，不用调整
        return;
    }
    [self setContentOffset:CGPointMake(self.contentOffset.x, contentOffsetY) animated:animated];
}

@end
