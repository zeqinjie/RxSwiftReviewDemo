//
//  ZQOperatorOtherViewController.swift
//  RxSwiftReviewDemo
//
//  Created by zhengzeqin on 2021/2/2.
//

import UIKit

class ZQOperatorOtherViewController: BaseViewController {

    var deferredValue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.delay()
//        self.delaySubscription()
//        self.materialize()
//        self.dematerialize()
//        self.timeout()
//        self.using()
        self.deferred()
        // Do any additional setup after loading the view.
    }

}

extension ZQOperatorOtherViewController {
    func delay() {
//        该操作符会将 Observable 的所有元素都先拖延一段设定好的时间，然后才将它们发送出来
        Observable.of(1, 2, 1)
            .delay(DispatchTimeInterval.seconds(3), scheduler: MainScheduler.instance) //元素延迟3秒才发出
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }

    func delaySubscription() {
//        使用该操作符可以进行延时订阅。即经过所设定的时间后，才对 Observable 进行订阅操作。
        Observable.of(1, 2, 1)
            .delaySubscription(DispatchTimeInterval.seconds(3), scheduler: MainScheduler.instance) //延迟3秒才开始订阅
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    func materialize() {
//        该操作符可以将序列产生的事件，转换成元素。
//        通常一个有限的 Observable 将产生零个或者多个 onNext 事件，最后产生一个 onCompleted 或者onError事件。而 materialize 操作符会将 Observable 产生的这些事件全部转换成元素，然后发送出来。
        Observable.of(1, 2, 1)
            .materialize()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    func dematerialize() {
//        该操作符的作用和 materialize 正好相反，它可以将 materialize 转换后的元素还原。
        Observable.of(1, 2, 1)
            .materialize()
            .dematerialize()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    func timeout() {
//        使用该操作符可以设置一个超时时间。如果源 Observable 在规定时间内没有发任何出元素，就产生一个超时的 error 事件
        //定义好每个事件里的值以及发送的时间
        let times = [
            [ "value": 1, "time": 0 ],
            [ "value": 2, "time": 0.5 ],
            [ "value": 3, "time": 1.5 ],
            [ "value": 4, "time": 4 ],
            [ "value": 5, "time": 5 ]
        ]
        
        //生成对应的 Observable 序列并订阅
        Observable.from(times)
            .flatMap { item in
                return Observable.of(Int(item["value"]!))
                    .delaySubscription(Double(item["time"]!),
                                       scheduler: MainScheduler.instance)
            }
            .timeout(DispatchTimeInterval.seconds(2), scheduler: MainScheduler.instance) //超过两秒没发出元素，则产生error事件
            .subscribe(onNext: { element in
                print(element)
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    func using() {
//        使用 using 操作符创建 Observable 时，同时会创建一个可被清除的资源，一旦 Observable终止了，那么这个资源就会被清除掉了。
        //一个无限序列（每隔0.1秒创建一个序列数 ）
        let infiniteInterval$ = Observable<Int>
            .interval(DispatchTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            .do(
                onNext: { print("infinite$: \($0)") },
                onSubscribe: { print("开始订阅 infinite$")},
                onDispose: { print("销毁 infinite$")}
        )
        
        //一个有限序列（每隔0.5秒创建一个序列数，共创建三个 ）
        let limited$ = Observable<Int>
            .interval(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .take(2)
            .do(
                onNext: { print("limited$: \($0)") },
                onSubscribe: { print("开始订阅 limited$")},
                onDispose: { print("销毁 limited$")}
        )
        
        //使用using操作符创建序列
        let o: Observable<Int> = Observable.using({ () -> AnyDisposable in
            return AnyDisposable(infiniteInterval$.subscribe())
        }, observableFactory: { _ in return limited$ }
        )
        o.subscribe().disposed(by: disposeBag)
    }
    
    fileprivate func deferred() {
//        let val = deferredTest()
        
//        just1.subscribe(onNext: { val in
//            print("just 2 -- \(val)")
//        }).disposed(by: self.disposeBag)
        
//        let defered2 = Observable<Int>.deferred { [weak self] () -> Observable<Int> in
//            guard let self = self else { return Observable<Int>.empty() }
//            return  Observable<Int>.just(self.deferredTest())
//        }
        
//        defered2.subscribe(onNext: { val in
//            print("defered 2 -- \(val)")
//        }).disposed(by: self.disposeBag)
        
        
//        let just1 = Observable<Int>.just(0)
//
//        let defered1 = createVaule()
//
//        just1.subscribe(onNext: { [weak self] val in
//            self?.deferredTest()
//        }).disposed(by: self.disposeBag)
//
//
//        defered1.subscribe(onNext: { val in
//            print("defered 1 -- \(val)")
//        }).disposed(by: self.disposeBag)
        
        
        let just1 = Observable<Int>.just(0)
        
        /// deferred 作用：当它被订阅的时候，会执行闭包的回调以确保拿到的值不是最初初始化的值,而是当前闭包执行时候的值
        let defered1 = Observable<Int>.deferred { [weak self]  in
            guard let self = self else { return Observable<Int>.empty() }
            return .just(self.deferredValue)
        }
        
        just1.subscribe(onNext: { [weak self] val in
            print("just1 -- subscribe")
            print("just1 1 -- \(self?.deferredValue)")
            self?.deferredTest()
            print("just1 2 -- \(self?.deferredValue)")
        }).disposed(by: self.disposeBag)
        
        defered1.subscribe(onNext: { val in
            print("defered -- \(val)")
        }).disposed(by: self.disposeBag)
        
    }
    
    fileprivate func createVaule() -> Observable<Int> {
        let val = self.deferredTest()
        return Observable<Int>.just(0).flatMap { _ in Observable.just(val) }
    }
    
    fileprivate func deferredTest() -> Int {
        self.deferredValue = deferredValue+1
        return self.deferredValue
    }
}

class AnyDisposable: Disposable {
    let _dispose: () -> Void
    
    init(_ disposable: Disposable) {
        _dispose = disposable.dispose
    }
    
    func dispose() {
        _dispose()
    }
}
