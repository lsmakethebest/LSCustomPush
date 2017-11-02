

#import "UIToast.h"

#define UIToastContentFont [UIFont systemFontOfSize:16]
#define UIToastBorder 10

#define UIToastDuration 1.7f

#define UIToastAnimationDuration 0.3f

// 屏幕尺寸
#define UIToastSCREEN_W    ([UIScreen mainScreen].bounds.size.width)
#define UIToastSCREEN_H    ([UIScreen mainScreen].bounds.size.height)

@interface UIToast ()

@property(nonatomic, assign) BOOL isAdd;
@property(nonatomic, assign) BOOL completed;
@property (nonatomic ,assign)BOOL isHaveOne;//标记当前是否已经有一个

@end
@implementation UIToast

+ (instancetype)shareInstance {
    return [[self alloc] init];
}

//+ (id)allocWithZone:(struct _NSZone *)zone {
//  static id instance;
//  static dispatch_once_t token;
//  dispatch_once(&token, ^{
//    instance = [super allocWithZone:zone];
//  });
//  return instance;
//}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.numberOfLines = 0;
        //323133
        self.backgroundColor =
        [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1];
        self.font = UIToastContentFont;
        self.layer.cornerRadius = 7.0f;
        self.layer.masksToBounds = YES;
        self.textColor = [UIColor colorWithRed:255/255.0 green:254/255.0 blue:254/255.0 alpha:1];
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (id)initWithMessage:(NSString *)message  withY:(CGFloat)y
{
    if (self) {
        CGSize msg_size = [UIToast stringSizeWith:message];
        CGFloat msg_x = (UIToastSCREEN_W - msg_size.width - 2 * UIToastBorder) / 2;
        self.frame = CGRectMake(msg_x, y, msg_size.width + 2 * UIToastBorder,
                                msg_size.height + 2 * UIToastBorder);
        self.text = message;
    }
    return self;
}

#pragma mark - message显示到3/4处
+ (void)showMessage:(NSString *)message
{
    [self showMessage:message offset:0];
}

+(void)showMessage:(NSString *)message offset:(CGFloat)offset
{
    CGFloat msg_y = UIToastSCREEN_H * 3 / 4+offset;
    [self showMessage:message withY:msg_y];
}

#pragma mark - 显示到中心
+(void)showMessageToCenter:(NSString *)message
{
    
    [self showMessageToCenter:message offset:0];
}

+(void)showMessageToCenter:(NSString *)message offset:(CGFloat)offset
{
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGSize msg_size = [UIToast stringSizeWith:message];
    CGFloat msg_y =msg_size.height+2*UIToastBorder;
    [self showMessage:message withY :(height-msg_y)/2+offset];
    
}
#pragma mark - 根据 Y 显示 message
+ (void)showMessage:(NSString *)message  withY:(CGFloat)y{
    
    if (message.length<=0) {
        return;
    }
    UIToast *toast = [[UIToast shareInstance] initWithMessage:message withY:y];
    //    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    
    [window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIToast class]]) {
            [obj removeFromSuperview];
            obj.alpha=0;
            [obj.layer removeAllAnimations];
            *stop=YES;
        }
    }];
    
    [toast show];
}
- (void)show {
    if (self.isHaveOne) {
        return;
    }
//    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    [window addSubview:self];
    self.alpha = 0;
    [UIView animateWithDuration:UIToastAnimationDuration
                     animations:^{
                         
                         self.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         self.isHaveOne =YES;
                         [self addAnimation];
                     }];
}

- (void)addAnimation {
    //将吐司时间延长到1.5秒
    
    [UIView animateWithDuration:UIToastAnimationDuration
                          delay:UIToastDuration
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         self.isHaveOne =NO;
                     }];
}

+ (CGSize)stringSizeWith:(NSString *)string {
    CGSize stringSize;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        stringSize =
        [string boundingRectWithSize:CGSizeMake(UIToastSCREEN_W - 2 * UIToastBorder, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:UIToastContentFont} context:nil].size;
    } else {
        stringSize =
        [string
         boundingRectWithSize:CGSizeMake(UIToastSCREEN_W - 2 * UIToastBorder, 200)
         options:NSStringDrawingUsesLineFragmentOrigin
         attributes:@{
                      NSFontAttributeName : UIToastContentFont
                      }
         context:nil]
        .size;
    }
    return stringSize;
}

@end
