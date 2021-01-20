//
//  RootViewController.swift
//  RxSwiftReviewDemo
//
//  Created by zhengzeqin on 2020/12/9.
//

import UIKit
import RxSwift
import RxCocoa

fileprivate struct ListModel {
    let className: UIViewController.Type?
    let name: String?
}

fileprivate struct ListViewModel {
    let data = Observable<[ListModel]>.just([
        ListModel(className: ZQObservableViewController.self,name: "Observable - 序列特征"),
        ListModel(className: ZQObserverViewController.self,name: "Observer - 响应事件"),
        ListModel(className: ZQSubjectsViewController.self,name: "Subject 既是可监听序列也是观察者"),
        ListModel(className: ZQOperatorTransformViewController.self,name: "Operator - 转换操作符"),
        ListModel(className: ZQOperatorCombineViewController.self,name: "Operator - 结合操作符"),
        ListModel(className: ZQOperatorFilterViewController.self,name: "Operator - 过滤操作符"),
    ])
}

class RootViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    fileprivate let cellId = "cell"
    fileprivate let disposeBag = DisposeBag()
    fileprivate let dataList = ListViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        dataList.data
            .bind(to: tableView.rx.items(cellIdentifier: cellId)) { _, model, cell in
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = model.name
            }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ListModel.self).subscribe({ event in
            let lVCClass = event.element?.className
            if let lVCClass = lVCClass{
                let lVC = lVCClass.init()
                self.navigationController?.pushViewController(lVC, animated: true)
            }
        }).disposed(by: disposeBag)
        
        
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
