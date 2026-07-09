ClearEnemySprites
        LDX #$12
        LDA #$00
CES_Loop 
        STA spriteY+SPR_ENEMYUPPER,X
        DEX
        BPL CES_Loop
        JSR SortSprites
        JMP CopySpritesToIrq

CompleteStage 
        JSR ToggleScreenOn
        LDY stage
        INY
        STY stage
        LDA stageStartPosLSBTbl,Y
        STA stagePosLSB
        LDA stageStartPosMSBTbl,Y
        STA stagePosMSB
        LDA stageEndSongTbl,Y
        TAY
        JSR PlaySong
        JSR ClearEnemySprites
        LDA #$08
        JSR SwapGraphicsData
        LDA #$01
        STA haltPlayerFlag
        LDA #$03
        JSR PrintFullScreen
        LDA stage
        CMP #$04
        PHP
        BNE CS_NotLastStage
        LDA #$01
        .BYTE $2C
CS_NotLastStage 
        LDA #$00
        JSR PrintFullScreen
        PLP
        PHP
        BNE CS_NotLastStage2
        LDA #$03
        JSR PrintTextScreen
        JMP CS_Common

CS_NotLastStage2 
        LDA #$01
        JSR PrintTextScreen
        LDA #$02
        JSR PrintTextScreen
CS_Common 
        LDA #$00
        STA scrollX
        STA spawnTblIndexMod
        STA activeExtraWeapon
        STA playerCoarseX
        LDA #$0F
        STA textD018Value
        LDA #$96
        STA textVideoBank
        LDA #$BB
        STA spriteY
        CLC
        ADC #$15
        STA spriteY+SPR_PLRLOWER
        LDA #$08
        STA temp2
        PLP
        BNE CS_NotLastStage3
        JSR InitPrisoners
CS_NotLastStage3
        JSR ToggleScreenOn
        LDA #$00
        STA frameSyncFlag
CS_StageOutroLoop 
        JSR CopySpritesToIrq
        LDA stage
        CMP #$04
        BEQ CS_IsVictoryScreen
        LDY temp2
        JSR AP_NoProne
        JSR UpdateStageArrows
        JSR UpdateStageOutro
CS_OutroLoopCommon 
        JSR SortSprites
        JSR UpdateMusicWaitFrame
        JSR CheckSongEnd
        BNE CS_StageOutroLoop
        JSR ToggleScreenOn
        LDA #$08
        JSR SwapGraphicsData
        JSR ResetGameVars
        JSR InitPlayer
        LDA #$12
        STA textD018Value
        LDA #$90
        STA textVideoBank
        LDY #$41
        JSR PlaySong
        LDA stage
        CMP #$04
        BNE CS_NextStage
        LDA #$00
        STA stage
        STA stagePosLSB
        STA stagePosMSB
        LDY difficultyMod
        LDA #$82
        STA difficultyMod1
        DEY
        BMI CS_DifficultyModDone
        LDA #$FA
        STA difficultyMod2
CS_DifficultyModDone 
        INY
        STY difficultyMod
        JSR ResetGraphicsSwaps
        JSR ResetGameChars
CS_NextStage
        JSR PrepareStageGraphics
        JMP ResumeGame

CS_IsVictoryScreen 
        JSR UpdateVictoryAnim
        LDY temp2
        BEQ CS_OutroLoopCommon
        JSR AP_NoProne
        JMP CS_OutroLoopCommon

InitNextLife 
        LDA #$01
        STA haltPlayerFlag
        JSR WaitSongToEnd

    .if INFINITE_LIVES_CHEAT = 0

        ; Original code, lives are decremented
        DEC lives
    
    .else

        ; Cheat code, lives not decremented
        LDA lives

    .endif

        BPL INL_NoGameOver
        JSR ShowGameOver
        LDY #$23
        JSR PlaySong
        JSR WaitSongToEnd
        JSR ToggleScreenOn
        JMP EnterTitleScreen

INL_NoGameOver 
        JSR ToggleScreenOn
        LDY #$41
        JSR PlaySong
        LDY #$2E
INL_FindRestartPos 
        LDA stagePosMSB
        CMP stageRestartMSBTbl,Y
        BCC INL_RestartNoMatch
        BNE INL_RestartFound
        LDA stagePosLSB
        CMP stageRestartLSBTbl,Y
        BCC INL_RestartNoMatch
INL_RestartFound 
        LDA stageRestartLSBTbl,Y
        SEC
        SBC #$28
        STA stagePosLSB
        LDA stageRestartMSBTbl,Y
        SBC #$00
        STA stagePosMSB
        LDA stage
        CMP #$01
        BNE INL_NoDogSwap
        LDA stageEndReached
        BEQ INL_NoDogSwap
        LDA #$07
        JSR SwapGraphicsData
INL_NoDogSwap
        JSR ResetGameVars
        JSR ClearEnemySprites
        LDA #$00
        STA spawnTblIndexMod
        JMP ResumeGame

INL_RestartNoMatch 
        DEY
        DEY
        BNE INL_FindRestartPos
        LDY #$00
        BEQ INL_RestartFound

stageRestartMSBTbl = stageRestartLSBTBL+1
stageRestartLSBTbl 
        .WORD $0028,$0068,$00C8,$0108,$0148,$01C7,$0218,$0268
        .WORD $02D0,$0318,$0368,$03D9,$0438,$0498,$04F8,$0558
        .WORD $05C8,$068E,$06C6,$06F6,$0740,$0788,$0838,$08B8

PrepareStageGraphics
        LDY stage
        BEQ PSG_Skip
        LDA stageGraphicsTbl1-1,Y
        JSR SwapGraphicsData
        LDY stage
        LDA stageGraphicsTbl2-1,Y
        BEQ PSG_Done
        JSR SwapGraphicsData
        LDY stage
        LDA stageGraphicsTbl3-1,Y
        BEQ PSG_Done
        JSR SwapGraphicsData
PSG_Done
        JSR ResetGameVars
PSG_Skip
        RTS

ResumeGame
        JSR InitStatusPanel
        LDA stage
        CMP #$03
        BNE RG_NoStage4CharReset
        JSR ResetBank2GameChars
RG_NoStage4CharReset
        JSR BeginStage
        JSR InitPlayer
        JMP MainLoop

ToggleScreenOn
        LDA $D011
        AND #$7F
        EOR #$10
        STA $D011
        RTS

stageGraphicsTbl1
        .BYTE $00,$01,$04

stageGraphicsTbl2
        .BYTE $00,$03,$06

stageGraphicsTbl3
        .BYTE $00,$02,$05

stageStartPosLSBTbl 
        .BYTE $00,$9F,$B1,$66

stageStartPosMSBTbl
        .BYTE $00,$01,$03

stageEndSongTbl
        .BYTE $06,$17,$1D,$3B,$11

ResetGameVars LDY #$00
        TYA
RGV_Loop
        STA flameDetachedTimer,Y
        INY
        CPY #$CD
        BNE RGV_Loop
        LDY #$00
RGV_Loop2 
        STA spawnEnemyTimer,Y
        INY
        CPY #$88
        BNE RGV_Loop2
        LDX #$14
RGV_SpriteLoop 
        STA spriteY,X
        STA spriteXMSB,X
        STA spriteX,X
        DEX
        BPL RGV_SpriteLoop
        LDX #$3B
RGV_StaticSpawnLoop
        STA staticEnemySpawnFlag,X
        DEX
        BPL RGV_StaticSpawnLoop
        LDX #$05
        LDA #$15
RGV_EnemyAdjustLoop 
        STA enemyYAdjust,X
        DEX
        BPL RGV_EnemyAdjustLoop
        RTS

Stage1EndEnemySpawn 
        LDA #$01
        STA spawnRetryCount
        LDA #$04
        STA enemySpawnDirTbl
        LDA #$00
        STA nextSpawnTblIndex
        LDA platformEnemyCount
        CMP #$03
        BCS S1EES_Wait
        CMP #$02
        BCC S1EES_DoSpawn
        LDA gameTimer
        BEQ S1EES_DoSpawn
        RTS

S1EES_DoSpawn 
        LDA #$F5
        STA gameTimer
        LDY endFightEnemiesLeft
        DEY
        BMI S1EES_Wait
        STY endFightEnemiesLeft
        LDA stage1EndEnemyTypeTbl,Y
        STA spawnEnemyType
        JSR FindFreeEnemySlot
        LDY #$00
        JSR CheckSpawnNewEnemyY
        STX platformTemp
        LDA #$04
        JSR AE_RestartAnimation
        LDX platformTemp
        LDA #$04
        STA enemyHorizMove,X
        STA enemyControls,X
        STA enemyLastControls,X
        LDA #$00
        STA enemyTimerActive,X
S1EES_Wait
        RTS

stage1EndEnemyTypeTbl
        .BYTE ENEMY_MARTIALARTIST,ENEMY_UNARMED,ENEMY_UNARMED
        .BYTE ENEMY_MARTIALARTIST,ENEMY_UNARMED,ENEMY_MARTIALARTIST
        .BYTE ENEMY_UNARMED,ENEMY_MARTIALARTIST,ENEMY_UNARMED
        .BYTE ENEMY_MARTIALARTIST,ENEMY_MARTIALARTIST,ENEMY_UNARMED
        .BYTE ENEMY_UNARMED,ENEMY_MARTIALARTIST,ENEMY_UNARMED
        .BYTE ENEMY_UNARMED,ENEMY_MARTIALARTIST,ENEMY_UNARMED
        .BYTE ENEMY_MARTIALARTIST,ENEMY_UNARMED
