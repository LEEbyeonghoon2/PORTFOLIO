//
//  TutorialMasterVC.swift
//  MyMemory
//
//  Created by 이병훈 on 2021/01/03.
//

import UIKit

class TutorialMasterVC: UIViewController, UIPageViewControllerDataSource {
    //페이지 뷰컨트롤러의 인스턴스를 참조할 멤버 변수를 선언
    var pageVC: UIPageViewController!
    @IBAction func close(_ sender: Any) {
        let ud = UserDefaults.standard
        ud.set(true, forKey: UserInfoKey.tutorial)
        ud.synchronize()
        
        self.presentingViewController?.dismiss(animated: true)
    }
    
    //콘텐츠 뷰 컨트롤러에 들어갈 타이틀과 이미지
    var contentTitles = ["STEP 1", "STEP 2", "STEP 3", "STEP 4"]
    var contentImages = ["Page0", "Page1", "Page2", "Page3"]
    //컨텐츠 뷰컨트롤러를 동적으로 생성할 메소드 정의
    func getContentVC(atIndex idx: Int) -> UIViewController? {
        //인덱스값이 배열길이 범위 내에 있을 경우에만 뷰컨트롤러 인스턴스를 생성하는 guard 구문
        guard self.contentTitles.count >= idx && self.contentTitles.count > 0 else {
            return nil
        }
        //인스턴스 생성 & TutorialContentsVC로 캐스팅
        guard let cvc = self.instanceTutorialVC(name: "ContentsVC") as? TutorialContentsVC else {
            return nil
        }
        //콘텐츠 뷰 컨트롤러 내용구성
        cvc.titleText = self.contentTitles[idx]
        cvc.imageFile = self.contentImages[idx]
        cvc.pageIndex = idx
        
        return cvc
    }
    //현재의 콘텐츠 뷰컨트롤러 보다 앞쪽에 올 콘텐츠 뷰컨트롤러 객체, 즉 앞으로 스와이프 할때 보여줄 콘텐츠 뷰 컨트롤러
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //현재의 페이지 인덱스
        guard var index = (viewController as! TutorialContentsVC).pageIndex else {
            return nil
        }
        //현재의 인덱스가 맨앞이라면 nil을 반환
        guard index > 0 else {
            return nil
        }
        index -= 1
        return self.getContentVC(atIndex: index)
    
    }
    //현재의 콘텐츠 뷰컨트롤러 보다 뒤쪽에 올 콘텐츠 뷰컨트롤러 객체 즉 뒤로 스와이프 할때 보여줄 콘텐츠 뷰컨트롤러
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //현재의 인덱스 페이지
        guard var index = (viewController as! TutorialContentsVC).pageIndex else {
            return nil
        }
        index += 1
        //index가 배열데이터의 크기보다 크면 nil을 반환
        guard index < self.contentTitles.count else {
            return nil
        }
        return self.getContentVC(atIndex: index)
    }
    override func viewDidLoad() {
        //페이지 뷰컨틀롤러 객체 생성
        self.pageVC = self.instanceTutorialVC(name: "PageVC") as? UIPageViewController
        self.pageVC.dataSource = self
        //페이지 뷰컨트롤러 기본페이지 지정
        let startContentVC = self.getContentVC(atIndex: 0)!
        self.pageVC.setViewControllers([startContentVC], direction: .forward, animated: true)
        //페이지 뷰컨트롤러의 출력 영역 지정
        self.pageVC.view.frame.origin = CGPoint(x: 0, y: 0)
        self.pageVC.view.frame.size.width = self.view.frame.width
        self.pageVC.view.frame.size.height = self.view.frame.height - 50
        //페이지 뷰컨트롤러를 마스터 뷰컨트롤러의 자식 뷰컨트롤러로 설정, 공식처럼 외워라
        self.addChild(self.pageVC) // 페이지 뷰컨트롤러를 자식으로 등록하고
        self.view.addSubview(self.pageVC.view) //페이지 뷰 컨트롤러의 뷰들을 서브뷰로 등록하고
        self.pageVC.didMove(toParent: self) //자식 뷰컨트롤러에게 뷰컨트롤러가 바뀌었음을 알려주는것
    }
    //페이지 인디케이터를 위한 메소드
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.contentTitles.count
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0 //첫번째 페이지의 인덱스 
    }
}
