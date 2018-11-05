//
//  Graph_MiniSpanTree_c.c
//  iOS_Demos
//
//  Created by 张一鸣 on 2018/8/17.
//  Copyright © 2018年 张一鸣. All rights reserved.
//

#include "Graph_MiniSpanTree_c.h"
#include <stdio.h>
#include <stdlib.h>

struct TemperEdge
{
    int adjvex;
    int lowcost;
} TemperEdge, Closedge[MAX_VEX];



int minimum(struct TemperEdge edges[MAX_VEX], int vexnum)
{

    int k = 1000;
    int index = -1;
    for (int i = 0; i < vexnum; i++)
    {
        if (edges[i].lowcost > 0 && edges[i].lowcost < k)
        {
            k = edges[i].lowcost;
            index = i;
        }
    }
    printf("the lowest cost index: %d\n", index);

    return index;
}

Status MiniSpanTree_PRIM_MGraph(MGraph *G, int u)
{

    // 这个matrix 这样转化真的很重要
    int(*matrix)[G->Vexnum][G->Vexnum] = (int(*)[G->Vexnum][G->Vexnum])transMGraph(G);

    for (int j = 0; j < G->Vexnum; j++)
    {
        if (j != u)
        {
            // 这个点被U点链接
            Closedge[j].adjvex = u;
            // 这个点到U的距离
            Closedge[j].lowcost = element_Matrix((int **)(*matrix), G->Vexnum, u, j) != 0 ? element_Matrix((int **)(*matrix), G->Vexnum, u, j) : 10000;

            printf("%d\n", Closedge[j].lowcost);
        }
    }

    printf("------------------\n");

    Closedge[u].lowcost = 0;
    
    int sum = 0;

    for (int i = 0; i < G->Vexnum; ++i)
    {

        if (i == u)
        {
            continue;
        }

        int k = minimum(Closedge, G->Vexnum);
        sum += Closedge[k].lowcost;
        printf("------------sum:%d\n",sum);
        if (k <= 0)
        {
            return Error;
        }

        printf("%d --- %d \n", G->Vertex[k].data, Closedge[k].lowcost);

        // 首先置空
        Closedge[k].lowcost = 0;

        // 接下来将选出来的k点到剩余点的距离都计算出来，如果比上个点短的话，则更新为现在的点到那一点的距离
        for (int j = 0; j < G->Vexnum; j++)
        {

            // 如果当前这个点已经被选出，则这个点不做比较
            // 如果这个点和j点没有链接，那么j点就跳过
            if (Closedge[j].lowcost == 0 || G->arcs[k][j].Graph_Net.Value == 0)
            {
                continue;
            }

            // 如果这个点有数值而且小于当前值，则将最短路径数组更新
            if (G->arcs[k][j].Graph_Net.Value < Closedge[j].lowcost)
            {
                Closedge[j].adjvex = k;
                Closedge[j].lowcost = (*matrix)[k][j];
            }
        }

        for (size_t i = 0; i < G->Vexnum; i++)
        {
            printf("current Closedge % d -- %d\n", Closedge[i].adjvex, Closedge[i].lowcost);
        }
    }

    return Success;
}

struct TemperEdge_KRUSKAl
{
    int cost;
    int vexA; // 这个边的节点A
    int vexB; // 这个边的节点B
    struct TemperEdge_KRUSKAl * edge;
} TemperEdge_KRUSKAl;

struct TemperFlow_KRUSKAL {
    int edgeNum;
    int stackNum;
}TemperFlow_KRUSKAL;


struct TemperEdge_KRUSKAl * sortedEdge_KRUSKAL(MGraph * G) {
    
    struct TemperEdge_KRUSKAl * tEdge = NULL;
   struct TemperEdge_KRUSKAl * pointer = NULL;
   int(*matrix)[G->Vexnum][G->Vexnum] = (int(*)[G->Vexnum][G->Vexnum])transMGraph(G);

    int edgeNumber = 0;
    
    // 便利整个邻接矩阵
    for (int i = 0; i < G->Vexnum; i++) {
        for (int j = i + 1; j < G->Vexnum; j++) {
            
            
            if (element_Matrix((int **)(*matrix), G->Vexnum, i, j) != 0) {
                if (tEdge == NULL) { // 第一个点初始化
                    tEdge = malloc(sizeof(TemperEdge_KRUSKAl));
                    tEdge->cost = element_Matrix((int **)(*matrix), G->Vexnum, i, j);
                    tEdge->vexA = i;
                    tEdge->vexB = j;
                    tEdge->edge = NULL;
                    pointer = tEdge;
                } else {
                    pointer->edge = malloc(sizeof(TemperEdge_KRUSKAl));
                    pointer = pointer->edge;
                    pointer->cost = element_Matrix((int **)(*matrix), G->Vexnum, i, j);
                    pointer->vexA = i;
                    pointer->vexB = j;
                    pointer->edge = NULL;
                } // if
                edgeNumber++;
            } // if
        }// for
    }// for
    
    printf("------edge num: %d--------\n",edgeNumber);
    // 指向第一点，开始便利输出，查看一下是否正确
    pointer = tEdge;
    for ( NULL; pointer != NULL ; pointer = pointer->edge) {
        printf("edge: %d  %d   %d\n",pointer->vexA,pointer->vexB,pointer->cost);
    }
    
    printf("--------------\n");
    
    // 冒泡排序
    int isNeedChange = 1;
    while (isNeedChange == 1) {
        isNeedChange = 0;
        // 指向第一点，开始便利输出，查看一下是否正确
        pointer = tEdge;
        if (pointer->edge != NULL && pointer->cost > pointer->edge->cost) {
            
            printf("change the first edge");
            printf("pointer->cost : %d  pointer->edge->cost： %d\n",pointer->cost,pointer->edge->cost);
            // 存储第二个节点
            struct TemperEdge_KRUSKAl * temp = pointer->edge->edge;
            // 首节点指针指向第二个节点
            tEdge = pointer->edge;
            // 第二个节点指向第一个节点
            pointer->edge->edge = pointer;
            // 新的第二个节点指向缓存节点
            pointer->edge = temp;
            isNeedChange = 1;
        }
        
        pointer = tEdge;
//        printf("first edge: %d  %d   %d\n",pointer->vexA,pointer->vexB,pointer->cost);
        
        for (int i = 0 ; i < edgeNumber - 1; i ++) {
//            printf("--------------\n");
//
//            printf("--edge: %d  %d   %d\n",pointer->vexA,pointer->vexB,pointer->cost);
            if( pointer == NULL || pointer->edge == NULL || pointer->edge->edge == NULL) {
                printf("break\n");
                break;
            }
//            printf("--edge->next: %d  %d   %d\n",pointer->edge->vexA,pointer->edge->vexB,pointer->edge->cost);
//            printf("--edge->next->next: %d  %d   %d\n",pointer->edge->edge->vexA,pointer->edge->edge->vexB,pointer->edge->edge->cost);

            if ( pointer->edge->cost > pointer->edge->edge->cost) {
                
                // 记住下三个节点
               struct TemperEdge_KRUSKAl * temp = pointer->edge->edge->edge;
                printf("--temp: %d  %d   %d\n",temp->vexA,temp->vexB,temp->cost);

                // 将下两个节点指向下一个节点， 这就出现了环
                pointer->edge->edge->edge = pointer->edge;
                // 将当前节点指向下两个节点 ， 将环解锁
                pointer->edge = pointer->edge->edge;
                // 下两个节点指向原本的第三个节点
                pointer->edge->edge->edge = temp;
                isNeedChange = 1;
            }
//            printf("--edge: %d  %d   %d\n",pointer->vexA,pointer->vexB,pointer->cost);
//            printf("--edge->next: %d  %d   %d\n",pointer->edge->vexA,pointer->edge->vexB,pointer->edge->cost);
//            printf("--edge->next->next: %d  %d   %d\n",pointer->edge->edge->vexA,pointer->edge->edge->vexB,pointer->edge->edge->cost);

            
            pointer = pointer->edge;
            
//            printf("--------------\n");

        }
        
    }
    printf("--------------\n");
    
    // 指向第一点，开始便利输出，查看一下是否正确
//    pointer = tEdge;
//    for ( NULL; pointer != NULL ; pointer = pointer->edge) {
//        printf("edge: %d  %d   %d\n",pointer->vexA,pointer->vexB,pointer->cost);
//    }
    
    
    return tEdge;
}

Status MiniSpanTree_KRUSKAL_MGraph(MGraph *G) {
    
    struct TemperEdge_KRUSKAl * edges = sortedEdge_KRUSKAL(G);
    
    struct TemperEdge_KRUSKAl * pointer = edges;
    for ( NULL; pointer != NULL ; pointer = pointer->edge) {
        printf("edge: %d  %d   %d\n",pointer->vexA,pointer->vexB,pointer->cost);
    }
    
    struct TemperFlow_KRUSKAL vex[G->Vexnum];
    
    for (int i = 0; i < G->Vexnum; i++) {
 
        vex[i].edgeNum = -1;
        vex[i].stackNum = -1;
    }
    
    
    
    for (int i = 0; i < G->Vexnum; i++) {
        printf(" edgeNum : %d stackNum : %d\n",vex[i].edgeNum,vex[i].stackNum);
    }
    
    int stack = 1;
    int sum = 0;
    pointer = edges;
    for ( NULL; pointer != NULL ; pointer = pointer->edge,stack ++) {
        printf("--edge: %d  %d   %d\n",pointer->vexA,pointer->vexB,pointer->cost);
        printf("vex[pointer->vexA].stackNum :%d vex[pointer->vexB].stackNum:%d\n",vex[pointer->vexA].stackNum,vex[pointer->vexB].stackNum);
        if (vex[pointer->vexA].stackNum == -1 && vex[pointer->vexB].stackNum == -1) {
            vex[pointer->vexA].stackNum = stack;
            vex[pointer->vexB].stackNum = stack;
            printf("1 edge is choosen: %d  %d   %d\n",pointer->vexA,pointer->vexB,pointer->cost);
            sum += pointer->cost;
            printf("------------sum:%d\n",sum);
            continue;
        }
        
        if (vex[pointer->vexA].stackNum != -1 && vex[pointer->vexB].stackNum == -1) {
            vex[pointer->vexB].stackNum = vex[pointer->vexA].stackNum;
            printf("2 edge is choosen: %d  %d   %d\n",pointer->vexA,pointer->vexB,pointer->cost);
            sum += pointer->cost;
            printf("------------sum:%d\n",sum);

            continue;
        }
        
        if (vex[pointer->vexB].stackNum != -1 && vex[pointer->vexA].stackNum == -1) {
            vex[pointer->vexA].stackNum = vex[pointer->vexB].stackNum;
            printf("3 edge is choosen: %d  %d   %d\n",pointer->vexA,pointer->vexB,pointer->cost);
            sum += pointer->cost;
            printf("------------sum:%d\n",sum);
            continue;
        }
        
        if (vex[pointer->vexB].stackNum != -1 && vex[pointer->vexA].stackNum != -1 && vex[pointer->vexB].stackNum != vex[pointer->vexA].stackNum) {
            int vexbValue =  vex[pointer->vexB].stackNum;
            for (int j = 0; j < G->Vexnum; ++j) {
                printf("Vex[%d]: %d\n",j,vex[j].stackNum);
                if (vex[j].stackNum ==vexbValue) {
                    vex[j].stackNum = vex[pointer->vexA].stackNum;
                    printf("change Vex[%d]: %d\n",j,vex[j].stackNum);
                }
            }
            
            printf("4 edge is choosen: %d  %d   %d\n",pointer->vexA,pointer->vexB,pointer->cost);
            sum += pointer->cost;
            printf("------------sum:%d\n",sum);

            continue;
        }
        printf("-----------------------------\n");

    }
    
    return Success;
}


