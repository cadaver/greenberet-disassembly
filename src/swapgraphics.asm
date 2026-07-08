SwapGraphicsData 
        TAY
        LDA $3FF0,Y
        EOR #$01
        STA $3FF0,Y
        LDA $FF95,Y
        STA sgdBankConfig
        CMP #$35
        BEQ SGD_NoIrqDisable
        SEI 
SGD_NoIrqDisable TYA
        ASL 
        TAX 
        LDA swapSrcTblLo,X
        STA screenPtrLo
        LDA swapSrcTblHi,X
        STA screenPtrHi
        LDA swapDestTblLo,X
        STA srcPtrLo
        LDA swapDestTblHi,X
        STA srcPtrHi
        LDA swapLengthTblLo,X
        STA swapEndCmp
        LDA swapLengthTblHi,X
        TAX 
sgdBankConfig   =*+$01
        LDA #$35
        STA $01
        LDY #$00
SGD_FullPageLoop LDA (srcPtrLo),Y
        STA columnSrcBase
        LDA (screenPtrLo),Y
        STA (srcPtrLo),Y
        LDA columnSrcBase
        STA (screenPtrLo),Y
        INY 
        BNE SGD_FullPageLoop
        DEX 
        BEQ SGD_FullPagesDone
        INC screenPtrHi
        INC srcPtrHi
        BNE SGD_FullPageLoop
SGD_FullPagesDone INC screenPtrHi
        INC srcPtrHi
        LDA swapEndCmp
        BEQ SGD_Done
bFF48   LDA (srcPtrLo),Y
        STA columnSrcBase
        LDA (screenPtrLo),Y
        STA (srcPtrLo),Y
        LDA columnSrcBase
        STA (screenPtrLo),Y
        INY 
swapEndCmp   =*+$01
        CPY #$00
        BNE bFF48
SGD_Done LDA #$35      
        STA $01
        CLI 
        RTS 

swapSrcTblHi   =*+$01
swapSrcTblLo 
        .WORD $D000,$8000,$9000,$D800,$D440,$8DC0,$9DC0,$C580
        .WORD $C800

swapDestTblHi   =*+$01
swapDestTblLo 
        .WORD $7A00,$A000,$B000,$7800,$7B00,$A200,$B200,$71C0
        .WORD $7800

swapLengthTblHi   =*+$01
swapLengthTblLo 
        .WORD $0440,$0DC0,$0DC0,$0800,$02D0,$0240,$0240,$0280
        .WORD $0687

        .BYTE $30,$35,$35,$30,$30,$35,$35,$35,$35

FormatWeaponShots LDA collectedExtraWeapon
        BNE FWS_HasWeapon
        RTS

FWS_HasWeapon ASL
        TAY
        DEY
        DEY
        LDA extraWeaponShotsLeft
        SEC
        SBC #$01
        ASL
        STA tempStore
        LDX #$08
FWS_EmptyShotLoop CPX tempStore
        BEQ $FFC6
        LDA #$20
        STA statusScreen+$029,X
        STA statusScreen+$02A,X
        DEX
        DEX
        BPL FWS_EmptyShotLoop
        RTS
        LDA tempStore
        BEQ $FFC5
FWS_DrawShotLoop LDA wpnShotCharsLeft,Y
        STA statusScreen+$029,X
        LDA wpnShotCharsRight,Y
        STA statusScreen+$02A,X
        LDA wpnShotColors,Y
        STA colorRam+$029,X
        STA colorRam+$02A,X
        DEX
        DEX
        BPL FWS_DrawShotLoop
        RTS

        .BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
        .BYTE $AA,$AA,$AA,$AA,$AA,$FC,$FF,$40,$40,$22,$00
