//
//  PPParticleButton.swift
//  PPParticleButtonExample
//
//  Created by HikaruSato on 2015/11/29.
//  Copyright © 2015年 HikaruSato. All rights reserved.
//

import UIKit
import SpriteKit
import QuartzCore

enum PPParticleButtonEffectType {
	case normal
	case selected
	case unSelected
}

class PPParticleButton: UIButton {
	//var particleFileName:String = "starParticle"
	var particleFileNameMap:[PPParticleButtonEffectType:String] = [PPParticleButtonEffectType:String]()
	var effectParticleDuration:TimeInterval = 0.5

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		createSubViews()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		createSubViews()
	}
	
	func createSubViews() {
		addTarget(self, action: #selector(PPParticleButton.effectParticle(_:)), for: UIControlEvents.touchUpInside)
	}
	
	func effectParticle(_ button:UIButton) {
		guard let particleFileName = self.getParticleFileName() else {
			//Nothing particle effect
			return
		}
		let skView = SKView(frame:CGRect(
			origin:CGPoint(x: -self.frame.origin.x, y: -self.frame.origin.y),
			size: self.superview!.frame.size))
		skView.backgroundColor = UIColor.clear
		skView.allowsTransparency = true
		self.addSubview(skView)
		let scene = SKScene(size: self.superview!.frame.size)
		scene.scaleMode = SKSceneScaleMode.aspectFill
		scene.backgroundColor = UIColor.clear
		let particle:SKEmitterNode = NSKeyedUnarchiver.unarchiveObject(withFile: Bundle.main.path(forResource: particleFileName, ofType: "sks")!) as! SKEmitterNode
		particle.position = CGPoint(x: self.center.x, y: skView.frame.size.height - self.center.y)
		skView.presentScene(scene)
		let effect = SKAction.speed(to: 0.1, duration: self.effectParticleDuration)
		let actionBlock = SKAction.run { () -> Void in
			particle.particleBirthRate = 0;
		}
		let fadeOut = SKAction()
		fadeOut.duration = 1
		let remove = SKAction.removeFromParent()
		let sequence = SKAction.sequence([effect, actionBlock, fadeOut, remove])
		particle.run(sequence)
		skView.scene!.addChild(particle)
		let delay = (effect.duration + fadeOut.duration) * Double(NSEC_PER_SEC)
		let time  = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
		DispatchQueue.main.asyncAfter(deadline: time, execute: {
			skView.presentScene(nil)
			skView.removeFromSuperview()
		})
	}
	
	func getParticleFileName() -> String? {
		if let filename = particleFileNameMap[PPParticleButtonEffectType.normal] {
			return filename
		}
		if self.isSelected {
			return particleFileNameMap[PPParticleButtonEffectType.selected]
		} else {
			return particleFileNameMap[PPParticleButtonEffectType.unSelected]
		}
	}
}
