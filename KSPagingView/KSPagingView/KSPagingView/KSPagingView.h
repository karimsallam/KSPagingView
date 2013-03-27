//
//  KSPagingView.h
//
//  Created by Karim Sallam on 26/02/12.
//
// Copyright (c) 2013, Karim Sallam
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//      * Neither the name of Karim Sallam nor the
//        names of its contributors may be used to endorse or promote products
//        derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY KARIM SALLAM ``AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL KARIM SALLM BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "KSView.h"

@class UIScrollView;

@protocol KSPagingViewDataSource;
@protocol KSPagingViewDelegate;

typedef enum
{
  KSPagingViewModeHorizontal  = 0,
  KSPagingViewModeVertical    = 1,
} KSPagingViewMode;

/**
 Specifies the allowed scroll direction.
 */
typedef enum
{
  KSPagingViewScrollDirectionHorizontal  = 0,
  KSPagingViewScrollDirectionVertical    = 1,
} KSPagingViewScrollDirection;

@interface KSPagingView : KSView

///------------------------------
/// @name Designated Initializers
///------------------------------

/**
 Creates and initializes a `KSPagingView` view the specified scroll direction.
 
 @param scrollDirection The allowed scroll direction. If the direction is not one of the available direction 
 
 @return The newly-initialized KSPagingView
 */
- (id)initWithMode:(KSPagingViewMode)mode;

// If you need to reuse the view (eg. KSPagingView inside of a KSPagingView).
- (id)initWithMode:(KSPagingViewMode)mode reuseIdentifier:(NSString *)reuseIdentifier;

#pragma mark - Protocols

@property (weak, nonatomic) IBOutlet id <KSPagingViewDataSource>  dataSource;
@property (weak, nonatomic) IBOutlet id <KSPagingViewDelegate>    delegate;

#pragma mark - Customization properties

/*
 The following properties and methods are for customizing the view behaviour.
 */

@property (nonatomic) KSPagingViewMode                mode;                           // Default KSPagingViewModeHorizontal.
@property (nonatomic) CGFloat                         gapBetweenViews;                // Default 20.0.
@property (nonatomic) CGSize                          viewSize;                       // Default KSPagingView.frame.size - gapBetweenViews.
@property (nonatomic) NSInteger                       numberOfViewsToPreload;         // Default 0.
@property (nonatomic, getter = isScrollEnabled) BOOL  scrollEnabled;                  // Default YES.
@property (nonatomic, getter = isPagingEnabled) BOOL  pagingEnabled;                  // Default YES.
@property (nonatomic)                           BOOL  bounces;                        // Default YES.
@property (nonatomic)                           BOOL  alwaysBounceHorizontal;         // Default NO.
@property (nonatomic)                           BOOL  alwaysBounceVertical;           // Default NO.
@property (nonatomic)                           BOOL  showsHorizontalScrollIndicator; // Default NO.
@property (nonatomic)                           BOOL  showsVerticalScrollIndicator;   // Default NO.
@property (nonatomic) UIScrollViewIndicatorStyle      indicatorStyle;                 // Default is UIScrollViewIndicatorStyleDefault.
- (void)flashScrollIndicators;

/*
 The following properties and methos are for checking the view status.
 */

@property (readonly, nonatomic, getter = isMoving) BOOL moving;


#pragma mark - Dequeuing

- (id)dequeueReusableViewWithIdentifier:(NSString *)identifier;

#pragma mark - Views methods

- (NSInteger)numberOfViews;
- (id)viewAtIndex:(NSInteger)index;
- (NSArray *)visibleViews;
- (NSArray *)loadedViews;
- (NSRange)visibleViewsRange;
- (void)setVisibleViewsRange:(NSRange)visibleViewsRange animated:(BOOL)animated;
- (NSRange)loadedViewsRange;

#pragma mark - Content reload

- (void)reloadViews;

@end

#pragma mark - DataSource protocol

@protocol KSPagingViewDataSource <NSObject>

- (NSInteger)numberOfViewsInPagingView:(KSPagingView *)pagingView;
- (KSView *)pagingView:(KSPagingView *)pagingView viewAtIndex:(NSInteger)index;
 
@end

#pragma mark - Delegate protocol

@protocol KSPagingViewDelegate<NSObject>

@optional
- (void)pagingView:(KSPagingView *)pagingView didChangeVisibleViewsRange:(NSRange)visibleViewsRange;
- (void)pagingView:(KSPagingView *)pagingView didChangeLoadedViewsRange:(NSRange)visibleViewsRange;
- (void)pagingViewWillBeginMoving:(KSPagingView *)pagingView;
- (void)pagingViewDidEndMoving:(KSPagingView *)pagingView;

@end
