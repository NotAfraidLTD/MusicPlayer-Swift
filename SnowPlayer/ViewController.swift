//
//  ViewController.swift
//  SnowPlayer
//
//  Created by 刘瑞龙 on 15/9/24.
//  Copyright (c) 2015年 刘瑞龙. All rights reserved.
//

import UIKit

let ScreenWidth = UIScreen.mainScreen().bounds.size.width
let ScreenHeight = UIScreen.mainScreen().bounds.size.height
//let ImageViewSize = CGFloat(10 + arc4random()%15)
//let ImageLocation =
var ImageLocation: CGFloat{
    return CGFloat(arc4random())%ScreenWidth
}

var ImageViewSize: CGFloat{
   return CGFloat(10 + arc4random()%15)
}


class ViewController: UIViewController {
    var imageArr: [SnowImageView] = []
    static var i: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        createSnowImage()
    }
    func createSnowImage(){
        for var i = 0; i < 40; ++i{
            let size = ImageViewSize
            let imageView = SnowImageView(frame: CGRectMake(ImageLocation, CGFloat(-30.0), size, size))
            imageView.image = UIImage(named: "snow")
            imageView.alpha = 0.5 + CGFloat(arc4random()%5)/10
            imageArr.append(imageView)
            self.view.addSubview(imageView)
        }
        NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector:"createSnowAnimation" , userInfo: nil, repeats: true);
    }
    func createSnowAnimation(){
        if imageArr.count > 0 {
            let imageView = imageArr[0]
            if ViewController.i == Int.max {
                ViewController.i = 0
            }
            imageView.tag = ++ViewController.i;
            UIView.beginAnimations(String(imageView.tag), context: nil)
            UIView.setAnimationDuration(15.0)
            imageView.frame = CGRectMake(imageView.frame.origin.x, self.view.bounds.size.height + 30, imageView.bounds.size.width, imageView.bounds.size.height)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDidStopSelector("animationStop:")
            UIView.commitAnimations()
            if imageView.timer == nil{
                imageView.timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "snowMove:", userInfo: imageView, repeats: true)
            }
            imageArr.removeAtIndex(imageArr.startIndex)
        }
    }
    func animationStop(tagStr: String){
        let str: NSString = NSString(string: tagStr)
        if let imageView: SnowImageView = self.view.viewWithTag(str.integerValue)! as? SnowImageView {
            let size = ImageViewSize
            imageView.frame = CGRectMake(ImageLocation, -30.0, size, size)
            imageArr.append(imageView)
        }
    }
    func snowMove(timer: NSTimer){
        if timer.userInfo != nil{
            if let imageView = timer.userInfo as? SnowImageView{
                UIView.animateWithDuration(3.0, animations: { () -> Void in
                    let location = imageView.frame.origin.x + (-CGFloat(arc4random()%51) + 25)
                    print((-CGFloat(arc4random()%30) + 15))
                    imageView.frame = CGRectMake(location, imageView.frame.origin.y, imageView.bounds.size.width, imageView.bounds.size.height)
                })
            }
        }
    }
}

