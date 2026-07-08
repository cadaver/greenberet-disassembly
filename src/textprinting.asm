ShowTitleScreen
        LDA #$00
        STA frameSyncFlag
        JSR PrintTextScreen
        JSR ToggleScreenOn
        LDY #$35
        JSR PlaySong
STS_WaitFire 
        JSR UpdateMusicWaitFrame
        LDA playerControls
        AND #$10
        BEQ STS_WaitFire
        JMP ToggleScreenOn

PrintTextScreen 
        ASL 
        TAY 
        LDX #$00
        PHP
        SEI 
        LDA #$30
        STA $01
        LDA textScreenTblLo,Y
        STA screenPtrLo
        LDA textScreenTblHi,Y
        LDY stage
        CLC 
        ADC stageTextAddrModTbl,Y
        STA screenPtrHi
        LDY #$00
PTS_Loop 
        LDA (screenPtrLo),Y
        BMI PTS_NewDestOrDone
        INY
        AND #$3F
PTS_DestLo   =*+$01
PTS_DestHi   =*+$02
        STA $FFFF,X
        INX
        JMP PTS_Loop

PTS_NewDestOrDone 
        CMP #$FF
        BEQ PTS_Done
        INY
        LDA (screenPtrLo),Y
        STA PTS_DestLo
        INY
        LDA (screenPtrLo),Y
        STA PTS_DestHi
        LDX #$00
        INY
        JMP PTS_Loop

PTS_Done 
        LDA #$35
        STA $01
        PLP 
        RTS 

stageTextAddrModTbl 
        .BYTE $00,$00,$06,$06,$00

frameCount
        .BYTE $00

InitSprites 
        LDY #$14
IS_Loop TYA 
        STA spriteOrder,Y
        TYA 
        AND #$0F
        TAX 
        LDA #$00
        STA $D000,X
        DEY
        BPL IS_Loop
        SEI 
        JSR CopySpritesToIrq
        JMP SortSprites

        .BYTE $CE,$00,$00