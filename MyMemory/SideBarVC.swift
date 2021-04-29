//
//  SideBarVC.swift
//  MyMemory
//
//  Created by 이병훈 on 2020/12/06.
//

import UIKit

class SideBarVC: UITableViewController {
    let uinfo = UserInfoManager() //개인정보 관리매니저 인스턴스 생성
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let profileImage = UIImageView()
    
    let titles = ["새글 작성하기", "친구 새글","달력으로 보기", "공지사항","통계", "계정 관리"]
    
    //아이콘 데이터 배열
    let icons = [
    UIImage(named: "icon01.png"),
    UIImage(named: "icon02.png"),
    UIImage(named: "icon03.png"),
    UIImage(named: "icon04.png"),
    UIImage(named: "icon05.png"),
    UIImage(named: "icon06.png")
    ]
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "menuCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        
        cell.textLabel?.text = self.titles[indexPath.row]
        cell.imageView?.image = self.icons[indexPath.row]
        //폰트 설정
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {//테이블의 첫번째 행을 선택했으면
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "MemoForm")
            
            let target = self.revealViewController()?.frontViewController as! UINavigationController
            target.pushViewController(uv!, animated: true) //이 push 메소드를 쓰기위해서 UINavigationController 객체를 캐스팅했다.
            self.revealViewController()?.revealToggle(self) //사이드 바를 닫아주는 메소드 
        } else if indexPath.row == 5 {
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "_Profile")
            uv?.modalPresentationStyle = .fullScreen
            self.present(uv!, animated: true) {
                self.revealViewController()?.revealToggle(self) //사이드 바를 닫아주는 메소드 
            }
        }
    }
    override func viewDidLoad() {
        //헤더 뷰 역활할 뷰 정의
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
        
        headerView.backgroundColor = .brown
        
        //테이블 뷰의 헤더뷰러 지정
        self.tableView.tableHeaderView = headerView
        
        //이름 레이블 속성 설정 하고 헤더뷰의 서브뷰로 추가
        self.nameLabel.frame = CGRect(x: 70, y: 15, width: 100, height: 30)
        
//        self.nameLabel.text = "꼼꼼한 재은씨" //기본텍스트
        self.nameLabel.textColor = .white //텍스트 생상
        self.nameLabel.font = UIFont.boldSystemFont(ofSize: 15) //폰트 사이즈
        self.nameLabel.backgroundColor = .clear
        
        self.emailLabel.frame = CGRect(x: 70, y: 30, width: 120, height: 30)
        
        self.emailLabel.text = "dog10041@naver.com"
        self.emailLabel.textColor = .white
        self.emailLabel.font = UIFont.systemFont(ofSize: 11)
        self.emailLabel.backgroundColor = .clear
        
        //기본 이미지 구현
//        let defaultProfile = UIImage(named: "account.jpg")
//
//        self.profileImage.image = defaultProfile
        self.profileImage.frame = CGRect(x: 10, y: 10, width: 50, height: 50) //위치와 크기를 지정
        //프로필 이미지 둥글게 만들기
        self.profileImage.layer.cornerRadius = (self.profileImage.frame.width / 2) //반원 형태로
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true // 위에서 반원형태로 레이어를 추가해주고 마스크로 잘라오는것(가리는역홀(
        
        
        headerView.addSubview(self.nameLabel)
        headerView.addSubview(self.emailLabel)
        headerView.addSubview(self.profileImage)
    }
    override func viewWillAppear(_ animated: Bool) {
        //사이드가 화면에 표시될때마다 로그인정보를 읽어와 갱신
        self.nameLabel.text = self.uinfo.name ?? "Guest" //아무도없을시 guest 로 텍스트표시
        self.emailLabel.text = self.uinfo.account ?? ""
        self.profileImage.image = self.uinfo.profile
    }
}
