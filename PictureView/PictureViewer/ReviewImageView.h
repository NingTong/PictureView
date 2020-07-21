//
//  ReviewImageView.h
//  CompetitivePublicChain
//
//  Created by admin on 2020/06/20.
//  Copyright © 2020 superchain. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReviewImageView : UIView

/// 初始化方法
/// @param datas <#datas description#>
/// @param index <#index description#>
/// @param rects <#rects description#>
- (id)initWithDatas:(NSMutableArray *)datas index:(NSInteger)index rects:(NSMutableArray *)rects;
@end

NS_ASSUME_NONNULL_END
