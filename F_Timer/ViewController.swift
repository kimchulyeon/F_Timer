//
//  ViewController.swift
//  F_Timer
//
//  Created by chulyeon kim on 2023/03/07.
//

import UIKit

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
	
	var duration = 60
	var timerStatus: TimerStatus = .end


	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.configureToggleButton()
	}
	
	
	/// 피커가 사라지고 타이머 라벨이 보이게
	func setTimerInfoViewVisible(isHidden: Bool) {
		self.timerLabel.isHidden = isHidden
		self.progressView.isHidden = isHidden
	}
	func configureToggleButton() {
		self.toggleButton.setTitle("시작", for: .normal)
		self.toggleButton.setTitle("일시정지", for: .selected)
	}


	@IBAction func tapCancelButton(_ sender: UIButton) {
		switch self.timerStatus {
		case .start, .pause:
			self.timerStatus = .end
			self.cancelButton.isEnabled = false
			self.setTimerInfoViewVisible(isHidden: true)
			self.datePicker.isHidden = false
		default:
			break
		}
		
		self.setTimerInfoViewVisible(isHidden: true)
		self.cancelButton.isEnabled = false
		self.datePicker.isHidden = false
		self.toggleButton.isSelected = false
		self.timerStatus = .end
	}
	@IBAction func tapToggleButton(_ sender: UIButton) {
		// datePicker에서 설정한 값으로 self.duration 값 설정
		self.duration = Int(self.datePicker.countDownDuration)
		
		switch timerStatus {
		case .start:
			self.timerStatus = .pause
			self.toggleButton.isSelected = false
		case .end:
			self.timerStatus = .start
			self.datePicker.isHidden = true
			self.setTimerInfoViewVisible(isHidden: false)
			self.toggleButton.isSelected = true
			self.cancelButton.isEnabled = true
		case .pause:
			self.timerStatus = .start
			self.toggleButton.isSelected = true
		}
	}
}

