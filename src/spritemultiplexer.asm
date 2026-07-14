        ; Copy sprites from the main program for use by the sprite multiplexer IRQs. Called from the main loop.

CopySpritesToIrq
        LDA sortSprNumReorders
        BEQ CSTI_NoNewOrder

        ; If the sprite order is unchanged, it will not be copied again. Note also that sprite colors and frames are
        ; not double-buffered similarly as positions, therefore the main program could theoretically update them again
        ; while the IRQs use them for displaying, leading into the new animation frames and colors becoming visible one
        ; frame too early.

        LDX #$14
CSTI_WithOrderLoop
        LDA spriteY,X
        STA irqSpriteY,X
        LDA spriteX,X
        STA irqSpriteX,X
        LDA spriteXMSB,X
        STA irqSpriteXMSB,X
        LDA spriteOrder,X
        STA irqSpriteOrder,X
        DEX
        BPL CSTI_WithOrderLoop
        RTS

CSTI_NoNewOrder
        LDX #$14
CSTI_NoNewOrderLoop
        LDA spriteY,X
        STA irqSpriteY,X
        LDA spriteX,X
        STA irqSpriteX,X
        LDA spriteXMSB,X
        STA irqSpriteXMSB,X
        DEX
        BPL CSTI_NoNewOrderLoop
        RTS

        ; Multiplexer IRQ handler code. Sets hardware sprite values in a top-to-bottom sort order. The handler chains
        ; into more IRQs until all sprites have been displayed.

SpriteDisplayIrq 
        LDA sprIrqYCheck
        CLC
        ADC #$0E
        STA sprIrqYCheck
        CLI 
SDI_Loop 
        LDY sprIrqIndex
        LDX irqSpriteOrder,Y
        LDA irqSpriteY,X
        CMP sprIrqYCheck
        BCS SDI_Done
        STA sprIrqYStore
        LDY sprIrqHWIndex
        LDA spriteColor,X
        STA $D027,Y
        LDA spriteFrame,X
        STA screen+$3F8,Y
        LDA irqSpriteXMSB,X
        BEQ SDI_NoMSB
        LDA $D010
        ORA sprOrBitTbl,Y
        JMP SDI_StoreD010

SDI_NoMSB
        LDA $D010
        AND sprAndBitTbl,Y
SDI_StoreD010 
        STA $D010
        TYA 
        ASL
        TAY 
        LDA sprIrqYStore
        STA $D001,Y
        LDA irqSpriteX,X
        STA $D000,Y
        DEC sprIrqIndex
        BMI SDI_AllDone
        DEC sprIrqHWIndex
        BPL SDI_Loop
        LDA #$07
        STA sprIrqHWIndex
        JMP SDI_Loop

        DEC sprIrqIndex
        BMI SDI_AllDone
        JMP SDI_Loop

SDI_AllDone
        LDA #$07
        STA sprIrqHWIndex
        INC frameCount
        LDA #$F6
        STA $D012
        LDA #$32
        STA sprIrqYCheck
        RTS

SDI_Done 
        SBC #$0E
        CMP $D012
        BEQ SDI_IsLate
        BCS SDI_SetupNextIrqPos
SDI_IsLate 
        LDA $D012
        ADC #$02
SDI_SetupNextIrqPos
        ADC #$00
        STA $D012
        STA sprIrqYCheck
        PLA
        PLA
        JMP ExitIrq
