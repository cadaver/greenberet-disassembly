        ; Drawing new stage graphics, as well as mines to the bottom of the screen, and mine collision handling. When a
        ; player-thrown grenade tries to destroy a partially visible mine, the game would lock up. Partial mines cannot
        ; be destroyed, because the rightmost char is yet to scroll onto the screen, and it would cause a visible error.
        ; See defines.asm for the define that enables the fix.

        ; Drawing the new graphics uses the (zeropage,x) addressing mode, using a screen memory and color memory pointer
        ; for each of the 16 rows.

DrawNewColumn
        LDA newColumnFlag
        BNE DNC_AdvanceAndDraw
        RTS

DNC_AdvanceAndDraw 
        LDX #$00
        STX newColumnFlag
        LDA #$07
        STA columnBase
        LDA #$01
        STA columnSrcBase
        INC stagePosLSB
        BNE DNC_NoMSB
        INC stagePosMSB
DNC_NoMSB 
        LDA stagePosLSB
        TAY
        AND #$07
        STA columnAdd
        LDA stagePosMSB
        STA screenPtrHi
        TYA 
        LSR screenPtrHi
        ROR 
        LSR screenPtrHi
        ROR
        AND #$FE
        CLC
        ADC #$00
        STA columnSrcLo
        LDA screenPtrHi
        ADC #$C0
        STA columnSrcHi
DNC_TileLoop 
        LDY columnSrcBase
        LDA #$00
        STA screenPtrLo
        LDA (columnSrcLo),Y
        LSR 
        ROR screenPtrLo
        LSR
        ROR screenPtrLo
        TAY 
        LDA screenPtrLo
        CLC 
        ADC #$00
        STA screenPtrLo
        STA srcPtrLo
        TYA
        ADC #$A0
        STA screenPtrHi
        ORA #$10
        STA srcPtrHi
DNC_RowLoop 
        LDA columnBase
        ASL 
        ASL 
        ASL 
        ADC columnAdd
        TAY 
        LDA (screenPtrLo),Y
        STA (screenRowPtrs,X)
        LDA (srcPtrLo),Y
        STA (colorRowPtrs,X)
        INX 
        INX
        CPY #$08
        BCC DNC_TileFinished
        DEC columnBase
        JMP DNC_RowLoop

DNC_TileFinished 
        LDA #$07
        STA columnBase
        CPX #$20
        BCC DNC_NewTile
        JMP DNC_DrawMines

DNC_NewTile 
        DEC columnSrcBase
        JMP DNC_TileLoop

AnimateMineChars 
        LDA stage
        ASL
        TAY
        LDA mineCharAddrTblLo,Y
        STA mineCharDestLo
        LDA mineCharAddrTblHi,Y
        STA mineCharDestHi
        LDA gameTimer
        AND #$04
        LSR 
        LSR
        TAX 
        LDY mineFrameDataIndex,X
        LDX #$0F
AMC_Loop
        LDA mineFrameData,Y
mineCharDestLo   =*+$01
mineCharDestHi   =*+$02
        STA $FFFF,X
        DEY
        DEX
        BPL AMC_Loop
        RTS 

DNC_DrawMines 
        LDY stage
        LDX stageMineStartTbl,Y
DNC_DrawMinesLoop 
        LDA stagePosMSB
        CMP stageMinePosMSBTbl,X
        BNE DNC_DrawMinesNext
        LDA stagePosLSB
        CMP stageMinePosLSBTbl,X
        BNE DNC_DrawMinesNext
        TXA 
        AND #$01
        CLC 
        ADC mineCharCodes,Y
        LDX #$1E
        STA (screenRowPtrs,X)
        LDA #$0F
        STA (colorRowPtrs,X)
        RTS

DNC_DrawMinesNext 
        INX
        TXA
        CMP stageMineEndTbl,Y
        BCC DNC_DrawMinesLoop
        RTS

stageMineStartTbl 
        .BYTE $00,$06,$1A,$2E
stageMineEndTbl 
        .BYTE $06,$1A,$2E,$44

stageMinePosMSBTbl 
        .BYTE $00,$00,$00,$00,$00,$00,$01,$01,$02,$02,$02,$02,$02,$02,$02,$02
        .BYTE $02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$04,$04,$04,$04,$04,$04
        .BYTE $04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06
        .BYTE $06,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07,$07,$07,$07
        .BYTE $07,$07,$08,$08

stageMinePosLSBTbl 
        .BYTE $EC,$ED,$F0,$F1,$F4,$F5,$DA,$DB,$00,$01,$08,$09,$2E,$2F,$B4,$B5
        .BYTE $B8,$B9,$BC,$BD,$26,$27,$2A,$2B,$2E,$2F,$24,$25,$28,$29,$54,$55
        .BYTE $82,$83,$06,$07,$1C,$1D,$4C,$4D,$94,$95,$EE,$EF,$00,$01,$A8,$A9
        .BYTE $C0,$C1,$C6,$C7,$D8,$D9,$F0,$F1,$08,$09,$26,$27,$C4,$C5,$CC,$CD
        .BYTE $FE,$FF,$0A,$0B

mineFrameDataIndex 
        .BYTE $0F,$1F

mineCharAddrTblLo
        .BYTE $90

mineCharAddrTblHi
        .BYTE $7A,$F0,$79,$90,$7A,$00,$7D

mineCharCodes 
        .BYTE $52,$3E,$52,$A0

mineClearCharTbl  
        .BYTE $50,$50,$50,$50

mineFrameData
        .BYTE $55,$54,$43,$3F,$FA,$E8,$FF,$30,$55,$15,$C1,$FC,$AF,$2B,$FF,$0C
        .BYTE $55,$54,$42,$2A,$AF,$BC,$FF,$30,$55,$15,$81,$A8,$FA,$3E,$FF,$0C

charData1 
        .BYTE $FF,$FF,$00,$FF,$00,$00,$55,$55,$FF,$00,$FF,$00,$FF,$00,$55,$55

charData2 
        .BYTE $42,$50,$54,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$15,$05,$C1

charData3 
        .BYTE $77,$00,$FF,$AA,$40,$40,$30,$30,$55,$55,$55,$55,$55,$55,$55,$55

CheckDestroyMines LDX #$02
CDM_Loop
        LDA bulletActive,X
        BNE CDM_BulletActive
CDM_Next  
        DEX
        BPL CDM_Loop
        RTS 

CDM_BulletActive 
        LDY collectedExtraWeapon
        LDA spriteY+SPR_BULLET,X
        CMP #$DE
        BCC CDM_Next
        CPY #WEAPON_GRENADE
        BEQ CDM_GrenadeAreaDestroy
        LDA bulletCoarseX,X
        SEC
        SBC #$0C
        LSR 
        LSR
        TAY
        LDA screen+$398,Y
        JSR CheckDestroyMine
        BNE CDM_Next
        JSR DestroyMine
        JMP CDM_Next

CDM_GrenadeAreaDestroy 
        LDA bulletXSpeed,X
        BNE CDM_Next
        LDA bulletCoarseX,X
        LSR 
        LSR
        SEC 
        SBC #$06
        BCS CDM_GADNoUnderFlow
        LDA #$00
CDM_GADNoUnderFlow
        TAY
        CLC
        ADC #$0C
        STA temp2
CDM_GADLoop
        LDA screen+$398,Y
        JSR CheckDestroyMine

    .if GRENADE_HANG_FIX = 0

        ;Original code, will hang if mine is partially on screen

        BEQ CDM_GADDoDestroy
        INY
        CPY temp2
        BCC CDM_GADLoop
        JMP CDM_Next

CDM_GADDoDestroy
        JSR DestroyMine
        JMP CDM_GADLoop

    .else

        ; Fixed code, will jump over one char after destroying the mine, but mines are never placed tightly next to each other

        BNE CDM_GADDestroySkip
        JSR DestroyMine
        BCS CDM_Next
CDM_GADDestroySkip
        INY
        CPY temp2
        BCC CDM_GADLoop
        JMP CDM_Next
        NOP ;Padding to keep code size the same

    .endif

DestroyMine
        STY tempStoreY2
        LDY stage
        LDA mineClearCharTbl,Y
        LDY tempStoreY2
        CPY #$26
        BCS DM_OutsideScreen
        STA screen+$398,Y
        INY
        STA screen+$398,Y
        INY
DM_OutsideScreen
        RTS

CheckDestroyMine
        STY tempStoreY2
        PHA
        LDA stage
        ASL
        TAY
        PLA
        CMP mineLeftCharTbl,Y
        BEQ CDM_Done
        CMP mineRightCharTbl,Y
        PHP 
        LDY tempStoreY2
        PLP 
        BNE CDM_Done
        PHP
        DEY
        BPL CDM_NoUnderFlow
        INY
CDM_NoUnderFlow
        PLP
        RTS 

CDM_Done
        PHP
        LDY tempStoreY2
        PLP
        RTS

CheckPlayerHitMine 
        LDA stage
        ASL 
        TAY
        LDA charAtPlayer
        CMP mineLeftCharTbl,Y
        BEQ KillPlayerToMine
        CMP mineRightCharTbl,Y
        BEQ KillPlayerToMine
        RTS

KillPlayerToMine

    .if INVULNERABILITY_CHEAT = 0

        ; Original code, proceed with player death
        JSR ResetSID

    .else

        ; Cheat code, skip death + extra bytes to keep memory alignment the same
        RTS
        NOP
        NOP

    .endif

        INC haltPlayerFlag
        JSR PlayExplosionSound
        JSR WaitSongToEnd
        LDY #$29
        JSR PlaySong
        PLA
        PLA
        JMP InitNextLife

mineLeftCharTbl
        .BYTE $52
mineRightCharTbl
        .BYTE $53,$3E,$3F,$52,$53,$A0,$A1

ResetGameChars PHP
        LDY #$0F
        SEI
        LDA #$30
        STA $01
RGC_Loop
        LDA charData1,Y
        STA $79F0,Y
        LDA charData2,Y
        STA $DA90,Y
        LDA charData3,Y
        STA $D640,Y
        DEY
        BPL RGC_Loop
        LDA #$35
        STA $01
        PLP
        RTS

ResetBank2GameChars 
        LDY #$0F
RB2GC_Loop 
        LDA charData2,Y
        STA f7A90,Y
        DEY
        BPL RB2GC_Loop
        RTS

        ; Stage beginning or resume, which will draw the entire screen with a "wipe" effect, by adjusting the zeropage
        ; row pointers. The color RAM is also initialized completely here, while scrolling only updates those color
        ; rows that will actually change their content during scrolling to save CPU time.

BeginStage
        LDX #$3F
        STX haltPlayerFlag
BS_InitRowPtrs
        LDA rowPtrInitData,X
        STA screenRowPtrs,X
        DEX
        BPL BS_InitRowPtrs
        LDA #$00
        STA initialDrawColumn
        STA $D015
        JSR PlayerWorldCollision
        JSR ClearGameScreen
        JSR FormatScore
        JSR CheckNewHighScore
        JSR FormatHighScore
        JSR CheckNextExtraLife
        JSR FormatLives
        JSR ToggleScreenOn
        LDA #$00
        STA frameSyncFlag
BS_InitialDrawLoop 
        JSR UpdateMusicWaitFrame
        LDA #$01
        STA newColumnFlag
        JSR DrawNewColumn
        LDX #$1E
BS_IncrementRowPtrs 
        INC screenRowPtrs,X
        INC colorRowPtrs,X
        BNE BS_IncNoMSB
        INC screenRowPtrsHi,X
        INC colorRowPtrsHi,X
BS_IncNoMSB 
        DEX
        DEX
        BPL BS_IncrementRowPtrs
        INC initialDrawColumn
        LDA initialDrawColumn
        TAY
        DEY
        LDA #$21
        STA screen+$077,Y
        STA screen+$09F,Y
        STA screen+$0C7,Y
        STA screen+$0EF,Y
        STA screen+$117,Y
        LDA #$FB
        STA screen+$3BF,Y
        CPY #$27
        BCS BS_InitialDrawDone
        JMP BS_InitialDrawLoop

BS_InitialDrawDone 
        LDA #$09
        LDY #$00
BS_MiddleColorsLoop 
        STA colorRam+$140,Y
        INY
        CPY #$A0
        BCC BS_MiddleColorsLoop
        LDA #$FB
        STA screen+$3E7
        LDA #$01
        STA newColumnFlag
        LDA #$FF
        STA $D015
        LDA #$00
        STA haltPlayerFlag
        RTS

ClearGameScreen
        LDY #$00
        LDA #$20
CGS_Loop 
        STA screen+$050,Y
        STA screen+$136,Y
        STA screen+$21C,Y
        STA screen+$302,Y
        LDA #$00
        CPY #$28
        BCC CGS_UseBlack
        LDA #$09
CGS_UseBlack 
        STA colorRam+$050,Y
        LDA #$09
        STA colorRam+$136,Y
        STA colorRam+$21C,Y
        STA colorRam+$302,Y
        LDA #$20
        INY
        CPY #$E6
        BCC CGS_Loop
        RTS

rowPtrInitData 
        .BYTE $3F,$41,$67,$41,$8F,$41,$B7,$41,$DF,$41,$07,$42,$2F,$42,$57,$42
        .BYTE $7F,$42,$A7,$42,$CF,$42,$F7,$42,$1F,$43,$47,$43,$6F,$43,$97,$43
        .BYTE $3F,$D9,$67,$D9,$8F,$D9,$B7,$D9,$DF,$D9,$07,$DA,$2F,$DA,$57,$DA
        .BYTE $7F,$DA,$A7,$DA,$CF,$DA,$F7,$DA,$1F,$DB,$47,$DB,$6F,$DB,$97,$DB

sprAndBitTbl
        .BYTE $FE,$FD,$FB,$F7,$EF,$DF,$BF,$7F

sprOrBitTbl
        .BYTE $01,$02,$04,$08,$10,$20,$40,$80

irqJumpTblHi   =*+$01
irqJumpTblLo
        .WORD SpriteDisplayIrq,IrqUpdateGame,ScrollSplitIrq

        .BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
        .BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA

textScreenTblHi   =*+$01
textScreenTblLo 
        .WORD titleTexts,rescueCaptivesText,wellDoneText,victoryText

        .BYTE $CA,$4C
a3DFE   .BYTE $00
a3DFF   .BYTE $40