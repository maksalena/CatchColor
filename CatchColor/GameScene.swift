//
//  GameScene.swift
//  CatchColor
//
//  Created by Алёна Максимова on 22.09.2024.
//

import SpriteKit
import GameplayKit
import AVFoundation

protocol GameSceneDelegate: AnyObject {
    func didPressHomeButton()
}

class GameScene: SKScene {
    
// MARK: - Private Variables
    
    var selectedLevel: Int?
    weak var gameSceneDelegate: GameSceneDelegate?
    
    // Настройки звука
    var audioPlayer: AVAudioPlayer?
    var isSoundEnabled: Bool {
        set {
            return UserDefaults.standard.set(newValue, forKey: "isSoundEnabled")
        } get {
            UserDefaults.standard.bool(forKey: "isSoundEnabled")
        }
    }
    
    // Главный шар и массив маленьких шаров
    private var mainBall: SKSpriteNode!
    private var smallBalls = [SKSpriteNode]()
    
    // Цвета для игры
    private var ballTextures: [SKTexture] = [
        SKTexture(imageNamed: "blue_ball"),
        SKTexture(imageNamed: "red_ball"),
        SKTexture(imageNamed: "green_ball"),
    ]
    
    private var mainBallTextures: [SKTexture] = [
        SKTexture(imageNamed: "blue_ball"),
        SKTexture(imageNamed: "red_ball"),
        SKTexture(imageNamed: "green_ball"),
    ]
    
    // Интерфейс: счет, таймер и пауза
    private var scoreLabel: SKLabelNode!
    private var timerLabel: SKLabelNode!
    private var pauseButton: SKSpriteNode!
    private var playButton: SKSpriteNode!
    
    // Меню паузы
    private var pauseMenu: SKNode!
    private var resumeButton: SKSpriteNode!
    private var restartButton: SKSpriteNode!
    private var soundButton: SKSpriteNode!
    private var homeButton: SKSpriteNode!
    private var isGamePaused = false
    
    // Переменные для счета и таймера
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    private var bestScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: "bestScore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "bestScore")
        }
    }
    
    private var gameTimer: Timer?
    private var elapsedTime: TimeInterval = 1
    private var gameStartTime: TimeInterval?
    private var pausedTime: TimeInterval = 0
    
    // Переменные для ускорения появления шаров
    private var currentWaitDuration: TimeInterval = 1.0
    private let minimumWaitDuration: TimeInterval = 0.4
    private let waitDecrement: TimeInterval = 0.01

    // Жизни
    private var hearts: [SKSpriteNode] = []
    private let maxHearts = 5
    
    // Таймер для смены цвета главного шара
    private var colorChangeTimer: Timer?

    override func didMove(to view: SKView) {
        isSoundEnabled = UserDefaults.standard.bool(forKey: "isSoundEnabled")
        setupScene()
    }
    
    func setupScene() {
        // Фон
        setupBackground()
        
        // Главный шар
        mainBall = SKSpriteNode(texture: mainBallTextures.randomElement()!, size: CGSize(width: 125, height: 125)) // Случайная текстура из массива
        mainBall.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(mainBall)
        
        // Счет
        scoreLabel = SKLabelNode(fontNamed: "Courier-Bold")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 24
        scoreLabel.position = CGPoint(x: size.width - 85, y: size.height - 80)
        addChild(scoreLabel)
        
        // Таймер
        timerLabel = SKLabelNode(fontNamed: "Courier")
        timerLabel.text = "Time: 0s"
        timerLabel.fontSize = 20
        timerLabel.position = CGPoint(x: size.width - 85, y: size.height - 110)
        addChild(timerLabel)
        
        // Кнопка паузы
        pauseButton = SKSpriteNode(imageNamed: "pause_icon")
        pauseButton.position = CGPoint(x: 40, y: size.height - 80)
        pauseButton.size = CGSize(width: 40, height: 40)
        addChild(pauseButton)
        
        // Кнопка play
        playButton = SKSpriteNode(imageNamed: "play_icon")
        playButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        playButton.size = CGSize(width: 80, height: 80)
        playButton.isHidden = false // Показывается в начале
        addChild(playButton)
        
        // Создаем меню паузы
        createPauseMenu()
    }
    
// MARK: - Game Cycle
    
    func startGame() {
        setupLevels()
        currentWaitDuration = 1.0
        pausedTime = 0
        isGamePaused = false
        playButton.isHidden = true
        pauseButton.isHidden = false
        pauseMenu.isHidden = true
        startGameTimer()
        startColorChangeTimer() // Таймер смены цвета главного шара
        renderHearts()
        spawnBalls()
    }

    func startGameTimer() {
        gameStartTime = CACurrentMediaTime() - pausedTime
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateGameTime()
        }
    }
    
    func updateGameTime() {
        guard let startTime = gameStartTime else { return }
        elapsedTime = CACurrentMediaTime() - startTime
        timerLabel.text = String(format: "Time: %.0fs", elapsedTime)
    }

    func pauseGame() {
        isGamePaused = true // Устанавливаем состояние паузы
        pausedTime = elapsedTime
        gameTimer?.invalidate()
        colorChangeTimer?.invalidate() // Останавливаем таймер смены цвета
        physicsWorld.speed = 0 // Останавливаем физику
        pauseMenu.isHidden = false // Показываем меню паузы
        playButton.isHidden = true
        removeAction(forKey: "spawnBalls") // Останавливаем создание маленьких шаров
    }
    
    func resumeGame() {
        guard !hearts.isEmpty else { startGame(); return }
        isGamePaused = false // Возвращаемся в состояние игры
        physicsWorld.speed = 1
        startGameTimer()
        startColorChangeTimer() // Перезапуск таймера смены цвета
        playButton.isHidden = true
        pauseMenu.isHidden = true // Скрываем меню паузы
        spawnBalls()
    }
    
    func restartGame() {
        removeAllChildren()
        removeAllActions()
        setupScene() // Перезапускаем сцену
        score = 0
        elapsedTime = 1
        scoreLabel.text = "Score: \(score)"
        timerLabel.text = "Time: 0s"
        playButton.isHidden = true
        pauseMenu.isHidden = true
        startGame()
    }
    
    func endGame() {
        pauseMenu.isHidden = true
        pauseButton.isHidden = true
        if isSoundEnabled { playSound(forResult: true) }
        if score > bestScore {
            bestScore = score
        }
        
        let currentLevel = LevelManager.loadHighestLevel()
        if score > 100 && currentLevel < 12 {
            LevelManager.saveHighestLevel(currentLevel + 1) // Разблокировать новый уровень
        }
        
        isGamePaused = true
        gameTimer?.invalidate()
        colorChangeTimer?.invalidate() // Останавливаем таймер смены цвета
        physicsWorld.speed = 0 // Останавливаем физику
        removeAction(forKey: "spawnBalls") // Останавливаем создание маленьких шаров
        createGameOverMenu()
    }

// MARK: - Game Functions
    
    func setupLevels() {
        guard let level = selectedLevel else { return }
        
        if level > 3 {
            ballTextures.append(SKTexture(imageNamed: "pink_ball"))
            ballTextures.append(SKTexture(imageNamed: "orange_ball"))
            mainBallTextures.append(SKTexture(imageNamed: "pink_ball"))
            mainBallTextures.append(SKTexture(imageNamed: "orange_ball"))
        }
        
        if level > 9 {
            ballTextures.append(SKTexture(imageNamed: "bomb_ball"))
        }
    }
    
    func addFlashingEffect(to ball: SKSpriteNode) {
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 1)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 1)
        let flashingSequence = SKAction.sequence([fadeOut, fadeIn])
        ball.run(SKAction.repeatForever(flashingSequence))
    }
    
    func startColorChangeTimer() {
        let interval = TimeInterval(Int.random(in: 3...5))
        
        colorChangeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            // Проверяем, если игра не на паузе, меняем цвет и запускаем таймер снова
            if !self.isGamePaused {
                let newTexture = self.mainBallTextures.randomElement()! // Случайная текстура для нового главного шара
                self.mainBall.texture = newTexture // Меняем текстуру главного шара
                self.startColorChangeTimer() // Перезапуск таймера, только если игра не на паузе
            }
        }
    }

    func spawnBalls() {
        let spawnAction = SKAction.run { [weak self] in
            self?.createRandomBall()
            
            // Уменьшаем время ожидания, но не ниже минимального значения
            if let self = self {
                self.currentWaitDuration = max(self.minimumWaitDuration, currentWaitDuration - waitDecrement)
            }
        }

        // Используем рекурсивный подход для создания последовательности
        let spawnSequence = SKAction.sequence([
            spawnAction,
            SKAction.wait(forDuration: currentWaitDuration),
            SKAction.run { [weak self] in
                self?.spawnBalls() // Рекурсивно вызываем spawnBalls для продолжения
            }
        ])
        
        run(spawnSequence, withKey: "spawnBalls")
    }

    func createRandomBall() {
        let texture = ballTextures.randomElement()! // Случайная текстура для маленького шара
        let ball = SKSpriteNode(texture: texture, size: CGSize(width: 50, height: 50)) // Размер маленького шара
        let randomX = CGFloat.random(in: 40...(size.width - 40))
        let randomY = CGFloat.random(in: (mainBall.position.y - 100)...(mainBall.position.y - 40)) // ниже главного шара
        ball.position = CGPoint(x: randomX, y: randomY)
        ball.name = "smallBall"
        addChild(ball)
        smallBalls.append(ball)
        
        if let level = selectedLevel, level > 6 && Bool.random() {
            addFlashingEffect(to: ball)
        }
        
        let moveAction = SKAction.moveTo(y: 0, duration: 5.0)
        let removeAction = SKAction.removeFromParent()
        ball.run(SKAction.sequence([moveAction, removeAction]))
    }

    func updateScore(isCorrect: Bool) {
        if isCorrect {
            score += 10
            if isSoundEnabled { playSound(forResult: true) }
        } else {
            score -= 15
            if isSoundEnabled { playSound(forResult: false) }
            if score < 0 { score = 0 }
            
            // Уменьшаем количество жизней
            if hearts.count > 0 {
                let heart = hearts.removeLast() // Убираем последнее сердце
                heart.run(SKAction.sequence([
                    SKAction.scale(to: 0, duration: 0.2), // Уменьшаем размер до 0
                    SKAction.removeFromParent() // Удаляем сердце из сцены
                ]))
            }
            
            // Если жизни закончились, можно завершить игру или показать сообщение
            if hearts.isEmpty {
                endGame()
            }
        }

        scoreLabel.text = "Score: \(score)"
    }
    
// MARK: - Menus
    
    // Показать меню паузы
    func createPauseMenu() {
        pauseMenu = SKNode()
        pauseMenu.isHidden = true
        
        // Фон меню паузы (белый прямоугольник)
        let menuBackground = SKSpriteNode(texture: SKTexture(imageNamed: "pause-background"), size: CGSize(width: size.width * 0.8, height: size.height * 0.36))
        menuBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        menuBackground.zPosition = 101
        pauseMenu.addChild(menuBackground)
        
        // Заголовок меню
        let titleLabel = SKLabelNode(text: "Paused")
        titleLabel.fontName = "Courier"
        titleLabel.fontSize = 30
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 60)
        titleLabel.zPosition = 102
        pauseMenu.addChild(titleLabel)
        
        // Лучший счет
        let bestScoreLabel = SKLabelNode(text: "Best score: \(bestScore)")
        titleLabel.fontName = "Courier"
        bestScoreLabel.fontSize = 26
        bestScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 30)
        bestScoreLabel.zPosition = 102
        pauseMenu.addChild(bestScoreLabel)
        
            
        // Кнопки
        let buttonWidth: CGFloat = 40
        let buttonHeight: CGFloat = 40

        // Кнопка "Продолжить"
        resumeButton = SKSpriteNode(imageNamed: "play_icon")
        resumeButton.size = CGSize(width: buttonWidth, height: buttonHeight)
        resumeButton.position = CGPoint(x: size.width / 2 - buttonWidth / 2 - 10, y: size.height / 2 - 10)
        resumeButton.name = "resumeButton"
        resumeButton.zPosition = 102
        pauseMenu.addChild(resumeButton)
        
        // Кнопка "Начать заново"
        restartButton = SKSpriteNode(imageNamed: "restart_icon")
        restartButton.size = CGSize(width: buttonWidth, height: buttonHeight)
        restartButton.position = CGPoint(x: size.width / 2 + buttonWidth / 2 + 10, y: size.height / 2 - 10)
        restartButton.name = "restartButton"
        restartButton.zPosition = 102
        pauseMenu.addChild(restartButton)
        
        // Кнопка "Выключить звук"
        soundButton = SKSpriteNode(imageNamed: isSoundEnabled ? "sound_on_icon" : "sound_off_icon")
        soundButton.size = CGSize(width: buttonWidth, height: buttonHeight)
        soundButton.position = CGPoint(x: size.width / 2 - buttonWidth / 2 - 10, y: size.height / 2 - 60)
        soundButton.name = "soundButton"
        soundButton.zPosition = 102
        pauseMenu.addChild(soundButton)
        
        // Кнопка "Уровни игры"
        homeButton = SKSpriteNode(imageNamed: "home_icon")
        homeButton.size = CGSize(width: buttonWidth, height: buttonHeight)
        homeButton.position = CGPoint(x: size.width / 2 + buttonWidth / 2 + 10, y: size.height / 2 - 60)
        homeButton.name = "homeButton"
        homeButton.zPosition = 102
        pauseMenu.addChild(homeButton)

        
        addChild(pauseMenu)
    }
    
    func createGameOverMenu() {
        let gameOverMenu = SKNode()
        
        // Фон меню
        let menuBackground = SKSpriteNode(texture: SKTexture(imageNamed: "pause-background"), size: CGSize(width: size.width * 0.8, height: size.height * 0.36))
        menuBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        menuBackground.zPosition = 101
        gameOverMenu.addChild(menuBackground)
        
        // Заголовок меню
        let titleLabel = SKLabelNode(text: "Game Over!")
        titleLabel.fontName = "Courier-Bold"
        titleLabel.fontSize = 30
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 60)
        titleLabel.zPosition = 102
        gameOverMenu.addChild(titleLabel)
        
        // Текущий счет
        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontName = "Courier"
        scoreLabel.fontSize = 24
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 30)
        scoreLabel.zPosition = 102
        gameOverMenu.addChild(scoreLabel)
        
        // Лучший счет
        let bestScoreLabel = SKLabelNode(text: "Best score: \(bestScore)")
        bestScoreLabel.fontName = "Courier"
        bestScoreLabel.fontSize = 26
        bestScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bestScoreLabel.zPosition = 102
        gameOverMenu.addChild(bestScoreLabel)
        
        // Кнопка "Начать заново"
        restartButton = SKSpriteNode(imageNamed: "restart_icon")
        restartButton.size = CGSize(width: 60, height: 60)
        restartButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        restartButton.name = "restartButton"
        restartButton.zPosition = 102
        gameOverMenu.addChild(restartButton)
        
        addChild(gameOverMenu)
    }

// MARK: - Other Game Settings
    
    func renderHearts() {
        // Создание жизней
        hearts = []
        for i in 0..<maxHearts {
            let heart = SKSpriteNode(imageNamed: "heart_icon")
            heart.size = CGSize(width: 40, height: 40)
            heart.position = CGPoint(x: size.width - 50 - CGFloat(i * 50), y: 40) // Позиция внизу справа
            hearts.append(heart)
            addChild(heart)
        }
    }
    
    func setupBackground() {
        // Создаем текстуру из изображения
        let backgroundTexture = SKTexture(imageNamed: "background")
        let background = SKSpriteNode(texture: backgroundTexture, size: self.size)
        
        // Устанавливаем позицию фона в центре сцены
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = -1
        
        // Добавляем фон на сцену
        addChild(background)
    }
    
    func playSound(forResult isCorrect: Bool) {
        var soundName = isCorrect ? "bonus_sound" : "error_sound"
        
        if hearts.isEmpty {
            soundName = "game_over_sound"
        }
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Ошибка воспроизведения звука: \(error)")
        }
    }

    
    func toggleSound() {
        isSoundEnabled.toggle()
        
        // Меняем изображение кнопки в зависимости от состояния
        soundButton.texture = isSoundEnabled ? SKTexture(imageNamed: "sound_on_icon") : SKTexture(imageNamed: "sound_off_icon")
    }
    
    func showLevels() {
        // Сообщаем GameViewController перейти на страницу с уровнями
        gameSceneDelegate?.didPressHomeButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        if nodesAtPoint.contains(playButton) {
            startGame()
        } else if nodesAtPoint.contains(pauseButton) {
            pauseGame()
        } else if nodesAtPoint.contains(resumeButton) {
            resumeGame()
        } else if nodesAtPoint.contains(restartButton) {
            restartGame()
        } else if nodesAtPoint.contains(soundButton) {
            toggleSound()
        } else if nodesAtPoint.contains(homeButton) {
            showLevels()
        } else {
            for node in nodesAtPoint {
                if let ball = node as? SKSpriteNode, ball.name == "smallBall" {
                    let isCorrectTexture = ball.texture?.description == mainBall.texture?.description
                    updateScore(isCorrect: isCorrectTexture)
                    ball.removeFromParent()
                    break
                }
            }
        }
    }
}
