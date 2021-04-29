//
//  TutorialContentsVC.swift
//  MyMemory
//
//  Created by 이병훈 on 2021/01/03.
//

import UIKit

class TutorialContentsVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgimageView: UIImageView!
    
    var pageIndex: Int! //페이지 번호
    var titleText: String! //타이틀
    var imageFile: String! //이미지 정보
    
    override func viewDidLoad() {
        //이미지를 꽉채울수 있게
        self.bgimageView.contentMode = .scaleAspectFill
        //전달받은 타이틀 정보를 레이블 객체에 대입하고 크기를 조절
        self.titleLabel.text = self.titleText
        self.titleLabel.sizeToFit()
        //전달받은 이미지 정보를 이미지뷰에 대입
        self.bgimageView.image = UIImage(named: self.imageFile)
    }
}
