//
//  ProfileVC.swift
//  MyMemory
//
//  Created by 이병훈 on 2020/12/06.
//

import UIKit
import Alamofire
import LocalAuthentication

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    //API호출 상태값을 알려주는것, 호출 성공하면 true 실패하면 false를 한다.
    var isCalling = false
    let uinfo = UserInfoManager() //개인정보관리자 클래스의 인스턴스생성
    
    let profileImage = UIImageView() //프로필 사진이미지
    let tv = UITableView() // 프로필 목록
    //화면이 표시 될때마다 토큰 상태를 점검하고, 만료된 경우 터치 아이디 인증창을 실행해 줄것이다.
    override func viewWillAppear(_ animated: Bool) {
        //토큰 인증 여부 체크
        self.tokenValidate()
    }
    override func viewDidLoad() {
        self.navigationItem.title = "프로필"
        //뒤로 가기 버튼 처리
        let backBtn = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(close(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        //배경이미지 설정
        let bg = UIImage(named: "profile-bg")
        let bgImg = UIImageView(image: bg)
        
        bgImg.frame.size = CGSize(width: bgImg.frame.size.width, height: bgImg.frame.size.height)
        bgImg.center = CGPoint(x: self.view.frame.width / 2, y: 40)
        //둥글게
        bgImg.layer.cornerRadius = bgImg.frame.size.width / 2
        bgImg.layer.borderWidth = 0
        bgImg.layer.masksToBounds = true
        
        self.view.addSubview(bgImg)
        //배경과 프로필 이미지를 맨앞으로 가져가는 함수
        self.view.bringSubviewToFront(self.tv)
        self.view.bringSubviewToFront(self.profileImage)
        //프로필에 들어갈 이미지
        let image = self.uinfo.profile
        //프로필 이미지 처리
        self.profileImage.image = image
        self.profileImage.frame.size = CGSize(width: 100, height: 100)
        self.profileImage.center = CGPoint(x: self.view.frame.width / 2, y: 270)
        //프로필 이미지 둥글게 처리하기
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true
        
        //루트뷰에 프로필 이미지 추가
        self.view.addSubview(self.profileImage)
        
        //테이블 뷰 생성
        self.tv.frame = CGRect(x: 0, y: self.profileImage.frame.origin.y + self.profileImage.frame.size.height + 20, width: self.view.frame.width, height: 100)
        self.tv.dataSource = self
        self.tv.delegate = self
        
        self.view.addSubview(self.tv)
        //네비게이션 바 숨기기
        self.navigationController?.navigationBar.isHidden = true
        // 최초 화면 로딩시 로그인상태에 따라 버튼을 출력하게 하기위해
        self.drawBtn()
        //프로필 이미지 뷰 객체에 탭 제스처를 등록
        let tap = UITapGestureRecognizer(target: self, action: #selector(profile(_:)))
        self.profileImage.addGestureRecognizer(tap)
        self.profileImage.isUserInteractionEnabled = true // 사용자와 해당객체의 상호반응을 허락해주는 역할
        self.view.bringSubviewToFront(indicatorView)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "이름"
            cell.detailTextLabel?.text = self.uinfo.name ?? "Login please"
        case 1:
            cell.textLabel?.text = "계정"
            cell.detailTextLabel?.text = self.uinfo.account ?? "Login please"
        default :
            ()
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.uinfo.isLogin == false {
            // 로그인이 되어있지 않다면 로그인창을 띄어준다.
            self.doLogin(self.tv)
        }
    }
    @objc func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    // 로그인 창을 표시할 메소드 doLogin(_:) 추가
    @objc func doLogin(_ sender: Any) {
        if self.isCalling == true {
            self.alert("응답을 기다리는중, \n 잠시만 기다려주세요.")
            return
        } else {
            self.isCalling = true
        }
        let loginAlert = UIAlertController(title: "LOGIN", message: nil, preferredStyle: .alert)
        
        //알림창에 들어갈 입력폼 추가
        loginAlert.addTextField() { (tf) in
            tf.placeholder = "Your Account"
        }
        loginAlert.addTextField() { (tf) in
            tf.placeholder = "password"
            tf.isSecureTextEntry = true //입력했을때 *을 나오게
        }
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            //취소 버튼 액션을 눌렀을때 isCalling 변수를 false로 변경해 주어야한다.
            self.isCalling = false
        })
        loginAlert.addAction(UIAlertAction(title: "Login", style: .destructive) { (_) in
            //인디케이터 나타내기
            self.indicatorView.startAnimating()
            
            let account = loginAlert.textFields?[0].text ?? ""
            let passwd = loginAlert.textFields?[1].text ?? ""
            //로그인 쪽을 서버 api 연결로 인한 코드 수정
//            if(self.uinfo.login(account: account, passwd: passwd)) {
//                //로그인 성공시 처리할 메소드 내용
//                self.tv.reloadData() //테이블 뷰를 갱신
//                self.profileImage.image = self.uinfo.profile
//                self.drawBtn()
//            } else{
//                let alert = UIAlertController(title: nil, message: "로그인에 실패하였습니다.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
//                self.present(alert, animated: false)
//            }
            //비동기 방식
            self.uinfo.login(account: account, passwd: passwd, success: {
                self.indicatorView.stopAnimating()
                self.isCalling = false
                self.tv.reloadData() //테이블 뷰 갱신
                self.profileImage.image = self.uinfo.profile
                self.drawBtn()
                
                //서버와 데이터 동기화
                let sync = DataSync()
                DispatchQueue.global(qos: .background).async {
                    sync.downloadBackupData() // 서버에 저장된 데이터가 있으면 내려받는다.
                }
                //로그인시 데이터 업로드가 실행되도록 설정
                DispatchQueue.global(qos: .background).async {
                    sync.uploadData() //서버에 저장해야할 업로드가 있으면 업로드한다.
                }
                //서버의 백업 데이터 다운로드가 끝나기를 기다리지 않고 동시에 위의 DispatchQueue.gloabal로 데이터를 내려받는 동시에 서버에 업로드하는 프로세스도 수행 한다.
            }, fail: { msg in
                self.indicatorView.stopAnimating()
                self.isCalling = false
                self.alert(msg)
            })
        })
        self.present(loginAlert, animated: false)
    }
    //로그아웃 창을 표시할 메소드 정의
    @objc func doLogout(_ sender: Any) {
        let msg = "로그아웃 하시겠습니까?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive) { (_) in
//            if self.uinfo.logout() {//로그아웃 성공시
//                self.tv.reloadData()
//                self.profileImage.image = self.uinfo.profile
//                self.drawBtn()
//            }
            self.indicatorView.startAnimating()
            //API를 통한 로그아웃 방법 변경
            self.uinfo.logout() {
                //로그아웃 실행이 완료되면 실행되는 클로저
                self.indicatorView.stopAnimating()
                self.tv.reloadData()
                self.profileImage.image = self.uinfo.profile
                self.drawBtn()
            }
        })
        self.present(alert, animated: false)
    }
    //로그인/ 로그아아웃 버튼을 만줄어줄 메소드
    func drawBtn() {
        //버튼을 감쌀 뷰 정의
        let v = UIView()
        v.frame.size.width = self.view.frame.width
        v.frame.size.height = 40
        v.frame.origin.x = 0
        v.frame.origin.y = self.tv.frame.origin.y + self.tv.frame.height
        v.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        
        self.view.addSubview(v)
        //버튼을 정의
        let btn = UIButton(type: .system)
        btn.frame.size.width = 100
        btn.frame.size.height = 30
        btn.center.x = v.frame.size.width / 2
        btn.center.y = v.frame.size.height / 2
        
        //로그인 상태일때 로그아웃 버튼을 로그아웃 상태일때 로그인 상태로
        if self.uinfo.isLogin == true {
            btn.setTitle("로그아웃", for: .normal)
            btn.addTarget(self, action: #selector(doLogout(_:)), for: .touchUpInside)
        } else {
            btn.setTitle("로그인", for: .normal)
            btn.addTarget(self, action: #selector(doLogin(_:)), for: .touchUpInside)
        }
        v.addSubview(btn)
    }
    //이미지 피커 컨트롤러를 실행할 커스텀 메소드 정의
    func imgPicker( _ source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true)
    }
    //프로필 사진의 소스타입을 선택하는 액션 메소드
    @objc func profile(_ sender: UIButton) {
        //로그인 되어있지 않을 경우 로그인 창을 띄어준다.
        guard self.uinfo.account != nil  else {
            self.doLogin(self)
            return
        }
        let alert = UIAlertController(title: nil, message: "사진을 가져올곳을 선택!", preferredStyle: .actionSheet)
        
        //카메라를 사용할수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "카메라", style: .default) { (_) in
                self.imgPicker(.camera)
            })
        }
        //저장된 앨범을 사용할수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            alert.addAction(UIAlertAction(title: "저장된 앨범", style: .default) { (_) in
                self.imgPicker(.savedPhotosAlbum)
            })
        }
        //포토라이브러리를 사용할수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "포토 라이브러리", style: .default) { (_) in
                self.imgPicker(.photoLibrary)
            })
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    //이미지를 선택하면 이 메소드가 자동으로 호출
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.indicatorView.startAnimating()
        
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.uinfo.newProfile(img, success: {
                self.indicatorView.stopAnimating()
                self.profileImage.image = img
            }, fail: { msg in
                self.indicatorView.stopAnimating()
                self.alert(msg)
            })
//            self.uinfo.profile = img
//            self.profileImage.image = img
        }
        picker.dismiss(animated: true)
    }
    @IBAction func backProfileVC(_ segue: UIStoryboardSegue) {
        //프로필 와면으로 되돌아 오는 세그웨이를 생성하기위해 단지 표식만 하는 역할을 한다.
    }
}

extension ProfileVC {
    //토큰 인증 메서드
    func tokenValidate() {
        //0. 응답 캐시를 사용하지 않도록
        URLCache.shared.removeAllCachedResponses()
        //1. 키 체인에 액세스 토큰이 없을 경우 유효성 검증을 진행하지 않음
        let tk = TokenUtils()
        guard let header = tk.getAuthoricationHeader() else {
            return
        }
        
        self.indicatorView.startAnimating()
        
        //tokenValidate API 호출
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/tokenValidate"
        let validate = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        
        validate.responseJSON() { res in
            self.indicatorView.stopAnimating()
            
            let responseBody = try! res.result.get()
            print(responseBody) //응답 결과를 확인 하기위해
            guard let jsonObject = responseBody as? NSDictionary  else {
                self.alert("잘못된 응답!")
                return
            }
            //3. 응답 결과 처리
            let resultCode = jsonObject["result_code"] as! Int
            
            if resultCode != 0 { // 토큰이 만료했을때
                self.touchID()
            }
        }
    }
    //터치아이디 인증 메서드
    func touchID() {
        //1. LAContext 인스턴스, 인증컨텍스트
        let context = LAContext()
        
        //2. 로컬 인증에 사용할 변수 정의
        var error: NSError?
        let msg = "인증이 필요해...ㅠ"
        let deviceAuth = LAPolicy.deviceOwnerAuthenticationWithBiometrics
        
        //3. 로컬 인증이 사용가능하지 여부 확인
        if context.canEvaluatePolicy(deviceAuth, error: &error) {
            //4. 터치 아이디 인증 실행창
            context.evaluatePolicy(deviceAuth, localizedReason: msg) { (succss, e) in
                if succss { //5. 인증 성공이면
                    //5-1 토큰 갱신 로직 실행
                    self.refresh()
                } else { //6. 인증 실패시
                    //인증 실패 원인에 대한 대응 로직
                    //에러 추력
                    print((e?.localizedDescription)!)
                    
                    switch e!._code {
                    case LAError.systemCancel.rawValue:
                        self.alert("시스템이 의해 인증이 취소되었습니다.")
                    case LAError.userCancel.rawValue:
                        self.alert("사용자에 의해 인증이 취소되었습니다.") {
                            //아예 로그아웃 처리
                            self.commonLogout(true)
                        }
                        //userFallback은 사용자가 로컬 인증 대신 암호를 입력하여 로그인하기 위해 선택한 취소이다.
                    case LAError.userFallback.rawValue:
                        OperationQueue.main.addOperation {
                            self.commonLogout(true)
                        }
                    default:
                        OperationQueue.main.addOperation {
                            self.commonLogout(true)
                        }
                    }
                }
            }
        } else { //7. 인증창이 실행되지 못했을때
            //인증창 실행 불가 원인에 대한 로직 대표적으로 로그인 창으로 돌려준다.
            print(error!.localizedDescription)
            
            switch error!.code {
            case LAError.biometryNotEnrolled.rawValue:
                print("터치 아이디가 등록 되지 않았습니다.")
            case LAError.passcodeNotSet.rawValue:
                print("패스 코드가 설정되어 있지 않습니다.")
            default:
                print("터치 아이디를 사용할수 없습니다.")
            }
            OperationQueue.main.addOperation {
                self.commonLogout(true)
            }
            
        }
        
    }
    //토큰 갱신 메서드
    func refresh() {
        self.indicatorView.startAnimating()
        
        //1.인증 헤더
        let tk = TokenUtils()
        let header = tk.getAuthoricationHeader()
        
        //2. 리프레시 토큰 전달 준비
        let refreshToken = tk.load("kr.co.rubypaper.MyMemory", account: "refreshToken")
        let param: Parameters = ["refresh_token": refreshToken!]
        
        //3. 호출 및 응답
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAcoount/refresh"
        let refresh = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        
        refresh.responseJSON() { res in
            self.indicatorView.stopAnimating()
            
            guard let jsonObject = try! res.result.get() as? NSDictionary else {
                self.alert("잘못된 응답!")
                return
            }
            
            //4. 응답 결과 처리
            let resultCode = jsonObject["result_code"] as! Int
            
            if resultCode == 0 { //액세스 토큰 갱신에 성공 했으면
                let accessToken = jsonObject["access_token"] as! String
                tk.save("kr.co.rubypaper.MyMemory", account: "accessToken", value: accessToken)
            } else { //실패시
                self.alert("인증이 만료되어 다시 로그인 해주세용")
                //로그아웃처리
                OperationQueue.main.addOperation {
                    self.commonLogout(true)
                }
            }
        }
    }
    //인증이 아예 실패시 로그아웃을 하고 로그인 창을 띄우기 위한 메소드
    func commonLogout(_ isLogin: Bool = false) {
        //1. 저장된 개인정보 & 키 체인 데이터 삭제하고 로그아웃 상태로 전환
        let userInfo = UserInfoManager()
        userInfo.deviceLogout()
        
        //프로필 화면의 ui 갱신
        self.tv.reloadData()
        self.profileImage.image = userInfo.profile
        self.drawBtn()
        
        //기본 로그인 창 실행 여보
        if isLogin {
            self.doLogin(self)
        }
    }
}
