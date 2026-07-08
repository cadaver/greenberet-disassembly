CheckKillEnemies 
		LDX #$05
CKE_Loop LDA enemyActive,X
        BNE CKE_IsActive
CKE_Next DEX
        BPL CKE_Loop
        RTS 

CKE_IsActive 
		LDA enemyHit,X
        BEQ CKE_Next
        LDA enemyDying,X
        BEQ CKE_DoKill
        JMP CKE_NoNewKill

CKE_DoKill
		LDA enemyType,X
        ASL
        TAY
        SED
        LDA scoreAdd
        CLC
        ADC enemyScoreTblLo,Y
        STA scoreAdd
        LDA scoreAdd+1
        ADC enemyScoreTblHi,Y
        STA scoreAdd+1
        LDA scoreAdd+2
        ADC #$00
        STA scoreAdd+2
        CLD
        LDA #$80
        STA enemyTimerActive,X
        STA enemyTimer,X
        STA enemyDying,X
        LDA enemyType,X
        CMP #$01
        BEQ CKE_CheckSpawnPickup
        CMP #$06
        BNE CKE_NoSpawnPickup
CKE_CheckSpawnPickup 
		PHA
        LDA enemyLowerY,X
        SEC 
        SBC #$15
        STA enemyUpperY,X
        LDA enemyLowerX,X
        STA enemyUpperX,X
        LDA enemyLowerXMSB,X
        STA enemyUpperXMSB,X
        PLA
        CMP #$01
        BNE CKE_NoSpawnPickup
        LDY enemyStaticIndex,X
        LDA staticEnemyWpnType,Y
        TAY
        STA weaponPickupType
        LDA enemyUpperY,X
        SEC 
        SBC #$0A
        STA extraPickupY
        LDA enemyUpperX,X
        STA weaponPickupX
        LDA enemyUpperXMSB,X
        STA weaponPickupXMSB
        LDA weaponPickupFrameTbl,Y
        STA weaponPickupFrame
        LDA weaponPickupColorTbl,Y
        STA weaponPickupColor
        LDA #$00
        STA weaponPickupRestFlag
        LDA #$0B
        STA weaponPickupCoarseX
CKE_NoSpawnPickup 
		LDA enemyHorizMove,X
        LSR 
        LSR
        LSR
        TAY
        LDA enemyDeadUpperFrames,Y
        STA enemyUpperFrame,X
        LDA enemyDeadLowerFrames,Y
        STA enemyLowerFrame,X
CKE_NoNewKill 
		LDA enemyTimer,X
        CMP #$60
        BCC CKE_Remove
        AND #$04
        LSR
        LSR
        TAY
        LDA enemyDeadColorTbl,Y
        STA enemyUpperColor,X
        STA enemyLowerColor,X
        JMP CKE_Next

CKE_Remove 
		JSR RemoveEnemy
        JMP CKE_Next

enemyDeadColorTbl 
		.BYTE $01,$02

enemyDeadLowerFrames
		.BYTE $B0,$B2

enemyDeadUpperFrames
		.BYTE $B1,$B3

weaponPickupColorTbl
		.BYTE $01,$05,$01,$05,$01

weaponPickupFrameTbl
		.BYTE $67,$67,$6C,$67,$6D

enemyScoreTblLo
		.BYTE $20

enemyScoreTblHi
		.BYTE $00,$50,$02,$35,$00,$25,$00,$50
        .BYTE $00,$75,$00,$85,$00,$35,$00,$55
        .BYTE $00