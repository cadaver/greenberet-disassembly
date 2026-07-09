        ; Truck sprite animation at the end of the first stage. When the truck is on screen, sprites are used directly
        ; but the enemies are set inactive, meaning it cannot be hit by player attacks.

TruckAnimation
        LDA stageEndReached
        BEQ TA_Init
        RTS

TA_Init LDA truckInitFlag
        BNE TA_TruckCreated
        INC truckInitFlag
        LDA #$06
        STA firstStageEndCounter
        LDA #$01
        STA truckAnimTimer
        LDA #$11
        STA endFightEnemiesLeft
        LDY #$4D
        JSR PlaySong
        LDY #$08
        LDX #$02
TA_SpriteLoop 
        LDA truckColorTbl,Y
        STA spriteColor+SPR_ENEMYUPPER,X
        LDA truckFrameTbl,Y
        STA spriteFrame+SPR_ENEMYUPPER,X
        DEY
        LDA truckFrameTbl,Y
        STA spriteFrame+SPR_ENEMYUPPER+3,X
        LDA truckColorTbl,Y
        STA spriteColor+SPR_ENEMYUPPER+3,X
        DEY
        LDA truckFrameTbl,Y
        STA spriteFrame+SPR_ENEMYLOWER,X
        LDA truckColorTbl,Y
        STA spriteColor+SPR_ENEMYLOWER,X
        DEY
        DEX
        BPL TA_SpriteLoop
        LDX #$02
TA_SpriteCoordLoop 
        LDA platformYTbl
        SEC
        SBC #$19
        STA spriteY+SPR_ENEMYUPPER,X
        CLC
        ADC #$15
        STA spriteY+SPR_ENEMYUPPER+3,X
        CLC
        ADC #$15
        STA spriteY+SPR_ENEMYLOWER,X
        LDA #$00
        STA spriteX+SPR_ENEMYUPPER,X
        STA spriteXMSB+SPR_ENEMYUPPER,X
        STA spriteX+SPR_ENEMYUPPER+3,X
        STA spriteXMSB+SPR_ENEMYUPPER+3,X
        STA spriteX+SPR_ENEMYLOWER,X
        STA spriteXMSB+SPR_ENEMYLOWER,X
        DEX
        BPL TA_SpriteCoordLoop
TA_TruckCreated 
        LDA stageEndReached
        BEQ TA_MoveTruck
        RTS

truckFrameTbl 
        .BYTE $70,$76,$CC,$75,$77,$7A,$73,$78,$7B

truckColorTbl
        .BYTE $0B,$0B,$09,$0B,$09,$09,$0B,$09,$09

TA_MoveTruck 
        JSR TA_AnimateTruck
        LDA spriteX+SPR_ENEMYUPPER
        CLC
        ADC firstStageEndCounter
        STA spriteX+SPR_ENEMYUPPER
        STA spriteX+SPR_ENEMYUPPER+3
        STA spriteX+SPR_ENEMYLOWER
        BCC TA_NoMSB
        LDA #$01
        STA spriteXMSB+SPR_ENEMYUPPER
        STA spriteXMSB+SPR_ENEMYUPPER+3
        STA spriteXMSB+SPR_ENEMYLOWER
TA_NoMSB 
        LDA enemyCoarseX
        CMP #$0A
        BCC TA_Done
        LDA spriteX+SPR_ENEMYUPPER+1
        CLC
        ADC firstStageEndCounter
        STA spriteX+SPR_ENEMYUPPER+1
        STA spriteX+SPR_ENEMYUPPER+4
        STA spriteX+SPR_ENEMYLOWER+1
        BCC TA_NoMSB2
        LDA #$01
        STA spriteXMSB+SPR_ENEMYUPPER+1
        STA spriteXMSB+SPR_ENEMYUPPER+4
        STA spriteXMSB+SPR_ENEMYLOWER+1
TA_NoMSB2 
        LDA dogCoarseX
        CMP #$0A
        BCC TA_Done
        LDA spriteX+SPR_ENEMYUPPER+2
        CLC
        ADC firstStageEndCounter
        STA spriteX+SPR_ENEMYUPPER+2
        STA spriteX+SPR_ENEMYUPPER+5
        STA spriteX+SPR_ENEMYLOWER+2
        BCC TA_NoMSB3
        LDA #$01
        STA spriteXMSB+SPR_ENEMYUPPER+2
        STA spriteXMSB+SPR_ENEMYUPPER+5
        STA spriteXMSB+SPR_ENEMYLOWER+2
TA_NoMSB3 
        LDA truckCoarseX
        CMP #$32
        BCC TA_Done
        CMP #$5A
        BCC TA_UseSpeed4
        CMP #$78
        BCC TA_UseSpeed3
        CMP #$AA
        BCC TA_UseSpeed2
        LDA #$01
        STA stageEndReached
        LDA #$00
        STA platformEnemyCount
        LDA #$00
        LDY #$08
TA_RemoveTruckLoop 
        STA spriteY+SPR_ENEMYUPPER,Y
        DEY
        BPL TA_RemoveTruckLoop
TA_Done RTS

TA_UseSpeed4 
        LDA #$04
        STA firstStageEndCounter
        RTS 

TA_UseSpeed3 
        LDA #$03
        STA firstStageEndCounter
        RTS

TA_UseSpeed2 
        LDA #$02
        STA firstStageEndCounter
        RTS

UpdateEnemyTimers 
        LDX #$05
UET_Loop
        LDA enemyTimerActive,X
        BEQ UET_Next
        LDA enemyTimer,X
        BEQ UET_Next
        DEC enemyTimer,X
        BNE UET_Next
        LDA #$00
        STA enemyTimerActive,X
        LDY enemyPlatformHeight,X
        LDA platformYTbl,Y
        STA spriteY+SPR_ENEMYUPPER,X
        CLC 
        ADC #$15
        STA spriteY+SPR_ENEMYLOWER,X
        LDA spriteX+SPR_ENEMYUPPER,X
        STA spriteX+SPR_ENEMYLOWER,X
        LDA spriteXMSB+SPR_ENEMYUPPER,X
        STA spriteXMSB+SPR_ENEMYLOWER,X
        LDA #$03
        STA enemyLastControls,X
UET_Next 
        DEX
        BPL UET_Loop
        RTS

TA_AnimateTruck
        DEC truckAnimTimer
        BNE TA_AnimateSkip
        LDA #$07
        SEC
        SBC firstStageEndCounter
        STA truckAnimTimer
        LDA spriteFrame+SPR_ENEMYLOWER
        CLC
        ADC #$01
        CMP #$72
        BCS TA_AnimationWrap
        STA spriteFrame+SPR_ENEMYLOWER
        LDA spriteFrame+SPR_ENEMYLOWER+2
        CLC 
        ADC #$01
        STA spriteFrame+SPR_ENEMYLOWER+2
TA_AnimateSkip 
        RTS

TA_AnimationWrap
        LDA #$6F
        STA spriteFrame+SPR_ENEMYLOWER
        LDA #$72
        STA spriteFrame+SPR_ENEMYLOWER+2
        RTS