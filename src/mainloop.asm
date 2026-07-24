        * = $06E0

        ; Game frame main loop that calls the per-frame update routines in sequence. Instead of a per-object "tick" that
        ; would update everything about the object at once, several of the routines go through the enemy or bullet
        ; arrays, checking which are active, and doing one operation on those active such as movement, animation or
        ; collision. This helps to keep the routines small and understandable, but loses some CPU cycles on the repeated
        ; looping and active checks.

        ; The frame syncing with the IRQ happens in the loop beginning. First the IRQ is waited for completion, then the
        ; previous frame's sprites are copied for the multiplexer and scrolling is performed if necessary. Only after
        ; that the game logic processing for the new frame is started.

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

        ; Branch off to calling different routines depending on whether the end-of-the-stage fight is active

        LDA stageEndFightActive
        BEQ Main_NoStageEndFight
        JMP UpdateStageEndFight

        ; Main loop end without the end fight. Among other things, this will spawn the fighter jet that appears after
        ; too much idle time.

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

        ; This routine is called from the screen bottom raster interrupt handler instead of the main program, and
        ; it reads the joystick and moves the player, and also advances the playroutine's sound effects part. It also
        ; does a knife collision check for a few frames after a fire press, while the player character is still in the
        ; knife strike pose. Note also the jump to the code in stack copied in entrypoint.asm, which is apparently a
        ; freezer protection (jam the processor if timer not expired.)

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
