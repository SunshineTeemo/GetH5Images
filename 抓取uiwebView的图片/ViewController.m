//
//  ViewController.m
//  抓取uiwebView的图片
//
//  Created by 龙培 on 16/9/22.
//  Copyright © 2016年 龙培. All rights reserved.
//

#import "ViewController.h"
#import "SDWebImage/WebImage.h"
#define RGBColorMaker(r, g, b, a) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]
#define PhoneScreen_HEIGHT [UIScreen mainScreen].bounds.size.height
#define PhoneScreen_WIDTH [UIScreen mainScreen].bounds.size.width
@interface ViewController ()
{
    UIWebView *myWebView;
    UIView *bgView;
    UIImageView *imgView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadWebView];
}
- (void)loadWebView
{
    myWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 20, PhoneScreen_WIDTH, PhoneScreen_HEIGHT-20)];
    
    //自动缩放适应屏幕
   myWebView.scalesPageToFit=YES;
   myWebView.delegate=self;
    //       myWebView.allowsLinkPreview=YES;
    //lol掌游宝no
   myWebView.allowsInlineMediaPlayback=NO;
   myWebView.mediaPlaybackRequiresUserAction=YES;
   myWebView.userInteractionEnabled = YES;
//    NSURL *url=[NSURL URLWithString:@"http://qt.qq.com/static/pages/news/phone/34/article_23034.shtml"];
     NSURL *url=[NSURL URLWithString:@"http://www.jianshu.com/p/931c54d38ce1"];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
   [myWebView loadRequest:request];
    
    [self.view addSubview:myWebView];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //调整字号
    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '95%'";
    [webView stringByEvaluatingJavaScriptFromString:str];
    
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var imgs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<imgs.length;i++){\
    imgScr = imgScr + imgs[i].src + '+';\
    imgs[i].onclick=function(){\
    document.location=\"myweb:imageClick:\"+this.src;\
    };\
    };\
    return imgScr;\
    };";
    
    [webView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
    
    //注入自定义的js方法后别忘了调用 否则不会生效（不调用也一样生效了，，，不明白）
//    NSString *resurlt = [webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
    NSString *urlResurlt = [webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
    NSMutableArray *mUrlArray = [NSMutableArray arrayWithArray:[urlResurlt componentsSeparatedByString:@"+"]];

    if (mUrlArray.count >= 2) {
        [mUrlArray removeLastObject];
    }
    NSLog(@"urls:%@",mUrlArray);

    NSLog(@"count:%ld",mUrlArray.count);


  
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //将url转换为string
    NSString *requestString = [[request URL] absoluteString];
        NSLog(@"requestString is %@",requestString);
    
    //hasPrefix 判断创建的字符串内容是否以pic:字符开始
    if ([requestString hasPrefix:@"myweb:imageClick:"])
    {
        NSString *imageUrl = [requestString substringFromIndex:@"myweb:imageClick:".length];
        //        NSLog(@"image url------%@", imageUrl);
        
        if (bgView)
        {
            //设置不隐藏，还原放大缩小，显示图片
            bgView.hidden = NO;
//            imgView.frame = CGRectMake(10, 10, PhoneScreen_WIDTH-40, 220);
            [imgView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
        }
        else
        {
            [self showBigImage:imageUrl];
        }//创建视图并显示图片
        
        return NO;
    }
    return YES;
}
#pragma mark 显示大图片
-(void)showBigImage:(NSString *)imageUrl{
    //创建灰色透明背景，使其背后内容不可操作
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, PhoneScreen_WIDTH, PhoneScreen_HEIGHT-20)];
//    [bgView setBackgroundColor:[UIColor colorWithRed:0.3
//                                               green:0.3
//                                                blue:0.3
//                                               alpha:0.7]];
    
    bgView.backgroundColor = [UIColor blackColor];
    bgView.userInteractionEnabled = YES;
    [self.view addSubview:bgView];
    
  
    
    //创建关闭按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"imageDelect"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(removeBigImage) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setFrame:CGRectMake(0, 0, 30, 30)];
    [bgView addSubview:closeBtn];
    
    //创建显示图像视图
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, PhoneScreen_WIDTH, PhoneScreen_HEIGHT-20)];
    imgView.userInteractionEnabled = YES;
    [imgView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    [bgView addSubview:imgView];
    //让图片根据自己的比例自适应
    imgView.contentMode=UIViewContentModeScaleAspectFit;
    //添加捏合手势
    [imgView addGestureRecognizer:[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)]];
    
    
}
//关闭按钮
-(void)removeBigImage
{
    bgView.hidden = YES;
}

- (void) handlePinch:(UIPinchGestureRecognizer*) recognizer
{
    //缩放:设置缩放比例
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
