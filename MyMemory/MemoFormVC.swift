//
//  MemoFormVC.swift
//  MyMemory
//
//  Created by 이병훈 on 2020/09/21.
//

import UIKit
/*이미지 피커 델리게이트 메소드하고 네비게이션 컨트롤러 델리게이트 메소드를 구현하기 위해 가져온것 */
class MemoFormVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextViewDelegate {
    var subject: String!
    //코어데이터 추가
    lazy var dao = MemoDAO()
    @IBOutlet weak var contents: UITextView!
    
    @IBOutlet weak var preview: UIImageView!
    
    @IBAction func save(_ sender: Any) {
        //경고창에 사용할 콘텐츠 뷰컨트롤러 생성
        let alertV = UIViewController()
        let iconImage = UIImage(named: "warning-icon-60")
        alertV.view = UIImageView(image: iconImage)
        alertV.preferredContentSize = iconImage?.size ?? CGSize.zero //view에 이미지크기만큼 넣고 만약 이미지가 없으면 크기는 0으로한다.
        //내용을 입력하지 않았을 경우 경고
        guard self.contents.text?.isEmpty == false else {
            //알람 등록
            let alert = UIAlertController(title: nil, message: "내용을 입력해주세요", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            //콘텐츠 뷰영역에 등록
            alert.setValue(alertV, forKey: "contentViewController")
            self.present(alert, animated: true)
            
            return
        }
        let data = MemoData()
        //subject는 아래에서 입력된값을 범위만 잘라낸것
        data.title = self.subject //제목
        data.contents = self.contents.text // 내용
        data.image = self.preview.image // 이미지
        data.regdate = Date() // 작성시간
        
        //앱 델리게이트 객체를 불러온다음 앱델리게이트에 선언한 memolist배열에 data를 넣는다,
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.memolist.append(data)
        //코어데이터 추가
        self.dao.insert(data)
        
        _=self.navigationController?.popViewController(animated: true)
    }
    @IBAction func pick(_ sender: Any) {
        let picker = UIImagePickerController()
        let alert = UIAlertController(title:"선택",message: "이미지 가져올 곳을 선택하세요",preferredStyle: UIAlertController.Style.actionSheet)
        
        let camera = UIAlertAction(title: "카메라", style: .default, handler: {(_) in
            picker.delegate = self //델리게이트를 자신으로 지정
            
            picker.sourceType = .camera
            picker.allowsEditing = true
            //이미지 피커 화면을 표시한다.
            
        }
        )
        let photo = UIAlertAction(title: "이미지라이브러리", style: .default, handler: {(_) in
            picker.delegate = self //델리게이트를 자신으로 지정
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            //이미지 피커 화면을 표시한다.
            
        }
        )
        let album = UIAlertAction(title:"앨범", style: .default, handler: {(_) in
            picker.delegate = self
            
            picker.sourceType = .savedPhotosAlbum
            picker.allowsEditing = true
                }
        )
        alert.addAction(camera)
        alert.addAction(photo)
        alert.addAction(album)
        
        self.present(alert, animated: false)
        }
        
        
        
    //사용자가 이미지를 선택하면 자동으로 호출되는 델리게이트 메소드이다.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //UIImagePickerController.InfoKey.editedImage 는 .editedImage로 줄여 쓸수있다.
        self.preview.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage //info는 우리가 선택한 미디어의 정보가 담겨있다.
        
        picker.dismiss(animated: false)
    }
    override func viewDidLoad() {
        self.contents.delegate = self
        
        //배경이미지 설정
        let bgImage = UIImage(named: "memo-background.png")!
        self.view.backgroundColor = UIColor(patternImage: bgImage)
        //텍스트 뷰의 기본 속성 설정
        self.contents.layer.borderWidth = 0
        self.contents.layer.borderColor = UIColor.clear.cgColor
        self.contents.backgroundColor = UIColor.clear
        //텍스트 뷰의 줄 간격 설정
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 9//줄간격을 설정할때는 NSMutableParagraphStyle 클래스의 lineSpacing을 사용한다.
        self.contents.attributedText = NSAttributedString(string: " ", attributes: [.paragraphStyle: style])// 텍스트 뷰의 줄 간격이 설정된다.
        self.contents.text = ""
    }
    //사용자가 텍스트 뷰에 뭔가를 입력하면 자동으로 이 메소드가 호출 된다.
    func textViewDidChange(_ textView: UITextView) {
        let contents = textView.text as NSString
        let length = ((contents.length > 15) ? 15 : contents.length) //길이의 최대를 15로 지정한다.
        
        self.subject = contents.substring(with: NSRange(location: 0, length: length)) //입력한것을 subject 변수에 저장한다. substring은 문자열에서 원하는 범위만 잘라내는 메소드 
        
        self.navigationItem.title = self.subject
    }
    //사용자가 뷰를 터치했을때 호출되는 메소드이다.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bar = self.navigationController?.navigationBar
        let ts = TimeInterval(0.3)
        UIView.animate(withDuration: ts) {
            bar?.alpha = ( bar?.alpha == 0 ? 1: 0 )
        }
    }
}
