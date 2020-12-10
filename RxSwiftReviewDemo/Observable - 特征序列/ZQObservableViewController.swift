//
//  ViewController.swift
//  RxSwiftReviewDemo
//
//  Created by zhengzeqin on 2020/11/16.
//  特征序列

import UIKit
import RxSwift
import RxCocoa

class ZQObservableViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    /// Signal 部分
    var signalEvent: Signal<Void>!
    var driverEvent: Driver<Void>!
    var button: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        self.view.addGestureRecognizer(tap)
        ///  执行函数
//        createObservable()
//        createSingle()
//        createCompletable()
//        createMaybe()
//        createDriverUI()
//        createSignalUI()
        creatControlEvent()
    }

    // MARK: - Action
    @objc fileprivate func viewTap() {
        view.endEditing(false)
//        signalTouch()
    }
    
    // MARK: - Observable
    //******* Observable ******* //
    /// 创建 Observable
    fileprivate func createObservable() {
        /// never就是创建一个sequence，但是不发出任何事件信号。
        let neverObser = Observable<Int>.never()
        neverObser.subscribe { (event : Event<Int>) in
            print(event)
        }.disposed(by: disposeBag)

        /// empty就是创建一个空的sequence,只能发出一个completed事件
        let emptyObser = Observable<Int>.empty()
        emptyObser.subscribe { (event : Event<Int>) in
            print(event)
        }.disposed(by: disposeBag)
        
        /// just是创建一个sequence只能发出一种特定的事件，能正常结束
        let justObser = Observable<[String]>.just(["a","b","c"])
        justObser.subscribe { (event: Event<[String]>) in
            print(event)
        }.disposed(by: disposeBag)
        
        
        /// of是创建一个sequence能发出很多种事件信号
        let ofObser = Observable.of("a", "b", "c")
        ofObser.subscribe { (event : Event<String>) in
            print(event)
        }.disposed(by: disposeBag)

        /// from就是从数组中创建sequence
        let fromObser = Observable.from([1, 2, 3])
        fromObser.subscribe { (event : Event<Int>) in
            print(event)
        }.disposed(by: disposeBag)

        /// range就是创建一个sequence，他会发出这个范围中的从开始到结束的所有事件
        let rangeObser = Observable.range(start: 1, count: 10)
        rangeObser.subscribe { (event : Event<Int>) in
            print(event)
        }.disposed(by: disposeBag)

        /// 创建一个sequence，发出特定的事件n次
        let repeatElementObser = Observable.repeatElement("hell zzq").take(3)
        repeatElementObser.subscribe { (event : Event<String>) in
            print(event)
        }.disposed(by: disposeBag)


        /// 自定义可观察的sequence，那就是使用create
        let myJust = createMyJust(123)
        myJust.subscribe { (event) in
            print(event)
        }.disposed(by: disposeBag)
        
        justObser.asSingle().subscribe { (event) in
            print(event)
        }.disposed(by: disposeBag)

    }
    
    /// 通过 create 创建
    fileprivate func createMyJust<T>(_ string: T) -> Observable<T>{
        let observable = Observable<T>.create { (observer) -> Disposable in
            observer.onNext(string)
            observer.onCompleted()
            return Disposables.create()
        }
        return observable
    }
    
    // MARK: - Single
    //******* Single ******* //
    /*
     • 发出一个元素，或一个 error 事件。
     • 不会共享附加作用
     SingleObserver 在创建 create 函数中，返回一个 SingleObserver 类型闭包。
     闭包需要传 SingleEvent 参数，只存在 success(Element) 和 error 事件（有点类似 Completable 的 CompletableObserver）
     使用场景：常用于网络请求，对应答或者错误做出响应。
     */
    fileprivate func createSingle() {
        let single = createMySingle("0")
        single.subscribe { (json) in
            print("JSON结果: ", json)
        } onError: { (error) in
            print("发生错误: ", error)
        }.disposed(by: disposeBag)
    }

    //与数据相关的错误类型
    enum DataError: Error {
        case cantParseJSON
    }

    fileprivate func createMySingle(_ channel: String) -> Single<[String: Any]> {
        return Single<[String: Any]>.create { single in
            let url = "https://douban.fm/j/mine/playlist?"
                + "type=n&channel=\(channel)&from=mainsite"
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, _, error in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data,
                                                                 options: .mutableLeaves),
                    let result = json as? [String: Any] else {
                        single(.error(DataError.cantParseJSON))
                        return
                }
                single(.success(result))
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }


    // MARK: - Completable
    //******* Completable ******* //
    /*
     • 不会发出元素
     • 发出一个 completed 事件或者一个 error 事件
     • 不会共享附加作用
     Completable 在创建 create 函数中，返回一个 CompletableObserver 类型闭包。
     闭包需要传 CompletableEvent 参数，只存在 error 和 completed 事件（有点类似 Signle 的 SingleObserver）
     使用场景:一般用在不关心后端返回的结果，只在于发出请求。比如数据统计，数据缓存
     */
    fileprivate func createCompletable() {
        let completable = createMyCompletable()
        completable.subscribe {
            print("保存成功!")
        } onError: { (error) in
            print("保存失败: \(error.localizedDescription)")
        }.disposed(by: disposeBag)

    }

    //与缓存相关的错误类型
    enum CacheError: Error {
        case failedCaching
    }

    fileprivate func createMyCompletable() -> Completable {
        return Completable.create { completable in
            //将数据缓存到本地（这里掠过具体的业务代码，随机成功或失败）
            let success = (arc4random() % 2 == 0)
            guard success else {
                completable(.error(CacheError.failedCaching))
                return Disposables.create {}
            }
            completable(.completed)
            return Disposables.create {}
        }
    }

    // MARK: - Maybe
    //******* Maybe ******* //
    /* 发出一个元素或者一个 completed 事件或者一个 error 事件,不会共享附加作用
     应用场景：可能需要发出一个元素，又可能不需要发出的情况。
     */
    fileprivate func createMaybe() {
        createMyMaybe().subscribe { (event) in
            print(event)
        }.disposed(by: disposeBag)
    }

    //与缓存相关的错误类型
    enum StringError: Error {
        case failedGenerate
    }

    fileprivate func createMyMaybe() -> Maybe<String> {
        return Maybe<String>.create { maybe in
            maybe(.success("success"))
            maybe(.completed)
            return Disposables.create {}
        }
    }


    // MARK: - Driver
    /* 与 UI 相关
     • 不会产生 error 事件
     • 一定在 MainScheduler 监听
     • 共享附加作用
     */
    fileprivate func createDriverUI()  {
        let textField1 = UITextField()
        textField1.placeholder = "textField1"
        textField1.frame = CGRect(x: 10, y: 64, width: 100, height: 50)
        let textField2 = UITextField()
        textField2.placeholder = "textField2"
        textField2.frame = CGRect(x: 10, y: 110, width: 100, height: 50)
        let textField3 = UITextField()
        textField3.placeholder = "textField3"
        textField3.frame = CGRect(x: 10, y: 160, width: 100, height: 50)
        self.view.addSubview(textField1)
        self.view.addSubview(textField2)
        self.view.addSubview(textField3)


        /// 使用的是 Observable
        let results = textField1.rx.text
            .flatMapLatest {[unowned self] query in
               return self.fetchAutoCompleteItems(query)
                .observeOn(MainScheduler.instance).catchErrorJustReturn("error")
               /// 1. UI 需在主线程操作  2. Observable 产生异常会中断绑定
            }
            .share(replay: 1) /// 使用 share 是被共享的,否则 bind 多次会执行多次 fetchAutoCompleteItems

        results
            .map { "\($0 ?? "abc")~" }
            .bind(to: textField2.rx.text)
            .disposed(by: disposeBag)

        results
            .bind(to: textField3.rx.text)
            .disposed(by: disposeBag)


        /// 使用 Driver
        let results1 = textField1.rx.text
            .asDriver() // 将普通序列转换为 Driver
            .flatMapLatest { [unowned self] query in
            return fetchAutoCompleteItems("")
                .asDriver(onErrorJustReturn: "error") // 仅仅提供发生错误时的备选返回值
        }

        //将返回的结果绑定到显示结果数量的label上
        results1
            .map { "\($0 ?? "abc")~" }
            .drive(textField2.rx.text)  // 这里使用 Drive 使用 drive 而不是 bindTo
            .disposed(by: disposeBag)

        results1
            .drive(textField3.rx.text)
            .disposed(by: disposeBag)

    }

    
    /// 获取数据
    fileprivate func fetchAutoCompleteItems(_ str: String?) -> Observable<String?> {
        return Observable.create { observer -> Disposable in
            observer.onNext(str)
            print("666 \(str ?? "")")
            return Disposables.create()
        }
    }

    // MARK: - Signal
    /*
     Signal 和 Driver 相似，唯一的区别是，Driver 会对新观察者回放（重新发送）上一个元素，而 Signal 不会对新观察者回放上一个元素
     状态序列我们会选用 Driver 这个类型，事件序列我们会选用 Signal 这个类型
     */
    fileprivate func signalTouch() {
        let observer: () -> Void = { self.showAlert("弹出提示框2") }
//        driverEvent = button.rx.tap.asDriver()  /// 注意不能重新转换，会初始化新的 event
        driverEvent.drive(onNext:observer).disposed(by: disposeBag)
        signalEvent.emit(onNext:observer).disposed(by: disposeBag)
    }

    fileprivate func showAlert(_ str: String) {
        print("弹出提示框 -- \(str)")
    }
    
    fileprivate func createSignalUI() {
        let button: UIButton = UIButton(frame: CGRect(x: 10, y: 164, width: 100, height: 50))
        button.backgroundColor = UIColor.red
        self.button = button
        self.view.addSubview(button)

        let observer: () -> Void = { self.showAlert("弹出提示框1")  }

//        driverEvent = button.rx.tap.asDriver()
//        driverEvent.drive(onNext:observer).disposed(by: disposeBag)

        signalEvent = button.rx.tap.asSignal()
        signalEvent.emit(onNext: observer).disposed(by: disposeBag)
    }
    
    // MARK: - ControlEvent
    /*
     ControlEvent 专门用于描述 UI 控件所产生的事件，它具有以下特征：
     • 不会产生 error 事件
     • 一定在 MainScheduler 订阅（主线程订阅）
     • 一定在 MainScheduler 监听（主线程监听）
     • 共享附加作用
     */
    
    fileprivate func creatControlEvent()  {
        /**
            同样地，在 RxCocoa 下许多 UI 控件的事件方法都是被观察者（可观察序列）。
            那么我们如果想实现当一个 button 被点击时，在控制台输出一段文字。即前者作为被观察者，后者作为观察者。可以这么写：
         */
        let btn:UIButton = UIButton.init(type: .custom)
        btn.frame = CGRect(x: 30, y: 100, width: 50, height: 50)
        btn.setTitle("点击", for: .normal)
        btn.backgroundColor  = .red
        self.view.addSubview(btn)
//        btn.rx.tap
//            .subscribe(onNext: {
//                print("欢迎")
//            }).disposed(by: disposeBag)
        
        btn.rx.tap.subscribe { (event) in
            print("欢迎")
        } onError: { (error) in
            print("error")
        } onCompleted: {
            print("onCompleted")
        }.disposed(by: disposeBag)

    }
    

}
