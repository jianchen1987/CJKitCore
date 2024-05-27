//
//  UICollectionView+HD.m
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDLog.h"
#import "HDRunTime.h"
#import "UICollectionView+HDKitCore.h"

@implementation UICollectionView (HDKitCore)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 防止 release 版本滚动到不合法的 indexPath 会 crash
        OverrideImplementation([UICollectionView class], @selector(scrollToItemAtIndexPath:atScrollPosition:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UICollectionView *selfObject, NSIndexPath *indexPath, UICollectionViewScrollPosition scrollPosition, BOOL animated) {
                BOOL isIndexPathLegal = YES;
                NSInteger numberOfSections = [selfObject numberOfSections];
                if (indexPath.section >= numberOfSections) {
                    isIndexPathLegal = NO;
                } else {
                    NSInteger items = [selfObject numberOfItemsInSection:indexPath.section];
                    if (indexPath.item >= items) {
                        isIndexPathLegal = NO;
                    }
                }
                if (!isIndexPathLegal) {
                    HDLogWarn(@"UICollectionView (HDKitCore)", @"%@ - target indexPath : %@ ，不合法的indexPath。\n%@", selfObject, indexPath, [NSThread callStackSymbols]);
                    NSAssert(NO, @"出现不合法的indexPath");
                    return;
                }

                // call super
                void (*originSelectorIMP)(id, SEL, NSIndexPath *, UICollectionViewScrollPosition, BOOL);
                originSelectorIMP = (void (*)(id, SEL, NSIndexPath *, UICollectionViewScrollPosition, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, indexPath, scrollPosition, animated);
            };
        });
    });
}

- (void)hd_clearsSelection {
    NSArray *selectedItemIndexPaths = [self indexPathsForSelectedItems];
    for (NSIndexPath *indexPath in selectedItemIndexPaths) {
        [self deselectItemAtIndexPath:indexPath animated:YES];
    }
}

- (void)hd_reloadDataKeepingSelection {
    NSArray *selectedIndexPaths = [self indexPathsForSelectedItems];
    [self reloadData];
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        [self selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

/// 递归找到view在哪个cell里，不存在则返回nil
- (UICollectionViewCell *)parentCellForView:(UIView *)view {
    if (!view.superview) {
        return nil;
    }

    if ([view.superview isKindOfClass:[UICollectionViewCell class]]) {
        return (UICollectionViewCell *)view.superview;
    }

    return [self parentCellForView:view.superview];
}

- (NSIndexPath *)hd_indexPathForItemAtView:(id)sender {
    if (sender && [sender isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)sender;
        UICollectionViewCell *parentCell = [self parentCellForView:view];
        if (parentCell) {
            return [self indexPathForCell:parentCell];
        }
    }

    return nil;
}

- (BOOL)hd_itemVisibleAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *visibleItemIndexPaths = self.indexPathsForVisibleItems;
    for (NSIndexPath *visibleIndexPath in visibleItemIndexPaths) {
        if ([indexPath isEqual:visibleIndexPath]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray<NSIndexPath *> *)hd_indexPathsForVisibleItems {
    NSArray<NSIndexPath *> *visibleItems = [self indexPathsForVisibleItems];
    NSSortDescriptor *sectionSorter = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
    NSSortDescriptor *rowSorter = [[NSSortDescriptor alloc] initWithKey:@"item" ascending:YES];
    visibleItems = [visibleItems sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sectionSorter, rowSorter, nil]];
    return visibleItems;
}

- (NSIndexPath *)hd_indexPathForFirstVisibleCell {
    NSArray *visibleIndexPaths = [self hd_indexPathsForVisibleItems];
    if (!visibleIndexPaths || visibleIndexPaths.count <= 0) {
        return nil;
    }

    return visibleIndexPaths.firstObject;
}

- (BOOL)hd_hasData {
    return self.hd_totalDataCount > 0;
}

- (NSInteger)hd_totalDataCount {
    NSInteger totalCount = 0;
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;

        for (NSInteger section = 0; section < tableView.numberOfSections; section++) {
            totalCount += [tableView numberOfRowsInSection:section];
        }
    } else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;

        for (NSInteger section = 0; section < collectionView.numberOfSections; section++) {
            totalCount += [collectionView numberOfItemsInSection:section];
        }
    }
    return totalCount;
}
@end
