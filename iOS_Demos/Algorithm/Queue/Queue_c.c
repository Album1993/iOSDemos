//
//  Queue_c.c
//  iOS_Demos
//
//  Created by 张一鸣 on 2018/8/3.
//  Copyright © 2018年 张一鸣. All rights reserved.
//

#include "Queue_c.h"
#include <stdlib.h>


void InitQueue(Link_Queue* Q)
{
    Q->front = Q->rear = (QueuePtr)malloc(sizeof(Queue_Node));
    if (!Q->front) {
        exit(0);
    }
    
    Q->front->next = NULL;
    return ;
}

void DestoryQueue(Link_Queue* Q)
{
    while (Q->front) {
        Q->rear = Q->front->next;
        free(Q->front);
        Q->front = Q->rear;
    }
}

//入队列
void EnQueue(Link_Queue* Q, int data)
{
    Queue_Node * p = (QueuePtr)malloc(sizeof(Queue_Node));
    if (!p) {
        exit(0);
    }
    
    p->data = data;
    p->next = NULL;
    Q->rear->next = p;
    Q->rear = p;
    
    return;
}



void DeQueue(Link_Queue* Q, int * e)
{
    if (Q->front == Q->rear) {
        return;
    }
    
    QueuePtr p = Q->front->next;
    
    *e = p->data;
    Q->front->next = p->next;
    
    if (Q->rear == p) {
        Q->rear = Q->front;
    }
    
    free(p);
    return;
    
}


//1 means Null
int QueueEmpty(Link_Queue* queue)
{
    return (queue->front == queue->rear);
}
