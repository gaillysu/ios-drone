//
//  HotKeyTableViewCell
//  Drone
//
//  Created by Karl-John Chow on 8/5/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
import RxSwift

class HotKeyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var remoteCameraButton: HotKeyTableViewCellButton!
    @IBOutlet weak var findYourPhoneButton: HotKeyTableViewCellButton!
    @IBOutlet weak var controlMusicButton: HotKeyTableViewCellButton!
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var crosshairImageView: UIImageView!
    @IBOutlet weak var headphonesImageView: UIImageView!
    var all:[(button:HotKeyTableViewCellButton, imageView:UIImageView, faType:FAType)] = []
    
    var disposeBag = DisposeBag()
    var selectedFeature = Variable(HotKey.Feature.disabled)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        all = [(remoteCameraButton, cameraImageView, .FACamera),
               (findYourPhoneButton, crosshairImageView, .FACrosshairs),
               (controlMusicButton, headphonesImageView, .FAHeadphones)]
        
        findYourPhoneButton.rx.tap.subscribe({ _ in
            self.selectedFeature.value = HotKey.Feature.findYourPhone
        }).addDisposableTo(disposeBag)
        
        remoteCameraButton.rx.tap.subscribe({ _ in
            self.selectedFeature.value = HotKey.Feature.remoteCamera
        }).addDisposableTo(disposeBag)
        
        controlMusicButton.rx.tap.subscribe({ _ in
            self.selectedFeature.value = HotKey.Feature.controlMusic
        }).addDisposableTo(disposeBag)
        
        selectedFeature.asObservable().subscribe { feature in
            self.all.forEach({ model in
                model.button.selected(selected: false)
                model.imageView.setFAIconWithName(icon: model.faType, textColor: .getBaseColor())
            })
            switch (feature.element!){
            case .findYourPhone:
                self.findYourPhoneButton.selected(selected: true)
                self.crosshairImageView.setFAIconWithName(icon: .FACrosshairs, textColor: .white)
            case .remoteCamera:
                self.remoteCameraButton.selected(selected: true)
                self.cameraImageView.setFAIconWithName(icon: .FACamera, textColor: .white)
            case .controlMusic:
                self.controlMusicButton.selected(selected: true)
                self.headphonesImageView.setFAIconWithName(icon: .FAHeadphones, textColor: .white)
            default:
                break
            }
            }.addDisposableTo(disposeBag)
    }
}
