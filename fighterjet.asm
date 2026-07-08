UpdateFighterJet
		LDA fighterJetIndex
        BNE UFJ_IsActive
        LDA playerRightLimit
        CMP #$E0
        BEQ UFJ_NoSpawn
        LDA idleTimer
        CMP #$07
        BCS SpawnFighterJet
UFJ_NoSpawn
		RTS

SpawnFighterJet
		LDY #$00
        LDX #$02
SFJ_SearchEmptyLoop
		LDA bulletActive+3,X
        BNE SFJ_BulletInUse
        INY
        CPY #$02
        BCS SFJ_SpawnOK
SFJ_BulletInUse
		DEX
        BPL SFJ_SearchEmptyLoop
        RTS

SFJ_SpawnOK
		JMP DoSpawnFighterJet

UFJ_IsActive 
		JSR UFJ_DoJetMove
        JMP CheckDropBomb

UFJ_DoJetMove 
		JMP MoveFighterJet

FindJetOrBomb LDA bulletType+3,X
        CMP #$07
        BEQ MoveFighterJet
        INX
        CPX #$03
        BNE FindJetOrBomb
        RTS

MoveFighterJet 
		LDX fighterJetIndex
        LDA bulletCoarseX,X
        CMP #$18
        BCS MFJ_Done
        LDA bulletFrame,X
        CMP #$C1
        BEQ MFJ_FlyAway
        LDA #$00
        STA bulletXSpeed,X
        LDA #$C1
        STA bulletFrame,X
MFJ_Done
		RTS

MFJ_FlyAway 
		DEC bulletY,X
        LDA bulletY,X
        CMP #$42
        BCS MFJ_Done
        LDA #$00
        STA fighterJetIndex
        STA bulletActive,X
        STA bulletY,X
        LDA #$00
        STA idleTimer
        RTS

CheckDropBomb
		LDA playerCoarseX
        CLC
        ADC #$07
        CMP bulletCoarseX,X
        BCS CDB_DropOK
CDB_Fail 
		RTS

CDB_DropOK 
		TXA
        CMP fighterJetIndex
        BNE CDB_Check
        TAY
CDB_Retry 
		INY
CDB_Check 
		LDA bulletType,Y
        CPY #$06
        BCS CDB_Fail
        CMP #$07
        BNE CDB_Retry
        LDA bulletY,Y
        BNE CDB_Fail
        LDA bulletX,X
        STA bulletX,Y
        LDA bulletXMSB,X
        STA bulletXMSB,Y
        LDA bulletY,X
        CLC 
        ADC #$15
        STA bulletY,Y
        RTS

DoSpawnFighterJet 
		LDA #$07
        STA bulletType+3,X
        TXA
        CLC
        ADC #$03
        STA fighterJetIndex
        STA bulletActive+3,X
        LDA #$50
        STA bulletY+3,X
        LDA #$C2
        STA bulletFrame+3,X
        LDA #$05
        STA bulletColor+3,X
        LDA #$40
        STA bulletX+3,X
        LDA #$01
        STA bulletXMSB+3,X
        LDA #$04
        STA bulletXSpeed+3,X
        STA bulletXDir+3,X
        LDA bulletActive+3+1,X
        BEQ DSFJ_BombSlotOK
        INX
DSFJ_BombSlotOK 
		INX
        LDA #$07
        STA bulletType+3,X
        STA bulletActive+3,X
        LDA #$00
        STA bulletY+3,X
        LDA #$00
        STA bulletXSpeed+3,X
        LDA #$01
        STA bulletXMSB+3,X
        LDA #$40
        STA bulletX+3,X
        LDA #$65
        STA bulletFrame+3,X
        JSR PlayFighterJetSound
        RTS
