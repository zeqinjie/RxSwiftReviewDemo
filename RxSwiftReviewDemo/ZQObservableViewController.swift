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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
//        creatDriverUI()
        creatSignalUI()
    }
    
    @objc func viewTap() {
        view.endEditing(false)
    }

    // MARK: - Driver
    func creatDriverUI()  {
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
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        self.view.addGestureRecognizer(tap)
        
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
    
    func fetchAutoCompleteItems(_ str: String?) -> Observable<String?> {
        return Observable.create { observer -> Disposable in
            observer.onNext(str)
            print("666 \(str ?? "")")
            return Disposables.create()
        }
    }
    
    // MARK: - Signal
    
    func creatSignalUI() {
        /*
        let textField: UITextField = UITextField(frame: CGRect(x: 10, y: 64, width: 100, height: 50))
        textField.placeholder = "textField1"
        let nameLabel: UILabel = UILabel(frame: CGRect(x: 10, y: 110, width: 100, height: 50))
        nameLabel.backgroundColor = UIColor.red
        let nameSizeLabel: UILabel = UILabel(frame: CGRect(x: 10, y: 160, width: 100, height: 50))
        nameSizeLabel.backgroundColor = UIColor.blue
        self.view.addSubview(textField)
        self.view.addSubview(nameLabel)
        self.view.addSubview(nameSizeLabel)
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        self.view.addGestureRecognizer(tap)
        
        
        let state: Driver<String?> = textField.rx.text.asDriver()
        let observer = nameLabel.rx.text
        state.drive(observer).disposed(by: disposeBag)
        
        let newObserver = nameSizeLabel.rx.text
        state.map { $0?.count.description }.drive(newObserver).disposed(by: disposeBag)
        */
        
        let button: UIButton = UIButton(frame: CGRect(x: 10, y: 64, width: 100, height: 50))
        button.backgroundColor = UIColor.red
        self.view.addSubview(button)
        let showSignalAlert: (String) -> Void = {
            (str) in
            print("str ...\(str)")
        }
//        let event: Driver<Void> = button.rx.tap.asDriver()
//        let observer: () -> Void = { showSignalAlert("弹出提示框1") }
//        event.drive(onNext: observer).disposed(by: disposeBag)
//        let newObserver: () -> Void = { showSignalAlert("弹出提示框2") }
//        event.drive(onNext: newObserver).disposed(by: disposeBag)
        
        
        let event: Signal<Void> = button.rx.tap.asSignal()
        let observer: () -> Void = { showSignalAlert("弹出提示框1") }
        event.emit(onNext: observer).disposed(by: disposeBag)
        let newObserver: () -> Void = { showSignalAlert("弹出提示框2") }
        event.emit(onNext: newObserver).disposed(by: disposeBag)
    }
    
}





