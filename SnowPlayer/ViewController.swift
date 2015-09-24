//
//  ViewController.swift
//  SnowPlayer
//
//  Created by 刘瑞龙 on 15/9/24.
//  Copyright (c) 2015年 刘瑞龙. All rights reserved.
//

import UIKit
import AVFoundation

let ScreenWidth = UIScreen.mainScreen().bounds.size.width
let ScreenHeight = UIScreen.mainScreen().bounds.size.height

var ImageLocation: CGFloat{
    return CGFloat(arc4random())%ScreenWidth
}

var ImageViewSize: CGFloat{
    return CGFloat(10 + arc4random()%15)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var backImageView: UIImageView!
    var imageArr: [SnowImageView] = []
    var effectView: UIVisualEffectView?
    var isShowEffect: Bool = false
    var musicPlayer: AVAudioPlayer?
    static var i: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSnowImage()
        createGesture()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let path = NSBundle.mainBundle().pathForResource("他不懂", ofType: "mp3")
        let url: NSURL = NSURL(fileURLWithPath: path!)
        do{
            try musicPlayer = AVAudioPlayer(contentsOfURL: url)
        }catch{
        }
        musicPlayer?.prepareToPlay()
        musicPlayer?.play()
    }
    //添加手势
    func createGesture(){
        let tap = UITapGestureRecognizer(target: self, action: "tapAct")
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tap)
        
        //left
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: "swipeAct:")
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(leftSwipe)
        
        //right
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: "swipeAct:")
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(rightSwipe)
        
        //up
        let upSwipe = UISwipeGestureRecognizer(target: self, action: "swipeAct:")
        upSwipe.direction = UISwipeGestureRecognizerDirection.Up
        self.view.addGestureRecognizer(upSwipe)
        
        //down
        let downSwip = UISwipeGestureRecognizer(target: self, action: "swipeAct:")
        downSwip.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(downSwip)
    }
    //轻触手势
    func tapAct(){
        print("tap act")
        if effectView == nil{
            let effect = UIBlurEffect(style: .Dark)
            effectView = UIVisualEffectView(effect: effect)
            effectView?.alpha = 0.0
            effectView?.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
        }
        if isShowEffect{
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                effectView?.alpha = 0.0
                }, completion: { (com) -> Void in
                    if com {
                        self.effectView?.removeFromSuperview()
                        self.effectView = nil
                        self.isShowEffect = false
                    }
            })
        }else{
            self.view.addSubview(effectView!)
            self.view.insertSubview(effectView!, aboveSubview: self.backImageView)
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                effectView?.alpha = 1.0
            })
            isShowEffect = true
        }
    }
    //轻扫手势
    func swipeAct(swipe: UISwipeGestureRecognizer){
        if swipe.direction == UISwipeGestureRecognizerDirection.Left{
            print("swip  left")
        }else if swipe.direction == UISwipeGestureRecognizerDirection.Right{
            print("swip  right")
        }else if swipe.direction == UISwipeGestureRecognizerDirection.Down{
            print("swip  down")
        }else if swipe.direction == UISwipeGestureRecognizerDirection.Up{
            print("swip  up")
        }
    }
    func createSnowImage(){
        for var i = 0; i < 50; ++i{
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
                    imageView.frame = CGRectMake(location, imageView.frame.origin.y, imageView.bounds.size.width, imageView.bounds.size.height)
                })
            }
        }
    }
}
