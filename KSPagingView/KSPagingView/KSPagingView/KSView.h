//
//  KSView.h
//  KSFramework
//
//  Created by Karim Sallam on 26/02/12.
//  Copyright (c) 2012 Karim Sallam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSView : UIView

@property (readonly, copy, nonatomic) NSString *reuseIdentifier;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (id)initWithCoder:(NSCoder *)aDecoder reuseIdentifier:(NSString *)reuseIdentifier;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

- (void)prepareForReuse;

@end
