//
//  KSView.m
//  KSFramework
//
//  Created by Karim Sallam on 26/02/12.
//  Copyright (c) 2012 Karim Sallam. All rights reserved.
//

#import "KSView.h"

@implementation KSView

- (id)initWithReuseIdentifier:(NSString *)aReuseIdentifier
{
  self = [super init];
  if (!self) return nil;
  _reuseIdentifier = [aReuseIdentifier copy];
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder reuseIdentifier:(NSString *)aReuseIdentifier
{
  self = [super initWithCoder:aDecoder];
  if (!self) return nil;
  _reuseIdentifier = [aReuseIdentifier copy];
  return self;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)aReuseIdentifier
{
  self = [super initWithFrame:frame];
  if (!self) return nil;
  _reuseIdentifier = [aReuseIdentifier copy];
  return self;
}

- (void)prepareForReuse
{
  // Empty implementation.
}

@end
