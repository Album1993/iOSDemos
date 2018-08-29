//
//  Queue_c.h
//  iOS_Demos
//
//  Created by 张一鸣 on 2018/8/3.
//  Copyright © 2018年 张一鸣. All rights reserved.
//

#ifndef Queue_c_h
#define Queue_c_h

#include <stdio.h>
typedef struct Queue_Node
{
    int data;
    struct Queue_Node* next;
}Queue_Node,*QueuePtr;

typedef struct
{
    Queue_Node* front;
    Queue_Node* rear;
}Link_Queue;

void InitQueue(Link_Queue*);
void EnQueue(Link_Queue*, int);
void DeQueue(Link_Queue* Q, int * e);
void PrintQueue(Link_Queue* queue);
int QueueEmpty(Link_Queue* queue);
void DelQueue(Link_Queue* queue);
#endif /* Queue_c_h */
