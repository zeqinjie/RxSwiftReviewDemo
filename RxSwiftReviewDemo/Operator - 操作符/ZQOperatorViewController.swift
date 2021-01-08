//
//  ZQOperatorViewController.swift
//  RxSwiftReviewDemo
//
//  Created by zhengzeqin on 2021/1/4.
//

import UIKit

class ZQOperatorViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        transformOperator()

    }
    
    

}

// MARK: - 变化操作符
extension ZQOperatorViewController {
    fileprivate func transformOperator() {
        createmap()
        createflatMap()
        createflatMapLatest()
    }
    
    // 该操作符通过传入一个函数闭包把原来的 Observable 序列转变为一个新的 Observable 序列
    fileprivate func createmap() {
        print("-----createmap------")
        Observable<Int>.of(1,2,3)
            .map { $0 * 10 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        
        // 等价于下面 map + merge = flatMap （前提是 map 返回的是序列）
        Observable<Int>.of(1,2,3)
            .map { Observable.just($0)}
            .merge()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        Observable<Int>.of(1,2,3)
            .flatMap { Observable.just($0) }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    
    /*
     个人理解：
     • map 闭包返回的还是元素值的操作，最终返回的是原序列，只是对其元素值做了修改
     • flatMap 闭包返回的是序列，最终返回的是新的序列，如果元素是序列那么通过 flatMap 可以对元素是序列的里的元素进行发送，如果使用 map 只能发出的是序列了
     */
    fileprivate func createflatMap() {
        print("-----createflatMap------")
        let first = BehaviorSubject(value: "👦🏻")
        let second = BehaviorSubject(value: "🅰️")
        let variable = Variable(first) // 通过 flatMap 对元素是序列的的元素进行发出

        variable.asObservable()
                .flatMap { $0 }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        
        first.onNext("🐱")
        variable.value = second
        second.onNext("🅱️")
        first.onNext("🐶")
    }
    
    /*
     flatMapLatest与flatMap 的唯一区别是：flatMapLatest只会接收最新的value 事件
     下面varivale 的value修改成 second 后，first 发出的值接收不到了
     */
    
    fileprivate func createflatMapLatest() {
        print("-----createflatMapLatest------")
        let first = BehaviorSubject(value: "👦🏻")
        let second = BehaviorSubject(value: "🅰️")
        let variable = Variable(first)
        
        variable.asObservable()
                .flatMapLatest { $0 }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        
        first.onNext("🐱")
        variable.value = second
        second.onNext("🅱️")
        first.onNext("🐶")
    }
    
    fileprivate func createbuffer() {
        
    }
    
    fileprivate func createwindow() {
        
    }
    
    fileprivate func createconcatMap() {
        
    }
    
    fileprivate func createscan() {
        
    }
    
    fileprivate func creategroupBy() {
        
    }
}
