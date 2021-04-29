//
//  CSLogButton.swift
//  MyMemory
//
//  Created by 이병훈 on 2020/11/29.
//

import UIKit
//외부에서도 참조할수 있게 public 접근제한자 사용
public enum CSLogType: Int {
    case basic //기본 로그타입
    case title //버튼의 타이틀을 출력
    case tag //버튼의 태그값을 출력
}
public class CSLogButton: UIButton {
    public var logType: CSLogType = .basic
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //버튼 스타일에 적용한다.
        self.setBackgroundImage(UIImage(named: "button-bg"), for: .normal)
        self.tintColor = .white
        
        self.addTarget(self, action: #selector(logging(_:)), for: .touchUpInside)
    }
    @objc func logging(_ sender: UIButton) {
        switch self.logType {
        case .basic:
            NSLog("버튼이 클릭되었습니다.")
        case .title:
            let btnTitle = sender.titleLabel?.text ?? "타이틀이 없는"
            NSLog("\(btnTitle) 버튼이 클릭 되었습니다.")
        case .tag:
            NSLog("\(sender.tag) 버튼이 클릭되었습니다.")
        }
    }
}

