//
//  JoinVC.swift
//  MyMemory
//
//  Created by 이병훈 on 2021/02/22.
//

import UIKit
import Alamofire

class JoinVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    //API호출 상태값을 관리할 변수
    var isCalling = false
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //프로필 이미지를 원형으로 설정
        self.profile.layer.cornerRadius = self.profile.frame.width / 2
        self.profile.layer.masksToBounds = true
        //프로필 이미지를 탭했을때 액션 이벤트 설정
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfile(_:)))
        self.profile.addGestureRecognizer(gesture)
        //인디케이터 뷰를 맨 앞으로 가져오는 코드
        self.view.bringSubviewToFront(self.indicatorView)
    }
    
    var fieldAccount: UITextField! //계정 텍스트 필드
    var fieldPassword: UITextField! // 계정 비밀번호 필드
    var fieldName: UITextField! // 계정 이름 필드
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        //각 테이블 뷰 셀 모두에 적용될 프레임 객체
        let tFrame = CGRect(x: 20, y: 0, width: cell.bounds.width - 20, height: 37)
        switch indexPath.row {
        case 0:
            self.fieldAccount = UITextField(frame: tFrame)
            self.fieldAccount.placeholder = "계정(이메일)"
            self.fieldAccount.borderStyle = .none //가장자리 없애기
            self.fieldAccount.autocapitalizationType = .none //자동 대문자
            self.fieldAccount.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(fieldAccount)
        case 1:
            self.fieldPassword = UITextField(frame: tFrame)
            self.fieldPassword.placeholder = "비밀번호"
            self.fieldPassword.borderStyle = .none
            self.fieldPassword.isSecureTextEntry = true
            self.fieldPassword.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(fieldPassword)
        case 2:
            self.fieldName = UITextField(frame: tFrame)
            self.fieldName.placeholder = "이름"
            self.fieldName.borderStyle = .none
            self.fieldName.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(fieldName)
        //switch 구문 특성상 default 블록을 누락할 수는 없으므로 마지막 위치에 추가해준다.
        default :
            ()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //셀의 높이를 일괄 설정 매개변수를 통해 설정하는게 아니라 return 값으로 해당 셀의 높이를 설정한다.
        return 40
    }
    @IBAction func submit(_ sender: Any) {
        if self.isCalling == true {
            self.alert("진행중이에요 잠시만요!")
            //submit 메소드를 종료하기 위한 return
            return
        } else {
            self.isCalling = true
        }
        //인디케이터 애니메이션 시작
        self.indicatorView.startAnimating()
        //JSON타입으로 서버와 통신 새로운 아이디를 보내는것이다.
        //이미지를 Base64 인코딩 처리
        let profile = self.profile.image!.pngData()?.base64EncodedString()
       // NSLog("\(profile) , profile Base64 인코딩 처리 ")
        //파라미터 타입으로 객체를 정의
        let param: Parameters = [
            "account" : self.fieldAccount.text!,
            "passwd" : self.fieldPassword.text!,
            "name" : self.fieldName.text!,
            "profile_image" : profile!
        ]
        //API호출
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/join"
        let call = AF.request(url, method: HTTPMethod.post, parameters: param, encoding: JSONEncoding.default)
        
        call.responseJSON { res in
            //인디케이터 뷰 에니메이션 종료
            self.indicatorView.stopAnimating()
            //JSON 형식으로 값이 있는지 확인
            guard let jsonObject = try! res.result.get() as? [String: Any] else {
                //서버수신에서 오류가 발생하였으므로 다시 버튼을 활성화 하기 위해 isCalling을 false 로 해준다.
                self.isCalling = false
                self.alert("서버 호출 과정에 오류 생성!")
                return
            }
            //응답코드 확인 Api 문서에 성공 했을때 0을 반환한다고 되있음
            //서버 호출 자체는 호출에 성공했다고 하더라도 중복된 계정이나 잘못된 값 입력 떄문에 서버 로직 처리단계에서 결과가 실패로 나올수 있다.
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                self.alert("가입이 완료되었습니다.") {
                    //언와인드 세그웨이 생성
                    //경고창을 눌렀을때 실행할 클로저 실행
                    self.performSegue(withIdentifier: "backProfileVC", sender: self)
                }
            } else {
                self.isCalling = false
                let erroMsg = jsonObject["error_msg"] as! String
                self.alert("오류는: \(erroMsg)")
            }
        }
    }
    @objc func tappedProfile(_ sender: Any) {
        //actionSheet
        let msg = "프로필 이미지를 읽어올 곳을 선택하세요."
        let sheet = UIAlertController(title: msg, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        sheet.addAction(UIAlertAction(title: "저장된 앨범", style: .default){(_) in
            self.selectLibrary(src: .savedPhotosAlbum)
        })
        sheet.addAction(UIAlertAction(title: "포토 라이브러리", style: .default) {(_) in
            self.selectLibrary(src: .photoLibrary)
        })
        sheet.addAction(UIAlertAction(title: "카메라", style: .default) {(_) in
            self.selectLibrary(src: .camera)
        })
        self.present(sheet, animated: false)
    }
    //전달된 소스 타입에 맞게 이미지 피커 창 열기
    func selectLibrary(src: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(src) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            
            self.present(picker, animated: false)
        } else {
            self.alert("사용할수 없는 타입")
        }
    }
    //사용자가 이미지 피커 컨트롤러에서 이미지를 선택했을때 실행될 델리게이트 메소드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let rawVal = UIImagePickerController.InfoKey.originalImage.rawValue // 이미지를 선택했을때 오리지날 이미지
        if let img = info[UIImagePickerController.InfoKey(rawValue: rawVal)] as? UIImage  {
            self.profile.image = img
        }
        self.dismiss(animated: true)
    }
}
