//
//  ViewController.swift
//  F_Timer
//
//  Created by chulyeon kim on 2023/03/07.
//

import UIKit
import AudioToolbox

enum TimerStatus {
	case start
	case pause
	case end
}

class ViewController: UIViewController {
	@IBOutlet weak var timerLabel: UILabel!
	@IBOutlet weak var progressView: UIProgressView!
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var toggleButton: UIButton!
	@IBOutlet weak var imgView: UIImageView!
	
	var duration = 60
	var timerStatus: TimerStatus = .end
	var timer: DispatchSourceTimer?
	var currentSeconds = 0


	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureToggleButton()
	}


	// isHidden이 true면 시간 라벨과 진행바 숨기고 datePicker 보이기
	func setTimerInfoViewVisible(isHidden: Bool) {
		self.timerLabel.isHidden = isHidden
		self.progressView.isHidden = isHidden
		self.datePicker.isHidden = !isHidden
	}
	// 시작 | 일시정지 버튼 상태에 따라 타이틀 변경
	func configureToggleButton() {
		self.toggleButton.setTitle("시작", for: .normal)
		self.toggleButton.setTitle("일시정지", for: .selected)
	}
	// 타이머
	func startTimer() {
		if self.timer == nil {
			self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
			self.timer?.schedule(deadline: .now(), repeating: 1)
			self.timer?.setEventHandler(handler: { [weak self] in
				guard let self = self else { return } // 강한 참조로 설정
				self.currentSeconds -= 1
				let hour = self.currentSeconds / 3600
				let minutes = (self.currentSeconds % 3600) / 60
				let seconds = (self.currentSeconds % 3600) % 60
				
				self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)
				self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
				
				UIView.animate(withDuration: 0.5, delay: 0, animations: {
					self.imgView.transform = CGAffineTransform(rotationAngle: .pi)
				})
				UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
					self.imgView.transform = CGAffineTransform(rotationAngle: .pi * 2)
				})
				

				if self.currentSeconds <= 0 {
					self.stopTimer()
					AudioServicesPlaySystemSound(1005)
				}
			})
			
			self.timer?.resume()
		}
	}
	// 타이머 취소
	func stopTimer() {
		// ✅ suspend된 timer에 nil을 넣으면 런타임에러 발생 (일시정지시키고 취소버튼 눌렀을 경우)
		if self.timerStatus == .pause {
			self.timer?.resume()
		}
		self.timerStatus = .end
		self.cancelButton.isEnabled = false
		self.toggleButton.isSelected = false
		//self.setTimerInfoViewVisible(isHidden: true)
		UIView.animate(withDuration: 0.2, animations: {
			self.timerLabel.alpha = 0
			self.progressView.alpha = 0
			self.datePicker.alpha = 1
			self.imgView.transform = .identity
		})
		self.timer?.cancel()
		self.timer = nil // 메모리에서 해제
	}


	// 취소 버튼
	@IBAction func tapCancelButton(_ sender: UIButton) {
		switch self.timerStatus {
			// 취소
		case .start, .pause:
//			self.timerStatus = .end
//			self.cancelButton.isEnabled = false
//			self.toggleButton.isSelected = false
//			self.setTimerInfoViewVisible(isHidden: true)
			self.stopTimer()
		default:
			break
		}
	}
	// 시작 | 일시정지 버튼
	@IBAction func tapToggleButton(_ sender: UIButton) {
		// datePicker에서 설정한 값으로 self.duration 값 설정
		self.duration = Int(self.datePicker.countDownDuration)

		switch self.timerStatus {
		case .start: // 시작 중일 때
			self.timerStatus = .pause
			self.toggleButton.isSelected = false
			self.timer?.suspend() // ⛔️ suspend된 timer에 nil을 넣으면 런타임에러 발생 (일시정지시키고 취소버튼 눌렀을 경우)
			self.imgView.transform = .identity
		case .end: // 취소상태 일 때
			self.timerStatus = .start
			//self.setTimerInfoViewVisible(isHidden: false)
			UIView.animate(withDuration: 0.2, animations: {
				self.timerLabel.alpha = 1
				self.progressView.alpha = 1
				self.datePicker.alpha = 0
			})
			self.toggleButton.isSelected = true
			self.cancelButton.isEnabled = true
			self.currentSeconds = self.duration
			self.startTimer()
		case .pause: // 일시정지 중일 때
			self.timerStatus = .start
			self.toggleButton.isSelected = true
			self.timer?.resume()
		}
	}
}

