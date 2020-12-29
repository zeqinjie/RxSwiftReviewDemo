//
//  ZQSubjectsViewController.swift
//  RxSwiftReviewDemo
//
//  Created by zhengzeqin on 2020/12/23.
//

import UIKit
enum ZQError: Error {
    case error
}

class ZQSubjectsViewController: BaseViewController {

   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        createAsyncSubject()
        createPublicSubject()
//        createReplaySubject()
//        createBehaviorSubject()

    }
    
    
    /**
     1. AsyncSubject 将在源 Observable 产生完成事件后，发出最后一个元素（仅仅只有最后一个元素），如果源 Observable 没有发出任何元素，只有一个完成事件。那 AsyncSubject 也只有一个完成事件。
     它会对随后的观察者发出最终元素。
     2. 如果源 Observable 因为产生了一个 error 事件而中止， AsyncSubject 就不会发出任何元素，而是将这个 error 事件发送出来。
     
     个人理解：1. 在执行 completed 后只会发出最后一个元素并终止。2. 如果遇到 error 则只发出 error 事件并终止，不发出任何元素
     */
    fileprivate func createAsyncSubject() {
        let subject = AsyncSubject<String>()
        subject
          .subscribe { print("Subscription: 1 Event:", $0) }
          .disposed(by: disposeBag)
        subject.onNext("🐶")
//        subject
//          .subscribe { print("Subscription: 2 Event:", $0) }
//          .disposed(by: disposeBag)
        subject.onNext("🐱")
//        subject.onError(ZQError.error)
        subject.onNext("🐹")
        subject.onCompleted()
    }
        
    
    /**
     1. PublishSubject 将对观察者发送订阅后产生的元素，而在订阅前发出的元素将不会发送给观察者。如果你希望观察者接收到所有的元素，你可以通过使用 Observable 的 create 方法来创建 Observable，或者使用 ReplaySubject。
     2. 如果源 Observable 因为产生了一个 error 事件而中止， PublishSubject 就不会发出任何元素，而是将这个 error 事件发送出来。
     
     个人理解：1. 从你开始订阅开始，后面发送的元素能输出，之前的元素就不能被输出了。2. 如果遇到 error 则只发出 error 事件并终止
     */
    fileprivate func createPublicSubject() {
        let subject = PublishSubject<String>()
        subject
            .subscribe{ print("Subscription: 1 Event:", $0) }
            .disposed(by: disposeBag)
        subject.onNext("🐶")
        subject.onNext("🐱")
        
//        subject.onError(ZQError.error)
        subject
            .subscribe{ print("Subscription: 2 Event:", $0) }
            .disposed(by: disposeBag)
        
        subject.onNext("🅰️")
        subject.onNext("🅱️")
        /*
         Subscription: 1 Event: next(🐶)
         Subscription: 1 Event: next(🐱)
         Subscription: 1 Event: next(🅰️)
         Subscription: 2 Event: next(🅰️)
         Subscription: 1 Event: next(🅱️)
         Subscription: 2 Event: next(🅱️)
         */
    }
    
    /**
     1. ReplaySubject 将对观察者发送全部的元素，无论观察者是何时进行订阅的。
     2. 这里存在多个版本的 ReplaySubject，有的只会将最新的 n 个元素发送给观察者，有的只会将限制时间段内最新的元素发送给观察者。
     3. 如果把 ReplaySubject 当作观察者来使用，注意不要在多个线程调用 onNext, onError 或 onCompleted。这样会导致无序调用，将造成意想不到的结果。
     
     个人理解：1. bufferSize 缓存池大小来存储能发送的最近的元素个数 2. 不要在多线程去调用避免异常
     */
    fileprivate func createReplaySubject() {
        let subject = ReplaySubject<String>.create(bufferSize: 1)
        subject
          .subscribe { print("Subscription: 1 Event:", $0) }
          .disposed(by: disposeBag)

        subject.onNext("🐶")
        subject.onNext("🐱")
//        subject.onError(ZQError.error)
        subject
          .subscribe { print("Subscription: 2 Event:", $0) }
          .disposed(by: disposeBag)

        subject.onNext("🅰️")
        subject.onNext("🅱️")
        /*
         Subscription: 1 Event: next(🐶)
         Subscription: 1 Event: next(🐱)
         Subscription: 2 Event: next(🐱)
         Subscription: 1 Event: next(🅰️)
         Subscription: 2 Event: next(🅰️)
         Subscription: 1 Event: next(🅱️)
         Subscription: 2 Event: next(🅱️)
         */
    }
    
    /**
     1. AsyncSubject 将在源 Observable 产生完成事件后，发出最后一个元素（仅仅只有最后一个元素），如果源 Observable 没有发出任何元素，只有一个完成事件。那 AsyncSubject 也只有一个完成事件。
     它会对随后的观察者发出最终元素。
     2. 如果源 Observable 因为产生了一个 error 事件而中止， AsyncSubject 就不会发出任何元素，而是将这个 error 事件发送出来。
     
     个人理解：1. 在执行 completed 后只会发出最后一个元素并终止。2. 如果遇到 error 则只发出 error 事件并终止，不发出任何元素
     */
    fileprivate func createBehaviorSubject() {
        
    }

}
