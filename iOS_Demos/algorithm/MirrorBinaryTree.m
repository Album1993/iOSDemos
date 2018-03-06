//
//  MirrorBinaryTree.m
//  iOS_Demos
//
//  Created by 张一鸣 on 28/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "MirrorBinaryTree.h"


@implementation MirrorBinaryTree {
    BinaryNode *_tree;
}

- (void)svw_initialize {
    _tree = malloc(sizeof(BinaryNode));

    BinaryNode *node1 = malloc(sizeof(BinaryNode));
    BinaryNode *node2 = malloc(sizeof(BinaryNode));
    BinaryNode *node3 = malloc(sizeof(BinaryNode));
    BinaryNode *node4 = malloc(sizeof(BinaryNode));

    _tree->value = 0;
    node1->value = 1;
    node2->value = 2;
    node3->value = 3;
    node4->value = 4;

    _tree->m_leftNode  = node1;
    _tree->m_rightNode = node2;
    node1->m_leftNode  = node3;
    node2->m_rightNode = node4;
}

- (void)svw_printTree:(BinaryNode *)pNode {
    if (pNode == NULL || pNode->value < 0) {
        return;
    }
    NSLog(@"%d", pNode->value);
    [self svw_printTree:pNode->m_leftNode];
    [self svw_printTree:pNode->m_rightNode];
}

- (void)svw_mirrorRecursively:(BinaryNode *)pNode {
    if (pNode) {
    }

    BinaryNode *pTemp  = pNode->m_leftNode;
    pNode->m_leftNode  = pNode->m_rightNode;
    pNode->m_rightNode = pTemp;

    if (pNode->m_leftNode) {
        [self svw_mirrorRecursively:pNode->m_leftNode];
        [self svw_mirrorRecursively:pNode->m_rightNode];
    }
}

- (void)svw_mirrorTests {
    [self svw_initialize];
    [self svw_printTree:_tree];
    [self svw_mirrorRecursively:_tree];
    [self svw_printTree:_tree];
}


@end


@implementation MirrorBinaryTreeViewController

- (void)viewDidLoad {
    MirrorBinaryTree *test = [MirrorBinaryTree new];
    [test svw_mirrorTests];
}

@end
