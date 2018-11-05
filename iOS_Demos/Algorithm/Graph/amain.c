//
//  main.c
//  AL_Graph
//
//  Created by 张一鸣 on 2018/7/23.
//  Copyright © 2018年 张一鸣. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
 #include "Graph_C.h"
#include "Graph_Search_c.h"
#include "Graph_MiniSpanTree_c.h"

void testTravel(void);
void testDFS_Forest();
void testMiniSpanTree();
int main(int argc, const char * argv[]) {

    //  MGraph * G1 = malloc(sizeof(MGraph));

    //  CreatGraph_UDN(G1);
    //  travelGraph_UDN(G1);

    
    // ALGraph * G2 = malloc(sizeof(ALGraph));
    // CreatGraph_UDG(G2);
    // travelGraph_UDG(G2);

    // OLGraph * G3 = malloc(sizeof(OLGraph));
    // CreatGraph_DG(G3);
    // travelGraph_DG(G3);
    
//    AMLGraph * G4 = malloc(sizeof(AMLGraph));
//    CreateGraph_UDN_AML(G4);
//    travelGraph_UDN_AML(G4);
    
    testMiniSpanTree();

    return 0;
}

Status travelPrint(int value) {
    printf("%d\t",value);
    return Success;
}

void testTravel() {
    MGraph * G1 = malloc(sizeof(MGraph));
    
    CreatGraph_MGraph(G1);
    travelGraph_MGraph(G1);
    DFSTraverse_MGraph(G1, travelPrint);
    BFSTraverse_MGraph(G1, travelPrint);

}


void testDFS_Forest() {
    MGraph * G1 = malloc(sizeof(MGraph));
    G1->kind = DN;

    CreatGraph_MGraph(G1);
    printf("%d",G1->arcs[10][15].Graph_Net.Value);
    G1->arcs[10][14].Graph_Net.Value = 0;
    travelGraph_MGraph(G1);

    CSNode_Tree ** tree = malloc(sizeof(CSNode_Tree *));
    
    DFSForest_MGraph(G1, tree);
    
    printf("");
}

void testMiniSpanTree() {
    MGraph * G1 = malloc(sizeof(MGraph));
    G1->kind = UDN;
    CreatGraph_ForMiniSpanTree_MGraph(G1);
    travelGraph_MGraph(G1);
//    MiniSpanTree_PRIM_MGraph(G1, 0);
    
    MiniSpanTree_KRUSKAL_MGraph(G1);
}
