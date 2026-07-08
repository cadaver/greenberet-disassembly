PrintFullScreen ASL
        TAX
        LDA fullScreenTblLo,X
        STA srcPtrLo
        LDA fullScreenTblHi,X
        STA srcPtrHi
        LDA #<screen
        STA screenPtrLo
        LDA #>screen
        STA screenPtrHi
PFS_Loop JSR PFS_GetByte
        CMP #$FB
        BCS PFS_HandleCommand
        JSR PFS_PrintChar
        JMP PFS_Loop

PFS_HandleCommand SEC
        SBC #$FB
        ASL
        TAX
        LDA pfsCommandTblLo,X
        STA pfsCommandJumpLo
        LDA pfsCommandTblHi,X
        STA pfsCommandJumpHi
pfsCommandJumpLo   =*+$01
pfsCommandJumpHi   =*+$02
        JSR PFS_Exit
        JMP PFS_Loop

PFS_GetByte LDY #$00
        LDA (srcPtrLo),Y
        INC srcPtrLo
        BNE PFS_GetByteNoMSB
        INC srcPtrHi
PFS_GetByteNoMSB RTS

PFS_PrintChar LDY #$00
        STA (screenPtrLo),Y
        LDA screenPtrHi
        STA storeScreenPtrHi
        AND #$03
        ORA #$D8
        STA screenPtrHi
        LDA charColor
        STA (screenPtrLo),Y
        LDA storeScreenPtrHi
        STA screenPtrHi
        INC screenPtrLo
        BNE PFS_PrintCharNoMSB
        INC screenPtrHi
PFS_PrintCharNoMSB RTS

pfsCommandTblHi   =*+$01
pfsCommandTblLo .WORD PFS_RepeatChar,PFS_SetNewDestPtr,PFS_AdvanceSrcPtr,PFS_SetNewCharColor,PFS_Exit

PFS_RepeatChar JSR PFS_GetByte
        TAX
        JSR PFS_GetByte
        STA charToRepeatLot
PFS_RepeatCharLoop LDA charToRepeatLot
        JSR PFS_PrintChar
        DEX
        BNE PFS_RepeatCharLoop
        RTS

PFS_SetNewDestPtr JSR PFS_GetByte
        STA screenPtrLo
        JSR PFS_GetByte
        STA screenPtrHi
        RTS 

PFS_SetNewCharColor JSR PFS_GetByte
        STA charColor
        RTS 

PFS_Exit PLA
        PLA 
        RTS 

PFS_AdvanceSrcPtr LDA srcPtrLo
        CLC
        ADC #$14
        STA srcPtrLo
        LDA srcPtrHi
        ADC #$00
        STA srcPtrHi
        RTS

charToRepeatLot .BYTE $00
charColor   .BYTE $00
storeScreenPtrHi .BYTE $00

fullScreenTblHi   =*+$01
fullScreenTblLo .WORD stageOutroScreen,prisonWallScreen,gameTitleLogo,clearWholeScreen

ResetGraphicsSwaps LDY #$08
        PHP
RGS_Loop LDA $3FF0,Y
        BEQ RGS_Skip
        TYA
        PHA
        JSR SwapGraphicsData
        PLA
        TAY
RGS_Skip DEY
        BPL RGS_Loop
        PLP
        RTS 

wpnShotCharsLeft   .BYTE $B6
wpnShotCharsRight   .BYTE $B7,$B6,$B7,$BA,$20,$B8,$B9,$C2
        .BYTE $60,$FF