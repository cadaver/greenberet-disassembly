        ; Scrolling routine. Scrolling is called when the player is at the motion limit on the screen right side.
        ; Reaching the stage end and activating the warning siren is also checked here.

CheckScroll
        LDY stage
        LDA stagePosMSB
        CMP stageEndMSBTbl,Y
        BNE CS_NoStageEnd
        LDA stagePosLSB
        CMP stageEndLSBTbl,Y
        BEQ CS_AtStageEnd
CS_NoStageEnd LDA playerRunSpeed
        CLC
        ADC playerRunSubPixel
        STA playerRunSubPixel
        BCC CS_ScrollOnePixel
        JSR CS_ScrollOnePixel
CS_ScrollOnePixel
        LDY scrollX
        INC scrollSpeed
        DEY
        BPL CS_NoScrollWrap
        LDA idleTimer
        SEC
        SBC #$01
        BCC CS_NoIdleUnderflow
        STA idleTimer
CS_NoIdleUnderflow
        INC screenShiftFlag
        LDY #$07
CS_NoScrollWrap 
        STY scrollX
        RTS

stageEndLSBTbl 
        .BYTE $9F,$A8,$60,$18

stageEndMSBTbl
        .BYTE $01,$03,$06,$09

stageNumEndEnemyTbl 
        .BYTE $11,$11,$03,$11

CS_AtStageEnd LDA stageEndFightActive
        BEQ CS_WarningSiren
        RTS

CS_WarningSiren
        LDA #$06
        STA platformEnemyCount
        LDA #$E0
        CMP playerRightLimit
        BEQ CS_WarningSirenDone
        STA playerRightLimit
        STA platformEnemyCount+PLATFORM_MIDDLE
        STA platformEnemyCount+PLATFORM_TOP
        LDY stage
        LDA stageNumEndEnemyTbl,Y
        STA endFightEnemiesLeft
        LDY #$47
        JSR PlaySong
        LDA #$00
        STA stageEndReached
CS_WarningSirenDone
        RTS

ScrollScreen
        LDA screenShiftFlag
        BNE SS_DoScroll
        RTS

SS_DoScroll
        LDY #$00
SS_UpperLoop 
        LDA screen+$141,Y
        STA screen+$140,Y
        LDA screen+$169,Y
        STA screen+$168,Y
        LDA screen+$191,Y
        STA screen+$190,Y
        LDA screen+$1B9,Y
        STA screen+$1B8,Y
        LDA screen+$1E1,Y
        STA screen+$1E0,Y
        LDA colorRam+$1E1,Y
        STA colorRam+$1E0,Y
        LDA screen+$209,Y
        STA screen+$208,Y
        LDA colorRam+$209,Y
        STA colorRam+$208,Y
        LDA screen+$231,Y
        STA screen+$230,Y
        LDA colorRam+$231,Y
        STA colorRam+$230,Y
        LDA screen+$259,Y
        STA screen+$258,Y
        LDA colorRam+$259,Y
        STA colorRam+$258,Y
        LDA screen+$281,Y
        STA screen+$280,Y
        LDA colorRam+$281,Y
        STA colorRam+$280,Y
        LDA screen+$2A9,Y
        STA screen+$2A8,Y
        LDA colorRam+$2A9,Y
        STA colorRam+$2A8,Y
        INY
        CPY #$27
        BNE SS_UpperLoop
        LDY #$00
SS_LowerLoop 
        LDA screen+$2D1,Y
        STA screen+$2D0,Y
        LDA colorRam+$2D1,Y
        STA colorRam+$2D0,Y
        LDA screen+$2F9,Y
        STA screen+$2F8,Y
        LDA colorRam+$2F9,Y
        STA colorRam+$2F8,Y
        LDA screen+$321,Y
        STA screen+$320,Y
        LDA colorRam+$321,Y
        STA colorRam+$320,Y
        LDA screen+$349,Y
        STA screen+$348,Y
        LDA colorRam+$349,Y
        STA colorRam+$348,Y
        LDA screen+$371,Y
        STA screen+$370,Y
        LDA colorRam+$371,Y
        STA colorRam+$370,Y
        LDA screen+$399,Y
        STA screen+$398,Y
        LDA colorRam+$399,Y
        STA colorRam+$398,Y
        INY
        CPY #$27
        BNE SS_LowerLoop
        DEC screenShiftFlag
        INC newColumnFlag
        RTS

        ; Status panel init routine when the game starts or gameplay resumes.

InitStatusPanel
        LDY #$00
ISP_Loop
        LDA statusPanelText,Y
        CMP #$FF
        BEQ ISP_Finish
        AND #$3F
        STA statusScreen,Y
        LDA #$20
        CPY #$1C
        BCS ISP_UseCustomColor
        STA statusScreen+$028,Y
        BCC ISP_UseWhiteColor
ISP_UseCustomColor 
        .BYTE $2C
ISP_UseWhiteColor
        LDA #$01
        STA colorRam+$028,Y
        LDA #$01
        STA colorRam,Y
        INY
        JMP ISP_Loop

ISP_Finish 
        LDA #$09
        LDY #$09
ISP_FinishLoop 
        STA colorRam+$029,Y
        DEY 
        BPL ISP_FinishLoop
        LDA stage
        CLC 
        ADC #$31
        STA statusScreen+$025
        RTS

statusPanelText
        .BYTE $20,$20,$4C,$49,$56,$45,$53,$20,$31,$20,$20,$20,$53,$43,$4F,$52
        .BYTE $45,$20,$20,$20,$48,$49,$20,$20,$53,$43,$4F,$52,$45,$20,$20,$53
        .BYTE $54,$41,$47,$45,$20,$31,$20,$FF

        ; Update the music part of the playroutine and wait for the IRQ handler to be ready with the previous frame
        ; update, after which a new frame can be triggered.

UpdateMusicWaitFrame
        JSR UpdateMusicChannel3
        JSR UpdateMusicChannel2
        JSR UpdateMusicChannel1
WaitFrame
        LDA frameSyncFlag
        BEQ WaitFrame
        DEC frameSyncFlag
        RTS