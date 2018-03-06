//
//  BlurViewController.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 27/02/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import UIKit

@objc( BlurViewController)
class BlurViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 1
        view.backgroundColor = .white
        
        // 添加一个blur
        let imageview = UIImageView(frame: CGRect.init(x: 0, y: 100, width: self.view.bounds.width, height: 100))
        imageview.image = UIImage.init(named: "Christmas_Trees")
        self.view.addSubview(imageview)
        // 2
        // Create a UIBlurEffect with a UIBlurEffectStyle.light style.
        //This defines what style of blur is used.
        //The other available styles are .extraLight and .dark, .extraDark, regular, and prominent
        let blurEffect = UIBlurEffect(style: .extraLight)
        // 3
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageview.bounds;
        
        imageview.addSubview(blurView)
        
// ------------------------------------------------------------------
        
        // 添加vibrancy 就是上面的元素也有虚化
        // 必须加到contentview中间
        //Note: UIVibrancyEffect must be added to the contentView of a UIVisualEffectView that has been set up and configured with a UIBlurEffect object; otherwise, there won’t be any blurs to apply a vibrancy effect to!
        let imageview2 = UIImageView(frame: CGRect.init(x: 0, y: 220, width: self.view.bounds.width, height: 100))
        imageview2.image = UIImage.init(named: "Christmas_Trees")
        self.view.addSubview(imageview2)
        // 2
        // Create a UIBlurEffect with a UIBlurEffectStyle.light style.
        //This defines what style of blur is used.
        //The other available styles are .extraLight and .dark, .extraDark, regular, and prominent
        let blurEffect2 = UIBlurEffect(style: .dark)
        // 3
        let blurView2 = UIVisualEffectView(effect: blurEffect2)
        blurView2.frame = imageview2.bounds
        
        imageview2.addSubview(blurView2)
        
        let label = UILabel.init(frame: CGRect.init(x: 40, y: 40, width: 200, height: 30))
        label.text = "vibrancyEffect";
        // 1
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect2)
        // 2
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.frame = imageview2.bounds
        // 3
        vibrancyView.contentView.addSubview(label)
        // 4
        blurView2.contentView.addSubview(vibrancyView)

// ------------------------------------------------------------------
        // 当用户禁止使用虚化的时候
        guard UIAccessibilityIsReduceTransparencyEnabled() == false else {
            view.addSubview(label)
            return
        }

        

    }
}
