//
//  Utils.swift
//  MyMemory
//
//  Created by 이병훈 on 2021/01/03.
//

import UIKit
import Security
import Alamofire

//키체인을 쉽게 다룰수 있도록 래핑된 클래스를 사용
class TokenUtils {
    //키체인에 값을 저장하는 메소드
    func save(_ service: String, account: String, value: String) {
        let keyChainQuery: NSDictionary = [
            kSecClass : kSecClassGenericPassword, //kSecClass 아이템 클래스를 지정하는 항목, 일반비밀번호를 저장
            kSecAttrService : service, //kSecAttrService 서비서 아이디, 앱을 식별할 때 사용한다.
            kSecAttrAccount : account, //사용자 계정을 지정하는 방식으로 여러개의ㅣ 아이디를 지정할때 사용한다.
            kSecValueData : value.data(using: .utf8, allowLossyConversion: false)! //실제로 저장할 값
        ]
        //현재 저장되어있는 값 삭제
        SecItemDelete(keyChainQuery)
        
        //새로운 키 체인 아이템 등록
        let status: OSStatus = SecItemAdd(keyChainQuery, nil)
        assert(status == noErr, "토큰 저장에 실패 했습니다")
        NSLog("status = \(status)")
    }
    //읽어오기 db에서 select
    func load(_ service: String, account: String) -> String? {
        //키체인 쿼리
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService : service,
            kSecAttrAccount : account,
            kSecReturnData : kCFBooleanTrue!, //데이터타입을 결정하는 부분으로, 값으로 설정된 kCFBooleanTrue는 저장된 값을 CFData 형식으로 읽어오도록 지시
            kSecMatchLimit : kSecMatchLimitOne //중복이 나왔을때 하나를 고른다.
        ]
        //값을 읽어온다
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(keyChainQuery, &dataTypeRef)
        
        //처리 결과가 성공이면 Data 타입으로 반환후 String 타입 반환
        if status == errSecSuccess {
            let retrievedData = dataTypeRef as! Data
            let value = String(data: retrievedData, encoding: String.Encoding.utf8)
            return value
        } else {
            print("\(status)")
            return nil
        }
    }
    //삭제하기
    func delete(_ service: String, account: String) {
        let keyChainQuery: NSDictionary = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : service,
            kSecAttrAccount : account
        ]
        // 현재 저장되어 있는 값 삭제
        let status = SecItemDelete(keyChainQuery)
        assert(status == noErr, "토큰값 삭제에 실패")
        NSLog("status=\(status)")
    }
    //키 체인에 저장된 액세스 토큰을 이용하여 헤더를 만들어주는 메소드
    func getAuthoricationHeader() -> HTTPHeaders? {
        let serviceID = "kr.co.rubypaper.MyMemory"
        if let accessToken = self.load(serviceID, account: "accessToken") {
            return [ "Authorization" : "Bearer \(accessToken)"] as HTTPHeaders
        } else {
            return nil
        }
    }
}

extension UIViewController {
    var tutorialSB: UIStoryboard {
        return UIStoryboard(name: "Tutorial", bundle: Bundle.main) //스토리보드를 불러오기위한 프로퍼티
    }
    func instanceTutorialVC(name: String) -> UIViewController? {
        return self.tutorialSB.instantiateViewController(withIdentifier: name) //뷰컨트롤러의 인스턴스를 생성
    }
    func alert(_ message: String, competion:(()->Void)? = nil) {//completion은 만약 ok눌렀을때 클로저 실행
        //메인 스레드에서 실행, 혹시라도 해당 메소드가 서브 스레드에 호출될 경우를 대비하기 위함이다.
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "확인", style: .default){ (_) in
                competion?()
            }
            alert.addAction(okAction)
            self.present(alert, animated: false)
        }
    }
}
