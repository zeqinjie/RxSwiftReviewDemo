//
//  ZQOperatorCombineViewController.swift
//  RxSwiftReviewDemo
//
//  Created by zhengzeqin on 2021/1/11.
//  结合操作符

import UIKit

class ZQOperatorCombineViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        createstartWith()
//        createmerge()
//        createzip()
//        createcombineLatest()
//        createwithLatestFrom()
        createswitchLatest()
        
//        test()
        // Do any additional setup after loading the view.
    }

}

// MARK: - 结合操作符
extension ZQOperatorCombineViewController {
    /*
     将一些元素插入到序列的头部
     */
    fileprivate func createstartWith() {
        print("-----createstartWith------")
//        startWith
//        该方法会在 Observable 序列开始之前插入一些事件元素。即发出事件消息之前，会先发出这些预先插入的事件消息。
        Observable.of("2", "3")
            .startWith("1")
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
//        结果输出1，2，3
//        当然插入多数据也是可以的
        Observable.of("2", "3")
            .startWith("a")
            .startWith("b")
            .startWith("c")
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
//        最后插入的会先发出
//        这样就会输出c,b,a,2,3
    }
    
    /*
     将多个 Observables 合并成一个
     */
    fileprivate func createmerge() {
        print("-----createmerge------")
//        merge
//        该方法可以将多个（两个或两个以上的）Observable 序列合并成一个 Observable序列。
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<Int>()
        
        Observable.of(subject1, subject2)
            .merge()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject1.onNext(20)
        subject1.onNext(40)
        subject1.onNext(60)
        subject2.onNext(1)
        subject1.onNext(80)
        subject1.onNext(100)
        subject2.onNext(1)
//        结果20，40，60，1，80，100，1
    }
    
    /*
     通过一个函数将多个 Observables 的元素组合起来，然后将每一个组合的结果发出来
     */
    fileprivate func createzip() {
        print("-----createzip------")
//        zip
//        该方法可以将多个（两个或两个以上的）Observable 序列压缩成一个 Observable 序列。
//        而且它会等到每个 Observable 事件一一对应地凑齐之后再合并。
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<String>()
        
        Observable.zip(subject1, subject2) {
            "\($0)\($1)"
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject1.onNext(1)
        subject2.onNext("A")
        subject1.onNext(2)
        subject2.onNext("B")
        subject2.onNext("C")
        subject2.onNext("D")
        subject1.onNext(3)
        subject1.onNext(4)
        subject1.onNext(5)
//        结果1A,2B,3C,4D
    }
    
    /*
     当多个 Observables 中任何一个发出一个元素，就发出一个元素。这个元素是由这些 Observables 中最新的元素，通过一个函数组合起来的
     以合并第一个元素为主，遇到新的序列，则它将会以新的元素合并每一个
     */
    func createcombineLatest()  {
        print("-----createcombineLatest------")
//        combineLatest
//        该方法同样是将多个（两个或两个以上的）Observable 序列元素进行合并。
//        但与 zip 不同的是，每当任意一个 Observable 有新的事件发出时，它会将每个 Observable 序列的最新的一个事件元素进行合并。
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<String>()
        Observable.combineLatest(subject1, subject2) {
            "\($0)\($1)"
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject1.onNext(1)
        subject2.onNext("A")
        subject1.onNext(2)
        subject2.onNext("B")
        subject2.onNext("C")
        subject2.onNext("D")
        subject1.onNext(3)
        subject1.onNext(4)
        subject1.onNext(5)
//       结果1A,2A,2B,2C,2D,3D,4D,5D
    }
    
    /*
     将两个 Observables 最新的元素通过一个函数组合起来，当第一个 Observable 发出一个元素，就将组合后的元素发送出来
     */
    func createwithLatestFrom() {
        print("-----createwithLatestFrom------")
//        withLatestFrom
//        该方法将两个 Observable 序列合并为一个。每当 self 队列发射一个元素时，便从第二个序列中取出最新的一个值
//        这里的self相当于subject1
        let subject1 = PublishSubject<String>()
        let subject2 = PublishSubject<String>()
        
//        subject1.withLatestFrom(subject2)
//            .subscribe(onNext: { print($0) })
//            .disposed(by: disposeBag)
//
//        subject1.onNext("A")
//        subject2.onNext("1")
//        subject1.onNext("B")
//        subject1.onNext("C")
//        subject2.onNext("2")
//        subject1.onNext("D")
        //        结果1，1，2
        subject1
            .withLatestFrom(subject2) { $0 + $1 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject1.onNext("1")
        subject2.onNext("A")
        subject1.onNext("2")
        subject2.onNext("B")
        subject2.onNext("C")
        subject2.onNext("D")
        subject1.onNext("3")
        subject1.onNext("4")
        subject1.onNext("5")
        //        结果2A，3D，4D，5D
    }
    
    /*
     将可观察序列发出的元素转换为可观察序列，并从最近的内部可观察序列发出元素
     */
    func createswitchLatest()  {
        print("-----createswitchLatest------")
//        switchLatest
//        switchLatest 有点像其他语言的switch 方法，可以对事件流进行转换。
//        比如本来监听的 subject1，我可以通过更改 variable 里面的 value 更换事件源。变成监听 subject2。
        let subject1 = BehaviorSubject(value: "A")
        let subject2 = BehaviorSubject(value: "1")
        
        let variable = Variable(subject1)
        
        variable.asObservable()
            .switchLatest()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject1.onNext("B")
        subject1.onNext("C")
        
        //改变事件源
        variable.value = subject2
        subject1.onNext("D")
        subject2.onNext("2")
        
        //改变事件源
        variable.value = subject1
        subject2.onNext("3")
        subject1.onNext("E")
//        结果A,B,C,1,2,D,E
    }
    
    
//    struct State {
//        var section: [String] = []
//        var isDismiss: Bool = false
//    }
    
//    fileprivate func test() {
//        var state = State()
//        let subject = BehaviorSubject<State>(value: state)
//
//        subject.map { $0.section }
//            .subscribe(onNext: { print("(section:\($0))")})
//            .disposed(by: disposeBag)
//
//        subject.map { $0.isDismiss }
//            .subscribe(onNext: { print("(isDismiss:\($0))")})
//            .disposed(by: disposeBag)
//
//        state.isDismiss = true
//        subject.onNext(state)
//    }
}
