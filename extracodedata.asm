		* = $C257

wpnShotColors
         .BYTE $00,$00,$09,$09,$0D,$0D,$0F,$0F

FormatLives 
        LDA lives
        BEQ FL_ZeroLives
        CLC
        ADC #$30
        .BYTE $2C
FL_ZeroLives 
        LDA #$20
        STA statusScreen+$8
        RTS 

FormatScore 
        LDX #$02
        LDY #$00
FS_Loop LDA score,X
        PHA
        AND #$F0
        LSR
        LSR
        LSR
        LSR
        ADC #$30
        STA statusScreen+$033,Y
        INY 
        PLA
        AND #$0F
        ADC #$30
        STA statusScreen+$033,Y
        INY 
        DEX
        BPL FS_Loop
        LDA #$30
        STA statusScreen+$033,Y
        RTS 

FormatHighScore 
        LDX #$02
        LDY #$00
FHS_Loop    
        LDA highScore,X
        PHA
        AND #$F0
        LSR
        LSR 
        LSR 
        LSR
        ADC #$30
        STA statusScreen+$03D,Y
        INY 
        PLA
        AND #$0F
        ADC #$30
        STA statusScreen+$03D,Y
        INY 
        DEX 
        BPL FHS_Loop
        LDA #$30
        STA statusScreen+$03D,Y
        RTS 

AddAccumulatedScore 
        SED
        LDA scoreAdd
        CLC 
        ADC score
        STA score
        LDA scoreAdd+1
        ADC score+1
        STA score+1
        LDA scoreAdd+2
        ADC score+2
        STA score+2
        LDA #$00
        STA scoreAdd
        STA scoreAdd+1
        STA scoreAdd+2
        CLD
        RTS 

CheckNewHighScore 
        LDX #$02
CNHS_CheckLoop 
        LDA score,X
        CMP highScore,X
        BCC CNHS_Done
        BNE CNHS_HasNew
        DEX
        BPL CNHS_CheckLoop
CNHS_Done 
        RTS

CNHS_HasNew 
        LDX #$02
CNHS_CopyScoreLoop 
        LDA score,X
        STA highScore,X
        DEX 
        BPL CNHS_CopyScoreLoop
        RTS 

prisonWallScreen 
        .BYTE $FC,$00,$40,$FE,$01,$FB,$FF,$20,$FB,$91,$20,$FE,$02,$FB,$78,$9B
        .BYTE $FB,$06,$9A,$FE,$09,$9C,$FE,$02,$FB,$08,$9A,$FE,$09,$9C,$FE,$02
        .BYTE $FB,$09,$9A,$FE,$09,$9C,$FE,$02,$FB,$08,$9A,$FE,$09,$9C,$FE,$02
        .BYTE $FB,$05,$9A,$FB,$06,$9B,$FE,$09,$9C,$FE,$02,$B2,$FB,$07,$9B,$FE
        .BYTE $09,$9C,$FE,$02,$B2,$FB,$08,$9B,$FE,$09,$9C,$FE,$02,$B2,$FB,$07
        .BYTE $9B,$FE,$09,$9C,$FE,$02,$B1,$FB,$04,$9B,$FB,$06,$9A,$FE,$09,$9C
        .BYTE $FE,$02,$B1,$FB,$07,$9A,$FE,$09,$9C,$FE,$02,$B1,$FB,$08,$9A,$FE
        .BYTE $09,$9C,$FE,$02,$B1,$FB,$07,$9A,$FE,$09,$9C,$FE,$02,$B1,$FB,$04
        .BYTE $9A,$FB,$06,$99,$FE,$09,$9C,$FE,$02,$9F,$FB,$07,$99,$FE,$09,$9C
        .BYTE $FE,$02,$9F,$FB,$08,$99,$FE,$09,$9C,$FE,$02,$9F,$FB,$07,$99,$FE
        .BYTE $09,$9C,$FE,$02,$9F,$FB,$04,$99,$FE,$05,$FB,$06,$B4,$FE,$09,$9C
        .BYTE $FE,$05,$9E,$FB,$07,$B4,$FE,$09,$9C,$FE,$05,$9E,$FB,$08,$B4,$FE
        .BYTE $09,$9C,$FE,$05,$9E,$FB,$07,$B4,$FE,$09,$9C,$FE,$05,$9E,$FB,$04
        .BYTE $B4,$FB,$28,$B5,$FB,$28,$B4,$FB,$28,$B5,$FB,$28,$B4,$FB,$03,$9D
        .BYTE $FB,$22,$B3,$FE,$0D,$FB,$03,$9D,$FB,$51,$20,$FF,$09,$FF,$9C,$55
        .BYTE $40,$01,$B9,$0C,$C4,$8D,$FF,$C3,$B9,$0D,$C4,$8D,$00,$C4,$AD,$1B

        ; Ingame status screen at $c400

        * = statusScreen

        .BYTE $20,$20,$0C,$09,$16,$05,$13,$20,$32,$20,$20,$20,$13,$03,$0F,$12
        .BYTE $05,$20,$20,$20,$08,$09,$20,$20,$13,$03,$0F,$12,$05,$20,$20,$13
        .BYTE $14,$01,$07,$05,$20,$31,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
        .BYTE $20,$20,$20,$30,$30,$30,$30,$30,$30,$30,$20,$20,$20,$30,$30,$30
        .BYTE $33,$35,$36,$30

CopySpritesToIrq 
        LDA sortSprNumReorders
        BEQ CSTI_NoNewOrder
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
        INC aC563
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

aC563   .BYTE $00

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
aC580   .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$3C,$00,$00,$FF,$00,$00,$FF,$00,$00,$F5,$00,$00,$D5
        .BYTE $00,$00,$D4,$00,$00,$98,$00,$00,$AF,$F5,$00,$EA,$A4,$00,$BE,$80
        .BYTE $00,$A8,$00,$00,$A8,$00,$02,$AC,$00,$02,$AB,$00,$0B,$AB,$00,$DF
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$3C,$00,$00,$FF,$00,$00,$FF,$00,$00,$5F,$00,$00,$57
        .BYTE $00,$00,$17,$00,$00,$26,$00,$5F,$FA,$00,$1A,$AB,$00,$02,$BE,$00
        .BYTE $00,$2A,$00,$00,$2A,$00,$00,$3A,$80,$00,$EA,$80,$00,$EA,$E0,$DF
        .BYTE $00,$00,$00,$00,$00,$20,$00,$00,$28,$00,$00,$B4,$02,$A2,$AB,$2A
        .BYTE $AA,$BE,$EB,$EB,$A0,$2F,$FF,$80,$2F,$BF,$80,$2E,$AE,$A0,$2E,$03
        .BYTE $E0,$3A,$02,$8E,$E3,$00,$E0,$C3,$80,$38,$80,$A0,$08,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$80,$00,$00,$A0,$00,$02,$D0,$02,$8A,$AC,$0A
        .BYTE $AA,$F8,$2B,$AE,$80,$2E,$FE,$00,$FF,$BE,$00,$2B,$BA,$00,$0A,$EB
        .BYTE $00,$02,$F8,$00,$00,$AC,$00,$00,$A8,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$20,$00,$00,$28,$00,$00,$B4,$02
        .BYTE $A2,$AB,$2A,$AA,$BE,$EB,$EB,$A0,$2F,$FF,$80,$2F,$BE,$80,$0E,$AA
        .BYTE $80,$2A,$03,$80,$BA,$02,$E0,$EE,$0E,$38,$8E,$38,$0A,$89,$20,$00
        .BYTE $20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$08,$00,$00,$28,$00,$00,$1E,$00,$00,$EA,$8A,$80,$BE
        .BYTE $AA,$A8,$0A,$EB,$EB,$02,$FF,$F8,$02,$FE,$F8,$0A,$BA,$B8,$0B,$C0
        .BYTE $B8,$B2,$80,$AC,$0B,$00,$CB,$2C,$02,$C3,$20,$0A,$02,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$02,$00,$00,$0A,$00,$00,$07,$80,$00,$3A,$A2,$80,$2F
        .BYTE $AA,$A0,$02,$BA,$E8,$00,$BF,$B8,$00,$BE,$FF,$00,$AE,$E8,$00,$EB
        .BYTE $A0,$00,$2F,$80,$00,$3A,$00,$00,$2A,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$08,$00,$00,$28,$00,$00,$1E,$00,$00,$EA
        .BYTE $8A,$80,$BE,$AA,$A8,$0A,$EB,$EB,$02,$FF,$F8,$02,$BE,$F8,$02,$AA
        .BYTE $B0,$02,$C0,$A8,$0B,$80,$AE,$2C,$B0,$BB,$A0,$2C,$B2,$00,$08,$62
        .BYTE $00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$10,$05,$01,$24,$06,$42,$19,$01,$86,$69,$41,$99,$06,$41
        .BYTE $64,$02,$55,$64,$01,$66,$64,$01,$66,$64,$05,$A6,$99,$56,$5A,$55
        .BYTE $69,$45,$40,$19,$00,$00,$04,$00,$00,$04,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$40,$50,$04,$81,$90,$18,$92,$40,$64,$66,$41,$69,$19,$41
        .BYTE $90,$19,$55,$80,$19,$99,$40,$19,$99,$40,$66,$9A,$50,$55,$A5,$95
        .BYTE $01,$51,$69,$00,$00,$64,$00,$00,$10,$00,$00,$10,$00,$00,$00,$00
aC800   .BYTE $3C,$42,$99,$A1,$A1,$99,$42,$3C,$0C,$0C,$2C,$26,$5E,$46,$EE,$00
        .BYTE $EC,$66,$66,$6C,$66,$66,$EC,$00,$2E,$62,$E0,$E0,$E0,$62,$2E,$00
        .BYTE $E8,$6C,$66,$66,$66,$6C,$E8,$00,$EE,$66,$60,$6C,$60,$66,$EE,$00
        .BYTE $EE,$66,$60,$6C,$60,$60,$F0,$00,$2E,$66,$E0,$EE,$E6,$66,$2C,$00
        .BYTE $F6,$66,$66,$6E,$66,$66,$F6,$00,$3C,$18,$18,$18,$18,$18,$3C,$00
        .BYTE $1E,$0C,$0C,$0C,$6C,$6C,$38,$00,$F6,$64,$68,$6C,$6E,$66,$F6,$00
        .BYTE $F0,$60,$60,$60,$62,$66,$FE,$00,$C6,$EE,$7E,$B6,$86,$86,$CE,$00
        .BYTE $66,$72,$3A,$5E,$4E,$46,$E6,$00,$2C,$66,$66,$66,$66,$66,$2C,$00
        .BYTE $EC,$66,$66,$6C,$60,$60,$F0,$00,$2C,$66,$66,$66,$66,$2C,$0E,$00
        .BYTE $EC,$66,$66,$6C,$68,$64,$F6,$00,$2E,$66,$60,$3C,$06,$66,$6C,$00
        .BYTE $7E,$5A,$18,$18,$18,$18,$18,$00,$F6,$62,$62,$62,$62,$62,$2C,$00
        .BYTE $F6,$62,$62,$62,$22,$3C,$18,$00,$E6,$C2,$C2,$D2,$DA,$EC,$C6,$00
        .BYTE $CE,$CC,$68,$30,$58,$4C,$CE,$00,$E6,$62,$34,$18,$18,$18,$3C,$00
        .BYTE $76,$46,$0C,$18,$30,$66,$6E,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $6C,$FE,$FE,$FE,$7C,$38,$10,$00,$F4,$86,$86,$E5,$85,$84,$F4,$00
        .BYTE $B8,$A4,$A4,$A4,$A4,$A4,$B8,$00,$FF,$81,$81,$81,$81,$81,$81,$FF
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$F4,$94,$94,$F4,$A4,$94,$97,$00
        .BYTE $B8,$A4,$A4,$B8,$A4,$A4,$B8,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $C5,$10,$15,$5D,$71,$0D,$51,$51,$55,$55,$55,$5C,$71,$45,$C5,$15
        .BYTE $57,$57,$57,$57,$57,$57,$57,$57,$40,$55,$55,$55,$55,$55,$55,$55
        .BYTE $FF,$FF,$BF,$DB,$E7,$EF,$DF,$BF,$AA,$FD,$F3,$ED,$DB,$FD,$FF,$FF
        .BYTE $7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$00,$55,$55,$55,$75,$4D,$53,$54
        .BYTE $2C,$66,$66,$66,$66,$66,$2C,$00,$38,$18,$18,$18,$18,$18,$3C,$00
        .BYTE $2C,$66,$06,$0C,$30,$06,$7E,$00,$34,$66,$06,$14,$06,$66,$34,$00
        .BYTE $06,$16,$26,$46,$7F,$06,$0F,$00,$7E,$18,$40,$6C,$06,$66,$6C,$00
        .BYTE $2C,$66,$60,$6C,$66,$66,$2C,$00,$7E,$60,$04,$0C,$18,$18,$18,$00
        .BYTE $2C,$66,$66,$2C,$66,$66,$2C,$00,$2C,$66,$66,$2E,$06,$66,$2C,$00
        .BYTE $00,$00,$18,$00,$00,$18,$00,$00,$18,$08,$10,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$18,$18,$00,$24,$24,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$18,$08,$10,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
aCA00   .BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$55,$55,$55,$55,$55,$55,$55,$55
        .BYTE $E4,$E7,$E7,$E4,$E7,$E7,$E4,$E7,$00,$00,$C0,$40,$B0,$90,$2C,$24
        .BYTE $0B,$F9,$02,$3E,$C0,$0F,$F0,$00,$0F,$F2,$88,$22,$22,$84,$22,$22
        .BYTE $F0,$03,$FC,$8A,$22,$88,$22,$88,$00,$00,$0F,$F0,$03,$3C,$C0,$0F
        .BYTE $88,$22,$22,$88,$22,$22,$88,$00,$88,$22,$22,$88,$22,$22,$88,$00
        .BYTE $2D,$8D,$2D,$8D,$2D,$8D,$2D,$8D,$C4,$0F,$31,$CF,$2D,$8D,$2D,$8D
        .BYTE $00,$00,$00,$00,$0F,$F0,$23,$3C,$88,$62,$1A,$46,$11,$50,$55,$55
        .BYTE $A2,$22,$88,$22,$A2,$68,$58,$56,$2D,$8D,$2D,$8D,$2D,$8D,$2D,$4D
        .BYTE $D5,$D5,$D5,$D5,$D5,$D5,$D5,$D5,$55,$55,$55,$55,$55,$15,$45,$51
        .BYTE $00,$02,$0B,$2F,$BF,$FF,$FF,$FF,$AA,$BF,$BF,$BF,$BF,$BF,$BF,$BF
aCAA0   .BYTE $FF,$FC,$F1,$C5,$15,$55,$55,$55,$AA,$BF,$BF,$BF,$BB,$AF,$BF,$BF
        .BYTE $AA,$EF,$EF,$EF,$EF,$EF,$EF
aCAB7   .BYTE $EF,$AA,$FC,$FC,$FC,$EC,$BC,$FC,$FC,$80,$BF,$BF,$BE,$BB,$BF,$BF
        .BYTE $00,$00,$EF,$EF,$EC,$EF,$EC,$EF,$00,$00,$FC,$30,$0C,$0C,$C0,$FC
        .BYTE $00,$00,$FF,$FF,$00,$00,$00,$00,$00,$55,$11,$55,$11,$55,$55,$55
        .BYTE $55,$FF,$FF,$D6,$FF,$F3,$FF,$FF,$00,$FE,$FE,$D6,$FE,$5E,$FE,$FE
        .BYTE $00,$55,$55,$55,$55,$A9,$02,$AB,$FC,$55,$55,$55,$55,$AA,$00,$AA
        .BYTE $FF,$00,$00,$00,$00,$0A,$20,$2E,$2F,$30,$0C,$30,$33,$33,$33,$33
        .BYTE $0C,$30,$0F,$0F,$33,$3F,$3F,$3F,$0F,$00,$FF,$FF,$FF,$FF,$FF,$FF
        .BYTE $FF,$03,$C0,$F0,$F0,$FC,$FC,$C3,$FC,$00,$00,$00,$00,$AA,$00,$AA
        .BYTE $FF,$00,$00,$00,$00,$A8,$02,$AB,$FC,$3D,$3D,$3D,$3D,$3D,$3D,$3D
        .BYTE $3D,$FF,$FF,$00,$00,$00,$00,$00,$FF,$00,$55,$55,$55,$55,$55,$55
        .BYTE $55,$00,$D5,$D5,$D5,$D5,$D5,$D5,$D5,$38,$38,$38,$38,$38,$38,$38
        .BYTE $38,$01,$03,$07,$0F,$1F,$3F,$7F,$FF,$80,$C0,$E0,$F0,$F8,$FC,$FE
        .BYTE $FF,$D0,$D0,$D0,$D0,$D0,$D0,$D0,$D0,$07,$07,$07,$07,$07,$07,$07
        .BYTE $07,$AA,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$1C,$7F,$E3,$C1,$C1,$C1,$E3
        .BYTE $7E,$03,$13,$1F,$7F,$7F,$1F,$13,$03,$00,$FF,$AA,$00,$00,$00,$00
        .BYTE $00,$E0,$90,$88,$84,$88,$90,$E0,$00,$3F,$FF,$CF,$0A,$08,$08,$08
        .BYTE $28,$F0,$FC,$CC,$80,$80,$80,$80,$A0,$00,$FF,$AA,$03,$0F,$0F,$03
        .BYTE $0A,$00,$FF,$AA,$00,$C0,$C0,$00,$80,$00,$70,$78,$7C,$78,$70,$00
        .BYTE $00,$54,$54,$54,$54,$54,$54,$54,$54,$00,$54,$54,$54,$54,$54,$54
        .BYTE $54,$A8,$FC,$FC,$FC,$FC,$FC,$FC,$FC,$30,$0C,$30,$33,$AA,$00,$AA
        .BYTE $FF,$00,$FF,$FF,$FF,$AB,$02,$AB,$FC,$00,$00,$03,$0F,$1F,$3F,$3F
        .BYTE $7E,$3F,$FF,$FF,$E0,$80,$00,$00,$00,$E0,$FB,$FF,$7E,$1C,$18,$10
        .BYTE $00,$FF,$7F,$1F,$0F,$0F,$0F,$0F,$0F,$80,$FF,$FF,$FF,$FF,$E0,$C0
        .BYTE $C0,$00,$E0,$FC,$FE,$FE,$FF,$3F,$1F,$FF,$7F,$1F,$0F,$0F,$0F,$0F
        .BYTE $0F,$00,$FF,$FF,$C0,$80,$00,$00,$00,$3F,$FF,$FE,$7C,$18,$10,$00
        .BYTE $00,$FE,$7E,$3F,$3F,$3F,$1F,$1F,$1F,$00,$00,$00,$80,$C0,$E0,$E0
        .BYTE $F0,$FF,$7E,$3C,$3C,$3C,$3C,$3C,$7C,$FF,$7F,$1F,$0F,$0F,$0F,$0F
        .BYTE $0F,$80,$FF,$FF,$FF,$FF,$E0,$C0,$C0,$00,$E0,$FC,$FE,$FE,$FF,$3F
        .BYTE $1F,$3F,$7F,$7F,$FF,$C0,$80,$00,$00,$E7,$FF,$FF,$FF,$FF,$7E,$7E
        .BYTE $7E,$FF,$FF,$FE,$FE,$04,$04,$00,$00,$C0,$E0,$30,$38,$0C,$0E,$03
        .BYTE $03,$03,$0B,$0C,$2C,$30,$B0,$C0,$C0,$C3,$EB,$3C,$0C,$30,$BE,$C3
        .BYTE $C3,$CB,$EB,$3B,$3B,$0F,$0F,$0B,$0B,$E3,$EB,$EC,$EC,$F0,$F0,$E0
        .BYTE $E0,$0B,$0B,$0F,$2F,$3B,$BB,$CB,$CB,$C0,$E0,$F0,$F8,$EC,$EE,$E3
        .BYTE $E3,$7E,$7F,$3E,$00,$E7,$F7,$F3,$00,$FE,$7C,$00,$8F,$DF,$8F,$00
        .BYTE $F8,$FC,$FC,$00,$E7,$EF,$EF,$00,$FE,$F8,$F8,$F8,$F8,$F8,$F8,$F8
        .BYTE $F8,$00,$FF,$FF,$FF,$00,$FF,$FF,$00,$00,$02,$03,$0C,$03,$0C,$33
        .BYTE $CC,$40,$40,$00,$00,$C0,$C0,$C0,$00,$7E,$7E,$00,$FC,$FC,$FC,$FC
        .BYTE $FC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$7E,$3C
        .BYTE $3C,$0F,$0F,$00,$1F,$1F,$1F,$1F,$1F,$C0,$C0,$00,$E0,$FF,$FF,$80
        .BYTE $00,$1F,$1F,$00,$FE,$FC,$F8,$F8,$78,$1F,$1F,$00,$1F,$1F,$1F,$1F
        .BYTE $1F,$00,$01,$00,$FF,$FF,$87,$01,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$1F,$1F,$00,$3F,$3F,$3F,$3F,$3E,$FC,$FC,$00,$3E,$3F,$1F,$1F
        .BYTE $0F,$7C,$7C,$00,$78,$78,$F0,$F0,$F0,$0F,$0F,$00,$1F,$1F,$1F,$1F
        .BYTE $1F,$C0,$C0,$00,$E0,$FF,$FF,$80,$00,$1F,$1F,$00,$FE,$FC,$F8,$F8
        .BYTE $7C,$00,$00,$00,$00,$00,$00,$00,$00,$7E,$3F,$00,$3F,$3F,$3F,$3F
        .BYTE $FC,$E0,$60,$00,$80,$C0,$80,$00,$E0,$E0,$E0,$00,$E0,$E0,$E0,$00
        .BYTE $E0,$FF,$FF,$FF,$00,$FF,$FF,$FF,$FF,$CC,$33,$CC,$33,$CC,$33,$CC
        .BYTE $33,$CC,$CC,$33,$33,$CC,$CC,$33,$33,$00,$C0,$55,$DF,$65,$65,$40
        .BYTE $00,$00,$00,$50,$F4,$5C,$50,$00,$00,$00,$00,$0F,$3F,$FF,$FB,$0F
        .BYTE $00,$03,$CF,$FF,$FC,$EC,$B0,$C0,$00,$18,$66,$FF,$BD,$E7,$BD,$E7
        .BYTE $3C,$01,$37,$C5,$45,$45,$45,$35,$01,$00,$F0,$5E,$57,$05,$F5,$54
        .BYTE $40,$00,$00,$00,$FF,$11,$55,$00,$00,$00,$C0,$40,$FC,$14,$50,$00
        .BYTE $00,$55,$AA,$AA,$FF,$D7,$DF,$DF,$FF,$FC,$7C,$7E,$3E,$3F,$1F,$0F
        .BYTE $07,$00,$00,$00,$00,$01,$C7,$FF,$FF,$3C,$78,$F8,$F8,$F0,$E0,$C0
        .BYTE $80,$1F,$3F,$3F,$3E,$3E,$3E,$7F,$FF,$00,$00,$00,$00,$00,$00,$00
        .BYTE $81,$7C,$7C,$7C,$7C,$7C,$7C,$FE,$FF,$3F,$3F,$3F,$3F,$3F,$3F,$7F
        .BYTE $FF,$00,$00,$00,$00,$80,$C0,$FF,$FF,$00,$00,$01,$07,$0F,$1E,$FE
        .BYTE $FC,$3E,$3E,$3E,$7E,$7E,$7F,$7F,$FF,$0F,$07,$07,$03,$03,$03,$81
        .BYTE $C1,$F0,$E0,$E0,$E0,$C0,$C0,$C0,$C0,$1F,$3F,$3F,$3F,$3F,$3F,$7F
        .BYTE $FF,$00,$00,$00,$00,$00,$80,$FF,$FF,$1E,$1F,$1F,$1F,$3F,$FE,$FC
        .BYTE $F0,$00,$00,$00,$00,$00,$01,$03,$07,$FC,$FC,$FC,$FC,$FC,$FC,$FE
        .BYTE $FF

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

        ; Data under IO area ($d000)

        * = $d000

        .BYTE $00,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$54,$54,$54,$54,$54,$54,$54,$54
        .BYTE $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$30,$30,$30,$30,$30,$30,$30,$30
        .BYTE $00,$00,$00,$00,$40,$40,$50,$54,$30,$C0,$C0,$C0,$03,$00,$00,$00
        .BYTE $40,$40,$00,$00,$01,$01,$05,$15,$12,$12,$12,$12,$12,$12,$12,$12
        .BYTE $84,$84,$84,$84,$84,$84,$84,$84,$C2,$A2,$42,$42,$42,$42,$12,$12
        .BYTE $C1,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$13,$43,$43,$43,$0F,$0F,$3F,$FF
        .BYTE $C4,$C0,$C0,$C0,$F0,$F0,$FC,$FF,$C1,$C1,$C1,$C1,$F1,$F0,$FC,$FF
        .BYTE $01,$01,$01,$01,$41,$40,$50,$54,$07,$07,$07,$07,$07,$07,$07,$07
        .BYTE $55,$55,$55,$55,$55,$55,$55,$55,$FF,$00,$54,$54,$FC,$D4,$D4,$D4
        .BYTE $AB,$00,$00,$01,$02,$00,$00,$00,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4
        .BYTE $3F,$3F,$0F,$0F,$C3,$C3,$F0,$F0,$FC,$FC,$F0,$F0,$C3,$C3,$0F,$0F
        .BYTE $FC,$FC,$F0,$F0,$C3,$C3,$0F,$0F,$3F,$3F,$0F,$0F,$C3,$C3,$F0,$F0
        .BYTE $00,$55,$00,$FF,$FF,$FF,$FF,$FF,$76,$00,$D0,$00,$00,$E0,$00,$00
        .BYTE $BF,$00,$C7,$AF,$0F,$1F,$7F,$FF,$77,$00,$FF,$FE,$FC,$41,$E0,$C3
        .BYTE $D5,$55,$55,$D5,$D5,$55,$D5,$D5,$0A,$0E,$22,$22,$22,$2C,$2C,$2C
        .BYTE $FF,$00,$CF,$CF,$F0,$F3,$FC,$FC,$AA,$AA,$AA,$AA,$AA,$AB,$AD,$F5
        .BYTE $AA,$AA,$AA,$AF,$B5,$D5,$55,$55,$AB,$BD,$D5,$55,$55,$55,$55,$55
        .BYTE $FF,$55,$55,$00,$FF,$55,$55,$00,$55,$15,$C4,$77,$51,$5D,$54,$57
        .BYTE $55,$55,$55,$51,$5D,$45,$75,$55,$54,$54,$54,$54,$54,$54,$54,$54
        .BYTE $EA,$7E,$57,$55,$55,$55,$55,$55,$AA,$AA,$AA,$FA,$5E,$57,$55,$55
        .BYTE $AA,$AA,$AA,$AA,$AA,$EA,$7A,$5F,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5
        .BYTE $57,$57,$55,$57,$57,$57,$57,$55,$B6,$00,$0F,$00,$00,$0B,$00,$00
        .BYTE $EF,$00,$FF,$3F,$0F,$01,$00,$00,$FD,$00,$F0,$F8,$F8,$FE,$F7,$5F
        .BYTE $93,$00,$00,$54,$80,$00,$E0,$78,$A8,$A0,$B8,$88,$88,$18,$38,$38
        .BYTE $FC,$00,$F3,$F3,$0F,$CF,$3F,$3F,$C0,$F0,$30,$3C,$4C,$4F,$53,$53
        .BYTE $C0,$CF,$CC,$00,$10,$00,$0F,$F0,$C0,$30,$00,$00,$00,$00,$0F,$F0
        .BYTE $03,$0F,$0C,$3C,$31,$F1,$C5,$C5,$00,$00,$00,$00,$00,$00,$0F,$F0
        .BYTE $FC,$F0,$0F,$00,$00,$00,$00,$00,$FC,$F0,$0F,$F0,$00,$0F,$30,$00
        .BYTE $00,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$C0,$30,$30,$0C,$0C,$00
        .BYTE $00,$00,$03,$0C,$0C,$30,$30,$00,$00,$00,$00,$00,$00,$00,$FF,$FF
        .BYTE $55,$55,$41,$3C,$C3,$C3,$3C,$FF,$00,$FC,$00,$73,$7C,$00,$FF,$FF
        .BYTE $40,$3F,$FF,$FF,$FF,$FF,$FC,$C0,$00,$FF,$FF,$FF,$FF,$FF,$00,$00
        .BYTE $02,$F0,$FC,$FC,$FC,$FC,$FF,$0F,$02,$3C,$FC,$F0,$C3,$CC,$C0,$00
        .BYTE $55,$00,$FF,$FF,$00,$FF,$00,$55,$00,$FF,$33,$30,$33,$0F,$00,$00
        .BYTE $02,$FC,$CC,$C0,$CC,$FC,$00,$02,$C0,$00,$00,$01,$05,$00,$FF,$FF
        .BYTE $55,$55,$55,$55,$50,$4F,$3F,$3F,$55,$55,$55,$55,$05,$F1,$FC,$FC
        .BYTE $55,$54,$53,$53,$4F,$4F,$3F,$3F,$41,$30,$CC,$CF,$3F,$4F,$4F,$53
        .BYTE $55,$55,$55,$55,$55,$00,$FF,$FF,$55,$55,$55,$55,$55,$55,$15,$C5
        .BYTE $C5,$F1,$F1,$3C,$0C,$0F,$03,$03,$C5,$C5,$31,$31,$31,$31,$C5,$C5
        .BYTE $53,$4F,$4F,$3C,$30,$F0,$C0,$C0,$00,$0F,$F0,$F1,$C1,$C4,$C4,$C4
        .BYTE $00,$00,$FF,$55,$55,$00,$00,$00,$FF,$FC,$FF,$8F,$3B,$F3,$BF,$3F
        .BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FC,$F0,$02
        .BYTE $FF,$FF,$FF,$F0,$C0,$0A,$25,$95,$F0,$C0,$0A,$29,$A5,$95,$55,$55
        .BYTE $0A,$25,$95,$55,$55,$00,$00,$00,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3
        .BYTE $00,$CF,$CC,$CC,$CC,$CF,$00,$00,$55,$54,$40,$00,$00,$00,$00,$00
        .BYTE $55,$55,$55,$55,$54,$00,$00,$00,$00,$00,$FF,$55,$55,$55,$55,$55
        .BYTE $F0,$C0,$0A,$29,$A5,$95,$50,$40,$39,$39,$39,$39,$39,$39,$39,$39
        .BYTE $00,$00,$0F,$3A,$39,$39,$39,$39,$FF,$3F,$8F,$8F,$8F,$A3,$A3,$A3
        .BYTE $28,$28,$28,$28,$0A,$0A,$0A,$0A,$8F,$8F,$8F,$8F,$A3,$A3,$A3,$A3
        .BYTE $02,$C2,$C2,$C2,$C0,$C0,$00,$00,$FF,$0F,$00,$A0,$5A,$55,$05,$00
        .BYTE $28,$28,$0A,$0A,$00,$00,$00,$00,$00,$F0,$0F,$8F,$83,$23,$23,$23
        .BYTE $00,$00,$03,$03,$0F,$00,$00,$00,$8A,$0A,$0A,$A2,$02,$28,$20,$00
        .BYTE $20,$22,$88,$88,$0A,$AA,$80,$00,$AA,$AA,$AA,$AA,$AA,$AA,$2A,$2A
        .BYTE $AA,$8A,$22,$22,$08,$28,$02,$0A,$AA,$AA,$AA,$AA,$AA,$AA,$FF,$FF
        .BYTE $00,$00,$01,$01,$05,$00,$00,$00,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
        .BYTE $0A,$0A,$0A,$0A,$0F,$00,$00,$0F,$FF,$FC,$CF,$00,$55,$00,$00,$FF
        .BYTE $10,$10,$40,$40,$22,$22,$00,$FF,$1F,$13,$13,$10,$05,$00,$00,$FF
        .BYTE $FF,$FF,$FF,$3F,$4F,$13,$04,$FF,$FF,$FF,$FF,$FC,$F1,$C4,$10,$FF
        .BYTE $AA,$AA,$AA,$AA,$FC,$CC,$C0,$FF,$F3,$3C,$FF,$FF,$FF,$FF,$FF,$FF
        .BYTE $01,$01,$05,$00,$00,$00,$FF,$00,$14,$14,$00,$00,$FF,$F3,$C0,$FF
        .BYTE $28,$00,$00,$00,$00,$10,$10,$10,$14,$14,$00,$00,$00,$FF,$F0,$C5
        .BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$81,$81,$81,$81,$81,$81,$81,$81
        .BYTE $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$13,$13,$13,$13,$13,$13,$13,$13
        .BYTE $00,$EE,$66,$66,$66,$66,$F7,$00,$00,$FC,$C0,$F8,$0C,$0C,$F8,$00
        .BYTE $40,$40,$00,$00,$02,$02,$0A,$2A,$55,$55,$54,$53,$53,$4D,$35,$35
        .BYTE $55,$55,$55,$55,$57,$57,$53,$4D,$FF,$00,$55,$00,$55,$00,$55,$00
        .BYTE $FF,$FF,$B3,$FF,$8B,$FF,$FF,$00,$94,$80,$CC,$F8,$F0,$01,$FE,$00
        .BYTE $2D,$AE,$AF,$87,$89,$80,$7F,$00,$00,$00,$00,$00,$00,$00,$00,$00
aD440   .BYTE $55,$55,$55,$55,$55,$55,$15,$C5,$55,$55,$55,$55,$15,$C5,$C5,$00
        .BYTE $00,$C3,$82,$BE,$28,$08,$08,$08,$45,$45,$99,$11,$11,$11,$45,$00
        .BYTE $78,$78,$78,$FA,$FA,$D6,$14,$00,$78,$78,$78,$78,$78,$78,$78,$78
        .BYTE $55,$55,$55,$5D,$51,$78,$78,$78,$AA,$BF,$BF,$BE,$BB,$BF,$BF,$AA
        .BYTE $AA,$E3,$E3,$E3,$E3,$E3,$E3,$AA,$AA,$FC,$FC,$EC,$BC,$FC,$FC,$A8
        .BYTE $80,$BF,$BF,$BB,$AF,$BF,$BF,$80,$20,$E3,$E3,$E3,$E3,$E3,$E3,$00
        .BYTE $00,$FC,$EC,$EC,$BC,$FC,$FC,$00,$FF,$FF,$3F,$0C,$5D,$55,$55,$55
        .BYTE $AA,$00,$71,$71,$71,$71,$71,$71,$AA,$00,$C7,$7C,$71,$47,$CC,$01
        .BYTE $54,$54,$54,$54,$54,$54,$54,$54,$15,$15,$15,$15,$15,$15,$15,$15
        .BYTE $D5,$15,$D5,$D5,$15,$15,$D5,$D5,$55,$55,$45,$55,$11,$55,$11,$55
        .BYTE $55,$55,$45,$54,$54,$14,$54,$51,$55,$55,$15,$54,$55,$45,$55,$55
        .BYTE $FF,$AA,$00,$00,$00,$00,$00,$00,$55,$55,$57,$5C,$51,$75,$C5,$15
        .BYTE $FF,$F7,$00,$55,$00,$00,$55,$55,$38,$38,$38,$38,$38,$38,$38,$38
        .BYTE $51,$51,$73,$CF,$3C,$35,$00,$00,$FF,$FF,$FE,$3C,$30,$00,$00,$00
        .BYTE $AA,$AA,$AB,$BF,$DF,$FD,$BF,$F7,$00,$EF,$CF,$00,$FE,$FC,$00,$EF
        .BYTE $FF,$FC,$00,$EE,$C0,$00,$FC,$E0,$54,$54,$54,$54,$54,$54,$54,$54
        .BYTE $FE,$FC,$00,$EF,$CF,$00,$FE,$FC,$00,$EF,$CF,$00,$FE,$FC,$00,$EF
        .BYTE $55,$D5,$EA,$3F,$40,$55,$55,$00,$55,$55,$AA,$FF,$00,$55,$55,$00
        .BYTE $55,$55,$55,$55,$55,$55,$55,$00,$55,$5B,$AB,$FC,$01,$55,$55,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$C5,$C1,$C4,$85,$FF,$FF,$00,$C0
        .BYTE $71,$71,$71,$60,$F1,$F1,$01,$31,$AA,$FF,$FF,$AA,$00,$51,$45,$15
        .BYTE $AA,$FF,$FF,$AA,$00,$45,$51,$55,$D5,$DD,$D1,$D5,$D5,$DD,$D1,$C0
        .BYTE $54,$5C,$50,$54,$54,$5C,$50,$00,$00,$EF,$CF,$00,$FE,$FC,$00,$EF
        .BYTE $55,$D5,$EA,$3F,$40,$55,$55,$00,$55,$55,$AA,$FF,$00,$55,$55,$00
        .BYTE $55,$5B,$AB,$FC,$01,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$CF,$CF,$FF,$D5,$C0,$C0,$C0,$CF
        .BYTE $C4,$C1,$C4,$C1,$FF,$EA,$C0,$C1,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5
        .BYTE $44,$11,$44,$11,$FF,$AA,$00,$11,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $55,$55,$55,$55,$55,$55,$55,$55,$FF,$AA,$C0,$C0,$C0,$C0,$30,$30
        .BYTE $0F,$2A,$30,$30,$30,$30,$0C,$0C,$F0,$A4,$00,$00,$00,$00,$C0,$C0
        .BYTE $30,$30,$FF,$AA,$30,$30,$30,$30,$83,$8B,$83,$83,$83,$83,$83,$83
        .BYTE $77,$00,$FF,$AA,$40,$40,$30,$30,$55,$55,$55,$55,$55,$55,$55,$55
        .BYTE $FF,$F7,$00,$00,$55,$55,$55,$00,$FF,$F7,$00,$00,$55,$55,$55,$00
        .BYTE $55,$5B,$AB,$FC,$01,$55,$55,$00,$7F,$7F,$7F,$7F,$75,$55,$40,$50
        .BYTE $CF,$CF,$C0,$C3,$C0,$FF,$D5,$C0,$CC,$3C,$0C,$FC,$3C,$FC,$5C,$0C
        .BYTE $00,$F7,$FF,$00,$DF,$FF,$FF,$00,$53,$53,$53,$4F,$4F,$0F,$3F,$C0
        .BYTE $00,$FF,$F7,$00,$7F,$F7,$FF,$00,$35,$C7,$C7,$C5,$C7,$45,$31,$40
        .BYTE $4D,$F3,$F3,$73,$F3,$53,$45,$10,$00,$3F,$CF,$00,$C7,$CF,$3F,$00
        .BYTE $00,$CD,$CD,$03,$F3,$F3,$D3,$03,$55,$FF,$5F,$FF,$F7,$55,$55,$00
        .BYTE $00,$F7,$FF,$00,$DF,$FF,$FF,$00,$AA,$FF,$FF,$EA,$E0,$E1,$E1,$E1
        .BYTE $FF,$F7,$00,$00,$55,$55,$55,$00,$54,$51,$45,$55,$FF,$FF,$00,$00
        .BYTE $AA,$FF,$FF,$AA,$00,$51,$45,$15,$AA,$FF,$FF,$AA,$00,$45,$51,$55
        .BYTE $FE,$FC,$00,$EF,$CF,$00,$FE,$FC,$00,$EF,$CF,$00,$FE,$FC,$00,$EF
        .BYTE $00,$EF,$07,$00,$F1,$0C,$00,$1F,$FE,$07,$00,$C7,$15,$00,$7C,$78
        .BYTE $0F,$2A,$30,$30,$30,$30,$0C,$0C,$F0,$A4,$00,$00,$00,$00,$C0,$C0
        .BYTE $30,$30,$FF,$AA,$30,$30,$30,$30,$83,$8B,$83,$83,$83,$83,$83,$83
        .BYTE $77,$00,$FF,$AA,$40,$40,$30,$30,$55,$55,$55,$55,$55,$55,$55,$00
        .BYTE $FF,$F7,$00,$00,$55,$55,$55,$00,$FF,$F7,$00,$00,$55,$55,$55,$00
        .BYTE $55,$5B,$AB,$FC,$01,$55,$55,$00,$7F,$7F,$7F,$7F,$75,$55,$40,$50
        .BYTE $CF,$CF,$C0,$C3,$C0,$FF,$D5,$C0,$CC,$3C,$0C,$FC,$3C,$FC,$5C,$0C
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$FF,$F7,$00,$7F,$F7,$FF,$00,$35,$C7,$C7,$C5,$C7,$45,$31,$40
        .BYTE $4D,$F3,$F3,$73,$F3,$53,$45,$10,$00,$3F,$CF,$00,$C7,$CF,$3F,$00
        .BYTE $00,$CD,$CD,$03,$F3,$F3,$D3,$03,$55,$FF,$5F,$FF,$F7,$55,$55,$00
        .BYTE $00,$F7,$FF,$00,$DF,$FF,$FF,$00,$AA,$FF,$FF,$EA,$E0,$E1,$E1,$E1
        .BYTE $00,$FF,$F7,$00,$7F,$F7,$FF,$00,$54,$51,$45,$55,$FF,$FF,$00,$00
        .BYTE $AA,$FF,$FF,$AA,$00,$51,$45,$15,$AA,$FF,$FF,$AA,$00,$45,$51,$55
        .BYTE $FE,$FC,$00,$EF,$CF,$00,$FE,$FC,$00,$EF,$CF,$00,$FE,$FC,$00,$EF
        .BYTE $00,$EF,$07,$00,$F1,$0C,$00,$1F,$FE,$07,$00,$C7,$15,$00,$7C,$78
        .BYTE $20,$42,$9D,$A1,$A1,$9D,$42,$3C,$AA,$AA,$AB,$AF,$BF,$BF,$F7,$FF
        .BYTE $AA,$AA,$AB,$AF,$AF,$BF,$B7,$FD,$AA,$FA,$FE,$FF,$F7,$FF,$DF,$FF
        .BYTE $AA,$AA,$AB,$EF,$FF,$FF,$FD,$F5,$FA,$EA
        .BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$EA,$FA,$FA,$FE,$EA,$FA
        .BYTE $FA,$FE,$DF,$FF,$7F,$5F,$EA,$FE,$FF,$DF,$F7,$7F,$57,$55,$FF,$7F
        .BYTE $5F,$5F,$57,$55,$55,$55
        .BYTE $AA,$AA,$AA,$AA,$AA,$AF,$BF,$FF,$AA,$AB,$AF,$BF,$F7,$FF,$DF,$F5
        .BYTE $FF,$7D,$FD,$F5,$D5,$D5,$55,$55,$DD,$D5,$57,$55,$75,$55,$55,$5D
        .BYTE $D7,$57,$DD,$55,$55,$55,$75,$55,$FF,$DF,$7D,$FF,$FF,$FF,$DF,$FF
        .BYTE $00,$FF,$F7,$00,$7F,$F7,$FF,$00,$00,$F7,$FF,$00,$DF,$FF,$FF,$00
        .BYTE $00,$FF,$DF,$00,$F7,$FF,$FF,$00,$15,$1D,$11,$37,$1C,$35,$05,$15
        .BYTE $D7,$3D,$53,$75,$55,$7D,$47,$54,$5F,$DC,$DD,$33,$7C,$4D,$DF,$3C
        .BYTE $75,$75,$4D,$57,$F4,$15,$5D,$53,$C7,$24,$45,$45,$E5,$05,$4D,$47
        .BYTE $AA,$AA,$AA,$AA,$BA,$FA,$1E,$B2,$BA,$7A,$6E,$72,$EA,$2A,$AA,$AA
        .BYTE $AA,$EA,$6E,$F2,$1A,$B6,$EF,$A3,$B5,$7D,$4D,$75,$75,$C5,$55,$55
        .BYTE $5D,$51,$7D,$CD,$CD,$15,$4D,$5D,$0F,$0F,$03,$03,$00,$00,$0A,$0A
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$5D,$7F,$00,$7F,$77,$7F,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
        .BYTE $05,$F5,$DD,$01,$FD,$DD,$FD,$01,$7F,$7F,$7F,$7F,$75,$55,$40,$50
        .BYTE $FD,$DD,$FD,$F5,$55,$55,$01,$05,$55,$D7,$F7,$F7,$F3,$51,$45,$00
        .BYTE $55,$FF,$F7,$75,$D7,$55
        .BYTE $55,$00,$55,$FF,$5F,$FF,$F7,$55,$55,$00
        .BYTE $AA,$AA,$AA,$AA,$AA,$EA,$FA,$FE,$55,$55,$55,$55,$F5,$0D,$51,$55
        .BYTE $7D,$F1,$C5,$15,$55,$55,$55,$00,$55,$55,$55,$55,$55,$57,$5F,$5C
        .BYTE $57,$5F,$7C,$71,$F1,$C5,$15,$00,$55,$55,$57,$57,$5F,$7C,$F1,$C0
        .BYTE $DF,$F5,$3D,$4D,$4F,$53,$54,$00,$75,$5D,$D5,$55,$55,$D5,$F5,$35
        .BYTE $3D,$4F,$53,$54,$55,$55,$55,$00,$55,$55,$D5,$D5,$F5,$3D,$4F,$03
        .BYTE $55,$55,$55,$55,$55,$55,$55,$00,$E1,$E1,$E1,$E1,$E1,$E1,$E1,$E1
        .BYTE $FE,$FE,$FF,$FF,$FF,$FF,$3F,$3F,$55,$55,$95,$95,$E5,$E5,$F9,$F9
        .BYTE $4F,$4F,$53,$53,$54,$54,$55,$55,$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B
        .BYTE $D5,$D5,$D5,$D5,$D6,$D6,$DB,$DB,$6F,$6F,$BF,$BF,$FF,$FF,$FF,$FF
        .BYTE $FC,$FC,$F1,$F1,$C5,$C5,$15,$15,$55,$55,$55,$55,$56,$56,$5B,$5B
        .BYTE $A8,$FC,$FC,$FC,$FC,$FC,$FC,$00,$A8,$FC,$FC,$FC,$FC,$FC,$FC,$00
        .BYTE $54,$54,$94,$94,$E4,$E4,$F8,$F8,$FC,$FC,$F0,$F0,$C4,$C4,$14,$14
        .BYTE $54,$54,$54,$54,$54,$54,$54,$54,$AA
        .BYTE $FF,$FF,$FE,$FC,$FF,$FF,$00,$FF,$00,$00,$00,$00,$00,$00,$00,$55
        .BYTE $01,$FD,$FC
        .BYTE $A8,$00,$FC,$FC,$01,$05,$15,$15,$55,$55,$55,$55,$57,$5C,$70,$70
        .BYTE $40,$40,$00,$00,$88
        .BYTE $88,$88,$88,$88,$88,$88,$88,$FF,$AA,$00,$00,$30,$20,$00,$00,$0F
        .BYTE $3A,$20,$20,$E0,$80,$00,$00,$FC,$AB,$02,$02,$02,$02,$02,$02,$03
        .BYTE $02,$02,$02,$00,$00,$00,$00,$00
        .BYTE $00,$00,$FC,$A8,$00,$00,$00,$FF,$F0,$AC,$08,$0B,$0A,$08,$08,$DD
        .BYTE $DD,$88,$CC,$88,$88,$88,$88,$7F,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$F0
        .BYTE $BC,$2F,$0B,$42,$50,$54,$55,$55
        .BYTE $55,$55,$55,$55,$55,$55,$55,$55,$15,$05,$C1,$F0,$BC,$2F,$0B
        .BYTE $42,$50,$54,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$15,$05,$C1
        .BYTE $C1,$30,$0C,$C3,$F0,$32,$0A,$08,$FF
        .BYTE $00,$FC,$FC,$FC,$FC,$FC,$FC,$54,$50,$53,$43,$70,$4C,$53,$54,$57
        .BYTE $13,$CC,$CC,$32,$32,$C8,$C8,$CC,$22,$A2,$88,$08,$20,$20,$00,$55
        .BYTE $15,$C5,$30,$0F,$03,$00,$30,$20
        .BYTE $03,$03,$0F,$CF,$73,$43,$40,$57,$5C,$5C,$57,$55,$55,$55,$55,$FC
        .BYTE $02,$22,$22,$22,$22,$22,$88,$0C,$32,$30,$33,$3E,$38,$30,$00,$0C
        .BYTE $38,$E0,$80,$00,$00,$00,$00,$31
        .BYTE $4C,$50,$56,$54,$55,$55,$55,$AA,$AA
        .BYTE $00,$00,$00,$00,$00,$00,$FF,$00,$00,$00,$00,$00,$00,$00,$5C,$5C
        .BYTE $5C,$5C,$5C,$5C,$5C,$5C,$55,$55,$55,$55,$55,$55,$15,$10,$FD
        .BYTE $55,$55,$55,$55,$55,$55,$55,$0C,$43,$51,$51,$51,$51,$55,$55,$17
        .BYTE $00,$00,$01,$05,$15,$15,$55,$00,$00,$00,$00,$50,$55,$55,$55,$00
        .BYTE $00,$00,$55,$55,$55,$55,$55,$00
        .BYTE $00,$00,$00,$55,$55,$55,$55,$00,$C0,$40,$10,$05,$15,$55,$55,$55
        .BYTE $55,$D5,$FD,$A8,$01,$55,$55,$FC,$55,$FF,$FF,$AA,$00,$00,$40,$50
        .BYTE $50,$50,$4C,$4C,$3C,$3C,$FC,$05
        .BYTE $C5,$C5,$C5,$C5,$C5,$C5,$D4,$54,$54,$54,$53,$53,$53,$4F,$3F,$55
        .BYTE $F5,$FF,$BF,$55,$00,$05,$50,$15,$FF,$FF,$5A,$05,$00,$40,$55,$FF
        .BYTE $FF,$15,$41,$D5,$FF,$FF,$00,$F5
        .BYTE $FF,$D6,$C3,$C1,$C1,$D1,$F5,$55,$55,$55,$55,$55,$50,$4A,$2A,$BA
        .BYTE $EA,$AB,$AF,$FF,$FF,$00,$00,$5F,$FE,$F6,$F6,$BF,$AA,$00,$00,$55
        .BYTE $55,$BF,$F7,$A2,$00,$55,$55,$55,$55,$54,$43,$3F,$40,$55,$55,$FF
        .BYTE $EA,$AA,$AA,$AA,$AA,$A9,$95,$FD,$A8,$A4,$A4,$90,$50,$40,$00,$7F
        .BYTE $FF,$FE,$FA,$FA,$EA,$EA,$EA,$35,$35,$35,$35,$35,$35,$35,$35,$7F
        .BYTE $C0,$C4,$C5,$C5,$C5,$C5,$C5,$A9,$02,$02,$02,$02,$42,$42,$52,$FF
        .BYTE $EA,$EB,$EA,$EA,$55,$10,$AA,$FF,$55,$40,$10,$04,$00,$55,$AA,$00
        .BYTE $55,$5D,$51,$55,$55,$55,$55,$78,$79,$75,$75,$55,$55,$D7,$D4,$78
        .BYTE $78,$78,$78,$58,$58,$D4,$14,$00,$3D,$35,$35,$15,$15,$15,$00,$D4
        .BYTE $D4,$D4,$54,$11,$45,$55,$00,$00,$00,$50,$50,$50,$50,$50,$00,$01
        .BYTE $81,$85,$8D,$99,$B1,$E1,$FF,$80,$81,$A1,$B1,$99,$8D,$87,$BF,$A1
        .BYTE $A1,$B1,$99,$8D,$87,$83,$FF,$83,$87,$8D,$99,$B1,$E1,$C1,$BF,$78
        .BYTE $78,$78,$78,$78,$78,$78,$78,$00,$00,$80,$80,$A0,$A0,$A8,$A8,$00
        .BYTE $00,$02,$02,$0A,$0A,$2A,$2A,$03,$03,$4C,$4C,$50,$50,$D4,$17,$D5
        .BYTE $D5,$35,$35,$0D,$0D,$03,$03,$01,$31,$05,$05,$15,$15,$57,$54,$54
        .BYTE $54,$50,$50,$40,$40,$00,$00,$FF,$55,$5D,$51,$55,$55,$55,$55,$78
        .BYTE $78,$78,$78,$78,$78,$78,$78,$A8,$F8,$F8,$78,$78,$78,$78,$78,$00
        .BYTE $FF,$FF,$80,$20,$08,$00,$56,$00,$FB,$FE,$00,$08,$20,$80,$55,$FF
        .BYTE $08,$20,$00,$80,$20,$08,$00,$55,$45,$51,$54,$C5,$C5,$E4,$C1,$54
        .BYTE $51,$45,$55,$C5,$E5,$C1,$C5,$C5,$C0,$C4,$C4,$C4,$01,$01,$00,$FF
        .BYTE $20,$08,$02,$00,$20,$80,$00,$FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
        .BYTE $7C,$FC,$DC,$FC,$FC,$FC,$00,$FF,$FB,$FF,$DD,$FF,$FF,$FF,$00,$FF
        .BYTE $FF,$FF,$F7,$F7,$F5,$FF,$FF,$E0,$E1,$E1,$E1,$E1,$E1,$E1,$E1,$55
        .BYTE $45,$51,$54,$55,$51,$45,$15,$54,$51,$45,$55,$15,$45,$51,$55,$AA
        .BYTE $AA,$00,$55,$55,$55,$55,$55,$FF,$FF,$FF,$FF,$56,$56,$58,$58,$55
        .BYTE $AA,$FF,$6A,$40,$50,$58,$58,$62,$62,$8A,$8B,$2B,$2F,$AF,$BF,$BC
        .BYTE $FC,$F0,$F0,$F0,$C0,$C0,$C0,$55,$AA,$FF,$AA,$00,$00,$80,$AA,$70
        .BYTE $B0,$F4,$5C,$A0,$00,$00,$00,$AA,$AA,$00,$00,$FF,$FD,$5C,$5C,$AA
        .BYTE $AA,$00,$00,$0F,$3F,$3D,$D5,$03,$03,$0D,$35,$35,$D5,$55,$55,$00
        .BYTE $00,$00,$00,$00,$00,$03,$03,$0D,$35,$35,$D5,$55,$55,$55,$55,$00
        .BYTE $00,$00,$00,$03,$03,$0D,$35,$AA,$AA,$00,$00,$FF,$FF,$55,$55,$AA
        .BYTE $AA,$AA,$AA,$AA,$EA,$FE,$7F,$AA,$AA,$AA,$AA,$AA,$AB,$BF,$F5,$FF
        .BYTE $FF,$F3,$CF,$FF,$FF,$CC,$FF,$55,$55,$55,$51,$5D,$45,$35,$D5,$55
        .BYTE $55,$55,$15,$C5,$45,$71,$5D,$55,$FF,$55,$00,$FF,$55,$00,$55,$00
        .BYTE $54,$FC,$54,$00,$54,$FC,$54,$00,$55,$FF,$55,$00,$55,$FF,$55,$00
        .BYTE $15,$3F,$15,$00,$15,$3F,$15,$54,$54,$54,$54,$54,$54,$54,$54,$55
        .BYTE $55,$55,$55,$55,$55,$55,$55,$AA,$AA,$EA,$FA,$7F,$5D,$55,$55,$FA
        .BYTE $FE,$5F,$55,$55,$55,$55,$55,$AA,$AA,$AB,$AD,$FD,$F5,$55,$55,$AF
        .BYTE $BF,$F5,$D5,$55,$55,$55,$55,$D5,$D5,$D5,$D5,$D5,$D5,$D5,$D5,$30
        .BYTE $5D,$7F,$35,$55,$DD,$FF,$75,$00,$DD,$FF,$75,$55,$DD,$FF,$75,$00
        .BYTE $77,$FF,$D7,$5F,$DC,$FD,$5C,$55,$DD,$FF,$75,$55,$F7,$FF,$55,$7D
        .BYTE $71,$F7,$F3,$C1,$FF,$F7,$55,$FE,$07,$00,$C7,$15,$00,$7C,$78,$00
        .BYTE $EF,$07,$00,$F1,$0C,$00,$1F,$55,$D5,$EA,$3F,$40,$55,$55,$00,$55
        .BYTE $55,$AA,$FF,$00,$55,$55,$00,$55,$55,$55,$55,$55,$55,$55,$00,$55
        .BYTE $5B,$AB,$FC,$01,$55,$55,$00,$00,$EF,$CF,$00,$FE,$FC,$00,$EF,$C5
        .BYTE $C1,$C4,$85,$FF,$FF,$00,$C0,$71,$71,$71,$60,$F1,$F1,$01,$31,$AA
        .BYTE $FF,$FF,$AA,$00,$51,$45,$15,$AA,$FF,$FF,$AA,$00,$45,$51,$55,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $EF,$CF,$00,$FE,$FC,$00,$EF,$55,$D5,$EA,$3F,$40,$55,$55,$00,$55
        .BYTE $55,$AA,$FF,$00,$55,$55,$00,$55,$5B,$AB,$FC,$01,$55,$55,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$CF
        .BYTE $CF,$FF,$D5,$C0,$C0,$C0,$CF,$C4,$C1,$C4,$C1,$FF,$EA,$C0,$C1,$C5
        .BYTE $C5,$C5,$C5,$C5,$C5,$C5,$C5,$44,$11,$44,$11,$FF,$AA,$00,$11,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$FF
        .BYTE $AA,$C0,$C0,$C0,$C0,$30,$30,$0F,$2A,$30,$30,$30,$30,$0C,$0C,$F0
        .BYTE $A4,$00,$00,$00,$00,$C0,$C0,$30,$30,$FF,$AA,$30,$30,$30,$30,$83
        .BYTE $8B,$83,$83,$83,$83,$83,$83,$77,$00,$FF,$AA,$40,$40,$30,$30,$55
        .BYTE $55,$55,$55,$55,$55,$55,$00,$FF,$F7,$00,$00,$55,$55,$55,$00,$FF
        .BYTE $F7,$00,$00,$55,$55,$55,$00,$55,$5B,$AB,$FC,$01,$55,$55,$00,$7F
        .BYTE $7F,$7F,$7F,$75,$55,$40,$50,$CF,$CF,$C0,$C3,$C0,$FF,$D5,$C0,$CC
        .BYTE $3C,$0C,$FC,$3C,$FC,$5C,$0C,$00,$F7,$FF,$00,$DF,$FF,$FF,$00,$53
        .BYTE $53,$53,$4F,$4F,$0F,$3F,$C0,$00,$FF,$F7,$00,$7F,$F7,$FF,$00,$35
        .BYTE $C7,$C7,$C5,$C7,$45,$31,$40,$4D,$F3,$F3,$73,$F3,$53,$45,$10,$00
        .BYTE $3F,$CF,$00,$C7,$CF,$3F,$00,$00,$CD,$CD,$03,$F3,$F3,$D3,$03,$55
        .BYTE $FF,$5F,$FF,$F7,$55,$55,$00,$00,$F7,$FF,$00,$DF,$FF,$FF,$00,$AA
        .BYTE $FF,$FF,$EA,$E0,$E1,$E1,$E1,$FF,$F7,$00,$00,$55,$55,$55,$00,$54
        .BYTE $51,$45,$55,$FF,$FF,$00,$00,$AA,$FF,$FF,$AA,$00,$51,$45,$15,$AA
        .BYTE $FF,$FF,$AA,$00,$45,$51,$55,$FE,$FC,$00,$EF,$CF,$00,$FE,$FC,$00
        .BYTE $EF,$CF,$00,$FE,$FC,$00,$EF,$00,$EF,$07,$00,$F1,$0C,$00,$1F,$FE
        .BYTE $07,$00,$C7,$15,$00,$7C,$78
