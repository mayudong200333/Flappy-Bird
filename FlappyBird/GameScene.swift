//
//  GameScene.swift
//  FlappyBird
//
//  Created by 馬煜東 on 2019/10/24.
//  Copyright © 2019年 ikutou.ba. All rights reserved.
//

import SpriteKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    var play:SKAudioNode!
    
    
    let birdCategory:UInt32=1<<0
    let groundCategory:UInt32=1<<1
    let wallCategory:UInt32=1<<2
    let scoreCategory:UInt32=1<<3
    let itemCategory:UInt32=1<<4
    
    var score=0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    let userdefaults:UserDefaults=UserDefaults.standard
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity=CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate=self
        backgroundColor=UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        scrollNode=SKNode()
        addChild(scrollNode)
        
        wallNode=SKNode()
        addChild(wallNode)
        
        
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        
        setupScoreLabel()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed>0{
            bird.physicsBody?.velocity=CGVector.zero
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        }else if bird.speed==0{
            restart()
        }
        
    }
    
    
    func setupGround(){
        let groundTexture=SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        let needNumber = Int(self.frame.size.width/groundTexture.size().width)+2
        
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        let repeatGround = SKAction.repeatForever(SKAction.sequence([moveGround,resetGround]))
        
        for i in 0..<needNumber{
            let sprite=SKSpriteNode(texture: groundTexture)
            sprite.position=CGPoint(x: groundTexture.size().width/2+groundTexture.size().width*CGFloat(i), y: groundTexture.size().height/2)
            sprite.physicsBody=SKPhysicsBody(rectangleOf: groundTexture.size())
            sprite.physicsBody?.categoryBitMask=groundCategory
            sprite.physicsBody?.isDynamic=false
            sprite.run(repeatGround)
            scrollNode.addChild(sprite)
            
        }
    }
    
    func setupCloud(){
        let cloudTexture=SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        let needCloudNumber = Int(self.frame.size.width/cloudTexture.size().width)+2
        
        let moveCloud=SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
        let resetCloud=SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        let repeatScrollCloud=SKAction.repeatForever(SKAction.sequence([moveCloud,resetCloud]))
        
        for i in 0..<needCloudNumber{
            let sprite=SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100
            sprite.position=CGPoint(x: cloudTexture.size().width/2+cloudTexture.size().width*CGFloat(i), y: self.size.height-cloudTexture.size().height/2)
            sprite.run(repeatScrollCloud)
            scrollNode.addChild(sprite)
            
        }
        
    }
    
    func setupWall(){
        let wallTexture=SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .nearest
        
        let movingDistance=CGFloat(self.frame.width+wallTexture.size().width+200)
        let moveWall=SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        let removeWall=SKAction.removeFromParent()
        let wallAnimation=SKAction.sequence([moveWall,removeWall])
        let birdsize=SKTexture(imageNamed: "bird_a").size()
        let slit_length=birdsize.height*3
        let random_y_range=birdsize.height*3
        let groundSize=SKTexture(imageNamed: "ground").size()
        let center_y=groundSize.height+(self.frame.height-groundSize.height)/2
        let underwall_lowest_y = center_y - slit_length/2 - wallTexture.size().height/2 - random_y_range/2
        
        let creatWallAnimation=SKAction.run({
            let wall=SKNode()
            wall.position=CGPoint(x: self.frame.width+wallTexture.size().width, y: 0)
            wall.zPosition = -50
            let random_y=CGFloat.random(in: 0..<random_y_range)
            let under_wall_y=underwall_lowest_y+random_y
            let under=SKSpriteNode(texture: wallTexture)
            under.position=CGPoint(x: 0, y: under_wall_y)
            under.physicsBody=SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask=self.wallCategory
            under.physicsBody?.isDynamic=false
            wall.addChild(under)
            let upper=SKSpriteNode(texture: wallTexture)
            upper.position=CGPoint(x:0,y:under_wall_y+slit_length+wallTexture.size().height)
            upper.physicsBody=SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask=self.wallCategory
            upper.physicsBody?.isDynamic=false
            wall.addChild(upper)
            
            let scoreNode=SKNode()
            scoreNode.position=CGPoint(x: upper.size.width+birdsize.width/2, y: self.frame.height/2)
            scoreNode.physicsBody=SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic=false
            scoreNode.physicsBody?.categoryBitMask=self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask=self.birdCategory
            wall.addChild(scoreNode)
            
            let itemTexture=SKTexture(imageNamed: "ringo")
            itemTexture.filteringMode = .nearest
            let item=SKSpriteNode(texture: itemTexture)
            let item_y_range=(self.frame.size.height-groundSize.height)/4
            let random_item_y_range=CGFloat.random(in: -item_y_range..<item_y_range)
            let item_y=center_y+random_item_y_range
            let item_x_range=self.frame.size.width/2-upper.size.width
            let random_item_x_range=CGFloat.random(in:0..<item_x_range)
            let item_x=upper.size.width+item.size.width/2+random_item_x_range
            item.position=CGPoint(x: item_x, y: item_y)
            item.physicsBody=SKPhysicsBody(circleOfRadius: item.size.height/2)
            item.physicsBody?.categoryBitMask=self.itemCategory
            item.physicsBody?.contactTestBitMask=self.birdCategory
            item.physicsBody?.isDynamic=false
            wall.addChild(item)
            
            wall.run(wallAnimation)
            self.wallNode.addChild(wall)
        })
        
        let waitAnimation=SKAction.wait(forDuration: 2)
        let repeatForeverAnimation=SKAction.repeatForever(SKAction.sequence([creatWallAnimation,waitAnimation]))
        wallNode.run(repeatForeverAnimation)
        
    }
    
    func setupBird(){
        let birdTextureA=SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB=SKTexture(imageNamed: "bird_b")
        birdTextureA.filteringMode = .linear
        
        let textureAnimation=SKAction.animate(with: [birdTextureA,birdTextureB], timePerFrame: 0.2)
        let flap=SKAction.repeatForever(textureAnimation)
        bird = SKSpriteNode(texture:birdTextureA)
        bird.position=CGPoint(x: self.frame.size.width*0.2, y: self.frame.size.height*0.7)
        
        bird.physicsBody=SKPhysicsBody(circleOfRadius: bird.size.height/2)
        bird.physicsBody?.allowsRotation=false
        
        bird.physicsBody?.categoryBitMask=birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        
        bird.run(flap)
        addChild(bird)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let itemPlay=SKAction.playSoundFileNamed("item.mp3", waitForCompletion: true)
        if scrollNode.speed<=0{
            return
        }
        
        if (contact.bodyA.categoryBitMask&scoreCategory)==scoreCategory || (contact.bodyB.categoryBitMask&scoreCategory)==scoreCategory{
            print("ScoreUp")
            score+=1
            scoreLabelNode.text="Score:\(score)"
            
            var bestscore=userdefaults.integer(forKey: "Best")
            if score>bestscore{
                bestscore=score
                bestScoreLabelNode.text="Best Score:\(bestscore)"
                userdefaults.set(bestscore, forKey: "Best")
                userdefaults.synchronize()
            }
        }else if(contact.bodyA.categoryBitMask&itemCategory)==itemCategory || (contact.bodyB.categoryBitMask&itemCategory)==itemCategory{
            print("ScoreUp")
            score+=1
            scoreLabelNode.text="Score:\(score)"
            if contact.bodyA.categoryBitMask<contact.bodyB.categoryBitMask{
                contact.bodyB.node?.removeFromParent()
            } else {
                contact.bodyA.node?.removeFromParent()
            }
            self.run(itemPlay)
            
            
            var bestscore=userdefaults.integer(forKey: "Best")
            if score>bestscore{
                bestscore=score
                bestScoreLabelNode.text="Best Score:\(bestscore)"
                userdefaults.set(bestscore, forKey: "Best")
                userdefaults.synchronize()
            }
            
        }else{
            print("GameOver")
            scrollNode.speed=0
            bird.physicsBody?.collisionBitMask=groundCategory
            
            let roll=SKAction.rotate(byAngle: CGFloat(Double.pi)*CGFloat(bird.position.y)*0.01, duration: 1)
            bird.run(roll, completion: {self.bird.speed=0})
        }
        
    }
    
    func restart(){
        score=0
        scoreLabelNode.text="Score:\(score)"
        
        bird.position=CGPoint(x: self.frame.size.width*0.2, y: self.frame.height*0.7)
        bird.physicsBody?.velocity=CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation=0
        wallNode.removeAllChildren()
        bird.speed = 1
        scrollNode.speed=1
        
        
    }
    
    func setupScoreLabel(){
        
        scoreLabelNode=SKLabelNode()
        scoreLabelNode.fontColor=UIColor.black
        scoreLabelNode.position=CGPoint(x: 10, y: self.frame.size.height-60)
        scoreLabelNode.zPosition=100
        scoreLabelNode.horizontalAlignmentMode=SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text="Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode=SKLabelNode()
        bestScoreLabelNode.fontColor=UIColor.black
        bestScoreLabelNode.position=CGPoint(x: 10, y: self.frame.size.height-90)
        bestScoreLabelNode.horizontalAlignmentMode=SKLabelHorizontalAlignmentMode.left
        
        let bestScore=userdefaults.integer(forKey: "Best")
        bestScoreLabelNode.text=("Best score:\(bestScore)")
        self.addChild(bestScoreLabelNode)
        
    }
}
