//
//  KSPagingView.m
//  KSFramework
//
//  Created by Karim Sallam on 26/02/12.
//  Copyright (c) 2012 Karim Sallam. All rights reserved.
//

#import "KSPagingView.h"

static const CGFloat kDefaultAnimationDuration = 0.3;

@interface KSPagingView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView        *scrollView;        // Content ScrollView.
@property (strong, nonatomic) NSMutableArray      *visibleViews;      // Visible views.
@property (strong, nonatomic) NSMutableDictionary *reusableViews;     // Non visible views not preloaded that can be reused.
@property (nonatomic)         NSInteger           numberOfViews;      // Number of views in the scrollView.
@property (nonatomic)         NSRange             visibleViewsRange;  // The range of the visible views.
@property (nonatomic)         NSRange             loadedViewsRange;   // The range of the loaded views (visible + preloaded).

@end

@implementation KSPagingView

#pragma mark - Init methods

- (id)initWithMode:(KSPagingViewMode)mode
{
  self = [super init];
  if (!self) return nil;
  [self initializePagingView];
  _mode = mode;
  return self;
}

- (id)initWithMode:(KSPagingViewMode)mode reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithReuseIdentifier:reuseIdentifier];
  if (!self) return nil;
  [self initializePagingView];
  _mode = mode;
  return self;
}

- (id)init
{
  self = [super init];
  if (!self) return nil;
  [self initializePagingView];
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (!self) return nil;
  [self initializePagingView];
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (!self) return nil;
  [self initializePagingView];
  return self;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithReuseIdentifier:reuseIdentifier];
  if (!self) return nil;
  [self initializePagingView];
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithCoder:aDecoder reuseIdentifier:reuseIdentifier];
  if (!self) return nil;
  [self initializePagingView];
  return self;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
  if (!self) return nil;
  [self initializePagingView];
  return self;
}

#pragma mark Initialization

- (void)initializePagingView
{
  self.clipsToBounds = YES;
  
  // ScrollView.
  _scrollView = [[UIScrollView alloc] initWithFrame:[self frameForScrollView]];
  [_scrollView setClipsToBounds:NO];
  [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
  [_scrollView setBackgroundColor:[UIColor clearColor]];
  [_scrollView setBounces:YES];
  [_scrollView setShowsVerticalScrollIndicator:NO];
  [_scrollView setShowsHorizontalScrollIndicator:NO];
  [_scrollView setDelegate:self];
  [self addSubview:_scrollView];
  
  // Public properties initialization with default values.
  _mode = KSPagingViewModeHorizontal;
  _gapBetweenViews = 20.0;
  _viewSize = [self sizeForViewSize];
  _scrollView.pagingEnabled = YES;
  _numberOfViewsToPreload = 0;
  _moving = NO;
  
  // Private properties initialization.
  _visibleViews = [[NSMutableArray alloc] init];
  _reusableViews = [[NSMutableDictionary alloc] init];
  _numberOfViews = 0;
  _visibleViewsRange = NSMakeRange(NSNotFound, 0);
  _loadedViewsRange = NSMakeRange(NSNotFound, 0);
}

#pragma mark - Public properties getters and setters

- (void)setNumberOfViewsToPreload:(NSInteger)numberOfViewsToPreload
{
  if (_numberOfViewsToPreload == numberOfViewsToPreload) return;
  
  _numberOfViewsToPreload = numberOfViewsToPreload;
  if (_numberOfViews) [self configureViews];
}

//- (void)setGapBetweenViews:(CGFloat)gapBetweenViews
//{
//  // Resize scrollView.
//}

#pragma mark - Dequeuing

- (id)dequeueReusableViewWithIdentifier:(NSString *)identifier
{
  if (!identifier) return nil;
  NSMutableSet *identifierViews = [_reusableViews objectForKey:identifier];
  id dequeuedView = [identifierViews anyObject];
  if (dequeuedView) [identifierViews removeObject:dequeuedView];
  return dequeuedView;
}

#pragma mark - Views Methods

- (id)viewAtIndex:(NSInteger)index
{
  if (index < 0 || index >= _numberOfViews) return nil;
  id view = [_visibleViews objectAtIndex:index];
  return view != [NSNull null] ? view : nil;
}

- (NSArray *)visibleViews
{
  return [_visibleViews subarrayWithRange:NSMakeRange(_visibleViewsRange.location, _visibleViewsRange.length + 1)];
}

- (NSArray *)loadedViews
{
  return [_visibleViews subarrayWithRange:NSMakeRange(_loadedViewsRange.location, _loadedViewsRange.length + 1)];
}

- (void)setVisibleViewsRange:(NSRange)newVisibleViewsRange animated:(BOOL)animated
{
  if (NSEqualRanges(newVisibleViewsRange, _visibleViewsRange) || (NSMaxRange(newVisibleViewsRange) > _numberOfViews)) return;
  switch (_mode)
  {
    case KSPagingViewModeVertical:
      NSAssert(0, @"Not handled. Sorry. Game over! Please insert coin!");
      break;
    case KSPagingViewModeHorizontal:
      // Better performance animating ourselves instead of using animated:YES in scrollRectToVisible. Credits goes to GMGridView.
      [UIView animateWithDuration:animated ? kDefaultAnimationDuration : 0.0
                       animations:^{
                         [_scrollView scrollRectToVisible:CGRectMake((_viewSize.width + _gapBetweenViews) * newVisibleViewsRange.location,
                                                                     0,
                                                                     (_viewSize.width + _gapBetweenViews) * newVisibleViewsRange.length,
                                                                     _viewSize.height)
                                                 animated:NO];
                       }];
  }
}

#pragma mark - Content reload

- (void)reloadViews
{
  for (id view in _visibleViews)
  {
    if (view != [NSNull null])
    {
      [self recycleView:view];
    }
  }
  
  [_visibleViews removeAllObjects];
  
  _numberOfViews = [_dataSource numberOfViewsInPagingView:self];
  
  for (NSInteger index = 0; index < _numberOfViews; ++index)
  {
    [_visibleViews addObject:[NSNull null]];
  }
  
  _visibleViewsRange = NSMakeRange(NSNotFound, 0);
  _loadedViewsRange = NSMakeRange(NSNotFound, 0);
  
  _scrollView.frame = [self frameForScrollView];
  _scrollView.contentSize = [self sizeForScrollViewContent];
  _scrollView.contentOffset = CGPointZero;
  
  if (_numberOfViews)
  {
    // Because {0,0} and {NSNotFound, 0} are different and it will try to load a view at index 0 when numberOfViews are 0.
    [self configureViews];
  }
}

- (void)configureViews
{
  NSInteger firstVisibleViewIndex = [self firstVisibleViewIndex];
  NSInteger lastVisibleViewIndex = [self lastVisibleViewIndex];
  NSInteger firstPreloadViewIndex = MAX(0, firstVisibleViewIndex - _numberOfViewsToPreload);
  NSInteger lastPreloadViewIndex = MIN(_numberOfViews - 1, lastVisibleViewIndex + _numberOfViewsToPreload);
  
  NSRange newLoadedViewsRange = NSMakeRange(firstPreloadViewIndex, lastPreloadViewIndex - firstPreloadViewIndex);
  if (!NSEqualRanges(newLoadedViewsRange, _loadedViewsRange))
  {
    NSRange intersectionRange = NSIntersectionRange(newLoadedViewsRange, _loadedViewsRange);
    if (intersectionRange.length == 0) // No intersection
    {
      for (NSInteger index = _loadedViewsRange.location; index <= NSMaxRange(_loadedViewsRange); ++index) [self recycleViewAtIndex:index];
      for (NSInteger index = newLoadedViewsRange.location; index <= NSMaxRange(newLoadedViewsRange); ++index) [self loadViewAtIndex:index];
    }
    else
    {
      for (NSInteger index = _loadedViewsRange.location; index < intersectionRange.location; ++index) [self recycleViewAtIndex:index];
      for (NSInteger index = NSMaxRange(intersectionRange) + 1; index <= NSMaxRange(_loadedViewsRange); ++index) [self recycleViewAtIndex:index];
      for (NSInteger index = newLoadedViewsRange.location; index < intersectionRange.location; ++index) [self loadViewAtIndex:index];
      for (NSInteger index = NSMaxRange(intersectionRange) + 1; index <= NSMaxRange(newLoadedViewsRange); ++index) [self loadViewAtIndex:index];
    }
    
    _loadedViewsRange = newLoadedViewsRange;
    if ([_delegate respondsToSelector:@selector(pagingView:didChangeLoadedViewsRange:)]) [_delegate pagingView:self didChangeLoadedViewsRange:_loadedViewsRange];
  }
  
  NSRange newVisibleViewsRange = NSMakeRange(firstVisibleViewIndex, lastVisibleViewIndex - firstVisibleViewIndex);
  if (!NSEqualRanges(newVisibleViewsRange, _visibleViewsRange))
  {
    _visibleViewsRange = newVisibleViewsRange;
    if ([_delegate respondsToSelector:@selector(pagingView:didChangeVisibleViewsRange:)]) [_delegate pagingView:self didChangeVisibleViewsRange:_visibleViewsRange];
  }
}

#pragma mark - Visible views calculation

- (NSInteger)firstVisibleViewIndex
{
  CGRect visibleBounds = _scrollView.bounds;
  switch (_mode)
  {
    case KSPagingViewModeHorizontal: return MAX(floorf(CGRectGetMinX(visibleBounds) / (_viewSize.width + _gapBetweenViews)), 0);
    case KSPagingViewModeVertical: return MAX(floorf(CGRectGetMinY(visibleBounds) / (_viewSize.height + _gapBetweenViews)), 0);
  }
}

- (NSInteger)lastVisibleViewIndex
{
  CGRect visibleBounds = _scrollView.bounds;
  switch (_mode)
  {
    case KSPagingViewModeHorizontal: return MIN(floorf((CGRectGetMaxX(visibleBounds) - 1) / (_viewSize.width + _gapBetweenViews)), _numberOfViews - 1);
    case KSPagingViewModeVertical: return MIN(floorf((CGRectGetMaxY(visibleBounds) - 1) / (_viewSize.height + _gapBetweenViews)), _numberOfViews - 1);
  }
}

#pragma mark - Recycling

- (void)recycleView:(id)view
{
  if ([view respondsToSelector:@selector(prepareForReuse)]) [view prepareForReuse];
  
  NSMutableSet *identifierViews = [_reusableViews objectForKey:[view reuseIdentifier]];
  if (identifierViews) [identifierViews addObject:view];
  else
  {
    identifierViews = [[NSMutableSet alloc] initWithCapacity:1];
    [identifierViews addObject:view];
    [_reusableViews setObject:identifierViews forKey:[view reuseIdentifier]];
  }
  
  [view removeFromSuperview];
}

- (void)recycleViewAtIndex:(NSInteger)index
{
  if (index < 0 || index >= _numberOfViews) return;
  id view = [_visibleViews objectAtIndex:index];
  if (![view isKindOfClass:[NSNull class]])
  {
    [self recycleView:view];
    [_visibleViews replaceObjectAtIndex:index withObject:[NSNull null]];
  }
}

#pragma mak - Views configuration

- (void)loadViewAtIndex:(NSInteger)index
{
  KSView *view = [_dataSource pagingView:self viewAtIndex:index];
  NSAssert(view, @"%s Returned nil for view at index %d" , __PRETTY_FUNCTION__, index);
  NSAssert([view isKindOfClass:[KSView class]], @"%s View at index %d is not a subclass of KSView" , __PRETTY_FUNCTION__, index);
  [self configureView:view atIndex:index];
  [_scrollView insertSubview:view atIndex:0]; // So the scrollIndicator are always on top.
  [_visibleViews replaceObjectAtIndex:index withObject:view];
}

- (void)configureView:(KSView *)view atIndex:(NSInteger)index
{
  view.frame = [self frameForViewAtIndex:index];
  [view setNeedsDisplay];
}

#pragma mark - Layouting

- (void)layoutSubviews
{
  if (_numberOfViews)
  {
    for (NSInteger index = _loadedViewsRange.location; index <= NSMaxRange(_loadedViewsRange); ++index)
    {
      [self configureView:[_visibleViews objectAtIndex:index] atIndex:index];
    }
    
    [self configureViews]; // Load only the future visible view.
    
    [_scrollView flashScrollIndicators];
  }
}

- (CGRect)frameForScrollView
{
  CGSize size = self.bounds.size;
  switch (_mode)
  {
    case KSPagingViewModeHorizontal:
      return CGRectMake(-_gapBetweenViews / 2, 0, size.width + _gapBetweenViews, size.height);
    case KSPagingViewModeVertical:
      return  CGRectMake(0, -_gapBetweenViews / 2, size.width, size.height + _gapBetweenViews);
  }
}

- (CGSize)sizeForViewSize
{
  CGSize size = _scrollView.frame.size;
  switch (_mode)
  {
    case KSPagingViewModeHorizontal:
      return CGSizeMake(size.width - _gapBetweenViews, size.height);
    case KSPagingViewModeVertical:
      return CGSizeMake(size.width, size.height - _gapBetweenViews);
  }
}

- (CGSize)sizeForScrollViewContent
{
  switch (_mode)
  {
    case KSPagingViewModeHorizontal:
      return CGSizeMake((_viewSize.width + _gapBetweenViews) * _numberOfViews, _viewSize.height);
    case KSPagingViewModeVertical:
      return CGSizeMake(_viewSize.width, (_viewSize.height + _gapBetweenViews) * _numberOfViews);
  }
}

- (CGRect)frameForViewAtIndex:(NSInteger)index
{
  switch (_mode)
  {
    case KSPagingViewModeHorizontal:
      return CGRectMake((_viewSize.width + _gapBetweenViews) * index + _gapBetweenViews / 2, 0, _viewSize.width, _viewSize.height);
    case KSPagingViewModeVertical:
      return CGRectMake(0, (_viewSize.height + _gapBetweenViews) * index + _gapBetweenViews / 2, _viewSize.width, _viewSize.height);
  }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{ [self configureViews]; }

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{ [self knownToBeMoving]; }

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{ if (!decelerate) [self knownToBeIdle]; }

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{ [self knownToBeIdle]; }

#pragma mark - Moving/Idle tracking

- (void)knownToBeMoving
{
  if (!_moving)
  {
    _moving = YES;
    if ([_delegate respondsToSelector:@selector(pagingViewWillBeginMoving:)]) [_delegate pagingViewWillBeginMoving:self];
  }
}

- (void)knownToBeIdle
{
  if (_moving)
  {
    _moving = NO;
    if ([_delegate respondsToSelector:@selector(pagingViewDidEndMoving:)]) [_delegate pagingViewDidEndMoving:self];
  }
}

#pragma mark - Private scrollView exposed properties and methods

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
  [_scrollView setScrollEnabled:scrollEnabled];
}

- (BOOL)isScrollEnabled
{
  return [_scrollView isScrollEnabled];
}

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
  [_scrollView setPagingEnabled:pagingEnabled];
}

- (BOOL)isPagingEnabled
{
  return [_scrollView isPagingEnabled];
}

- (void)setBounces:(BOOL)bounces
{
  [_scrollView setBounces:bounces];
}

- (BOOL)bounces
{
  return [_scrollView bounces];
}

- (void)setAlwaysBounceHorizontal:(BOOL)alwaysBounceHorizontal
{
  [_scrollView setAlwaysBounceHorizontal:alwaysBounceHorizontal];
}

- (BOOL)alwaysBounceHorizontal
{
  return [_scrollView alwaysBounceHorizontal];
}

- (void)setAlwaysBounceVertical:(BOOL)alwaysBounceVertical
{
  [_scrollView setAlwaysBounceVertical:alwaysBounceVertical];
}

- (BOOL)alwaysBounceVertical
{
  return [_scrollView alwaysBounceVertical];
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)showsHorizontalScrollIndicator
{
  [_scrollView setShowsHorizontalScrollIndicator:showsHorizontalScrollIndicator];
}

- (BOOL)showsHorizontalScrollIndicator
{
  return [_scrollView showsHorizontalScrollIndicator];
}

- (void)setShowsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator
{
  [_scrollView setShowsVerticalScrollIndicator:showsVerticalScrollIndicator];
}

- (BOOL)showsVerticalScrollIndicator
{
  return [_scrollView showsVerticalScrollIndicator];
}

- (void)setIndicatorStyle:(UIScrollViewIndicatorStyle)indicatorStyle
{
  [_scrollView setIndicatorStyle:indicatorStyle];
}

- (UIScrollViewIndicatorStyle)indicatorStyle
{
  return [_scrollView indicatorStyle];
}

- (void)flashScrollIndicators
{
  [_scrollView flashScrollIndicators];
}

@end
