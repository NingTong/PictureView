//
//  ViewController.m
//  PictureView
//
//  Created by admin on 2020/07/13.
//  Copyright © 2020 tn. All rights reserved.
//

#import "ViewController.h"

#import <SDWebImage.h>

#import "ReviewImageView.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *arr;          // 图片地址 数组
@property (nonatomic, strong) NSMutableArray *rects;        // 控件 frame 数组
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化
    self.rects = @[].mutableCopy;
    
    // 来个网络图片地址的数组
    self.arr = @[
        @"http://b-ssl.duitang.com/uploads/item/201805/30/20180530080009_vqgvt.jpg",
        @"http://www.jshddq.net/UploadFiles/img_2_1800278031_3205362837_26.jpg",
        @"http://www.qhca.net/UploadFiles/img_0_2682568090_129848354_26.jpg",
        @"http://img3.imgtn.bdimg.com/it/u=245481813,1474012205&fm=214&gp=0.jpg",
        @"http://pic1.win4000.com/wallpaper/5/5406ba0866a14.jpg",
        @"http://d.ifengimg.com/q100/img1.ugc.ifeng.com/newugc/20181205/10/wemedia/baff7b75ed4d50233cb1daeb54e570c5d6c1a0a4_size317_w1920_h1080.jpg",
        @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/02/04/ChMkJlbKx8SIBoNRAARCi3EupqEAALH4gF7UdUABEKj965.jpg",
        @"http://b-ssl.duitang.com/uploads/item/201808/15/20180815112432_jsnic.thumb.700_0.jpeg",
        @"http://pic1.win4000.com/wallpaper/8/552f2311830d1.jpg"].mutableCopy;
    
    // for 循环创建控件
    CGFloat space = 14;
    CGFloat btnW = (self.view.frame.size.width - space*4)/3;
    for (int i = 0; i < self.arr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((i%3)*(btnW + space) + space, (i/3)*(btnW + space) + 100, btnW, btnW);
        btn.tag = i;
        [btn sd_setImageWithURL:self.arr[i] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"位图"]];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [btn addTarget:self action:@selector(reviewImageView:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        
        // 保存控件的绝对位置
        CGRect rect = [btn convertRect:btn.bounds toView:self.view];
        [self.rects addObject:[NSValue valueWithCGRect:rect]];
    }
}

// 点击方法  (如果会 RAC，就不用方法和变量了，直接写在 for 循环里面)
- (void)reviewImageView:(UIButton *)sender {
    ReviewImageView *view = [[ReviewImageView alloc] initWithDatas:self.arr index:sender.tag rects:self.rects];
    [[UIApplication sharedApplication].keyWindow addSubview:view];
}


@end
