//
//  ViewController.swift
//  RxSwiftReviewDemo
//
//  Created by zhengzeqin on 2020/11/16.
//

import UIKit
import RxSwift
import RxCocoa

class ZQObservableViewController: UIViewController {

    let disposeBag = DisposeBag()
    var signalEvent: Signal<Void>!
    var driverEvent: Driver<Void>!
    var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        self.view.addGestureRecognizer(tap)
        creatSignalUI()
    }

    // MARK: - Action
    @objc fileprivate func viewTap() {
        view.endEditing(false)
        signalTouch()
    }

    // MARK: - Driver
    fileprivate func creatDriverUI()  {
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

    fileprivate func fetchAutoCompleteItems(_ str: String?) -> Observable<String?> {
        return Observable.create { observer -> Disposable in
            observer.onNext(str)
            print("666 \(str ?? "")")
            return Disposables.create()
        }
    }

    // MARK: - Signal
    fileprivate func signalTouch() {
        let observer: () -> Void = { self.showAlert("弹出提示框2") }
//        driverEvent = button.rx.tap.asDriver()  /// 注意不能重新转换，会初始化新的 event
        driverEvent.drive(onNext:observer).disposed(by: disposeBag)
        signalEvent.emit(onNext:observer).disposed(by: disposeBag)
        
    }

    fileprivate func showAlert(_ str: String) {
        print("弹出提示框 -- \(str)")
    }

    fileprivate func creatSignalUI() {
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
    

}
