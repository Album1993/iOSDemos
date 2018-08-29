//
//  Graph_MiniSpanTree_c.c
//  iOS_Demos
//
//  Created by 张一鸣 on 2018/8/17.
//  Copyright © 2018年 张一鸣. All rights reserved.
//

#include "Graph_MiniSpanTree_c.h"



struct TemperEdge{
    int adjvex;
    int lowcost;
}TemperEdge, Closedge[MAX_VEX];

int minimum(struct TemperEdge edges[MAX_VEX],int vexnum) {

    int k = 1000;
    int index = -1;
    for (int i = 0;i < vexnum; i++) {
        if (edges[i].lowcost>0 && edges[i].lowcost< k) {
            k = edges[i].lowcost;
            index = i;
        }
    }

    return index;
}

Status  MiniSpanTree_PRIM_MGraph(MGraph * G,int u) {
    
    int*** matrix = transMGraph(G);

    for (int j = 0; j < G->Vexnum;j++) {
        if (j != u) {
            Closedge[j].adjvex = u;
            Closedge[j].lowcost = element_Matrix((*matrix), G->Vexnum, u, j);
            printf("%d\n",Closedge[j].lowcost);
        }
    }
    Closedge[u].lowcost = 0;
    
    
    
    for (int i = 0;i < G->Vexnum;++i) {
        int k = minimum(Closedge, G->Vexnum) ;
        if (k< 0) {
            return Error;
        }
        
        printf("%d --- %d \n",G->Vertex[k].data,Closedge[k].lowcost);
        
        Closedge[k].lowcost = 0;
        
        for (int j = 0; j < G->Vexnum; j++) {
            if (G->arcs[k][j].Graph_Net.Value < Closedge[j].lowcost) {
                Closedge[j].adjvex = k;
                Closedge[j].lowcost = (*matrix)[k][j];
            }
        }
    }
    
    return Success;
}
