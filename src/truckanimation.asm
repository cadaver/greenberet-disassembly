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
        STA enemyUpperColor,X
        LDA truckFrameTbl,Y
        STA enemyUpperFrame,X
        DEY
        LDA truckFrameTbl,Y
        STA enemyUpperFrame+3,X
        LDA truckColorTbl,Y
        STA enemyUpperColor+3,X
        DEY
        LDA truckFrameTbl,Y
        STA enemyLowerFrame,X
        LDA truckColorTbl,Y
        STA enemyLowerColor,X
        DEY
        DEX
        BPL TA_SpriteLoop
        LDX #$02
TA_SpriteCoordLoop 
		LDA platformYTbl
        SEC
        SBC #$19
        STA enemyUpperY,X
        CLC
        ADC #$15
        STA enemyUpperY+3,X
        CLC
        ADC #$15
        STA enemyLowerY,X
        LDA #$00
        STA enemyUpperX,X
        STA enemyUpperXMSB,X
        STA enemyUpperX+3,X
        STA enemyUpperXMSB+3,X
        STA enemyLowerX,X
        STA enemyLowerXMSB,X
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
        LDA enemyUpperX
        CLC
        ADC firstStageEndCounter
        STA enemyUpperX
        STA enemyUpperX+3
        STA enemyLowerX
        BCC TA_NoMSB
        LDA #$01
        STA enemyUpperXMSB
        STA enemyUpperXMSB+3
        STA enemyLowerXMSB
TA_NoMSB 
		LDA enemyCoarseX
        CMP #$0A
        BCC TA_Done
        LDA enemyUpperX+1
        CLC
        ADC firstStageEndCounter
        STA enemyUpperX+1
        STA enemyUpperX+4
        STA enemyLowerX+1
        BCC TA_NoMSB2
        LDA #$01
        STA enemyUpperXMSB+1
        STA enemyUpperXMSB+4
        STA enemyLowerXMSB+1
TA_NoMSB2 
		LDA dogCoarseX
        CMP #$0A
        BCC TA_Done
        LDA enemyUpperX+2
        CLC
        ADC firstStageEndCounter
        STA enemyUpperX+2
        STA enemyUpperX+5
        STA enemyLowerX+2
        BCC TA_NoMSB3
        LDA #$01
        STA enemyUpperXMSB+2
        STA enemyUpperXMSB+5
        STA enemyLowerXMSB+2
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
		STA enemyUpperY,Y
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
        STA enemyUpperY,X
        CLC 
        ADC #$15
        STA enemyLowerY,X
        LDA enemyUpperX,X
        STA enemyLowerX,X
        LDA enemyUpperXMSB,X
        STA enemyLowerXMSB,X
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
        LDA enemyLowerFrame
        CLC
        ADC #$01
        CMP #$72
        BCS TA_AnimationWrap
        STA enemyLowerFrame
        LDA enemyLowerFrame+2
        CLC 
        ADC #$01
        STA enemyLowerFrame+2
TA_AnimateSkip 
		RTS

TA_AnimationWrap
		LDA #$6F
        STA enemyLowerFrame
        LDA #$72
        STA enemyLowerFrame+2
        RTS