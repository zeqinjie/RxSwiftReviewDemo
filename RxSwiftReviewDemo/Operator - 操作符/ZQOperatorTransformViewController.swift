//
//  ZQOperatorViewController.swift
//  RxSwiftReviewDemo
//
//  Created by zhengzeqin on 2021/1/4.
//  转换操作符

import UIKit

class ZQOperatorTransformViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        createmap()
//        createflatMap()
//        createflatMapLatest()
//        createbuffer()
//        createwindow()
//        createconcatMap()
//        createscan()
        creategroupBy()
    }
    
    

}

// MARK: - 变化操作符
extension ZQOperatorTransformViewController {
    
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
    
    /*
     
     */
    fileprivate func createconcatMap() {
        print("-----createconcatMap------")
        //concatMap 与 flatMap 的唯一区别是：当前一个 Observable 元素发送完毕后，后一个Observable 才可以开始发出元素。或者说等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅。
        //如果subject1不发送onCompleted，subject2永远不会输出
        let subject1 = BehaviorSubject(value: "A")
        let subject2 = BehaviorSubject(value: "1")
        let variable = Variable(subject1)
        variable.asObservable()
            .concatMap({$0})
            .subscribe(onNext: {
                print($0)
            }).disposed(by: disposeBag)
        
        subject1.onNext("B")
        variable.value = subject2
        subject2.onNext("2")
        subject1.onNext("C")
        subject1.onCompleted() //只有前一个序列结束后，才能接收下一个序列
//        subject2.onCompleted()
    }
    
    /*
     buffer 将缓存 Observable 中发出的新元素，当元素达到某个数量，或者经过了特定的时间，它就会将这个元素集合发送出来
     */
    fileprivate func createbuffer() {
        print("-----createbuffer------")
        // 每隔 1 秒会将 3 个元素以字符串数组[String]形式发出，如果没有元素，则输出为空数组
        let subject = PublishSubject<String>()
        subject
            .buffer(timeSpan: RxTimeInterval.seconds(1), count: 3, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                print($0)
            }).disposed(by: disposeBag)
        
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")

        subject.onNext("a")
        subject.onNext("b")
        subject.onNext("c")
        
    }
    
    /*
     window 操作符和 buffer 十分相似，buffer 周期性的将缓存的元素集合发送出来，而 window 周期性的将元素集合以 Observable 的形态发送出来。
     buffer 要等到元素搜集完毕后，才会发出元素序列。而 window 可以实时发出元素序列
     */
    fileprivate func createwindow() {
        print("-----createwindow------")
        let subject = PublishSubject<String>()
        //每 3 个元素作为一个序列 (Observable<String>) 发出，如果没有元素，则输出 RxSwift.AddRef<Swift.String>
        subject.window(timeSpan: RxTimeInterval.seconds(1), count: 3, scheduler: MainScheduler.instance)
               .subscribe(onNext: {
                    print($0) //Observable<String> 类型
                    $0.subscribe(onNext: {
                        print($0)
                    }).disposed(by: self.disposeBag)
               }).disposed(by: disposeBag)
        
       
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")
        
        subject.onNext("a")
        subject.onNext("b")
        subject.onNext("c")
    }
    

    /*
     scan 操作符将对第一个元素应用一个函数，将结果作为第一个元素发出。然后，将结果作为参数填入到第二个元素的应用函数中，创建第二个元素。以此类推，直到遍历完全部的元素。
     这种操作符在其他地方有时候被称作是 accumulator。
     */
    fileprivate func createscan() {
        print("-----createscan------")
//        scan 就是先给一个初始化的数，然后不断的拿前一个结果和最新的值进行处理操作
//        输出为2，4，7，11，16
//        acum 为新值  elem为下一个值
        Observable.of(1, 2, 3, 4, 5)
            .scan(1) { (aggregateValue, newValue) -> Int in
                return aggregateValue + newValue
            }.subscribe(onNext: { print($0)}
            ).disposed(by: disposeBag)
    }
    
    /*
     将源 Observable 分解为多个子 Observable，并且每个子 Observable 将源 Observable 中“相似”的元素发送出来
     */
    fileprivate func creategroupBy() {
        //        groupBy 操作符将源 Observable 分解为多个子 Observable，然后将这些子 Observable 发送出来。
        //        也就是说该操作符会将元素通过某个键进行分组，然后将分组后的元素序列以 Observable 的形态发送出来。
        //将奇数偶数分成两组
        Observable<Int>.of(0, 1, 2, 3, 4, 5)
            .groupBy(keySelector: { (element) -> String in
                return element % 2 == 0 ? "偶数" : "基数"
            })
            .subscribe { (event) in
                switch event {
                case .next(let group):
                    group.asObservable().subscribe({ (event) in
                        print("key：\(group.key)    event：\(event)")
                    }).disposed(by: self.disposeBag)
                default:
                    print("")
                }
            }
            .disposed(by: disposeBag)
    }

}
