//
//  MemoDAO.swift
//  MyMemory
//
//  Created by 이병훈 on 2021/02/11.
//

import UIKit
import CoreData

class MemoDAO {
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    func fetch(keyword text: String? = nil) -> [MemoData] { //매개변수에 기본값을 넣어준 이유는 검색 키워드가 없을때도 호출하수 있게 하기 위해서이다.
        var memolist = [MemoData]()
        //1.요청 객체 생성
        let fetchRequest: NSFetchRequest<MemoMO> = MemoMO.fetchRequest()
        // 1-1 최신 글 순으로 정렬하도록 정렬 객체 생성
        let regdateDesc = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [regdateDesc]
        //NSPredicate
        if let t = text, t.isEmpty == false {
            fetchRequest.predicate = NSPredicate(format: "contents CONTAINS[c] %@", t)
        }
        
        do {
            let resultset = try self.context.fetch(fetchRequest)
            
            for record in resultset {
                let data = MemoData()
                
                data.title = record.title
                data.contents = record.contents
                data.regdate = record.regdate!
                data.objectID = record.objectID
                
                if let image = record.image as Data? {
                    //코어데이터의 image 데이터는 binary data이기 때문에 UIImage(data:)를 사용
                    data.image = UIImage(data: image)
                }
                memolist.append(data)
            }
        } catch let error as NSError {
                    NSLog("An error has ocuured: %s", error.localizedDescription)
                }
                return memolist
    }
    
    //새 메모를 저장하는 메소드
    func insert(_ data: MemoData) {
        let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO
        //MemoData로 부터 값을 복사한다.
        object.title = data.title
        object.contents = data.contents
        object.regdate = data.regdate
        
        if let image = data.image {
            object.image = image.pngData()! //? pngData
        }
        do {
            try self.context.save()
            //서버에 업로드 한다.
            let tk = TokenUtils()
            //getAuthoricationHeader 메소드는 인증 헤더를 구성하여 제공하는것이 본래 기능이지만, 로그아웃 상태일때 nil을 반환하므로 이값을 체크하여 로그인 여부를 쉽게 판단 할수 있다.!
            //로그인 되어있으면 서버에 업로드하고 그렇지않으면 save만한다.
            if tk.getAuthoricationHeader() != nil {
                DispatchQueue.global(qos: .background).async {
                    //서버에 데이터를 업로드
                    let sync = DataSync()
                    sync.uploadDatum(object)
                }
            }
        } catch let error as NSError {
            NSLog("An error has occured: %s", error.localizedDescription)
        }
        
    }
    //메모 내용 삭제
    func delete(_ objectID: NSManagedObjectID) -> Bool {
        let object = self.context.object(with: objectID) //해당 objectid의 context를 가져온다
        self.context.delete(object)
        
        do {
            try self.context.save()
            return true
        } catch let error as NSError {
            NSLog("An error has occured: %s", error.localizedDescription)
            return false
        }
    }
    
}
