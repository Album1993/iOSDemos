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
    
    AMLGraph * G4 = malloc(sizeof(AMLGraph));
    CreateGraph_UDN_AML(G4);
    travelGraph_UDN_AML(G4);

    return 0;
}
