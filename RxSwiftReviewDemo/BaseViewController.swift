//
//  BaseViewController.swift
//  RxSwiftReviewDemo
//
//  Created by zhengzeqin on 2020/12/29.
//  https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/rxswift_core.html
//  https://github.com/ZClee128/RXSwift-
//  

import UIKit
@_exported import RxSwift
@_exported import RxCocoa
class BaseViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
