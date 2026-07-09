        ; Format game state information for showing on the top of the screen status display. Score accumulation is also
        ; handled here. The data for the prison wall background is also contained here before the status screen memory
        ; and before other code.

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