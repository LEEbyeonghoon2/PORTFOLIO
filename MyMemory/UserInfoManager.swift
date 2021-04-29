//
//  UserInfoManager.swift
//  MyMemory
//
//  Created by 이병훈 on 2020/12/23.
//

import UIKit
//로그인 API 구현을 위한 임포트
import Alamofire

struct UserInfoKey {
    //저장에 사용될 키를 구조화
    static let loginId = "LOGINID"
    static let account = "ACCOUNT"
    static let name = "NAME"
    static let profile = "PROFILE"
    static let tutorial = "TUTORIAL"
}
//계정 및 사용자 정보를 저장하고 관리하는 클래스
class UserInfoManager {
    //loginID 정의
    var loginId: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserInfoKey.loginId)
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.loginId)
            ud.synchronize()
        }
    }
    var account: String? { //비로그인 상태에는 nil값을 받기 때문에 옵셔널로 설정
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.account)
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.account)
            ud.synchronize()
        }
    }
    var name: String? {
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.name)
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.name)
            ud.synchronize()
        }
    }
    var profile: UIImage? {
        get{
            let ud = UserDefaults.standard
            if let _profile = ud.data(forKey: UserInfoKey.profile) { //프로퍼티 리스트에 저장할수 없어 data타입으로 변환한 다음 저장
                return UIImage(data: _profile) //UIImage(data:)는 data타입을 손쉽게 uiimage 타입으로 변환 가능
            } else {
                return UIImage(named: "account.jpg") //이미지가 없다면 기본 이미지로
            }
        }
        set(v) {
            if v != nil {
                let ud = UserDefaults.standard
                ud.set(v!.pngData(), forKey: UserInfoKey.profile) //pngData 메소드는 UIImage 타입의 객체를 데이터 유실 없이 data 타입으로 변환 가능
                ud.synchronize()
            }
        }
    }
    //로그인 상태를 판별해주는 연산 프로퍼티 isLogin을 정의
    var isLogin: Bool {
        if self.loginId == 0 || self.account == nil {
            return false
        } else {
            return true
        }
    }
//    func login(account: String, passwd: String) -> Bool {
//        //이부분은 나중에 서버와 연동되는 코드로 대체될 예정
//        if account.isEqual("sqlpro@naver.com") && passwd.isEqual("1234") {
//            let ud = UserDefaults.standard
//            ud.set(100, forKey: UserInfoKey.loginId)
//            ud.set(account, forKey: UserInfoKey.account)
//            ud.set("재은 씨", forKey: UserInfoKey.name)
//            ud.synchronize()
//            return true
//        } else {
//            return false
//        }
//    }
    //success와 fail 매개변수를 옵셔널 타입으로 추가하고 필요없을때는 사용하지않게 초기값을 nil로 부여한다.
    //실패를 했을때는 실패사유를 확인해야 하기 때문에 String을 입력받는다, 즉 입력받은 인자값을 실패한 원인에 대한 메시지를 출력하는데 사용된다.
    //비동기식 처리방법
    func login(account: String, passwd: String, success: (() -> Void)? = nil, fail: ((String) -> Void)? = nil) {
        //전송할 url
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/login"
        let param: Parameters = [
            "account" : account,
            "passwd" : passwd
        ]
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
        
        call.responseJSON() { res in
            let result = try! res.result.get()
            NSLog("result:\(result), res:\(res)")
            guard let jsonObject = result as? NSDictionary else {
                NSLog("잘못된 응답 형식이다. \(result)")
                return
            }
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                //json 객체의 user_info 항목에서 사용자 정보를 추출하여 UserInfoManager 객체의 멤버 변수에 대입
                let user = jsonObject["user_info"] as! NSDictionary
                
                self.loginId = user["user_id"] as! Int
                self.account = user["account"] as? String
                self.name = user["name"] as? String
                
                if let path = user["profile_path"] as? String {
                    if let imageData = try? Data(contentsOf: URL(string: path)!) {
                        self.profile = UIImage(data: imageData)
                    }
                }
                //토큰 정보 추출
                let accessToken = jsonObject["access_token"] as! String //액세스 토큰
                let refreshToken = jsonObject["refresh_token"] as! String // 리프레시 토큰
                //토큰 정보 저장
                let tk = TokenUtils()
                tk.save("kr.co.rubypaper.MyMemory", account: "accessToken", value: accessToken) //이부분 조심 토큰 계정 오타 안나게
                tk.save("kr.co.rubypaper.MyMemory", account: "refreshToken", value: refreshToken)
                success?()
            } else {
                let msg = (jsonObject["error_msg"] as? String) ?? "로그인 실패했습니다."
                fail?(msg)
            }
        }
        
    }
//    func logout() -> Bool {
//        let ud = UserDefaults.standard
//        ud.removeObject(forKey: UserInfoKey.loginId)
//        ud.removeObject(forKey: UserInfoKey.account)
//        ud.removeObject(forKey: UserInfoKey.name)
//        ud.removeObject(forKey: UserInfoKey.profile)
//        ud.synchronize()
//        return true
//    }
    func logout(completion: (()->Void)? = nil) {
        //호출 url
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/logout"
        //인증 헤더 구현
        let tokenUtils = TokenUtils()
        let header = tokenUtils.getAuthoricationHeader()
        //API 호출 및 응답처리
        let call = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        
        call.responseJSON() { _ in
            //기존 저장소에 저장된 값을 모두 삭제
            self.deviceLogout()
            
            //전달받은 완료 클로저 실행
            completion?()
        }
    }
    func deviceLogout() {
        //기본 저장소에 저장된 값을 모두 삭제
        let ud = UserDefaults.standard
        ud.removeObject(forKey: UserInfoKey.loginId)
        ud.removeObject(forKey: UserInfoKey.account)
        ud.removeObject(forKey: UserInfoKey.name)
        ud.removeObject(forKey: UserInfoKey.profile)
        ud.synchronize() //동기화
        //키체인 삭제
        let tokenUtils = TokenUtils()
        
        tokenUtils.delete("kr.co.rubypaper.MyMemory", account: "refreshToken")
        tokenUtils.delete("kr.co.rubypaper.MyMemory", account: "accessToken")
    }
    //이미지 바뀔때마다 서버에다가 이미지 업로드
    func newProfile(_ profile: UIImage?, success: (()->Void)? = nil, fail: ((String)->Void)? = nil) {
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/profile"
        
        //인증 헤더
        let tk = TokenUtils()
        let header = tk.getAuthoricationHeader()
        
        //전송할 프로픨 이미지
        let profileData = profile!.pngData()?.base64EncodedString()
        let param: Parameters = [ "profile_image" : profileData! ]
        //이미지 전송
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        
        call.responseJSON() { res in
            guard let jsonObject = try! res.result.get() as? NSDictionary else {
                fail?("올바른 응답이 아니야")
                return
            }
            //응답 코드 확인
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                self.profile = profile
                success?()
            } else {
                let msg = (jsonObject["error_msg"] as? String) ?? "프로필 이미지 변경 실패"
                fail?(msg)
            }
        }
    }
}
