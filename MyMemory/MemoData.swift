//
//  MemoData.swift
//  MyMemory
//
//  Created by 이병훈 on 2020/09/21.
//

import UIKit
import CoreData

class MemoData {
    var memoIdx : Int?
    var title :  String?
    var contents : String?
    var image : UIImage?
    var regdate : Date?
    //MemoMO 객체를 참조하기 위한 속성, 구분하기 위한것
    var objectID: NSManagedObjectID?
}
