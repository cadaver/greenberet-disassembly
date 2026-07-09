        ; Player state init and IRQ handler part of the frame update. The fighter jet idle timer and the "spawn
        ; modification" timer which makes the martial artists and grenadiers appear after some time are also
        ; handled here.

InitPlayer
        LDA #$03
        STA playerAnimState
        STA playerRunAnimTimer
        LDA #$08
        STA playerFacingDir
        LDA #$88
        STA playerRightLimit
        LDA #$40
        STA spriteX
        STA spriteX+SPR_PLRLOWER
        LDA #$CD
        STA spriteY
        CLC
        ADC #$15
        STA spriteY+SPR_PLRLOWER
        LDA #$80
        STA playerRunSpeed
        JMP MP_NoClimbDown

videoRegsInitTbl 
        .BYTE $00,$00,$0C,$0E,$00,$0A,$00

IrqUpdateGame
        JSR IrqUpdatePlayer
        INC frameSyncFlag
        LDX #$05
IUG_TimersLoop
        INC gameTimer,X
        DEX
        BPL IUG_TimersLoop
        INC idleTimerLSB
        BNE IUG_NoIdleOverFlow
        LDA idleTimer
        CLC
        ADC #$01
        BCS IUG_IdleAtMax
        STA idleTimer
IUG_IdleAtMax LDY stage
        LDA stageSpawnModWaitTbl,Y
        ADC spawnTblDelay
        STA spawnTblDelay
        BCC IUG_NoIdleOverFlow
        LDA spawnTblIndexMod
        CLC
        ADC #$01
        CMP stageSpawnModMaxTbl,Y
        BCS IUG_NoIdleOverFlow
        STA spawnTblIndexMod
IUG_NoIdleOverFlow
        LDA #$10
        STA $D016
textD018Value   =*+$01
        LDA #$12
        STA $D018
textVideoBank   =*+$01
        LDA #$90
        STA $DD00
        LDA #$46
        STA $D012
        RTS

stageSpawnModMaxTbl 
        .BYTE $04,$07,$0A,$0F
stageSpawnModWaitTbl 
        .BYTE $80,$AA,$D2,$FA
spawnTblDelay 
        .BYTE $00
difficultyMod
        .BYTE $00

        ; Stationary and scrolling screen split IRQ handler.

ScrollSplitIrq
        LDA $D016
        AND #$10
        ORA scrollX
        STA $D016
        LDA #$00
        STA $D001
        STA $D003
        STA $D005
        STA $D007
        STA $D009
        STA $D00B
        STA $D00D
        STA $D00F
        LDA #$0F
        STA $D018
        LDA #$92
        STA $DD00
        INC $D012
        RTS

DisplayStageNumber
        LDA stage
        SED
        CLC
        ADC #$01
        CLD
        TAX
        AND #$0F
        CLC
        ADC #$30
        STA $401C
        TXA
        AND #$F0
        LSR
        LSR
        LSR
        LSR
        CLC
        ADC #$30
        STA $401B
        RTS

        .BYTE $00,$00
