//
//  ZQObserverViewController.swift
//  RxSwiftReviewDemo
//
//  Created by zhengzeqin on 2020/12/10.
//

import UIKit

class ZQObserverViewController: BaseViewController {

    var label: UILabel!
    var button: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creatUI()
//        createAnyObserver()
        createBinder()
        // Do any additional setup after loading the view.
    }
    
    fileprivate func creatUI() {
        label = UILabel(frame: CGRect(x: 0, y: 100, width: view.frame.size.width, height: 20))
        view.addSubview(label)
        
//        button = UIButton(frame: CGRect(x: 0, y: 130, width: 100, height: 20))
//        button.backgroundColor = .black
//        view.addSubview(button)
    }
    
    /// AnyObserver 可以用来描叙任意一种观察者。
    fileprivate func createAnyObserver() {
        /// AnyObserver(eventHandler: {event) in  })
        let observer: AnyObserver<Data> = AnyObserver { (event) in
            switch event {
            case .next(let data):
                self.label.text = "Data Task Success with count: \(data.count)"
            case .error(let error):
                print("Data Task Error: \(error)")
            default:
                break
            }
        }

        URLSession.shared.rx.data(request: URLRequest(url: URL(string: "https://www.baidu.com")!))
            .observeOn(MainScheduler.instance)
            .subscribe(observer)
            .disposed(by: disposeBag)

        /// 上面等价于
        URLSession.shared.rx.data(request: URLRequest(url: URL(string: "https://www.baidu.com")!))
            .observeOn(MainScheduler.instance)
            .subscribe { (data) in
            self.label.text = "Data Task Success with count: \(data.count)"
        } onError: { (error) in
            print("Data Task Error: \(error)")
        }.disposed(by: disposeBag)
    }
    
    /// Binder
    /**
     Binder 主要有以下两个特征：

     不会处理错误事件
     确保绑定都是在给定 Scheduler 上执行（默认 MainScheduler）
     一旦产生错误事件，在调试环境下将执行 fatalError，在发布环境下将打印错误信息。
     */
    fileprivate func createBinder() {
//        let observable = Observable<Int>.interval(DispatchTimeInterval.milliseconds(1), scheduler: MainScheduler.instance)
//        observable
//            .map({"当前的值 \($0)"})
//            .bind(to: label.rx.text)
//            .disposed(by: disposeBag)
        
        
        /// Binder 可以只处理 next 事件，并且保证响应 next 事件的代码一定会在给定 Scheduler 上执行，这里采用默认的 MainScheduler。
        URLSession.shared.rx.data(request: URLRequest(url: URL(string: "https://www.baidu.com")!))
            .map({"Data Task Success with count: \($0.count)"})
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
        
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

/// 扩展观察者属性
/// 扩展 label 观察者属性
extension Reactive where Base: UILabel {
    
    /// Bindable sink for `text` property.
    public var text: Binder<String?> {
        return Binder(self.base) { label, text in
            label.text = text
        }
    }
}
