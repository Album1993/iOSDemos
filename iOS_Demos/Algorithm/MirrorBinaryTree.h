//
//  MirrorBinaryTree.h
//  iOS_Demos
//
//  Created by 张一鸣 on 28/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct BinaryNode {
    struct BinaryNode *m_leftNode;
    struct BinaryNode *m_rightNode;
    int                value;
} BinaryNode;


@interface MirrorBinaryTree : NSObject

- (void)svw_mirrorTests;

@end


@interface MirrorBinaryTreeViewController : UIViewController

@end
