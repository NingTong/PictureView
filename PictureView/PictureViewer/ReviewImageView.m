//
//  ReviewImageView.m
//  CompetitivePublicChain
//
//  Created by admin on 2020/06/20.
//  Copyright © 2020 superchain. All rights reserved.
//

#import "ReviewImageView.h"
#import <SDWebImage.h>              // 加载网络图片

@interface ReviewImageView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;             // 左右滑动的视图

@property (nonatomic, strong) UIPageControl *pageControl;           // 页数小圆点

@property (nonatomic, strong) UIButton *saveButton;                 // 保存单张图片按钮

@property (nonatomic, strong) NSMutableArray *datas;                // 网络图片地址数据源

@property (nonatomic, strong) NSMutableArray *imageHeightArr;       // 加载后，图片的高度数组

@property (nonatomic, assign) NSInteger index;                      // 当前页数

@property (nonatomic, strong) NSMutableArray *rects;                // 上级界面控件 frame 数组

@property (nonatomic, assign) CGFloat lastScale;                    // 记录形变量（防拖动抖动）
@end

@implementation ReviewImageView

// 初始化
- (id)initWithDatas:(NSMutableArray *)datas index:(NSInteger)index rects:(NSMutableArray *)rects {
    self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    
    if (self) {
        self.datas = datas;
        
        self.index = index;
        
        self.rects = rects;
        
        // 初始化 UI
        [self loadUI];
    }
    return self;
}

// 加载页面
- (void)loadUI {
    // 背景色
    self.backgroundColor = [UIColor clearColor];
    
    // scrollView 初始化
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:scrollView];
    scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = YES;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    // 设置 scrollView 的区域
    CGFloat itemW = self.frame.size.width;
    [scrollView setContentSize:CGSizeMake(self.datas.count*itemW, self.frame.size.height)];
    [scrollView setContentOffset:CGPointMake(self.index*itemW, 0) animated:NO];
    self.scrollView = scrollView;
    // 添加 scrollView 点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
    [scrollView addGestureRecognizer:tap];
    
    // 保存单张图片按钮
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake(self.frame.size.width - 70, 44, 60, 44);
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [self addSubview:saveButton];
    [saveButton addTarget:self action:@selector(saveImage:) forControlEvents:UIControlEventTouchUpInside];
    self.saveButton = saveButton;
    
    // 页数小圆点
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(40, self.frame.size.height - 50, self.frame.size.width - 80, 50)];
    pageControl.numberOfPages = self.datas.count;//指定页面个数
    pageControl.currentPage = self.index;//指定pagecontroll的值，默认选中的小白点（第一个）
    pageControl.pageIndicatorTintColor = [[UIColor groupTableViewBackgroundColor] colorWithAlphaComponent:0.4];// 设置非选中页的圆点颜色
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor]; // 设置选中页的圆点颜色
    [self addSubview:pageControl];
    self.pageControl = pageControl;
    
    // for 循环创建图片组
    for (int i = 0; i < self.datas.count; i ++) {
        // 图片底层 view
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i*itemW, 0, itemW, self.frame.size.height)];
        view.backgroundColor = [UIColor clearColor];
        view.tag = 100 + i;
        [scrollView addSubview:view];
        
        // 图片
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        // 设置填充模式为宽度固定，高度自适应
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.tag = 10;
        [view addSubview:imageView];
        // 添加可拖拽手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognize:)];
        pan.delegate = self;
        [imageView addGestureRecognizer:pan];

        // 根据图片地址加载显示，并获取图片的宽高
        NSURL *url = [NSURL URLWithString:self.datas[i]];
        // 占位图
        UIImage *placeholderImage = [UIImage imageNamed:@"位图"];
        // 加载网络图片
        [imageView sd_setImageWithURL:url placeholderImage:placeholderImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image) {
                // 宽高比
                CGFloat scale = image.size.height/image.size.width;
                // 算出高度
                CGFloat itemH = scale * itemW;
                // 保存高度
                [self.imageHeightArr addObject:[NSNumber numberWithFloat:itemH]];
                
                // 设置 frame
                if (i == self.index) {
                    // 为指定页数展示的图片时
                    if (self.rects.count > self.index) {
                        // 不超过控件数量，则图片设置为相应控件的 frame
                        imageView.frame = [self.rects[self.index] CGRectValue];
                    }
                    else {
                        // 超过控件数量，则图片设置为最后一个控件的 frame
                        // 需要先判断是否传入至少一个控件的 frame
                        if (self.rects.count > 0) {
                            imageView.frame = [self.rects[self.rects.count - 1] CGRectValue];
                        }
                        else {
                            // 未传入 rects 时，使用默认 frame
                            imageView.frame = CGRectMake(0, (self.frame.size.height - self.frame.size.width)/2, self.frame.size.width, self.frame.size.width);
                        }
                    }
                }
                else {
                    // 其他页数的图片
                    imageView.frame = CGRectMake(0, (self.frame.size.height - itemH)/2, itemW, itemH);
                }
            }
            else {
                // 未获取到网络图片的情况下，默认占位图宽高
                CGFloat itemH = placeholderImage.size.height/placeholderImage.size.width * itemW;
                // 保存高度
                [self.imageHeightArr addObject:[NSNumber numberWithFloat:itemH]];
                imageView.frame = CGRectMake(0, (self.frame.size.height - itemH)/2, itemW, itemH);
            }
        }];
    }
    
    // 显示页面出现的动画
    [UIView animateWithDuration:0.3 animations:^{
        // 获取当前应展示的 imageView
        UIImageView *imageView = [[scrollView viewWithTag:100 + self.index] viewWithTag:10];
        
        // 获取对应的高度
        CGFloat itemH;
        if (self.imageHeightArr.count > self.index) {
            // 判断高度数组里是否有对应数据
            itemH = [self.imageHeightArr[self.index] floatValue];
        }
        else {
            // 没有对应数据则使用宽度作为默认值
            itemH = itemW;
        }
        
        // 将 imageView 从原始 frame 转换成 对应的 frame
        imageView.frame = CGRectMake(0, (self.frame.size.height - itemH)/2, itemW, itemH);
        
        // scrollView 的黑色背景透明度 从 0 到 1
        scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    }];
}

#pragma mark ---- ScrollViewDelegate ----
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 保存当前翻页的数量
    self.index = scrollView.contentOffset.x / self.frame.size.width;
    // 设置页码
    self.pageControl.currentPage = self.index;
}

#pragma mark ---- <保存到相册> ----
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    // 系统方法，根据 error 确定是否保存成功
    if(error) {
        NSLog(@"保存失败！请检查照片权限");
        // 写自己常用的提示框或 HUD
    }
    else {
        NSLog(@"保存完成！");
        // 写自己常用的提示框或 HUD
    }
}

#pragma mark ---- 图片拖动手势 ----
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    UIView *view = gestureRecognizer.view;
    // 判断是拖动手势
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        // 获取拖动的距离
        CGPoint offset = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:view];
        
        // 判断是左右拖动，则不可拖动，上下拖动，则可以拖动
        if ((fabs(offset.x) >= fabs(offset.y))) {
            return NO;
        }
        return YES;
    }
    return YES;
}

// 拖动时触发的方法
- (void)panGestureRecognize:(UIPanGestureRecognizer *)recognize {
    UIView *view = recognize.view;
    CGPoint offset = [recognize translationInView:view];
    CGFloat itemH;
    if (self.imageHeightArr.count > self.index) {
        itemH = [self.imageHeightArr[self.index] floatValue];
    }
    else {
        itemH = self.frame.size.width;
    }
    CGFloat scale = 1;
    CGRect rect;
    if (self.rects.count > self.index) {
        rect = [self.rects[self.index] CGRectValue];
    }
    else {
        rect = CGRectMake(0, (self.frame.size.height - itemH)/2, self.frame.size.width, itemH);
    }
    
    switch (recognize.state) {
        case UIGestureRecognizerStateBegan:
            self.saveButton.alpha = self.pageControl.alpha = 0;
            break;

        case UIGestureRecognizerStateChanged:
        {
            if (fabs(offset.y) < self.frame.size.height) {
                scale = (self.frame.size.height - fabs(offset.y))/(self.frame.size.height);
                self.lastScale = scale;
            }
            else {
                scale = self.lastScale;
            }
            CGAffineTransform transform;
            transform = CGAffineTransformMakeScale(scale, scale);
            view.transform = CGAffineTransformTranslate(transform, offset.x, offset.y);
            
            view.superview.superview.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scale];
        }
            break;

        case UIGestureRecognizerStateEnded:
        {
            if (fabs(offset.y) < self.frame.size.height/2) {
                [UIView animateWithDuration:0.3 animations:^{
                    view.transform = CGAffineTransformMakeScale(1, 1);
                    view.superview.superview.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
                } completion:^(BOOL finished) {
                    self.saveButton.alpha = self.pageControl.alpha = 1;
                }];
            }
            else {
                [self dismissToView:(UIScrollView *)view.superview.superview];
            }
        }
            break;

        case UIGestureRecognizerStateCancelled:
            break;
        default:
            break;
    }
}

#pragma mark ---- Action ----
// 保存图片
- (void)saveImage:(UIButton *)sender {
    // 保存照片
    UIImageView *imageView = [[self.scrollView viewWithTag:100 + self.index] viewWithTag:10];
    UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

// scrollView 点击手势
- (void)click:(UITapGestureRecognizer *)tap {
    [self dismissToView:self.scrollView];
}

// 返回
- (void)dismissToView:(UIScrollView *)scrollView {
    // 缩小并回滚图片位置的动画
    [UIView animateWithDuration:0.3 animations:^{
        // 根据 scrollView 当前滑动的距离来获取当前是哪张图片
        UIImageView *imageView = [[scrollView viewWithTag:100 + self.index] viewWithTag:10];
        
        // 判断在主界面控件的数量和实际展示图片的数量
        if (self.rects.count > self.index) {
            // 不超过控件数量，则按图片位置返回到控件的 frame 位置
            imageView.frame = [self.rects[self.index] CGRectValue];
        }
        else {
            if (self.rects.count > 0) {
                // 实际展示图片数量超过上级界面传入的控件数量
                // 则按图片位置返回到最后一个控件的 frame 位置
                imageView.frame = [self.rects[self.rects.count - 1] CGRectValue];
            }
            else {
                // 未传入控件
                // 则图片充满屏幕消失
                imageView.frame = CGRectMake(0, (self.frame.size.height - self.frame.size.width)/2, self.frame.size.width, self.frame.size.width);
            }
        }
        
        // scrollView 渐变消失
        scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        // 移除本视图
        [self removeFromSuperview];
    }];
}

#pragma mark ---- lazy load ----
// 图片高度数组（所有图片都是宽度充满屏幕，高度自适应）
- (NSMutableArray *)imageHeightArr {
    if (!_imageHeightArr) {
        _imageHeightArr = [NSMutableArray array];
    }
    return _imageHeightArr;;
}

// 上级界面传入的 frame 数组，用来做展示和返回动画放大缩小
- (NSMutableArray *)rects {
    if (!_rects) {
        _rects = [NSMutableArray array];
    }
    return _rects;
}

@end
