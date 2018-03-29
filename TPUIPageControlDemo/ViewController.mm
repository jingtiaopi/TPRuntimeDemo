//
//  ViewController.m
//  TPUIPageControlDemo
//
//  Created by TP on 2017/3/7.
//  Copyright © 2017年 Tendyron. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "SecondViewController.h"
//#import "NewChangePinViewController.h"

@interface ViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIPageControl *tpPageControl;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic, copy) NSString *testString;
@property (nonatomic, assign) NSInteger *testInteger;
@property (nonatomic, strong) NSArray *testArray;

@property (nonatomic, assign) NSInteger lastPage;
@property (nonatomic, strong) NSOperationQueue *tpWorkQueue;
@property (nonatomic, assign) NSInteger currentRv;


@end

static NSString *TPWorkQueueName = @"TPWorkQueueName";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTPOperationQueue];
    
    UIColor *color1 = [UIColor redColor];
    UIColor *color2 = [UIColor redColor];
    
    if (color1 == color2) {
        NSLog(@"color1 == color2");
    }

    if ([color1 isEqual:color2]) {
        NSLog(@"[color1 isEqual:color2]");
    }
    
    if (color1.hash == color2.hash) {
        NSLog(@"color1.hash == color2.hash");
    }
    
    //2017-03-09 16:55:44.162 TPUIPageControlDemo[308:41220] self class: ViewController
    //2017-03-09 16:55:44.162 TPUIPageControlDemo[308:41220] super class: ViewController
    NSLog(@"self class: %@", NSStringFromClass([self class]));
    NSLog(@"super class: %@", NSStringFromClass([super class]));
    //runtime 获取UIPageControl的私有方法列表，动态改变其属性值
    [self.tpPageControl setValue:[UIImage imageNamed:@"normal"] forKey:@"_pageImage"];
    [self.tpPageControl setValue:[UIImage imageNamed:@"highlighted"] forKey:@"_currentPageImage"];
    self.lastPage = 0;
    [self.tpPageControl addTarget:self action:@selector(doSomething:) forControlEvents:UIControlEventValueChanged];
    //获取ViewController的属性列表
    unsigned int vcPropertyCount = 0;
    /*
     通过class_copyPropertyList 和 protocol_copyPropertyList 方法获取类和协议中的属性
     返回的是属性列表，列表中每个元素都是一个 objc_property_t 指针
     */
    Ivar *properties = class_copyIvarList([ViewController class], &vcPropertyCount);
    NSLog(@"ViewController.properties: %lu", (unsigned long)vcPropertyCount);
    for (NSInteger i = 0; i < vcPropertyCount; i++)
    {
        NSString *name = @(ivar_getName(properties[i]));//@(const char *)
        NSString *type = @(ivar_getTypeEncoding(properties[i]));//@(const char *)
        NSLog(@"property.name: %@, propterty.type: %@", name, type);
    }
    
    NSLog(@"---------------------- 修改ViewController属性 ----------------------");
    Ivar viewControllerTestString = properties[2];//testString
    object_setIvar(self, viewControllerTestString, @"测试");
    NSLog(@"changed testString: %@", self.testString);
    Ivar viewControllerLastPage = properties[5];//lastPage
    object_setIvar(self, viewControllerLastPage, @(100));
    NSLog(@"changed lastPage: %ld", (long)self.lastPage);
    
    NSLog(@"---------------------- 给ViewController增加方法 ----------------------");
    [self tryAddingFunctionToViewController];
    [self performSelector:NSSelectorFromString(@"addMethodWithInt:withString:") withObject:@(52) withObject:@"呵哒哒"];
//    objc_msgSend(self, @selector(addMethodWithInt:withString:), @(520), @"呵哒哒");//参数传不过去
    
    //获取UIPageControl 的属性列表
/*
    unsigned int pageControlPropertyCount = 0;
    objc_property_t *propertyList = class_copyPropertyList([UIPageControl class], &pageControlPropertyCount);
    NSLog(@"UIPageControl.properties: %d", pageControlPropertyCount);
    for (NSInteger i = 0; i < pageControlPropertyCount; i++)
    {
        const char *propertyName = property_getName(propertyList[i]);
        NSString *propertyNameString = [[NSString alloc] initWithUTF8String:propertyName];
//        NSString *name = @(property_getName(propertyList[i]));
        const char *attributes = property_getAttributes(propertyList[i]);
        NSString *attributesString = [[NSString alloc] initWithUTF8String:attributes];
//        NSString *attributes = @(property_getAttributes(propertyList[i]));
        NSLog(@"UIPageControl.property.name: %@, UIPageControl.property.attributes: %@", propertyNameString, attributesString);
    }
*/
    //第二种
    unsigned int pageControlIvarCount = 0;
    Ivar *IvarList = class_copyIvarList([UIPageControl class], &pageControlIvarCount);
    for (NSInteger i = 0; i < pageControlIvarCount; i++)
    {
        Ivar var = IvarList[i];
        const char *varName = ivar_getName(var);
        const char *varType = ivar_getTypeEncoding(var);
        NSLog(@"UIPageControl.Ivar.name: %@, UIPageControl.Ivar.type: %@", [[NSString alloc] initWithUTF8String:varName], [[NSString alloc] initWithUTF8String:varType]);
    }
    
    
    //获取UIPageControl 的方法列表
    unsigned int pageControlMethodCount = 0;
    Method *methodList = class_copyMethodList([UIPasteboard class], &pageControlMethodCount);
    for (NSInteger i = 0; i < pageControlMethodCount; i++)
    {
        SEL methodName = method_getName(methodList[i]);
        NSString *methodNameString = NSStringFromSelector(methodName);
        NSLog(@"UIPageControl.method:%@", methodNameString);
    }
    
    //获取UIPageControl 的协议列表
    unsigned int pageControlProtocolCount = 0;
    Protocol *__unsafe_unretained *protocolList = class_copyProtocolList([UIPageControl class], &pageControlProtocolCount);
    for (NSInteger i = 0; i < pageControlProtocolCount; i++)
    {
        const char *protocolName = protocol_getName(protocolList[i]);
        NSString *protocolNameString = [[NSString alloc] initWithUTF8String:protocolName];
        NSLog(@"UIPageControl.protocol: %@", protocolNameString);
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(50.0, CGRectGetHeight(self.view.frame) * 4 / 5, CGRectGetWidth(self.view.frame) - 50.0 * 2, 80)];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), 3 * CGRectGetHeight(self.scrollView.frame));
    [self.view addSubview:self.scrollView];
    [self scrollViewFlashScrollIndicators];
    
    //替换系统方法
    SEL systemSel = NSSelectorFromString(@"_hideScrollIndicators");//仅在加载完后，不隐藏indicator，手动滑动之后隐藏(滑动后不调用该方法了)(可在滑动结束时再次调用flashScrollIndicators)
    SEL swizzSel = @selector(replaceSystemScrollViewHideIndicators);
    Method systemMethod = class_getInstanceMethod([UIScrollView class], systemSel);
    Method swizzMethod = class_getInstanceMethod([self class], swizzSel);
    BOOL isAdd = class_addMethod([UIScrollView class], systemSel, method_getImplementation(swizzMethod), method_getTypeEncoding(swizzMethod));
    if (isAdd)
    {
        //如果成功，说明类中不存在这个方法的实现
        //将被交换方法的实现替换到这个并不存在的实现
        class_replaceMethod([UIScrollView class], swizzSel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }
    else
    {
        //否则，交换两个方法的实现
        method_exchangeImplementations(systemMethod, swizzMethod);
    }
    
    //UIScrollView
    unsigned int scrollViewPropertyCount = 0;
    objc_property_t *scrollViewPropertyList = class_copyPropertyList([UIScrollView class], &scrollViewPropertyCount);
    for (NSInteger i = 0; i < scrollViewPropertyCount; i++)
    {
        const char *propertyName = property_getName(scrollViewPropertyList[i]);
        NSString *propertyNameString = [[NSString alloc] initWithUTF8String:propertyName];
        const char *attribute = property_getAttributes(scrollViewPropertyList[i]);
        NSString *propertyAttributeString = [[NSString alloc] initWithUTF8String:attribute];
        NSLog(@"UIScrollView.property.name: %@, UIScrollView.property.attribute: %@", propertyNameString, propertyAttributeString);
    }
    
    unsigned int scrollViewMethodCount = 0;
    Method *scrollViewMethodList = class_copyMethodList([UIScrollView class], &scrollViewMethodCount);
    for (NSInteger i = 0; i < scrollViewMethodCount; i++)
    {
        SEL methodName = method_getName(scrollViewMethodList[i]);
        NSString *methodNameString = NSStringFromSelector(methodName);
        NSLog(@"UIScrollView.method: %@", methodNameString);
    }
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tap];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"代理费及水立方是'圣诞节方法";
    titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    titleLabel.backgroundColor = [UIColor redColor];
    titleLabel.font = [UIFont systemFontOfSize:26.0 / 2];
    titleLabel.textAlignment = NSTextAlignmentRight;
    titleLabel.numberOfLines = 0;
    
    //八字折行
    //计算汉字及其他字符（要求全角8个换行、两个半角算一个全角）
    CGFloat charCount = 0.0;
    NSUInteger i = 0;
    NSUInteger theOtherCharacterCount = 0;
    NSMutableString *theOtherCaracterStr = [NSMutableString string];
    for(; i < [titleLabel.text length]; i++)
    {
        NSString *tempStr = [titleLabel.text substringWithRange:NSMakeRange(i, 1)];
        NSUInteger charStrLength = strlen([tempStr UTF8String]);
        if (charStrLength == 3)
        {
            charCount += charStrLength;
        }
        else
        {
            charCount += 1.5;
            theOtherCharacterCount++;
            [theOtherCaracterStr appendString:tempStr];
        }
        NSLog(@"第%ld个字是:%@, charCount: %.1f", (long)i, tempStr, charCount);
        if (charCount == 24.0)
        {
            break;
        }
        else if (charCount > 24.0)//一个汉字3，3 * 8 折行
        {
            i--;
            break;
        }
    }
    if (i+1 < titleLabel.text.length)
    {
        titleLabel.text = [NSString stringWithFormat:@"%@\n%@", [titleLabel.text substringToIndex:i+1], [titleLabel.text substringFromIndex:i+1]];
    }
    CGFloat titleLabelLimitWidth = [[titleLabel.text substringToIndex:MIN(i+1, titleLabel.text.length)] sizeWithAttributes:@{NSFontAttributeName : titleLabel.font}].width;
    CGFloat eightChineseLimitWidth = [@"计算八个汉字长度" sizeWithAttributes:@{NSFontAttributeName : titleLabel.font}].width;
    //该折行，并且包含其他字符（两个字符算一个汉字，但是宽度不够一个汉字）
    NSLog(@"charCount: %f, theOtherCharacterCount: %lu", charCount, (unsigned long)theOtherCharacterCount);
    if (charCount >= 24.0)
    {
        CGFloat theOtherCharacterWidth = [theOtherCaracterStr sizeWithAttributes:@{NSFontAttributeName : titleLabel.font}].width;
        titleLabelLimitWidth += (eightChineseLimitWidth - titleLabelLimitWidth - theOtherCharacterWidth);
    }
    CGFloat titleLabelHeight = [titleLabel.text boundingRectWithSize:CGSizeMake(titleLabelLimitWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : titleLabel.font} context:nil].size.height;
    titleLabel.frame = CGRectMake(50.0, 150.0, titleLabelLimitWidth, titleLabelHeight);
    [self.view addSubview:titleLabel];
    
    
/*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SecondViewController *second = [[SecondViewController alloc] init];
        [self presentViewController:second animated:YES completion:nil];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
    });
 */
}

#pragma mark - ViewController Replace Method
- (void)tryAddingFunctionToViewController
{
    class_addMethod([ViewController class], NSSelectorFromString(@"addMethodWithInt:withString:"), (IMP)myAddingFunction, "i@:i@");
}

int myAddingFunction(id self, SEL _cmd, NSNumber *var1, NSString *var2)
{
    NSLog(@"parameter1: %@, parameter2: %@", var1, var2);
    return 1;
}

#pragma mark - UIScrollView Replace Method

- (void)replaceSystemScrollViewHideIndicators
{
    
}

- (void)scrollViewFlashScrollIndicators
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        objc_msgSend(weakSelf.scrollView, @selector(flashScrollIndicators));
    });
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~ %s, decelerate: %d", __FUNCTION__, decelerate);
    if (!decelerate)
    {
        [self scrollViewFlashScrollIndicators];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!! %s", __FUNCTION__);
    [self scrollViewFlashScrollIndicators];
}

#pragma mark - Methods

- (void)tapAction
{
//    NewChangePinViewController *changePinVC = [[NewChangePinViewController alloc] init];
//    [self.navigationController pushViewController:changePinVC animated:YES];
//    return;
    
    [self getValue];
    SecondViewController *second = [[SecondViewController alloc] init];
//    second.modalPresentationStyle = /*iOS7*/ UIModalPresentationCurrentContext;///*iOS8*/ UIModalPresentationOverCurrentContext;
//    second.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentViewController:second animated:YES completion:nil];
    [self.navigationController pushViewController:second animated:YES];
}

- (void)doSomething:(UIPageControl *)pageControl
{
    NSLog(@"currentPage: %ld, lastPage: %ld", (long)pageControl.currentPage, (long)self.lastPage);
/*
    if (pageControl.currentPage > self.lastPage)
    {
        [self tpAsyncWork:^{
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"1、in main thread do something.");
        }];
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self tpAsyncWork:^{
                [NSThread sleepForTimeInterval:1.0];
                NSLog(@"2、in child thread do something.");
            }];
        });
    }
*/
/*
    if (pageControl.currentPage > self.lastPage)
    {
        __block NSUInteger rv = 0;
        rv = [self tpAsyncWorkWithReturnValue:^NSUInteger{
            [NSThread sleepForTimeInterval:1.0];
            rv++;
            NSLog(@"1、in main thread do something.");
            return rv;
        }];
        NSLog(@"1、rv: %lu", (unsigned long)rv);
    }
    else
    {
        __block NSUInteger rv = 0;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            rv = [self tpAsyncWorkWithReturnValue:^NSUInteger{
                [NSThread sleepForTimeInterval:1.0];
                rv++;
                NSLog(@"2、in child thread do something.");
                return rv;
            }];
            NSLog(@"2、rv: %lu", (unsigned long)rv);
        });
    }
*/
    __weak typeof(self) weakSelf = self;
    if (pageControl.currentPage > self.lastPage)
    {
        [self tpAsyncWorkWithReturnValue:^NSUInteger{
            weakSelf.currentRv++;
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"1、in main thread do something.");
            return weakSelf.currentRv;
        }];
        NSLog(@"1、rv: %ld\n", (long)weakSelf.currentRv);
        self.lastPage = pageControl.currentPage;
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"NSThread: %@", [NSThread currentThread]);
            [self tpAsyncWorkWithReturnValue:^NSUInteger{
                weakSelf.currentRv--;
                [NSThread sleepForTimeInterval:1.0];
                NSLog(@"2、in child thread do something.");
                return weakSelf.currentRv;
            }];
            NSLog(@"2、rv: %ld, NSThread: %@", (long)weakSelf.currentRv, [NSThread currentThread]);
            self.lastPage = pageControl.currentPage;
        });
    }
}

#pragma mark - OperationQueue
- (void)initTPOperationQueue
{
    self.tpWorkQueue = [[NSOperationQueue alloc] init];
    self.tpWorkQueue.maxConcurrentOperationCount = 1;//并发运行的线程个数
    self.tpWorkQueue.name = TPWorkQueueName;
}

-(void)getValue
{
    NSLog(@"currentRv:%ld",(long)self.currentRv);
}

- (void)tpAsyncWork:(void(^)())tpWorkBlock
{
    __block BOOL isTaskDoneFlag = NO;
    __block BOOL isInMainThreadFlag = [[NSThread currentThread] isMainThread];
    NSCondition *taskLockCondition = [[NSCondition alloc] init];
    CFRunLoopRef currentRunLoopRef = CFRunLoopGetCurrent();
    if (isInMainThreadFlag)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.tpWorkQueue addOperationWithBlock:^{
                tpWorkBlock();
            }];
            [self.tpWorkQueue waitUntilAllOperationsAreFinished];
            isTaskDoneFlag = YES;
            CFRunLoopStop(currentRunLoopRef);
        });
    }
    else
    {
        [self.tpWorkQueue addOperationWithBlock:^{
            tpWorkBlock();
        }];
        [self.tpWorkQueue waitUntilAllOperationsAreFinished];
        isTaskDoneFlag = YES;
        [taskLockCondition signal];
    }
    [taskLockCondition lock];
    while (!isTaskDoneFlag)
    {
        if (isInMainThreadFlag)
        {
            @autoreleasepool
            {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        }
        else
        {
            [taskLockCondition wait];
        }
    }
    [taskLockCondition unlock];
}

- (NSUInteger)tpAsyncWorkWithReturnValue:(NSUInteger(^)())tpWorkBlock
{
    __block NSUInteger rv = 0;
    __block BOOL isTaskDoneFlag = NO;
    __block BOOL isInMainThreadFlag = [[NSThread currentThread] isMainThread];
    CFRunLoopRef currentRunLoopRef = CFRunLoopGetCurrent();
    NSCondition *taskLockCondition = [[NSCondition alloc] init];
    if (isInMainThreadFlag)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.tpWorkQueue addOperationWithBlock:^{
                rv = tpWorkBlock();
            }];
            [self.tpWorkQueue waitUntilAllOperationsAreFinished];
            isTaskDoneFlag = YES;
            CFRunLoopStop(currentRunLoopRef);
        });
    }
    else
    {
        [self.tpWorkQueue addOperationWithBlock:^{
            rv = tpWorkBlock();
        }];
        [self.tpWorkQueue waitUntilAllOperationsAreFinished];
        isTaskDoneFlag = YES;
        [taskLockCondition signal];
    }
    [taskLockCondition lock];
    while (!isTaskDoneFlag)
    {
        if (isInMainThreadFlag)
        {
            @autoreleasepool
            {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        }
        else
        {
            [taskLockCondition wait];
        }
    }
    [taskLockCondition unlock];
    return rv;
}

@end
