        * = $6e0

MainLoop
		JSR UpdateMusicWaitFrame
        LDA scrollSpeed
        STA lastScrollSpeed
        LDA scrollX
        STA lastScrollX
        JSR CopySpritesToIrq
        JSR DrawNewColumn
        JSR ScrollScreen
        JSR FormatLives
        JSR AddAccumulatedScore
        JSR FormatScore
        JSR CheckNewHighScore
        JSR FormatHighScore
        JSR CheckNextExtraLife
        LDA stageEndFightActive
        BEQ Main_NoStageEndFight
        JMP UpdateStageEndFight

Main_NoStageEndFight 
		LDX parachuteKillFlag
        BEQ Main_NoParachuteKill
        JSR CleanupParachute
        LDA #$00
        STA parachuteKillFlag
        LDA #$80
        STA enemyTimerActive,X
        STA enemyTimer,X
Main_NoParachuteKill 
		JSR TrySpawnStaticEnemy
        JSR CheckParachuteEnemy
        JSR TrySpawnEnemy
        JSR SetCoarseXCoords
        JSR PlayerWorldCollision
        JSR UpdatePlatformCounts
        JSR ScrollEnemies
        JSR EnemyWorldCollision
        JSR FindPlayerPlatform
        JSR UpdateEnemyPathing
        JSR AnimateEnemies
        JSR UpdateBullets
        JSR UpdateExtraWeapon
        JSR RunEnemyBulletCode
        JSR UpdateEnemies
        JSR CheckEnemiesRunAway
        JSR UpdateFighterJet
        JSR SortSprites
        JSR UpdateWeaponPickup
        JSR CheckKillEnemies
        JSR CheckEnemyToPlayer
        JSR AnimateMineChars
        JSR CheckPlayerHitMine
        JSR SetEnemyToSpawn
        JSR UpdateEnemyTimers
        JSR CheckStartEndFight
        JMP MainLoop

IrqUpdatePlayer 
		JSR ReadControls
        LDA $DC01
        AND #$01
        BEQ IUP_SkipMove
        LDA haltPlayerFlag
        BNE IUP_SkipMove
        JSR MovePlayer
        JSR AnimatePlayer
        JSR IUP_CheckKnifeHeld
        JSR $0100
IUP_SkipMove 
		JSR FindFirstSprite
        JSR UpdateSoundChannel1
        JSR UpdateSoundChannel2
        JMP UpdateSoundChannel3

IUP_CheckKnifeHeld
		LDA playerAnimState
        AND #$10
        BNE IUP_HasDelayedKnife
        RTS

IUP_HasDelayedKnife
		LDA playerAnimState
        JMP CheckKnifeCollisions

