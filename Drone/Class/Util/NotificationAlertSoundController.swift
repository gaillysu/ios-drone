import UIKit
import AVFoundation
import MediaPlayer

class NotificationAlertSoundController: NSObject, AVAudioPlayerDelegate {
    
    static let manager:NotificationAlertSoundController = NotificationAlertSoundController()
    
    fileprivate var audioPlayer:AVAudioPlayer?
    fileprivate var timer:Timer?
    fileprivate var previousVolume:Float?

    override init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            self.previousVolume = AVAudioSession.sharedInstance().outputVolume
        } catch let error as NSError{
            print("Couldn't play sound. Error: \(error.localizedDescription)")
            print("Couldn't play sound. Code : \(error.code)")
        }
    }
    
    func playSound(_ name:String? = "bell", type:String? = "wav") {
        if let path = Bundle.main.path(forResource: name, ofType:type) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                setVolume(volume: 1.0)
                audioPlayer?.play()
            } catch let error as NSError{
                print("Couldn't play sound. Error: \(error.localizedDescription)")
                print("Couldn't play sound. Code : \(error.code)")
            }
        }
    }
    
    func playSoundAfter(after:Float){
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(after), target: self, selector: #selector(playSound), userInfo: nil, repeats: false)
    }
    
    func cancelScheduledSounds(){
        if let timer = self.timer{
            timer.invalidate()
        }
        self.timer = nil
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        do {
            if let volume = self.previousVolume {
                setVolume(volume: volume)
            }
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Couldn't set inactive.")
        }
    }
    
    func setVolume(volume:Float){
        (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) ==
            "MPVolumeSlider"}.first as? UISlider)?.setValue(volume, animated: false)
    }
}
