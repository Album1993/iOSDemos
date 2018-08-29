//
//  Graph_Search_c.h
//  iOS_Demos
//
//  Created by 张一鸣 on 2018/8/3.
//  Copyright © 2018年 张一鸣. All rights reserved.
//

#ifndef Graph_Search_c_h
#define Graph_Search_c_h

#include <stdio.h>
#include "Graph_C.h"
#include "Tree_c.h"

void DFSTraverse_MGraph(MGraph *G, Status(*Visit)(int v)) ;
void BFSTraverse_MGraph(MGraph * G, Status(*Visit)(int v));


void DFSForest_MGraph(MGraph * G, CSNode_Tree ** T);
#endif /* Graph_Search_c_h */
