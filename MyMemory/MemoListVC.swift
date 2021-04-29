//
//  MemoListVCTableViewController.swift
//  MyMemory
//
//  Created by 이병훈 on 2020/09/21.
//

import UIKit

class MemoListVC: UITableViewController, UISearchBarDelegate {
    //코어데이터 추가
    lazy var dao = MemoDAO()

    @IBOutlet weak var searchBar: UISearchBar!
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        //검색바의 키보드에서 리턴키가 항상 할성화되어 있도록 처리
        searchBar.enablesReturnKeyAutomatically = false
        //SWRevealViewController 라이브러리의 revealViewController 객체를 읽어온다.
        if let revealVC = self.revealViewController() {
            //버튼 추가
            let btn = UIBarButtonItem()
            btn.image = UIImage(named: "sidemenu.png")
            btn.target = revealVC // 버튼 클릭시 호출할 메소드가 있는 객체
            btn.action = #selector(revealVC.revealToggle(_:))
            //버튼을 등록한다.
            self.navigationItem.leftBarButtonItem = btn
            //제스처를 등록
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.appdelegate.memolist[indexPath.row] //선택한 행의 데이터
        
        let cellid = row.image == nil ? "memoCell" : "memoCellWithImage"
        // 재사용 큐로부터 프로포타입 셀의 인스턴스를 전달받는다.
        let cell = tableView.dequeueReusableCell(withIdentifier: cellid) as! MemoCell
        //memocell을 구성한다.
        cell.subject?.text = row.title
        cell.contents?.text = row.contents
        cell.img?.image = row.image
        //Date 타입의 날짜를 yyyy-mm-dd HH:mm:ss포맷에 맞게 변경
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
        cell.regdate?.text = formatter.string(from: row.regdate!)
        
        return cell
    
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //앱 델리게이트안에 있는 memolist의 갯수만큼 만든다.
        let count = self.appdelegate.memolist.count

        return count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.appdelegate.memolist[indexPath.row] //선택한 행의 데이터
        //읽어 들어올 화면의 인스턴스를 생성
        guard let vc = self.storyboard?.instantiateViewController(identifier: "MemoRead") as? MemoReadVC else {
            return
        }
        vc.param = row
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let data = self.appdelegate.memolist[indexPath.row] //선택된 배열의 값을 가져온다.
        
        if dao.delete(data.objectID!) {
            self.appdelegate.memolist.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    //viewWillAppear메소드는 앱 생명주기로 스크린에 뷰컨트롤러가 출력될때 마다 실행하는 메소드
    override func viewWillAppear(_ animated: Bool) {
        let ud = UserDefaults.standard
        if ud.bool(forKey: UserInfoKey.tutorial) == false {
            let vc = self.instanceTutorialVC(name: "MasterVC")
            vc?.modalPresentationStyle = .fullScreen
            self.present(vc!, animated: false)
            return
        }
        //코어 데이터에 저장된 값을 가져온다.
        //갱신된 데이터목록을 memolist에 넣는다.
        self.appdelegate.memolist = self.dao.fetch()
        self.tableView.reloadData()
    }
    // MARK: - uisearchbardelegate 메소드
    //사용자가 search 검색 버튼을 터치했을때 실행되는 델리게이트 메소드이다.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = searchBar.text
        //위 키워드로 가져온 텍스트를 통해 데이터 검색하고 테이블 뷰를 갱신
        self.appdelegate.memolist = self.dao.fetch(keyword: keyword)
        self.dismisskeyboard()
        self.tableView.reloadData()
    }

}
//2021-02-14 추가
extension MemoListVC {
    private func dismisskeyboard() {
        searchBar.resignFirstResponder()
    }
}
