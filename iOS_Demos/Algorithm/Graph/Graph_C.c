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

#define INFINITY 2147483647
#define MAX_VEX 30

typedef enum {Success, Error} Status;
typedef enum {DG,DN,UDG,UDN} GraphKind;
typedef enum {Border,UnBorder} Graph_Border;

typedef struct {
    int data;
}VertexNode;//图中顶点结构定义

typedef struct {
    union {
        Graph_Border adj;//适用于图，表示是否相邻
        int Value;//网，权值(这里定义权值类型为int型)
    }Graph_Net;
    char *info;//存储边或者弧的相关信息
}ArcCell,AdjMatrix[MAX_VEX][MAX_VEX];//边或弧结构的定义


typedef struct {
    VertexNode Vertex[MAX_VEX];//存储顶点数组
    AdjMatrix arcs;//存储顶点之间的关系，即边或弧(邻接矩阵)
    int Vexnum,Arcnum;//当前途中顶点数目、边或弧数目
    GraphKind kind;//图的类型
}MGraph;//图结构的定义


Status generateGraph_UDN(MGraph * G){
    (*G).arcs[0][1].Graph_Net.Value = 2;
    G.arcs[0][2].Graph_Net.Value = 1;
    G.arcs[1][2].Graph_Net.Value = 3;
    G.arcs[2][3].Graph_Net.Value = 4;
    G.arcs[0][4].Graph_Net.Value = 5;
    G.arcs[0][5].Graph_Net.Value = 7;
    G.arcs[5][6].Graph_Net.Value = 9;
    G.arcs[6][7].Graph_Net.Value = 8;
    G.arcs[4][8].Graph_Net.Value = 6;
    G.arcs[6][10].Graph_Net.Value = 7;
    G.arcs[8][12].Graph_Net.Value = 7;
    G.arcs[8][9].Graph_Net.Value = 1;
    G.arcs[9][13].Graph_Net.Value = 2;
    G.arcs[9][10].Graph_Net.Value = 4;
    G.arcs[10][14].Graph_Net.Value = 4;
    G.arcs[10][11].Graph_Net.Value = 3;

    for (int i = 0; i < G.Vexnum; i++) {
        for (int j = 0; j < G.Vexnum; j++) {
            if (G.arcs[i][j].Graph_Net.Value != INFINITY && G.arcs[j][i].Graph_Net.Value == INFINITY) {
                G.arcs[j][i].Graph_Net.Value = G.arcs[i][j].Graph_Net.Value;
            };
        }
    }
    return Success;
}

// 7.1 使用邻接矩阵
Status CreatGraph_UDN(MGraph G)
{//构造有向网结构
    G.Vexnum = 15;
    G.Arcnum = 16;
    for (int i = 0; i < G.Vexnum; i++) G.Vertex[i].data = i+1;
    for (int i = 0; i < G.Vexnum; i++) {
        for (int j = 0; j < G.Vexnum; j++) {
            G.arcs[i][j].info = NULL;
            G.arcs[i][j].Graph_Net.Value = INFINITY;
        }
    }

    generateGraph_UDN(G);

    return Success;
}


//// 使用邻接表
//typedef struct ArcNode { //邻接表中顶点对应链表的顶点
//    int adjvex; // 该弧指向的顶点的位置
//    struct ArcNode * nextArc;
//    char * info;
//}ArcNode;
//
//typedef struct VNode { // 邻接表中的顶点
//    int data;
//    ArcNode * firstarc;
//}VNode,AdjList[MAX_VEX];
//
//typedef struct { // 邻接表
//    AdjList vertices;
//    int vexnum,arcnum;
//    GraphKind kind;
//}ALGraph;
//
//ArcNode * createNode_UDG(int num, ... );
//
//Status generateGraph_UDG(ALGraph &G) {
//
//    G.vertices[0].firstarc = createNode_UDG(2,1,4);
//    G.vertices[1].firstarc = createNode_UDG(3,0,2,5);
//    G.vertices[2].firstarc = createNode_UDG(3,1,3,5);
//    G.vertices[3].firstarc = createNode_UDG(2,2,4);
//    G.vertices[4].firstarc = createNode_UDG(3,0,3,5);
//    G.vertices[4].firstarc = createNode_UDG(3,1,2,4);
//
//    return  Success;
//}
//
//ArcNode * createNode_UDG(int num, ... ) {
//    va_list nodesIndexs;
//    ArcNode *nodelist[num];
//    for (int i = 0 ; i < num ; i++) {
//        (*nodelist)[0].adjvex = va_arg(nodesIndexs, int);
//    }
//
//    va_end(nodesIndexs);
//
//    for (int i = 0; i < num-1; i++) {
//        (*nodelist)[i].nextArc = (*nodelist)[i+1].nextArc;
//    }
//
//    return nodelist[0];
//}
//
//Status CreatGraph_UDG(ALGraph &G) {
//    // 构造无向图
//    int vexNum = 6;
//    int arcNum = 8;
//
//    G.vexnum = vexNum;
//    G.arcnum = arcNum;
//    G.kind = UDG;
//
//    //  初始化图
//    for (int i = 0; i < vexNum; i++ ) {
//        G.vertices[i].data = i + 1;
//    }
//    generateGraph_UDG(G);
//
//    return Success;
//}
//
//
//// ---------------------十字链表--------
//typedef struct ArcBox{
//    int tailvex,headvex; // 弧的尾和头顶点的位置
//    struct ArcBox *hlink,*tlink; //  分别为弧头相同和弧尾相同的弧的链域
//    int info;
//}ArcBox;
//
//typedef struct VexNode{
//    int data;
//    ArcBox * firstIn,*firstout;
//}VexNode;
//
//typedef struct {
//    VexNode xlist[MAX_VEX];
//    int vexnum,arcnum;
//}OLGraph;
//
//
//ArcBox * generateArc_DG(OLGraph &G,int v1, int v2) {
//    ArcBox * arcbox;
//    arcbox = (ArcBox *)malloc(sizeof(ArcBox));
//    *arcbox = {v1,v2,G.xlist[v2].firstIn,G.xlist[v1].firstout,0};
//    return arcbox;
//}
//
//Status generateGraph_DG(OLGraph &G) {
//    ArcBox * a1 = generateArc_DG(G, 0, 1);
//    G.xlist[1].firstIn = G.xlist[0].firstout = a1;
//    ArcBox * a2 = generateArc_DG(G, 1, 2);
//    G.xlist[2].firstIn = G.xlist[1].firstout = a2;
//    ArcBox * a3 = generateArc_DG(G, 2, 3);
//    G.xlist[3].firstIn = G.xlist[2].firstout = a3;
//    ArcBox * a4 = generateArc_DG(G, 0, 4);
//    G.xlist[4].firstIn = G.xlist[0].firstout = a4;
//    ArcBox * a5 = generateArc_DG(G, 4, 3);
//    G.xlist[3].firstIn = G.xlist[4].firstout = a5;
//    ArcBox * a6 = generateArc_DG(G, 4, 5);
//    G.xlist[5].firstIn = G.xlist[4].firstout = a6;
//    ArcBox * a7 = generateArc_DG(G, 5, 1);
//    G.xlist[1].firstIn = G.xlist[5].firstout = a7;
//    ArcBox * a8 = generateArc_DG(G, 2, 5);
//    G.xlist[5].firstIn = G.xlist[2].firstout = a8;
//    return Success;
//}
//
//Status CreatGraph_DG(OLGraph &G) {
//    G.vexnum = 6;
//    G.arcnum = 8;
//
//    for (int i = 0; i < G.vexnum; i++) {
//        G.xlist[i].firstIn = NULL;
//        G.xlist[i].firstout = NULL;
//        G.xlist[i].data = i+1;
//    }
//
//    generateGraph_DG(G);
//    return Success;
//}
//
//
//// -----------------------临接多重表------------
//
//typedef enum {unvisited,visited} VisitIf;
//
//typedef struct EBox {
//    VisitIf mark;
//    int ivex,jvex;
//    struct EBox * ilink , * jlink;
//    int info;
//}EBox;
//
//typedef struct VexBox {
//    int data;
//    EBox * firstedge;
//}VexBox;
//
//typedef struct {
//    VexBox adjmulist[MAX_VEX];
//    int vexnum,edgenum;
//}AMLGraph;
//
//EBox * generateArc_UDG_AML(AMLGraph &G,int v1, int v2) {
//    EBox * ebox;
//    ebox = (EBox *)malloc(sizeof(EBox));
//    *ebox = {unvisited,v1,v2,G.adjmulist[v1].firstedge->ilink,G.adjmulist[v1].firstedge->jlink,0};
//    return ebox;
//}
//
//Status generateGraph_UDN_AML(AMLGraph &G) {
//    EBox * a1 = generateArc_UDG_AML(G, 0, 1);
//    G.adjmulist[0].firstedge = a1;
//    EBox * a2 = generateArc_UDG_AML(G, 1, 2);
//    G.adjmulist[1].firstedge = a2;
//    EBox * a3 = generateArc_UDG_AML(G, 2, 3);
//    G.adjmulist[2].firstedge = a3;
//    EBox * a4 = generateArc_UDG_AML(G, 0, 4);
//    G.adjmulist[3].firstedge = a4;
//    EBox * a5 = generateArc_UDG_AML(G, 4, 3);
//    G.adjmulist[4].firstedge = a5;
//    EBox * a6 = generateArc_UDG_AML(G, 4, 5);
//    G.adjmulist[5].firstedge = a6;
//    EBox * a7 = generateArc_UDG_AML(G, 5, 1);
//    G.adjmulist[6].firstedge = a7;
//    EBox * a8 = generateArc_UDG_AML(G, 2, 5);
//    G.adjmulist[7].firstedge = a8;
//    return Success;
//}
//
//Status CreateGraph_UDN_AML(AMLGraph &G) {
//    G.vexnum = 6;
//    G.edgenum = 8;
//
//    for (int i = 0; i < G.vexnum; i++) {
//        G.adjmulist[i].firstedge = NULL;
//        G.adjmulist[i].data = i + 1;
//    }
//
//    generateGraph_UDN_AML(G);
//
//
//
//    return Success;
//}
//
//
//bool Visited[MAX_VEX];
//Status (*VisitFunc)(int v);
//void DFS(AMLGraph& G, int v);
//
//void DFSTraverse(AMLGraph &G,Status (*Visit)(int v)){
//    VisitFunc = Visit;
//
//    for (int v = 0; v < G.vexnum; ++v)Visited[v] = false;
//    for (int v = 0; v < G.vexnum; ++v)
//        if (!Visited[v]) {
//            DFS(G, v);
//        }
//
//}
//
//
//void DFS(AMLGraph &G, int v) {
//    Visited[v] = true;
//    VisitFunc(v);
//    //    for (EBox * w = G.adjmulist[v].firstedge; w != NULL; w = G.adjmulist[v].firstedge->ilink) {
//    //        int index = w->
//    //        if (!Visited[w->]) {
//    //            DFS(G, w)
//    //        }
//    //    }
//}
//
//void BFS() {
//
//}
