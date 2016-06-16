//
//  SULocalMessagePort.h
//  Sparkle
//
//  Created by Mayur Pawashe on 3/9/16.
//  Copyright © 2016 Sparkle Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SULocalMessagePortProtocol.h"
#import "SULocalMessagePortDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface SULocalMessagePort : NSObject <SULocalMessagePortProtocol>

- (instancetype)init;

// Due to XPC reasons, this delegate is strongly referenced. Make sure to -invalidate when done with this instance.
- (instancetype)initWithDelegate:(id<SULocalMessagePortDelegate>)delegate;

// messageCallback may be invoked on non-main thread
- (void)setMessageCallback:(NSData * _Nullable(^)(int32_t identifier, NSData *data))messageCallback;

@end

NS_ASSUME_NONNULL_END
