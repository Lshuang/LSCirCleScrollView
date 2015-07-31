//
//  LSCircleView.swift
//  LSCircleScrollView
//
//  Created by Shawn Li on 15/7/15.
//  Copyright (c) 2015年 Shawn Li. All rights reserved.
//

import UIKit

let timeInterval: NSTimeInterval = 2.5   // 全局时间间隔
@objc protocol LSCircleViewDelegate {
    /*!
    点击图片的代理方法
    :param: currentIndex 当前点击的第几张图片
    */
    optional func imageDidClickedAtIndex(currentIndex: Int);
}

class LSCircleView: UIView, UIScrollViewDelegate {
    //MARK: Property
    var delegate: LSCircleViewDelegate!
    var contentScrollView: UIScrollView! //滚动视图
    var pageIndicator: UIPageControl!    //页数指示器
    var timer: NSTimer?                  //定时器
    var currentImageView: UIImageView!   //当前显示的图片
    var lastImageView: UIImageView!      //上一张图片
    var nextImageView: UIImageView!      //下一张图片
    var indexOfCurrentImage: Int! {  //当前显示的图片的下标
        didSet {//监听显示的第几张图片，来更新分页指示器
            self.pageIndicator.currentPage = indexOfCurrentImage;
        }
    }
    
    var images: [UIImage!]! { //监听图片数组的变化，如果有变化，立即刷新轮播图中显示的图片
        willSet{
            self.images = newValue;
        }
        /*! 如果数据源改变，则需要改变scrollView和分页指示器的数量 */
        didSet{
            contentScrollView.scrollEnabled = !(images.count == 1)
            self.pageIndicator.frame = CGRectMake(self.frame.size.width - 20 * CGFloat(images.count), self.frame.size.height - 30, 20 * CGFloat(images.count), 30);
            self.pageIndicator.numberOfPages = images.count;
            self.setScrollViewWithImage();//设置图片
        }
    }
    var urlImages: [String]? {
        willSet{
            self.urlImages = newValue;
        }
        didSet{
            //这里用了强制解包，所以不要把urlImages设为nil
            for urlStr in self.urlImages! {
                var urlImage = NSURL(string: urlStr);
                if urlImage == nil {break}
                var imageData = NSData(contentsOfURL: urlImage!);
                if imageData == nil {break};
                var image = UIImage(data: imageData!);
                if image == nil {break}
                images.append(image);
            }
        }
    }
    //MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    convenience init(frame: CGRect, images: [UIImage!]?) {
        self.init(frame: frame);
        self.images = images;
        
        self.indexOfCurrentImage = 0;//默认显示第一张图片
        self.setupCircleView();      //初始化视图
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: Private Methods
    /*! 初始化CircleView */
    private func setupCircleView() {
        //1.初始化scrollView
        self.contentScrollView = UIScrollView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
        contentScrollView.contentSize = CGSizeMake(self.frame.size.width * CGFloat(self.images.count), 0);
        contentScrollView.delegate = self;
        contentScrollView.bounces = false;
        contentScrollView.pagingEnabled = true;
        contentScrollView.backgroundColor = UIColor.cyanColor();
        contentScrollView.showsHorizontalScrollIndicator = false;
        contentScrollView.showsVerticalScrollIndicator = false;
        contentScrollView.scrollEnabled = !(self.images.count == 1);
        self.addSubview(contentScrollView);
        
        //2.初始化ImageView
        self.currentImageView = UIImageView(frame: CGRectMake(self.frame.size.width, 0, self.frame.size.width, 200));
        currentImageView.userInteractionEnabled = true;
        currentImageView.contentMode = UIViewContentMode.ScaleAspectFill;
        currentImageView.clipsToBounds = true;
        contentScrollView.addSubview(currentImageView);
        //添加点击事件
        var imageTap = UITapGestureRecognizer(target: self, action: "imageTapAction:");
        currentImageView.addGestureRecognizer(imageTap);
        
        self.lastImageView = UIImageView();
        lastImageView.frame = CGRectMake(0, 0, self.frame.size.width, 200);
        lastImageView.contentMode = UIViewContentMode.ScaleAspectFill;
        lastImageView.clipsToBounds = true;
        contentScrollView.addSubview(lastImageView);
        
        self.nextImageView = UIImageView();
        nextImageView.frame = CGRectMake(self.frame.size.width * 2, 0, self.frame.size.width, 200);
        nextImageView.contentMode = UIViewContentMode.ScaleAspectFill;
        nextImageView.clipsToBounds = true;
        contentScrollView.addSubview(nextImageView);
        
        //设置图片
        self.setScrollViewWithImage();
        contentScrollView.setContentOffset(CGPointMake(self.frame.size.width, 0), animated: false);
        
        //设置分页指示器 
        self.pageIndicator = UIPageControl(frame: CGRectMake(self.frame.size.width - 20 * CGFloat(images.count), self.frame.size.height - 30, 20 * CGFloat(images.count), 30));
        pageIndicator.hidesForSinglePage = true;
        pageIndicator.numberOfPages = images.count;
        pageIndicator.backgroundColor = UIColor.clearColor();
        pageIndicator.pageIndicatorTintColor = UIColor.lightGrayColor();
        pageIndicator.currentPageIndicatorTintColor = UIColor.redColor();
        self.addSubview(pageIndicator);
        
        //设置定时器
        self.timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: "timerAction", userInfo: nil, repeats: true);
    }
    /*! 设置图片*/
    private func setScrollViewWithImage() {
        self.currentImageView.image = self.images[self.indexOfCurrentImage];
        self.nextImageView.image = self.images[self.getNextImageIndex(indexOfCurrentImage: self.indexOfCurrentImage)];
        self.lastImageView.image = self.images[self.getLastImageIndex(indexOfCurrentImage: self.indexOfCurrentImage)];
    }
    
    /*! 得到上一张图片的下标 */
    private func getLastImageIndex(indexOfCurrentImage index: Int) -> Int {
        var lastIndex = index - 1;
        if lastIndex == -1 {
            return self.images.count - 1;
        } else {
            return lastIndex;
        }
    }
    
    /*! 得到下一张图片的下标 */
    private func getNextImageIndex(indexOfCurrentImage index: Int) -> Int {
        var nextIndex = index + 1;
        return nextIndex < self.images.count ? nextIndex : 0;
    }
    func timerAction() {
        //println("定时器正在工作")
        contentScrollView.setContentOffset(CGPointMake(self.frame.size.width * 2, 0), animated: true);
    }
    
    //MARK: 代理方法
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //如果用户手动拖动到了一个整页数的位置就不会发生滑动了，所以需要判断手动调用滑动停止方法
        if (!decelerate){
            self.scrollViewDidEndDecelerating(scrollView);
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var offset = scrollView.contentOffset.x;
        if offset == 0 {
            self.indexOfCurrentImage = self.getLastImageIndex(indexOfCurrentImage: self.indexOfCurrentImage);
        } else if (offset == self.frame.size.width * 2) {
            self.indexOfCurrentImage = self.getNextImageIndex(indexOfCurrentImage: self.indexOfCurrentImage);
        }
        //重新布局图片
        self.setScrollViewWithImage();
        //布局后把contentOffset设为中间
        scrollView.setContentOffset(CGPointMake(self.frame.size.width, 0), animated: false);
    }
    //时间触发器 设置滑动时动画为true，会触发方法
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        //println("动画")
        self.scrollViewDidEndDecelerating(contentScrollView);
    }
    
    //MARK: 公共方法
    func imageTapAction(tap: UITapGestureRecognizer) {
        self.delegate!.imageDidClickedAtIndex!(indexOfCurrentImage);
    }
    
}
