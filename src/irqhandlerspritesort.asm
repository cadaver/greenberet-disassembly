InitIrq SEI
        LDA #<IrqHandler
        STA $FFFE
        LDA #>IrqHandler
        STA $FFFF
        LDA #$01
        STA $D01A
        STA $DC0D
        LDA $DC0D
        LDA #>spriteOrder
        STA irqCounter
        LDA #<spriteOrder
        STA $01
        JMP SDI_AllDone

IrqHandler PHA
        TYA
        PHA 
        TXA 
        PHA 
        LDA #$FF
        STA $D019
        CLD 
irqJumpLo   =*+$01
irqJumpHi   =*+$02
        JSR SpriteDisplayIrq
        INC irqCounter
        LDA irqCounter
        CMP #$03
        BNE Irq_NoWrap
        LDA #$00
        STA irqCounter
Irq_NoWrap ASL 
        TAX 
        LDA irqJumpTblLo,X
        STA irqJumpLo
        LDA irqJumpTblHi,X
        STA irqJumpHi
ExitIrq PLA 
        TAX 
        PLA
        TAY 
        PLA
        RTI 

SortSprites LDA #$00
        STA sortSprNumReorders
        LDX #$01
SS_Loop LDY spriteOrder-1,X
        LDA spriteY,Y
        LDY spriteOrder,X
        CMP spriteY,Y
        BCS SS_InOrder
        LDA spriteY,Y
        STY sortSpriteStoreY
        STX sortSpriteStoreX
        DEX
SS_SearchPos DEX
        BMI SS_FoundPos
        LDY spriteOrder,X
        CMP spriteY,Y
        BEQ SS_FoundPos
        BCS SS_SearchPos
SS_FoundPos INX
        INC sortSprNumReorders
        STX sortMoveEndCmp
        LDX sortSpriteStoreX
SS_MoveOrderLoop LDA spriteOrder-1,X
        STA spriteOrder,X
        DEX 
        CPX sortMoveEndCmp
        BNE SS_MoveOrderLoop
        LDA sortSpriteStoreY
        STA spriteOrder,X
        LDX sortSpriteStoreX
SS_InOrder INX
        CPX #$15
        BNE SS_Loop
        PHP 
        SEI 
        LDA scrollSpeed
        CMP lastScrollSpeed
        BNE SS_HadNewScrollSpeed
        LDA #$00
        STA scrollSpeed
        PLP 
        RTS

SS_HadNewScrollSpeed   
        SEC
        SBC lastScrollSpeed
        STA scrollSpeed
        PLP
        RTS 
