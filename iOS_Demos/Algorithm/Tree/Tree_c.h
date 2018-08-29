//
//  Tree_c.h
//  iOS_Demos
//
//  Created by 张一鸣 on 2018/8/3.
//  Copyright © 2018年 张一鸣. All rights reserved.
//

#ifndef Tree_c_h
#define Tree_c_h

#include <stdio.h>


typedef struct CSNode_Tree {
    int data;
    struct CSNode_Tree * firstchild, *nextsibling;
}CSNode_Tree,*CSTree;

#endif /* Tree_c_h */
