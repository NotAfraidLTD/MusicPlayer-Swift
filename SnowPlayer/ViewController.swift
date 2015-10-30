//
//  ViewController.swift
//  SnowPlayer
//
//  Created by 刘瑞龙 on 15/9/24.
//  Copyright (c) 2015年 刘瑞龙. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

let songUrlKey = "songUrlKey"
let songPicKey = "songPicKey"
let songNameKey = "songNameKey"
let songArtistKey = "songArtistKey"

var ScreenWidth:CGFloat{
    return UIScreen.mainScreen().bounds.size.width
}

var ScreenHeight: CGFloat{
    return UIScreen.mainScreen().bounds.size.height
}

var ImageLocation: CGFloat{
    return CGFloat(arc4random())%ScreenWidth
}

var ImageViewSize: CGFloat{
    return CGFloat(10 + arc4random()%15)
}

class ViewController: UIViewController, AVAudioPlayerDelegate {
    static var i: Int = 0
    @IBOutlet weak var backImageView: UIImageView!
    var playingMusicInfoDic: [String : NSObject] = Dictionary()
    var backArrIndex = 0
    var songPlayIndex = 0
    var isShowEffect: Bool = false
    var seekTimer: NSTimer?
    var effectView: UIVisualEffectView?
    var musicPlayer: AVAudioPlayer?
    //用来装雪花的数组
    var imageArr: [SnowImageView] = []
    
    //背景图片的数组
    lazy var backArr: [UIImage] = {
        var arr: [UIImage] = []
        for i in 1...3{
            if let image = UIImage(named: "snowBack\(i)"){
                arr.append(image)
            }
        }
        return arr
    }()
    
    //用进行播放的音乐的URL数组
    lazy var songsUrlArr: [[String : NSObject]] = {
        var arr: [[String : NSObject]] = []
        for i in 1...3{
            let songPath = NSBundle.mainBundle().pathForResource("song\(i)", ofType: "mp3")
            let songUrl = NSURL(fileURLWithPath: songPath!)
            let songDic: [String : NSObject] = [songUrlKey : songUrl, songNameKey : "song\(i)", songPicKey : self.backArr[i - 1], songArtistKey : "小刘\(i)"]
            arr.append(songDic)
        }
        return arr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.backImageView.image = backArr[0]
        createSnowImage()
        createGesture()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configAudio()
        playMusic(self.songsUrlArr[0])
    }
    
    //MARK: 设置音频, 开启锁屏操作
    func configAudio(){
        let audio = AVAudioSession.sharedInstance()
        do{
            try audio.setActive(true)
            try audio.setCategory(AVAudioSessionCategoryPlayback)
        }catch let error as NSError{
            print(error.localizedDescription)
        }
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    //MARK: 当收到远程控制:
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        /*
        enum UIEventSubtype : Int {
        // available in iPhone OS 3.0
        case None
        // for UIEventTypeMotion, available in iPhone OS 3.0
        case MotionShake
        // for UIEventTypeRemoteControl, available in iOS 4.0
        case RemoteControlPlay
        case RemoteControlPause
        case RemoteControlStop
        case RemoteControlTogglePlayPause
        case RemoteControlNextTrack
        case RemoteControlPreviousTrack
        case RemoteControlBeginSeekingBackward
        case RemoteControlEndSeekingBackward
        case RemoteControlBeginSeekingForward
        case RemoteControlEndSeekingForward
        }
        */
        if event != nil{
            switch event!.type{
            case .RemoteControl:
                print("RemoteControl event")
                switch event!.subtype{
                case .RemoteControlPlay:
                    print("event subtype RemoteControlPlay")
                    if let player = musicPlayer{
                        if !player.playing{
                            player.play()
                        }
                    }
                case .RemoteControlPause:
                    if let player = musicPlayer{
                        if player.playing{
                            player.pause()
                        }
                    }
                    print("event subtype RemoteControlPause")
                case .RemoteControlStop:
                    print("event subtype RemoteControlStop")
                case .RemoteControlTogglePlayPause:
                    print("event subtype RemoteControlTogglePlayPause")
                case .RemoteControlNextTrack:
                    playNext()
                    print("event subtype RemoteControlNextTrack")
                case .RemoteControlPreviousTrack:
                    playPrevious()
                    print("event subtype RemoteControlPreviousTrack")
                case .RemoteControlBeginSeekingBackward:
                    seekTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "seekBackward", userInfo: nil, repeats: true)
                    print("event subtype RemoteControlBeginSeekingBackward")
                case .RemoteControlEndSeekingBackward:
                    if seekTimer!.valid{
                        seekTimer?.invalidate()
                        seekTimer = nil
                    }
                    print("event subtype RemoteControlEndSeekingBackward")
                case .RemoteControlBeginSeekingForward:
                    seekTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "seekForward", userInfo: nil, repeats: true)
                    print("event subtype RemoteControlBeginSeekingForward")
                case .RemoteControlEndSeekingForward:
                    if seekTimer!.valid{
                        seekTimer?.invalidate()
                        seekTimer = nil
                    }
                    print("event subtype RemoteControlEndSeekingForward")
                case .MotionShake:
                    print("event subtype MotionShake")
                case .None:
                    print("event subtype None")
                }
            case .Touches:
                print("Touches event")
            case .Motion:
                print("Motion event")
            default:
                print("event default")
            }
        }
    }
    
    //MARK: 快退
    func seekBackward(){
        let currentDuration = self.musicPlayer?.currentTime
        var seekTime = currentDuration! - 10.0
        if seekTime < 0.0{
            seekTime = 0.0
        }
        print("seek time \(seekTime)")
        self.musicPlayer?.currentTime = seekTime
        playingMusicInfoDic[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTime
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = playingMusicInfoDic
    }
    //MARK: 快进
    func seekForward(){
        let currntTime = self.musicPlayer?.currentTime
        if let ct = currntTime{
            var seekTime = ct + 10.0
            if seekTime > self.musicPlayer?.duration{
                seekTime = self.musicPlayer!.duration
            }
            self.musicPlayer?.currentTime = seekTime
            playingMusicInfoDic[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTime
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = playingMusicInfoDic
        }
    }
    
    //MARK: 杨晃手机触发的方法
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == UIEventSubtype.MotionShake{
            print("motion shake")
        }
    }
    
    //MARK: 播放下一首
    func playNext(){
        ++songPlayIndex
        if songPlayIndex >= songsUrlArr.count{
            songPlayIndex = 0
        }
        playMusic(songsUrlArr[songPlayIndex])
    }
    
    //MARK: 播放上一首
    func playPrevious(){
        --songPlayIndex
        if songPlayIndex <= 0{
            songPlayIndex = songsUrlArr.count - 1
        }
        playMusic(songsUrlArr[songPlayIndex])
    }
    
    //MARK: 播放音乐
    func playMusic(musicDic: [String : NSObject]){
        if let musicUrl = musicDic[songUrlKey] as? NSURL{
            do{
                try musicPlayer =  AVAudioPlayer(contentsOfURL: musicUrl, fileTypeHint: nil)
            }catch{
                
            }
            
            musicPlayer?.delegate = self
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
            let duration = musicPlayer?.duration
            let artWork = MPMediaItemArtwork(image: musicDic[songPicKey] as! UIImage)
            playingMusicInfoDic[MPMediaItemPropertyTitle] = musicDic[songNameKey]
            playingMusicInfoDic[MPMediaItemPropertyArtwork] = artWork
            playingMusicInfoDic[MPMediaItemPropertyArtist] = musicDic[songArtistKey]
            playingMusicInfoDic[MPMediaItemPropertyPlaybackDuration] = NSNumber(double: duration!)
            playingMusicInfoDic[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.musicPlayer?.currentTime
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = playingMusicInfoDic
            /*
            // MPMediaItemPropertyAlbumTitle
            // MPMediaItemPropertyAlbumTrackCount
            // MPMediaItemPropertyAlbumTrackNumber
            // MPMediaItemPropertyArtist
            // MPMediaItemPropertyArtwork
            // MPMediaItemPropertyComposer
            // MPMediaItemPropertyDiscCount
            // MPMediaItemPropertyDiscNumber
            // MPMediaItemPropertyGenre
            // MPMediaItemPropertyPersistentID
            // MPMediaItemPropertyPlaybackDuration
            // MPMediaItemPropertyTitle
            */
        }
    }
    
    //MARK: 音乐播放结束后触发的方法
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        print("audio player finish playing")
        playNext()
    }
    
    //MARK: 添加手势
    func createGesture(){
        let tap = UITapGestureRecognizer(target: self, action: "tapAct:")
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tap)
        
        let twiceTap = UITapGestureRecognizer(target: self, action: "tapAct:")
        twiceTap.numberOfTapsRequired = 2
        twiceTap.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(twiceTap)
        
        tap.requireGestureRecognizerToFail(twiceTap)
        
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
    
    //MARK: 轻触手势
    func tapAct(tap: UITapGestureRecognizer){
        //单击
        if tap.numberOfTapsRequired == 1{
            print("once tap act")
            if effectView == nil{
                let effect = UIBlurEffect(style: .Dark)
                effectView = UIVisualEffectView(effect: effect)
                effectView?.alpha = 0.0
                effectView?.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
            }
            if isShowEffect{
                UIView.animateWithDuration(1.0, animations: { () -> Void in
                    self.effectView?.alpha = 0.0
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
                    self.effectView?.alpha = 1.0
                })
                isShowEffect = true
            }
            //双击
        }else{
            print("twice tap act")
            if let player = self.musicPlayer {
                if player.playing {
                    player.pause()
                }else{
                    player.play()
                }
            }
        }
    }
    
    //MARK: 轻扫手势
    func swipeAct(swipe: UISwipeGestureRecognizer){
        if swipe.direction == UISwipeGestureRecognizerDirection.Left{
            print("swip  left")
            playPrevious()
        }else if swipe.direction == UISwipeGestureRecognizerDirection.Right{
            print("swip  right")
            playNext()
        }else if swipe.direction == UISwipeGestureRecognizerDirection.Down{
            ++backArrIndex
            if backArrIndex >= backArr.count{
                backArrIndex = 0
            }
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.backImageView.alpha = 0.0
                }, completion: { (isCom) -> Void in
                    self.backImageView.image = self.backArr[self.backArrIndex]
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.backImageView.alpha = 1.0
                    })
            })
        }else if swipe.direction == UISwipeGestureRecognizerDirection.Up{
            --backArrIndex
            if backArrIndex < 0{
                backArrIndex = backArr.count - 1
            }
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.backImageView.alpha = 0.0
                }, completion: { (isCom) -> Void in
                    self.backImageView.image = self.backArr[self.backArrIndex]
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.backImageView.alpha = 1.0
                    })
            })
        }
    }
    
    //MARK: 创建雪花的imageView
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
    
    //MARK: 开启雪花移动动画
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
    
    //MARK: 控制雪花横向的移动
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
    
    //MARK: 雪花动画结束
    func animationStop(tagStr: String){
        let str: NSString = NSString(string: tagStr)
        if let imageView: SnowImageView = self.view.viewWithTag(str.integerValue)! as? SnowImageView {
            let size = ImageViewSize
            imageView.frame = CGRectMake(ImageLocation, -30.0, size, size)
            imageArr.append(imageView)
        }
    }
    
    deinit{
        self.resignFirstResponder()
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
    }
}
