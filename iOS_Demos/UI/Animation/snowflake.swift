//
//  snowflake.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 2018/5/11.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import UIKit

class EmitterView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.frame = bounds
        emitterLayer.emitterPosition = center
        emitterLayer.emitterSize = bounds.size
        emitterLayer.emitterShape = kCAEmitterLayerCircle //发射器形状
        emitterLayer.emitterMode = kCAEmitterLayerOutline
        //这个时候看起来有那么一丁点相识，但仔细看的话只是粒子从小到大缩放而已，这是一个没有灵魂的黑洞。这其实还少了一个参数 preservesDepth = true 加上这个之后粒子发射就有了立体效果：
        emitterLayer.preservesDepth = true
        
        layer.addSublayer(emitterLayer)
        
        let cell = CAEmitterCell()
        cell.contents = #imageLiteral(resourceName: "circle_white").cgImage
        cell.birthRate = 50 // 粒子产生数量
        cell.lifetime = 10.0 // 粒子存活时间
        
        cell.scale = 0.25 //缩放比例
        cell.scaleRange = 0.1
        cell.scaleSpeed = 0.025
        cell.velocity = 50  //粒子的速度
        cell.velocityRange = 50 //粒子的速度范围
        cell.color = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1).cgColor
        cell.redRange = 1 // 颜色变化
        cell.greenRange = 1
        cell.blueRange = 1
        cell.alphaRange = 0.8
        cell.alphaSpeed = -0.1 // 透明速度（逐渐消失）
        
        emitterLayer.emitterCells = [cell]
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = Float.pi * 2
        rotateAnimation.duration = 60
        rotateAnimation.repeatCount = .greatestFiniteMagnitude
        emitterLayer.add(rotateAnimation, forKey: nil)
        
    }
}

