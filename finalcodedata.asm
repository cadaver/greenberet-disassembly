		* = $FD01

CheckEnemyBulletHits LDX #$02
CEBH_Loop LDA bulletActive+3,X
        BNE CEBH_CheckBullet
CEBH_Next DEX 
        BPL CEBH_Loop
        JMP CEBH_BulletsDone

CEBH_CheckBullet LDA spriteY
        CMP bulletY+3,X
        BCS CEBH_NoHit
        ADC #$1C
        CMP bulletY+3,X
        BCC CEBH_NoHit
        LDA playerCoarseX
        CMP bulletCoarseX+3,X
        BCS CEBH_NoHit
        ADC #$06
        CMP bulletCoarseX+3,X
        BCC CEBH_NoHit
        LDA bulletType+3,X
        BEQ CEBH_DoKill
        CMP #$05
        BEQ CEBH_DoKill
        TXA
        CLC 
        ADC #$03
        TAX 
        JSR ExplodeGrenade
CEBH_DoKill JMP KillPlayer

CEBH_NoHit JMP CEBH_Next

CEBH_BulletsDone LDA stage
        CMP #$01
        BNE CEBH_NoDogs
        LDX #$02
CEBH_DogLoop LDA dogActive,X
        BNE CEBH_CheckDog
CEBH_DogNext DEX
        BPL CEBH_DogLoop
CEBH_NoDogs RTS

CEBH_CheckDog LDA dogCoarseX,X
        CLC
        ADC #$03
        CMP playerCoarseX
        BCC CEBH_DogNext
        SEC
        SBC #$06
        CMP playerCoarseX
        BCS CEBH_DogNext
        LDA dogY,X
        CLC
        ADC #$0A
        CMP spriteY
        BCC CEBH_DogNext
        SEC
        SBC #$14
        CMP spriteY
        BCS CEBH_DogNext
        JMP KillPlayer

ShowGameOver LDX #$09
bFD7A   LDA gameOverText,X
        AND #$3F
        STA statusScreen+$1,X
        DEX
        BPL bFD7A
        RTS

gameOverText 
        .BYTE $47,$41,$4D,$45,$20,$4F,$56,$45,$52,$20

victoryText
        .BYTE $FC,$34,$40,$43,$4F,$4E,$47,$52,$41,$54,$55,$4C,$41,$54,$49,$4F
        .BYTE $4E,$53,$FC,$82,$40,$4D,$49,$53,$53,$49,$4F,$4E,$20,$41,$43,$43
        .BYTE $4F,$4D,$50,$4C,$49,$53,$48,$45,$44,$FC,$D0,$40,$4E,$4F,$57,$20
        .BYTE $50,$52,$4F,$43,$45,$45,$44,$20,$54,$4F,$20,$4E,$45,$58,$54,$20
        .BYTE $43,$41,$4D,$50,$FF,$00,$BF,$E0,$D8,$1C,$FF,$D0,$1C,$1C,$B2,$F9
        .BYTE $CA,$0C,$0F,$BF,$F0,$5F,$08,$8E,$D8,$C2,$4F,$FC,$C2,$4F,$FC,$D0
        .BYTE $1C,$1C,$78,$F9,$BF,$60,$CC,$04,$28,$02,$CE,$32,$02,$28,$01,$28          
        .BYTE $01,$28,$02,$28,$02,$CC,$02,$32,$04,$32,$02,$CE,$32,$04,$D0,$1C
        .BYTE $1C,$02,$FC,$C2,$BF,$FC,$5F,$0E,$C2,$BF,$FC,$5F,$08,$3C,$02,$3E
        .BYTE $02,$3F,$02,$C2,$F4,$FC,$BF,$48,$43,$0C,$D8,$06,$88,$D8,$07,$FF
        .BYTE $D8,$0C,$0C,$D8,$0D,$07,$D0,$1C,$1C,$A9,$3F,$BF,$0B,$C2,$78,$FC
        .BYTE $C2,$78,$FC,$D0,$1C,$0E,$CF,$F9,$CA,$1A,$AD,$CA,$1B,$32,$D4,$DE
        .BYTE $3F,$DA,$00,$86,$C0,$D8,$1C,$FF,$D0,$1C,$1C,$78,$F9,$BF,$C0,$C2
        .BYTE $45,$FD,$C2,$52,$FD,$C2,$45,$FD,$5F,$02,$32,$06,$32,$04,$32,$04
        .BYTE $2F,$06,$2F,$04,$28,$04,$2F,$04,$32,$06,$32,$04,$32,$04,$2B,$06
        .BYTE $2B,$04,$28,$04,$2B,$02,$C2,$45,$FD,$C2,$52,$FD,$C2,$45,$FD,$5F
        .BYTE $04,$32,$02,$32,$02,$32,$02,$32,$04,$32,$04,$2F,$03,$2F,$02,$2F
        .BYTE $02,$2F,$02,$2F,$02,$32,$02,$2F,$03,$28,$04,$28,$08,$28,$03,$28
        .BYTE $02,$28,$02,$28,$02,$88,$10,$C4,$66,$FD

CheckNextExtraLife LDX #$02
CNEL_Loop LDA score,X
        CMP nextExtraLifeScore,X
        BCC CNEL_NoNext
        BNE CNEL_HasNext
        DEX 
        BPL CNEL_Loop
CNEL_HasNext SED 
        LDA #$70
        CLC 
        ADC nextExtraLifeScore+1
        STA nextExtraLifeScore+1
        LDA nextExtraLifeScore+2
        ADC #$00
        STA nextExtraLifeScore+2
        CLD 
        LDA lives
        CMP #$09
        BCS CNEL_NoNext
        ADC #$01
        STA lives
        JSR FormatLives
CNEL_NoNext RTS 

SwapGraphicsData TAY 
        LDA $3FF0,Y
        EOR #$01
        STA $3FF0,Y
        LDA $FF95,Y
        STA sgdBankConfig
        CMP #$35
        BEQ SGD_NoIrqSisable
        SEI 
SGD_NoIrqSisable TYA
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
swapSrcTblLo .WORD $D000,$8000,$9000,$D800,$D440
        .WORD $8DC0,$9DC0,$C580,$C800
swapDestTblHi   =*+$01
swapDestTblLo .WORD $7A00,$A000,$B000,$7800,$7B00
        .WORD $A200,$B200,$71C0,$7800
swapLengthTblHi   =*+$01
swapLengthTblLo .WORD $0440,$0DC0,$0DC0,$0800,$02D0
        .WORD $0240,$0240,$0280,$0687

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

        .BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
        .BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
        .BYTE $AA,$AA,$AA,$AA,$AA,$FC,$FF,$40
        .BYTE $40,$22,$00
