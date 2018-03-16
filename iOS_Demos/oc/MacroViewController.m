//
//  MacroViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 07/03/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "MacroViewController.h"


#define __NSX_PASTE__(A, B) A##B

#define MIN(A, B) __NSMIN_IMPL__(A, B, __COUNTER__)

#define __NSMIN_IMPL__(A, B, L) ({                                                                   \
    __typeof__(A) __NSX_PASTE__(__a, L) = (A);                                                       \
    __typeof__(B) __NSX_PASTE__(__b, L) = (B);                                                       \
    (__NSX_PASTE__(__a, L) < __NSX_PASTE__(__b, L)) ? __NSX_PASTE__(__a, L) : __NSX_PASTE__(__b, L); \
})

//第一个__NSX_PASTE__里出现的两个连着的井号##在宏中是一个特殊符号，它表示将两个参数连接起来这种运算
// 。其实__COUNTER__是一个预定义的宏，这个值在编译过程中将从0开始计数，每次被调用时加1
//因为唯一性，所以很多时候被用来构造独立的变量名称。有了上面的基础，再来看最后的实现宏就很简单了。
//整体思路和前面的实现和之前的GNUC MIN是一样的，区别在于为变量名__a和__b添加了一个计数后缀，
//这样大大避免了变量名相同而导致问题的可能性（当然如果你执拗地把变量叫做__a9527并且出问题了的话


//A better version of NSLog
#define NSLog(format, ...)                                                                 \
    do {                                                                                   \
        fprintf(stderr, "<%s : %d> %s\n",                                                  \
                [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], \
                __LINE__, __func__);                                                       \
        (NSLog)((format), ##__VA_ARGS__);                                                  \
        fprintf(stderr, "-------\n");                                                      \
    } while (0)

//写为...的参数被叫做可变参数(variadic)。可变参数的个数不做限定。在这个宏定义中，除了第一个参数format将被单独处理外，接下来输入的参数将作为整体一并看待
//do while 只是为了保证一个作用域
//__VA_ARGS__表示的是宏定义中的...中的所有剩余参数。我们之前说过可变参数将被统一处理，在这里展开的时候编译器会将__VA_ARGS__直接替换为输入中从第二个参数开始的剩余参数。另外一个悬疑点是在它前面出现了两个井号##。还记得我们上面在MIN中的两个井号么，在那里两个井号的意思是将前后两项合并，在这里做的事情比较类似，将前面的格式化字符串和后面的参数列表合并，

//而直接写成NSLog(...)会不会有问题？对于我们这里这个例子来说的话是没有变化的，但是我们需要记住的是...是可变参数列表，它可以代表一个、两个，或者是很多个参数，但同时它也能代表零个参数。如果我们在申明这个宏的时候没有指定format参数，而直接使用参数列表，那么在使用中不写参数的NSLog()也将被匹配到这个宏中，导致编译无法通过。如果你手边有Xcode，也可以看看Cocoa中真正的NSLog方法的实现，可以看到它也是接收一个格式参数和一个参数列表的形式，我们在宏里这么定义，正是为了其传入正确合适的参数，从而保证使用者可以按照原来的方式正确使用这个宏。

//第二点是既然我们的可变参数可以接受任意个输入，那么在只有一个format输入，而可变参数个数为零的时候会发生什么呢？不妨展开看一看，记住##的作用是拼接前后，而现在##之后的可变参数是空：

//NSLog(@"Hello");
//=> do {
//    fprintf((stderr, "<%s : %d> %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __func__);
//            (NSLog)((@"Hello"), );
//            fprintf(stderr, "-------\n");
//            } while (0);

//中间的一行(NSLog)(@"Hello", );似乎是存在问题的，你一定会有疑惑，这种方式怎么可能编译通过呢？！原来大神们其实早已想到这个问题，并且进行了一点特殊的处理。这里有个特殊的规则，
//在逗号和__VA_ARGS__之间的双井号，除了拼接前后文本之外，还有一个功能，那就是如果后方文本为空，那么它会将前面一个逗号吃掉。这个特性当且仅当上面说的条件成立时才会生效，因此可以说是特例。加上这条规则后，我们就可以将刚才的式子展开为正确的(NSLog)((@"Hello"));了。
// 最后一个值得讨论的地方是(NSLog)((format), ##__VA_ARGS__);的括号使用。把看起来能去掉的括号去掉，写成NSLog(format, ##__VA_ARGS__);是否可以呢？在这里的话应该是没有什么大问题的，首先format不会被调用多次也不太存在误用的可能性（因为最后编译器会检查NSLog的输入是否正确）。另外你也不用担心展开以后式子里的NSLog会再次被自己展开，虽然展开式中NSLog也满足了我们的宏定义，但是宏的展开非常聪明，展开后会自身无限循环的情况，就不会再次被展开了。

#define NSLogRect(rect) NSLog(@"%s x:%.4f, y:%.4f, w:%.4f, h:%.4f", #rect, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define NSLogSize(size) NSLog(@"%s w:%.4f, h:%.4f", #size, size.width, size.height)
#define NSLogPoint(point) NSLog(@"%s x:%.4f, y:%.4f", #point, point.x, point.y)


#define XCTAssertTrue(expression, format...) \
    _XCTPrimitiveAssertTrue(expression, ##format)

#define _XCTPrimitiveAssertTrue(expression, format...)                                                                     \
    ({                                                                                                                     \
        @try {                                                                                                             \
            BOOL _evaluatedExpression = !!(expression);                                                                    \
            if (!_evaluatedExpression) {                                                                                   \
                _XCTRegisterFailure(_XCTFailureDescription(_XCTAssertion_True, 0, @ #expression), format);                 \
            }                                                                                                              \
        }                                                                                                                  \
        @catch (id exception) {                                                                                            \
            _XCTRegisterFailure(_XCTFailureDescription(_XCTAssertion_True, 1, @ #expression, [exception reason]), format); \
        }                                                                                                                  \
    })

//我们后面的的参数是format...，这其实也是可变参数的一种写法，和...与__VA_ARGS__配对类似，{NAME}...将于{NAME}配对使用
//就是定义的先对expression取了两次反？我不是科班出身，但是我还能依稀记得这在大学程序课上讲过，两次取反的操作可以确保结果是BOOL值，这在objc中还是比较重要的
//然后就是@#expression这个式子。我们接触过双井号##，而这里我们看到的操作符是单井号#，注意井号前面的@是objc的编译符号，不属于宏操作的对象。单个井号的作用是字符串化，简单来说就是将替换后在两头加上”“，转为一个C字符串。这里使用@然后紧跟#expression，出来后就是一个内容是expression的内容的NSString。
//然后这个NSString再作为参数传递给_XCTRegisterFailure和_XCTFailureDescription等，继续进行展开，这些是后话。简单一瞥，我们大概就可以想象宏帮助我们省了多少事儿了，如果各位看官要是写个断言还要来个十多行的话，想象都会疯掉的吧


//调用 RACSignal是类的名字

//以下开始是宏定义
//rac_valuesForKeyPath:observer:是方法名
#define RACObserve(TARGET, KEYPATH) \
    [(id)(TARGET) rac_valuesForKeyPath:@keypath(TARGET, KEYPATH) observer:self]

#define keypath(...) \
    metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__))(keypath1(__VA_ARGS__))(keypath2(__VA_ARGS__))

//这个宏在取得keypath的同时在编译期间判断keypath是否存在，避免误写
//您可以先不用介意这里面的巫术..
#define keypath1(PATH) \
    (((void)(NO && ((void)PATH, NO)), strchr(#PATH, '.') + 1))

#define keypath2(OBJ, PATH) \
    (((void)(NO && ((void)OBJ.PATH, NO)), #PATH))

//A和B是否相等，若相等则展开为后面的第一项，否则展开为后面的第二项
//eg. metamacro_if_eq(0, 0)(true)(false) => true
//    metamacro_if_eq(0, 1)(true)(false) => false
#define metamacro_if_eq(A, B) \
    metamacro_concat(metamacro_if_eq, A)(B)

// 当上面的a为1的时候到这，如果第二个为
// metamacro_if_eq1(0) --> metamacro_if_eq0(-1) --> metamacro_if_eq0_-1
// metamacro_if_eq1(1) --> metamacro_if_eq0(0) --> metamacro_if_eq0_0
#define metamacro_if_eq1(VALUE) metamacro_if_eq0(metamacro_dec(VALUE))

// 当上面的a为0的时候到这，
// metamacro_if_eq0(1) --> metamacro_if_eq0_1
// metamacro_if_eq0(0) --> metamacro_if_eq0_0
#define metamacro_if_eq0(VALUE) \
    metamacro_concat(metamacro_if_eq0_, VALUE)

//metamacro_if_eq0_1(a,b) --> metamacro_expand_
#define metamacro_if_eq0_1(...) metamacro_expand_

// metamacro_expand_(a,b) --> a,b
#define metamacro_expand_(...) __VA_ARGS__

// metamacro_argcount(a,b,c,s) -->
// metamacro_at20(a,b,c,s,20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)
//metamacro_head（5, 4, 3, 2, 1）--> 5

#define metamacro_argcount(...) \
    metamacro_at(20, __VA_ARGS__, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)


//     metamacro_at(4,1,2,3,4,5,6);--> 5
#define metamacro_at(N, ...) \
    metamacro_concat(metamacro_at, N)(__VA_ARGS__)

//metamacro_concat(a,b) ---> ab
#define metamacro_concat(A, B) \
    metamacro_concat_(A, B)

//metamacro_concat_(a,b) ---> ab
#define metamacro_concat_(A, B) A##B

//     metamacro_at2(_0, _1, @"a",@"b"); -->  @"a"
#define metamacro_at2(_0, _1, ...) metamacro_head(__VA_ARGS__)

// metamacro_at20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, @"a",@"b");--->  @"a"
// 这里的_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,是用来占位置的，在20的情况下，这些都会把数字往后顶，所以就可以知道到底有几个数字了
#define metamacro_at20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, ...) metamacro_head(__VA_ARGS__)

// metamacro_head_(@"1",@"2") --->  @"1"
// 这里的0 是为了防止没有填任何数字
#define metamacro_head(...) \
    metamacro_head_(__VA_ARGS__, 0)

// metamacro_head_(@"1",@"2") --->  @"1"
#define metamacro_head_(FIRST, ...) FIRST


// metamacro_dec(10)
// metamacro_at10() 这些在rac中已经都提前定义好了
#define metamacro_dec(VAL) \
    metamacro_at(VAL, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19)


@interface MacroViewController ()

@end


@implementation MacroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
