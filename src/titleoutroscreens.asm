InitVideo
        LDA #$0B
        STA $D011
        CLD
        STX $D01C
        LDY #$06
IV_RegLoop 
        LDA videoRegsInitTbl,Y
        STA $D020,Y
        DEY
        BPL IV_RegLoop
EnterTitleScreen 
        LDA #$00
        STA spawnTblIndexMod
        STA stagePosLSB
        STA stagePosMSB
        STA $D015
        STA stage
        STA difficultyMod
        LDX #$0B
        STX spriteColor
        STX spriteColor+SPR_PLRLOWER
        LDX #$08
ETS_ResetScore
        STA score,X
        DEX
        BPL ETS_ResetScore
        LDA #$30
        STA nextExtraLifeScore+1
        LDA #$50
        STA difficultyMod1
        STA difficultyMod2
        LDA #$01
        STA haltPlayerFlag
        LDA #$02
        STA lives
        LDA #$35
        STA $01
        JSR InitSprites
        JSR ResetGraphicsSwaps
        JSR ResetGameChars
        JSR ResetGameVars
        LDA #$80
        STA playerRunSpeed
        JSR ResetSID
        LDY #$0F
        STY $D418
        JSR InitIrq
        CLI
        LDA #$0F
        STA textD018Value
        LDA #$92
        STA textVideoBank
        LDA #$08
        JSR SwapGraphicsData
        LDA #$03
        JSR PrintFullScreen
        LDA #$02
        JSR PrintFullScreen
        JSR ShowTitleScreen
        LDA #$03
        JSR PrintFullScreen
        LDA #$01
        JSR PrintFullScreen
        LDA #$01
        JSR PrintTextScreen
        JSR InitPrisoners
        LDA #$FD
        STA charUnderIntroGuard1
        STA charUnderIntroGuard2
        LDA #$00
        STA frameSyncFlag
        LDA #$FF
        STA $D015
        JSR SpawnIntroGuards
        LDY #$05
        JSR PlaySong
        JSR ToggleScreenOn
IntroLoop 
        JSR UpdatePrisoners
        JSR AnimateEnemies
        JSR CopySpritesToIrq
        JSR UpdateEnemies
        JSR CheckEnemiesRunAway
        JSR SortSprites
        JSR UpdateMusicWaitFrame
        JSR CheckSongEnd
        BNE IntroLoop
        JSR ToggleScreenOn
        JSR ResetGameVars
        JSR InitSprites
        JSR CopySpritesToIrq
        LDA #$12
        STA textD018Value
        LDA #$90
        STA textVideoBank
        LDA #$08
        JSR SwapGraphicsData
        LDY #$0B
        JSR PlaySong
        LDA #$00
        STA frameSyncFlag
        STA spawnTblIndexMod
        JSR InitStatusPanel
        JSR BeginStage
        JSR InitPlayer
        JMP MainLoop

WaitSongToEnd 
        JSR UpdateMusicWaitFrame
        JSR CheckSongEnd
        BNE WaitSongToEnd
        RTS

InitPrisoners 
        LDX #$03
IP_Loop LDA prisonerFrameTbl,X
        STA spriteFrame+SPR_ENEMYUPPER,X
        LDA #$B5
        STA spriteFrame+SPR_ENEMYLOWER,X
        LDA #$0B
        STA spriteColor+SPR_ENEMYUPPER,X
        LDA #$09
        STA spriteColor+SPR_ENEMYLOWER,X
        LDA #$A0
        STA spriteY+SPR_ENEMYUPPER,X
        CLC
        ADC #$15
        STA spriteY+SPR_ENEMYLOWER,X
        LDA prisonerXTbl,X
        STA spriteX+SPR_ENEMYUPPER,X
        STA spriteX+SPR_ENEMYLOWER,X
        LDA prisonerXMSBTbl,X
        STA spriteXMSB+SPR_ENEMYUPPER,X
        STA spriteXMSB+SPR_ENEMYLOWER,X
        DEX 
        BPL IP_Loop
        RTS

prisonerFrameTbl 
        .BYTE $B4,$A7,$B4,$A7,$A7,$B4,$A7,$B4

prisonerXTbl 
        .BYTE $3F,$87,$D7,$1F

prisonerXMSBTbl
        .BYTE $00,$00,$00,$01

SpawnIntroGuards 
        LDA #$01
        STA spawnEnemyFlag+2
        STA spawnEnemyFlag+5
        LDA #ENEMY_PRISONGUARD
        STA spawnEnemyType+2
        STA spawnEnemyType+5
        JSR FindNextSpawnType
SIG_Loop 
        JSR FindFreeEnemySlot
        LDA #$C5
        JSR CSNE_SetEnemyPos
        JSR FindNextSpawnType
        BCS SIG_Loop
        RTS

UpdatePrisoners 
        LDX #$03
        LDA gameTimer
        AND #$10
        LSR
        LSR
        TAY
UPr_Loop 
        LDA prisonerFrameTbl,Y
        STA spriteFrame+SPR_ENEMYUPPER,X
        INY
        DEX
        BPL UPr_Loop
        RTS

UpdateStageOutro 
        LDA playerCoarseX
        CMP #$89
        BCS USO_PlayerAtWall
USO_MovePlayerRight 
        CLC
        ADC #$01
        STA playerCoarseX
        ASL
        STA spriteX
        STA spriteX+SPR_PLRLOWER
        LDA #$00
        ROL
        STA spriteXMSB
        STA spriteXMSB+SPR_PLRLOWER
        RTS

USO_SetSpritesOnTop 
        LDA #$00
        STA $D01B
        RTS

USO_PlayerAtWall 
        CMP #$8A
        BCC USO_PlayerClimbing
        LDA spriteY
        CMP #$C0
        BCS USO_SetSpritesOnTop
        ADC #$03
        STA spriteY
        ADC #$15
        STA spriteY+SPR_PLRLOWER
        LDA playerCoarseX
        JMP USO_MovePlayerRight

USO_PlayerClimbing 
        LDA spriteY
        SEC
        SBC #$03
        LDY #$0F
        STY temp2
        STA spriteY
        CLC
        ADC #$15
        STA spriteY+SPR_PLRLOWER
        CMP #$70
        BCS USO_SetSpritesOnTop
        LDA #$FF
        STA $D01B
        LDY #$09
        STY temp2
        LDA playerCoarseX
        JMP USO_MovePlayerRight

UpdateVictoryAnim 
        LDA playerCoarseX
        CMP #$98
        BCS UVA_Finished
        PHA
        LDX #$00
UVA_Loop 
        PLA
        PHA
        CMP prisonerFreeXTbl,X
        BCC UVA_Next
        LDA #$8A
        STA spriteFrame+SPR_ENEMYUPPER,X
        LDA #$8B
        STA spriteFrame+SPR_ENEMYLOWER,X
UVA_Next 
        INX
        CPX #$04
        BNE UVA_Loop
        PLA
        JMP USO_MovePlayerRight

UVA_Finished 
        LDA #$00
        STA temp2
        LDA #$8A
        STA spriteFrame
        LDA #$8B
        STA spriteFrame+SPR_PLRLOWER
        RTS

prisonerFreeXTbl 
        .BYTE $1F,$43,$6B,$8F

UpdateStageArrows 
        JSR USA_InitialDraw
        LDX stage
        DEX
        LDY stageArrowPosTbl,X
        LDA gameTimer
        LSR
        LSR
        LSR
        AND #$03
        TAX
        PHA
        CPX #$00
        BEQ USA_UseOutlineArrow
        LDA #$7A
USA_ArrowAnimLoop 
        STA screen+$398,Y
        INY
        DEX
        BNE USA_ArrowAnimLoop
USA_UseOutlineArrow 
        PLA
        TAX
        LDA #$75
        .BYTE $2C
USA_FinishArrowGroup 
        LDA #$7A
USA_FinishLoop 
        CPX #$03
        BEQ USA_Done
        STA screen+$398,Y
        INY
        INX
        JMP USA_FinishLoop

USA_Done 
        RTS

stageArrowPosTbl 
        .BYTE $0A,$16,$21

USA_InitialDraw 
        LDX stage
USA_InitialDrawLoop 
        CPX #$01
        BCC USA_Done
        DEX
        TXA
        PHA
        LDY stageArrowPosTbl,X
        LDX #$00
        JSR USA_FinishArrowGroup
        PLA
        TAX
        JMP USA_InitialDrawLoop

