//
//  Graph_C.c
//  AL_Graph
//
//  Created by 张一鸣 on 2018/7/23.
//  Copyright © 2018年 张一鸣. All rights reserved.
//

#include "Graph_C.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>





void printMatrix(int **matrix, int num)
{
    for (int i = 0; i < num; i++)
    {
        for (int j = 0; j < num; j++)
        {
            printf("%d \t", *((int *)matrix + num * i + j));
        }
        printf("\n\n");
    }
}

int element_Matrix(int **matrix,int num,int x,int y) {
    return *((int *)matrix + num * x + y);
}

//--------------------------------邻接矩阵----------------------------

int ***transMGraph(MGraph *G)
{
    int(*matrix)[G->Vexnum][G->Vexnum] = malloc(sizeof(int) * G->Vexnum * G->Vexnum);
    memset((*matrix), 0, sizeof((*matrix)));
    for (int i = 0; i < G->Vexnum; i++)
    {
        for (int j = 0; j < G->Vexnum; j++)
        {
            (*matrix)[i][j] = G->arcs[i][j].Graph_Net.Value != INFINITY ? G->arcs[i][j].Graph_Net.Value : 0;
        }
    }
    return (int ***)matrix;
}

Status generateGraph_MGraph(MGraph *G)
{
    (*G).arcs[0][1].Graph_Net.Value = 2;
    G->arcs[0][2].Graph_Net.Value = 1;
    G->arcs[1][2].Graph_Net.Value = 3;
    G->arcs[2][3].Graph_Net.Value = 4;
    G->arcs[0][4].Graph_Net.Value = 5;
    G->arcs[0][5].Graph_Net.Value = 7;
    G->arcs[5][6].Graph_Net.Value = 9;
    G->arcs[6][7].Graph_Net.Value = 8;
    G->arcs[4][8].Graph_Net.Value = 6;
    G->arcs[6][10].Graph_Net.Value = 7;
    G->arcs[8][12].Graph_Net.Value = 7;
    G->arcs[8][9].Graph_Net.Value = 1;
    G->arcs[9][13].Graph_Net.Value = 2;
    G->arcs[9][10].Graph_Net.Value = 4;
    G->arcs[10][14].Graph_Net.Value = 4;
    G->arcs[10][11].Graph_Net.Value = 3;

    if (G->kind == DN) {
        return Success;
    }
    
    for (int i = 0; i < G->Vexnum; i++)
    {
        for (int j = 0; j < G->Vexnum; j++)
        {
            if (G->arcs[i][j].Graph_Net.Value != INFINITY && G->arcs[j][i].Graph_Net.Value == INFINITY)
            {
                G->arcs[j][i].Graph_Net.Value = G->arcs[i][j].Graph_Net.Value;
            };
        }
    }
    return Success;
}

// 7.1 使用邻接矩阵
Status CreatGraph_MGraph(MGraph *G)
{ //构造有向网结构
    G->Vexnum = 15;
    G->Arcnum = 16;
    
//    G->kind = UDN;
    for (int i = 0; i < G->Vexnum; i++)
        G->Vertex[i].data = i + 1;
    for (int i = 0; i < G->Vexnum; i++)
    {
        for (int j = 0; j < G->Vexnum; j++)
        {
            G->arcs[i][j].info = NULL;
            G->arcs[i][j].Graph_Net.Value = INFINITY;
        }
    }

    generateGraph_MGraph(G);

    return Success;
}


Status generateGraph_ForMiniSpanTree_MGraph(MGraph *G)
{
    G->arcs[0][1].Graph_Net.Value = 6;
    G->arcs[0][2].Graph_Net.Value = 1;
    G->arcs[0][3].Graph_Net.Value = 5;
    G->arcs[1][2].Graph_Net.Value = 5;
    G->arcs[2][3].Graph_Net.Value = 5;
    G->arcs[1][4].Graph_Net.Value = 3;
    G->arcs[2][4].Graph_Net.Value = 6;
    G->arcs[2][5].Graph_Net.Value = 4;
    G->arcs[3][5].Graph_Net.Value = 2;
    G->arcs[4][5].Graph_Net.Value = 6;
    
    for (int i = 0; i < G->Vexnum; i++)
    {
        for (int j = 0; j < G->Vexnum; j++)
        {
            if (G->arcs[i][j].Graph_Net.Value != INFINITY && G->arcs[j][i].Graph_Net.Value == INFINITY)
            {
                G->arcs[j][i].Graph_Net.Value = G->arcs[i][j].Graph_Net.Value;
            };
        }
    }
    return Success;
}

// 7.1 使用邻接矩阵
Status CreatGraph_ForMiniSpanTree_MGraph(MGraph *G)
{ //构造有向网结构
    G->Vexnum = 6;
    G->Arcnum = 10;
    
    //    G->kind = UDN;
    for (int i = 0; i < G->Vexnum; i++)
    G->Vertex[i].data = i + 1;
    for (int i = 0; i < G->Vexnum; i++)
    {
        for (int j = 0; j < G->Vexnum; j++)
        {
            G->arcs[i][j].info = NULL;
            G->arcs[i][j].Graph_Net.Value = INFINITY;
        }
    }
    
    generateGraph_ForMiniSpanTree_MGraph(G);
    
    return Success;
}


void travelGraph_MGraph(MGraph *G)
{
    printf("vex num: %d\n", G->Vexnum);
    int(*matrix)[G->Vexnum][G->Vexnum] = (int(*)[G->Vexnum][G->Vexnum])transMGraph(G);
    printMatrix((int **)(*matrix), G->Vexnum);
}

// ------------------------------------------使用邻接表--------------------------------

ArcNode *createNode_UDG(int num, ...);

Status generateGraph_UDG(ALGraph *G)
{

    (*G).vertices[0].firstarc = createNode_UDG(2, 1, 4);
    (*G).vertices[1].firstarc = createNode_UDG(3, 0, 2, 5);
    (*G).vertices[2].firstarc = createNode_UDG(3, 1, 3, 5);
    (*G).vertices[3].firstarc = createNode_UDG(2, 2, 4);
    (*G).vertices[4].firstarc = createNode_UDG(3, 0, 3, 5);
    (*G).vertices[5].firstarc = createNode_UDG(3, 1, 2, 4);
    return Success;
}

ArcNode *createNode_UDG(int num, ...)
{
    va_list nodesIndexs;
    ArcNode *nodelist[num];
    va_start(nodesIndexs, num);
    for (int i = 0; i < num; i++)
    {
        int next = va_arg(nodesIndexs, int);
        nodelist[i] = malloc(sizeof(ArcNode));
        nodelist[i]->adjvex = next;
        nodelist[i]->nextArc = NULL;
    }

    va_end(nodesIndexs);

    for (int i = 0; i < num - 1; i++)
    {
        nodelist[i]->nextArc = nodelist[i + 1];
        printf("set node link: %d 's nextarc: %d\n", nodelist[i]->adjvex, nodelist[i + 1]->adjvex);
    }

    printf("\n\n");

    return nodelist[0];
}

Status CreatGraph_UDG(ALGraph *G)
{
    // 构造无向图
    int vexNum = 6;
    int arcNum = 8;

    (*G).vexnum = vexNum;
    (*G).arcnum = arcNum;
    (*G).kind = UDG;

    //  初始化图
    for (int i = 0; i < vexNum; i++)
    {
        (*G).vertices[i].data = i + 1;
    }
    generateGraph_UDG(G);

    return Success;
}

/**
    set node link: 1 's nextarc: 4


    set node link: 0 's nextarc: 2
    set node link: 2 's nextarc: 5


    set node link: 1 's nextarc: 3
    set node link: 3 's nextarc: 5


    set node link: 2 's nextarc: 4


    set node link: 0 's nextarc: 3
    set node link: 3 's nextarc: 5


    set node link: 1 's nextarc: 2
    set node link: 2 's nextarc: 4


    144
    node : 0 ,first arc:1
    current arc : 1 ,next arc:4
    current arc : 4 ,next arc:-1


    node : 1 ,first arc:0
    current arc : 0 ,next arc:2
    current arc : 2 ,next arc:5
    current arc : 5 ,next arc:-1


    node : 2 ,first arc:1
    current arc : 1 ,next arc:3
    current arc : 3 ,next arc:5
    current arc : 5 ,next arc:-1


    node : 3 ,first arc:2
    current arc : 2 ,next arc:4
    current arc : 4 ,next arc:-1


    node : 4 ,first arc:0
    current arc : 0 ,next arc:3
    current arc : 3 ,next arc:5
    current arc : 5 ,next arc:-1


    node : 5 ,first arc:1
    current arc : 1 ,next arc:2
    current arc : 2 ,next arc:4
    current arc : 4 ,next arc:-1

    0 	1 	0 	0 	1 	0 	

    1 	0 	1 	0 	0 	1 	

    0 	1 	0 	1 	0 	1 	

    0 	0 	1 	0 	1 	0 	

    1 	0 	0 	1 	0 	1 	

    0 	1 	1 	0 	1 	0 	
*/

int ***transALGraph(ALGraph *G)
{
    int(*matrix)[G->vexnum][G->vexnum] = malloc(sizeof(int) * G->vexnum * G->vexnum);
    memset((*matrix), 0, sizeof((*matrix)));
    printMatrix((int **)(*matrix), G->vexnum);
    for (int i = 0; i < G->vexnum; i++)
    {
        VNode *node = &(G->vertices[i]);
        ArcNode *arc = node->firstarc;
        printf("node : %d ,first arc:%d\n", node->data - 1, node->firstarc->adjvex);
        while (arc != NULL)
        {
            printf("current arc : %d ,next arc:%d\n", arc->adjvex, arc->nextArc ? arc->nextArc->adjvex : -1);
            (*matrix)[i][arc->adjvex] = 1;
            arc = arc->nextArc;
        };

        printf("\n\n");
    }
    return (int ***)matrix;
}
void travelGraph_UDG(ALGraph *G)
{
    int vexnum = G->vexnum;

    if (vexnum == 0)
    {
        printf("vexnum is zero");
        return;
    }

    printf("vex num: %d\n", G->vexnum);
    int(*matrix)[G->vexnum][G->vexnum] = (int(*)[G->vexnum][G->vexnum])transALGraph(G);
    printMatrix((int **)(*matrix), G->vexnum);
}

// ---------------------十字链表--------
/**
    144
    0 	1 	0 	0 	1 	0 	

    0 	0 	1 	0 	0 	0 	

    0 	0 	0 	1 	0 	1 	

    0 	0 	0 	0 	0 	0 	

    0 	0 	0 	1 	0 	1 	

    0 	1 	0 	0 	0 	0 	
*/
ArcBox *generateArc_DG(OLGraph *G, int v1, int v2)
{
    ArcBox *arcbox;
    arcbox = (ArcBox *)malloc(sizeof(ArcBox));
    arcbox->tailvex = v1;
    arcbox->headvex = v2;
    arcbox->hlink = G->xlist[v2].firstIn;
    arcbox->tlink = G->xlist[v1].firstout;
    arcbox->info = INFINITY;

    G->xlist[v2].firstIn = G->xlist[v1].firstout = arcbox;
    arcbox->info = 0;
    return arcbox;
}

Status generateGraph_DG(OLGraph *G)
{
    generateArc_DG(G, 0, 1);
    generateArc_DG(G, 1, 2);
    generateArc_DG(G, 2, 3);
    generateArc_DG(G, 0, 4);
    generateArc_DG(G, 4, 3);
    generateArc_DG(G, 4, 5);
    generateArc_DG(G, 5, 1);
    generateArc_DG(G, 2, 5);

    return Success;
}

Status CreatGraph_DG(OLGraph *G)
{
    G->vexnum = 6;
    G->arcnum = 8;

    for (int i = 0; i < G->vexnum; i++)
    {
        G->xlist[i].firstIn = NULL;
        G->xlist[i].firstout = NULL;
        G->xlist[i].data = i + 1;
    }

    generateGraph_DG(G);
    return Success;
}

int ***transGraph_DG_OL(OLGraph *G)
{
    int(*matrix)[G->vexnum][G->vexnum] = malloc(sizeof(int) * G->vexnum * G->vexnum);
    memset((*matrix), 0, sizeof((*matrix)));
    for (int i = 0; i < G->vexnum; i++)
    {
        VexNode *node = &(G->xlist[i]);

        ArcBox *arc = node->firstout;

        while (arc != NULL)
        {
            (*matrix)[arc->tailvex][arc->headvex] = 1;
            arc = arc->tlink;
        }
    }
    return (int ***)matrix;
}

void travelGraph_DG(OLGraph *G)
{

    int vexNum = G->vexnum;

    if (vexNum == 0)
    {
        return;
    }

    int(*matrix)[G->vexnum][G->vexnum] = (int(*)[G->vexnum][G->vexnum])transGraph_DG_OL(G);

    printMatrix((int **)(*matrix), G->vexnum);
}

// -----------------------临接多重表------------

EBox *generateArc_UDG_AML(AMLGraph *G, int v1, int v2)
{
    EBox *ebox;
    ebox = (EBox *)malloc(sizeof(EBox));
    ebox->mark = unvisited;
    ebox->ivex = v1;
    ebox->jvex = v2;
    ebox->ilink = G->adjmulist[v1].firstedge;
    ebox->jlink = G->adjmulist[v2].firstedge;

    ebox->info = 0;

    G->adjmulist[v1].firstedge = ebox;
    G->adjmulist[v2].firstedge = ebox;

    return ebox;
}

Status generateGraph_UDN_AML(AMLGraph *G)
{
    generateArc_UDG_AML(G, 0, 1);
    generateArc_UDG_AML(G, 1, 2);
    generateArc_UDG_AML(G, 2, 3);
    generateArc_UDG_AML(G, 0, 4);
    generateArc_UDG_AML(G, 4, 3);
    generateArc_UDG_AML(G, 4, 5);
    generateArc_UDG_AML(G, 5, 1);
    generateArc_UDG_AML(G, 2, 5);
    return Success;
}

Status CreateGraph_UDN_AML(AMLGraph *G)
{
    G->vexnum = 6;
    G->edgenum = 8;
    G->kind = UDN;

    for (int i = 0; i < G->vexnum; i++)
    {
        G->adjmulist[i].firstedge = NULL;
        G->adjmulist[i].data = i + 1;
    }

    generateGraph_UDN_AML(G);

    return Success;
}

/**
    0 	1 	0 	0 	1 	0 	

    1 	0 	1 	0 	0 	1 	

    0 	1 	0 	1 	0 	1 	

    0 	0 	1 	0 	1 	0 	

    1 	0 	0 	1 	0 	1 	

    0 	1 	1 	0 	1 	0 	
 */

int ***transGraph_UDN_AML(AMLGraph *G)
{
    int(*matrix)[G->vexnum][G->vexnum] = malloc(sizeof(int) * G->vexnum * G->vexnum);
    memset((*matrix), 0, sizeof((*matrix)));
    for (int i = 0; i < G->vexnum; i++)
    {
        VexBox *node = &(G->adjmulist[i]);

        EBox *arc = node->firstedge;

        while (arc != NULL)
        {

            if (arc->mark == visited)
            {
                break;
            }
            arc->mark = visited;
            (*matrix)[arc->ivex][arc->jvex] = 1;
            arc = arc->ilink;
        }
    }

    switch (G->kind)
    {
    case UDN:

        for (size_t i = 0; i < G->vexnum; i++)
        {
            for (size_t j = 0; j < G->vexnum; j++)
            {
                if ((*matrix)[i][j] == 1 && (*matrix)[j][i] == 0)
                {
                    (*matrix)[j][i] = 1;
                }
            }
        }

        break;

    default:
        break;
    }
    return (int ***)matrix;
}

Status travelGraph_UDN_AML(AMLGraph *G)
{

    int vexNum = G->vexnum;

    if (vexNum == 0)
    {
        return Error;
    }

    int(*matrix)[vexNum][vexNum] = (int(*)[vexNum][vexNum])transGraph_UDN_AML(G);
    printMatrix((int **)(*matrix), vexNum);

    return Success;
}
