//
//  ViewController.m
//  DispatchDemo
//
//  Created by jglx on 16/10/21.
//  Copyright © 2016年 Organization. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic,assign) int secondLB;

@property (nonatomic,strong)dispatch_source_t myTimer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self asyncConcurrent]; // 异步执行+加并行队列--
//    [self asyncSerial];       // 异步执行 + 串行队列
//    [self syncConcurrent];      // 同步执行 + 并行队列
//      [self syncSerial];    // 同步执行 + 串行队列
    [self syncMain]; // 同步队列 + 主队列(死锁)
}

-(void)asyncConcurrent{
    dispatch_queue_t queue = dispatch_queue_create("标识符", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"----start---");
    dispatch_async(queue, ^{
        NSLog(@"任务1 --- %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务2 --- %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务3 --- %@",[NSThread currentThread]);
    });
    NSLog(@"---end ---");
    
    // --- 异步执行意味着 1.可以开启新的线程 2/任务可以先绕过不执行,回头再来执行
    // --- 并行队列意味着 1.任务之间不需要排队,且具有同时被执行的"权利"
//        两者组合后的结果
//        开了三个新线程
//        函数在执行时，先打印了start和end，再回头执行这三个任务
//        这三个任务是同时执行的，没有先后
}

-(void)asyncSerial{
    dispatch_queue_t queue = dispatch_queue_create("标识符", DISPATCH_QUEUE_SERIAL);
//      DISPATCH_QUEUE_CONCURRENT
//    DISPATCH_QUEUE_CONCURRENT
    NSLog(@"----start ---- ");
    dispatch_async(queue, ^{
        //
        NSLog(@"任务1 --- %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        //
        NSLog(@"任务2 --- %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        //
        NSLog(@"任务3 --- %@",[NSThread currentThread]);
    });
    NSLog(@"----end---");
    
//    异步执行意味着
//    可以开启新的线程
//    任务可以先绕过不执行，回头再来执行
//    串行队列意味着
//    任务必须按添加进队列的顺序挨个执行
//    两者组合后的结果
//    开了一个新的子线程
//    函数在执行时，先打印了start和end，再回头执行这三个任务
//    这三个任务是按顺序执行的，所以打印结果是“任务1-->任务2-->任务3”
}

-(void)syncConcurrent{
    dispatch_queue_t queue = dispatch_queue_create("标识符",DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"--- start---");
    
    dispatch_sync(queue, ^{
        //
        NSLog(@"任务1 --- %@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        //
        NSLog(@"任务2 --- %@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        //
        NSLog(@"任务3 --- %@",[NSThread currentThread]);
    });
    NSLog(@"---- end --- ");
    
//    同步执行执行意味着
//    不能开启新的线程
//    任务创建后必须执行完才能往下走
//    并行队列意味着
//    任务必须按添加进队列的顺序挨个执行
//    两者组合后的结果
//    所有任务都只能在主线程中执行
//    函数在执行时，必须按照代码的书写顺序一行一行地执行完才能继续
//    注意事项
//    在这里即便是并行队列，任务可以同时执行，但是由于只存在一个主线程，所以没法把任务分发到不同的线程去同步处理，其结果就是只能在主线程里按顺序挨个挨个执行了
}

-(void)syncSerial{
    dispatch_queue_t queue = dispatch_queue_create("标识符", DISPATCH_QUEUE_SERIAL);
    NSLog(@"--- start---");
    
    dispatch_sync(queue, ^{
        //
        NSLog(@"任务1 --- %@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        //
        NSLog(@"任务2 --- %@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        //
        NSLog(@"任务3 --- %@",[NSThread currentThread]);
    });
    NSLog(@"---- end --- ");
    
//    这里的执行原理和步骤图跟“同步执行+并发队列”是一样的，只要是同步执行就没法开启新的线程，所以多个任务之间也一样只能按顺序来执行，
}

-(void)asyncMain{
    dispatch_queue_t queue = dispatch_get_main_queue();
    NSLog(@"--- start---");
    
    dispatch_async(queue, ^{
        //
        NSLog(@"任务1 --- %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        //
        NSLog(@"任务2 --- %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        //
        NSLog(@"任务3 --- %@",[NSThread currentThread]);
    });
    NSLog(@"---- end --- ");
//    异步执行意味着
//    可以开启新的线程
//    任务可以先绕过不执行，回头再来执行
//    主队列跟串行队列的区别
//    队列中的任务一样要按顺序执行
//    主队列中的任务必须在主线程中执行，不允许在子线程中执行
//    以上条件组合后得出结果：
//    所有任务都可以先跳过，之后再来“按顺序”执行

}

-(void)syncMain{
    dispatch_queue_t queue = dispatch_get_main_queue();
    NSLog(@"--- start -- ");
    dispatch_sync(queue, ^{
        //
        NSLog(@"任务1 --- %@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        //
        NSLog(@"任务2 --- %@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        //
        NSLog(@"任务3 --- %@",[NSThread currentThread]);
    });
//    主队列中的任务必须按顺序挨个执行
//    任务1要等主线程有空的时候（即主队列中的所有任务执行完）才能执行
//    主线程要执行完“打印end”的任务后才有空
//    “任务1”和“打印end”两个任务互相等待，造成死锁
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
