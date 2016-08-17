//
//  ViewController.m
//  fllowscroll
//
//  Created by wangrui on 16/8/17.
//  Copyright © 2016年 tools. All rights reserved.
//

#import "ViewController.h"
#import "WRContentViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UIScrollViewDelegate>

// 顶部按钮的数组
@property (nonatomic,strong) NSMutableArray *titlesBtn;

// 头部滚动视图
@property (nonatomic,weak) UIScrollView *topBarSV;
// 滚动的背景图
@property (nonatomic,weak) UIView *backShowView;
// 底部滚动的视图
@property (nonatomic, weak) UIScrollView *contentView;

// 当前选择的button
@property (nonatomic,weak) UIButton *selectedButton;

@property (nonatomic,assign) NSInteger leftIndex;

@end

@implementation ViewController

static const CGFloat topBarHeight = 50.0;
static const CGFloat topViewWidth = 70.0;
static const int topBarNum = 7;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupTopBar];
    [self setupChildVces];
    [self setupContentView];
    
}

// 头部选择按钮的点击
-(void)selectDay:(UIButton *)btn{
    self.selectedButton.enabled = YES;
    btn.enabled = NO;
    self.selectedButton = btn;
    CGPoint offset = self.contentView.contentOffset;
    offset.x = (btn.tag - 100) * self.contentView.frame.size.width;
    [self.contentView setContentOffset:offset animated:YES];
}

// 调整按钮的位置
- (void)setupTitleCenter:(UIButton *)btn
{
    CGFloat offset = btn.center.x - SCREEN_WIDTH * 0.5;
    
    if (offset < 0)
    {
        offset = 0;
    }
    
    CGFloat maxOffset = self.topBarSV.contentSize.width - SCREEN_WIDTH;
    if (offset > maxOffset)
    {
        offset = maxOffset;
    }
    
    [self.topBarSV setContentOffset:CGPointMake(offset, 0) animated:YES];
}

// 初始化顶部UI
-(void)setupTopBar{
    UIScrollView *topBarSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, topBarHeight)];
    topBarSV.bounces = false;
    topBarSV.showsHorizontalScrollIndicator = false;
    topBarSV.backgroundColor = [UIColor redColor];
    [self.view addSubview:topBarSV];
    self.topBarSV = topBarSV;
    topBarSV.contentSize = CGSizeMake(topBarNum * topViewWidth, topBarHeight);
    
    //  头部跟随移动的黄背景图
    UIView *backShowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, topViewWidth, topBarHeight)];
    backShowView.backgroundColor = [UIColor colorWithRed:252.0/255.0 green:208.0/255/0 blue:0 alpha:1];
    [self.topBarSV addSubview:backShowView];
    self.backShowView = backShowView;
    
    for (int i = 0; i < topBarNum; i++) {
        UIButton *topBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(topViewWidth * i, 0, topViewWidth, topBarHeight)];
        [topBarBtn setTitle:[NSString stringWithFormat:@"%d",i] forState:(UIControlStateNormal)];
        [topBarBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        topBarBtn.tag = 100+i;
        [topBarBtn addTarget:self action:@selector(selectDay:) forControlEvents:(UIControlEventTouchUpInside)];
        topBarBtn.backgroundColor = [UIColor clearColor];
        [topBarSV addSubview:topBarBtn];
        [self.titlesBtn addObject:topBarBtn];
        // 默认点击第一个按钮
        if (i == 0) {
            [self selectDay:topBarBtn];
        }
    }
}

// 初始化子控制器
- (void)setupChildVces{
    for (int i = 0; i < topBarNum; i ++) {
        WRContentViewController *contentVC = [[WRContentViewController alloc] init];
        [self addChildViewController:contentVC];
    }
}

// 中间可滚动的选择视图
- (void)setupContentView
{
    self.automaticallyAdjustsScrollViewInsets = false;
    
    UIScrollView *contentView = [[UIScrollView alloc] init];
    contentView.bounces = false;
    contentView.frame = CGRectMake(0, 20, SCREEN_WIDTH, self.view.frame.size.height - 20);
    contentView.backgroundColor = [UIColor clearColor];
    contentView.showsVerticalScrollIndicator = false;
    contentView.showsHorizontalScrollIndicator = false;
    contentView.delegate = self;
    contentView.pagingEnabled = YES;
    [self.view insertSubview:contentView atIndex:0];
    contentView.contentSize = CGSizeMake(contentView.frame.size.width * self.childViewControllers.count, 0);
    self.contentView = contentView;
    
    // 添加第一个控制器的view
    [self scrollViewDidEndScrollingAnimation:contentView];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 当前的索引
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    // 取出子控制器
    if (self.childViewControllers.count > 0) {
        UIViewController *vc = self.childViewControllers[index];
        CGRect rect = vc.view.frame;
        rect.origin.x = scrollView.contentOffset.x;
        rect.origin.y = topBarHeight;
        rect.size.height = scrollView.frame.size.height;
        vc.view.frame = rect;
        [scrollView addSubview:vc.view];
        [self selectDay:self.titlesBtn[index]];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
    
    // 点击按钮
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    [self selectDay:self.titlesBtn[index]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x / SCREEN_WIDTH * topViewWidth;
    self.backShowView.transform = CGAffineTransformMakeTranslation(offsetX, 0);
    
    CGFloat curPage = scrollView.contentOffset.x / SCREEN_WIDTH;
    NSInteger leftIndex = curPage;
    
    if (leftIndex != self.leftIndex) {
        UIButton *currentBtn = self.titlesBtn[leftIndex];
        [self setupTitleCenter:currentBtn];
        self.leftIndex = leftIndex;
    }
}

#pragma - mark 懒加载
-(NSMutableArray *)titlesBtn{
    if (!_titlesBtn) {
        _titlesBtn = [NSMutableArray array];
    }
    return _titlesBtn;
}

@end
