//
//  MemoReadVC.swift
//  MyMemory
//
//  Created by 이병훈 on 2020/09/21.
//

import UIKit

class MemoReadVC: UIViewController {
    //param은 데이터를 저장할 변수이다.
    var param: MemoData?
    
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var contents: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    override func viewDidLoad() {
        self.subject.text = param?.title
        self.contents.text = param?.contents
        self.img.image = param?.image
        //날짜 포맷 변환
        let formatter = DateFormatter()
        formatter.dateFormat = "dd일 HH:mm분에 작성됨"
        let dateString = formatter.string(from: (param?.regdate)!)
        
        self.navigationItem.title = dateString
    }

    

}
