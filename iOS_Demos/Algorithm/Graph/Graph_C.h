//
//  Graph_C.h
//  AL_Graph
//
//  Created by 张一鸣 on 2018/7/23.
//  Copyright © 2018年 张一鸣. All rights reserved.
//

#ifndef Graph_C_h
#define Graph_C_h

#include <stdio.h>

#define INFINITY 2147483647
#define MAX_VEX 30


typedef enum {Success, Error} Status;
typedef enum {DG,DN,UDG,UDN} GraphKind;
typedef enum {Border,UnBorder} Graph_Border;
typedef int MatrixDataType;
typedef MatrixDataType** GraphMatrix;
void printMatrix(int **matrix,int num);
int element_Matrix(int **matrix,int num,int x,int y);

//--------------------------------邻接矩阵----------------------------
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
// GraphMatrix * transMGraph(MGraph*G);

Status CreatGraph_MGraph(MGraph * G);
Status CreatGraph_ForMiniSpanTree_MGraph(MGraph *G);

void travelGraph_MGraph(MGraph * G);

// ------------------------------------------使用邻接表--------------------------------

typedef struct ArcNode { //邻接表中顶点对应链表的顶点
    int adjvex; // 该弧指向的顶点的位置
    struct ArcNode * nextArc;
    char * info;
}ArcNode;


typedef struct VNode { // 邻接表中的顶点
    int data;
    ArcNode * firstarc;
}VNode,AdjList[MAX_VEX];

typedef struct { // 邻接表
    AdjList vertices;
    int vexnum,arcnum;
    GraphKind kind;
}ALGraph;
Status CreatGraph_UDG(ALGraph *G);
void travelGraph_UDG(ALGraph * G);


// ---------------------十字链表--------
typedef struct ArcBox{
   int tailvex,headvex; // 弧的尾和头顶点的位置
   struct ArcBox *hlink,*tlink; //  分别为弧头相同和弧尾相同的弧的链域
   int info;
}ArcBox;

typedef struct VexNode{
   int data;
   ArcBox * firstIn,*firstout;
}VexNode;

typedef struct {
   VexNode xlist[MAX_VEX];
   int vexnum,arcnum;
}OLGraph;
Status CreatGraph_DG(OLGraph *G);
void travelGraph_DG(OLGraph *G);

// -----------------------临接多重表------------

typedef enum {unvisited,visited} VisitIf;

typedef struct EBox {
   VisitIf mark;
   int ivex,jvex;
   struct EBox * ilink , * jlink;
   int info;
}EBox;

typedef struct VexBox {
   int data;
   EBox * firstedge;
}VexBox;

typedef struct {
   VexBox adjmulist[MAX_VEX];
   int vexnum,edgenum;
   GraphKind kind;
}AMLGraph;

Status CreateGraph_UDN_AML(AMLGraph *G);
Status travelGraph_UDN_AML(AMLGraph *G);


#endif /* Graph_C_h */
