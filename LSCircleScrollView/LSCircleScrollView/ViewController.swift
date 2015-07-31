//
//  ViewController.swift
//  LSCircleScrollView
//
//  Created by Shawn Li on 15/7/15.
//  Copyright (c) 2015年 Shawn Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LSCircleViewDelegate {

    var circleView: LSCircleView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "图片轮播";
        self.automaticallyAdjustsScrollViewInsets = false;
        var images: [UIImage!] = [UIImage(named: "one.jpg"),UIImage(named: "two.jpg"),UIImage(named: "three.jpg")];
        self.circleView = LSCircleView(frame: CGRectMake(0, 64, self.view.frame.size.width, 200), images: images);
        circleView.backgroundColor = UIColor.yellowColor();
        circleView.delegate = self;
        self.view.addSubview(circleView);
        
        var addImageButton = UIButton(frame: CGRectMake(0, 300, self.view.frame.size.width, 30));
        addImageButton.backgroundColor = UIColor.greenColor();
        addImageButton.setTitle("添加图片", forState: UIControlState.Normal);
        addImageButton.addTarget(self, action: "addImage:", forControlEvents: UIControlEvents.TouchUpInside);
        self.view.addSubview(addImageButton);
    }
    
    func addImage(sender: UIButton) {
        println("添加图片")
        //circleView.images = [UIImage(named: "four.jpg"),UIImage(named: "five.jpg"),UIImage(named: "six.jpg"),UIImage(named: "seven.jpg"),UIImage(named: "eight.jpg")];//设置新数组
        circleView.urlImages = ["https://ss0.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/image/h%3D200/sign=d489522e86025aafcc3279cbcbecab8d/562c11dfa9ec8a1366bd430ef303918fa1ecc0bc.jpg","http://img.1985t.com/uploads/attaches/2012/08/6900-pHbmUQ.jpg"];
    }
    
    func imageDidClickedAtIndex(currentIndex: Int) {
        println("\(currentIndex)");
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

