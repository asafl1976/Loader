//
//  ViewController.swift
//  Loader
//
//  Created by ASAF LEVY on 30/07/2017.
//  Copyright © 2017 ASAF LEVY. All rights reserved.
//

import UIKit

class UIThread {
    class func execute(after: Double, block: @escaping @convention(block) () -> Swift.Void) {
        let delay = after * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            block()
        })
    }
    class func execute(block: @escaping @convention(block) () -> Swift.Void) {
        DispatchQueue.main.async() {
            block()
        }
    }
}


class ViewController: UIViewController {

    let loaderView = LoaderView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loaderView)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[loaderView(80)]", options: [], metrics: nil, views: ["loaderView":loaderView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-200-[loaderView(80)]", options: [], metrics: nil, views: ["loaderView":loaderView]))

        UIThread.execute(after: 2) {
            self.loaderView.completeLoading(true)
        }
        
    }

}

