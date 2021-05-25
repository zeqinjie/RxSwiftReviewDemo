//
//  ZQOperatorTransformingObservableViewController.swift
//  RxSwiftReviewDemo
//
//  Created by zhengzeqin on 2021/2/2.
//

import UIKit

class ZQOperatorMathematicalAggregateViewController: BaseViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.toArray()
//        self.reduce()
//        self.concat()
        
        // Do any additional setup after loading the view.
    }
    
}

extension ZQOperatorMathematicalAggregateViewController {
   fileprivate func toArray() {
    print("-----toArray------")
//        toArray
//        该操作符先把一个序列转成一个数组，并作为一个单一的事件发送，然后结束。
        Observable.of(1, 2, 3)
            .toArray()
            .asObservable()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
//        结果 [1,2,3]
    }
    
    fileprivate func reduce() {
        print("-----reduce------")
//        reduce 接受一个初始值，和一个操作符号。
//        reduce 将给定的初始值，与序列里的每个值进行累计运算。得到一个最终结果，并将其作为单个值发送出去
//        + - * ÷
        Observable.of(1, 2, 3, 4, 5)
            .reduce(0, accumulator: +)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
//        结果 15
    }
    
    fileprivate func concat()  {
        print("-----concat------")
//        concat 会把多个 Observable 序列合并（串联）为一个 Observable 序列。
//        并且只有当前面一个 Observable 序列发出了 completed 事件，才会开始发送下一个  Observable 序列事件。
        let subject1 = BehaviorSubject(value: 1)
        let subject2 = BehaviorSubject(value: 2)
        
        let variable = BehaviorRelay(value: subject1)
        variable.asObservable()
            .concat()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject2.onNext(3)
        subject1.onNext(4)
        subject1.onNext(5)
        subject1.onCompleted()

        variable.accept(subject2)
        subject2.onNext(6)
        subject1.onNext(7)
//       结果 1,4,5,3,6
    }
    
    
    
    
}
