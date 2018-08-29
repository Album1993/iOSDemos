//
//  Graph_Search_c.c
//  iOS_Demos
//
//  Created by 张一鸣 on 2018/8/3.
//  Copyright © 2018年 张一鸣. All rights reserved.
//

#include "Graph_Search_c.h"
#include <stdbool.h>
#include "Queue_c.h"


bool visited_T[MAX_VEX];
Status (*VisitFunc)(int v);

int FirstAdjVex_MGraph(MGraph * G,int v) ;
int NextAdjVex_MGraph(MGraph * G,int v,int w);
void DFS_MGraph(MGraph * G, int v);

// 深度优先遍历
void DFSTraverse_MGraph(MGraph *G, Status(*Visit)(int v)) {
    printf("DFS: ");
    
    VisitFunc = Visit;
    for (int v = 0; v < G->Vexnum; ++v) {
        visited_T[v] = false;
    }
    
    for (int v = 0; v < G->Vexnum; v++) {
        if (!visited_T[v]) {
            DFS_MGraph(G, v);
        }
    }
    printf("\n");
}

void DFS_MGraph(MGraph * G, int v) {
    visited_T[v] = true;
    VisitFunc(v);
    for (int w = FirstAdjVex_MGraph(G, v) ; w>=0; w = NextAdjVex_MGraph(G, v,w)) {
        if (!visited_T[w]) DFS_MGraph(G,w);
    }
}

int FirstAdjVex_MGraph(MGraph * G,int v) {
    for (int i = 0; i < G->Vexnum; i++) {
        if (G->arcs[v][i].Graph_Net.Value != 0 && G->arcs[v][i].Graph_Net.Value != INFINITY) {
            return i;
        }
    }
    return -1;
}

int NextAdjVex_MGraph(MGraph * G,int v,int w) {
    for (int i = w+1; i < G->Vexnum; i++) {
        if (G->arcs[v][i].Graph_Net.Value != 0 && G->arcs[v][i].Graph_Net.Value != INFINITY) {
            return i;
        }
    }
    return -1;
}


//---------------------广度优先遍历-----------------------


void BFSTraverse_MGraph(MGraph * G, Status(*Visit)(int v)) {
    
    printf("BFS: ");

    for (int v = 0; v < G->Vexnum; ++v) {
        visited_T[v] = false;
    }
    
    Link_Queue *q = (Link_Queue *)malloc(sizeof(Link_Queue));
    InitQueue(q);
    for (int v = 0; v<G->Vexnum; v++) {
        if (!visited_T[v]) {
            visited_T[v] = true;
            Visit(v);
            EnQueue(q, v);
            while (!QueueEmpty(q)) {
                int * u = malloc(sizeof(int));
                DeQueue(q,u);
                for (int w = FirstAdjVex_MGraph(G, *u); w >= 0; w = NextAdjVex_MGraph(G, *u, w)) {
                   if (!visited_T[w]) {
                        visited_T[w] = true;
                        Visit(w);
                        EnQueue(q, w);
                    }
                }
            }
        }
    }
    
    printf("\n");
}


//-----------------------------深度优先森林--------------------
void DFSTree_MGraph(MGraph *G, int v ,CSTree T);

void DFSForest_MGraph(MGraph * G, CSNode_Tree ** T) {
    (*T) = NULL;
    for (int v = 0; v<G->Vexnum; ++v) {
        visited_T[v] = false;
    }
    
    for (int v = 0; v < G->Vexnum; ++v) {
        if (!visited_T[v]) {
            CSTree p = (CSTree) malloc(sizeof(CSNode_Tree));
            p->data =  G->Vertex[v].data;
            p->firstchild = NULL;
            p->nextsibling = NULL;
            
            if (!(*T)) {(*T) = p;}
            else {
                CSTree q = *T;
                
                while (q->nextsibling) {
                    q = q->nextsibling;
                }
                
                q->nextsibling = p;
            }
            DFSTree_MGraph(G, v, p);

        }
    }
}


void DFSTree_MGraph(MGraph *G, int v ,CSTree T) {
    visited_T[v] = true;
    bool first = true;
    CSTree q = T->firstchild ;
    for (int w = FirstAdjVex_MGraph(G, v);w > 0; w = NextAdjVex_MGraph(G, v, w)) {
        if (!visited_T[w]) {
            CSTree p = (CSTree)malloc(sizeof(CSNode_Tree));
            p->data = G->Vertex[w].data;
            p->firstchild = NULL;
            p->nextsibling = NULL;

            if (first) {
                T->firstchild = p;
                first = false;
            } else {
                if (!q) return;
                q->nextsibling = p;
            }
            q = p;
            DFSTree_MGraph(G, w, q);
        }
    }
}

















