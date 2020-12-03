import UIKit
import RxSwift
var str = "Hello, playground"

let disposeBag = DisposeBag()


//******* Observable ******* //
/// 创建 Observable
func createObservable() {
    
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
func createMyJust<T>(_ string: T) -> Observable<T>{
    let observable = Observable<T>.create { (observer) -> Disposable in
        observer.onNext(string)
        observer.onCompleted()
        return Disposables.create()
    }
    return observable
}


//******* Single ******* //
func createSingle() {
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

func createMySingle(_ channel: String) -> Single<[String: Any]> {
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


//******* Completable ******* //
func createCompletable() {
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

func createMyCompletable() -> Completable {
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

//******* Maybe ******* //
func createMaybe() {
    createMyMaybe().subscribe { (event) in
        print(event)
    }.disposed(by: disposeBag)
}

//与缓存相关的错误类型
enum StringError: Error {
    case failedGenerate
}

func createMyMaybe() -> Maybe<String> {
    return Maybe<String>.create { maybe in
        maybe(.success("success"))
        maybe(.completed)
        return Disposables.create {}
    }
}


//******* Driver ******* //
func createDriver() {
  
}



///  执行函数
//createObservable()
//createSingle()
//createCompletable()
//createMaybe()
createDriver()

