CheckKnifeCollisions
        LDX #$05
        PHA
        AND #$02
        LSR
        TAY
        LDA spriteY
        CLC
        ADC knifeOffsetTbl,Y
        STA hitPointY
        PLA 
        LSR 
        AND #$06
        STY knifeHitTemp
        CLC 
        ADC knifeHitTemp
        TAY
        LDA playerCoarseX
        CLC
        ADC knifeOffsetTbl,Y
        STA hitPointX
CKC_Loop 
        LDA enemyActive,X
        BNE CKC_CheckEnemy
        LDA stageEndReached
        BEQ CKC_Next
        LDA stage
        CMP #$01
        BNE CKC_Next
        CPX #$04
        BCS CKC_Next
        CPX #$00
        BEQ CKC_Next
        JSR CKC_CheckDogBounds
CKC_Next
        DEX
        BPL CKC_Loop
        RTS

CKC_CheckEnemy 
        LDA enemyDying,X
        ORA enemyHit,X
        BNE CKC_Next
        LDA enemyType,X
        CMP #$09
        BNE CKC_CheckBounds
        LDA numAliveGyros
        BNE CKC_InGyroBossFight
        CPX paraEnemyIndices
        BEQ CKC_CheckBounds
        JMP CKC_Next

CKC_InGyroBossFight
        CPX #$01
        BEQ CKC_CheckBounds
        CPX #$04
        BEQ CKC_CheckBounds
        JMP CKC_Next

CKC_CheckBounds 
        LDA enemyCoarseX,X
        CMP #$0D
        BCC CKC_NoCollision
        CLC 
        ADC #$06
        STA knifeHitBoundHigh
        LDA enemyCoarseX,X
        SEC 
        SBC #$06
        STA knifeHitBoundLow
        LDA hitPointX
        CMP knifeHitBoundHigh
        BCS CKC_NoCollision
        CMP knifeHitBoundLow
        BCC CKC_NoCollision
        LDA enemyUpperY,X
        CLC
        ADC #$10
        STA knifeHitBoundHigh
        LDA enemyUpperY,X
        SEC
        SBC #$10
        STA knifeHitBoundLow
        LDA hitPointY
        CMP knifeHitBoundHigh
        BCS CKC_NoCollision
        CMP knifeHitBoundLow
        BCC CKC_NoCollision
        LDA #$80
        STA enemyHit,X
        STX tempStoreX
        STY tempStoreY
        LDA enemyType,X
        CMP #$09
        BNE CKC_NotParachute
        LDA numAliveGyros
        BNE CKC_NotParachute
        LDA #$01
        STA parachuteKillFlag
CKC_NotParachute 
        JSR PlayEnemyKillSound
        LDX tempStoreX
        LDY tempStoreY
CKC_NoCollision 
        JMP CKC_Next

knifeOffsetTbl 
        .BYTE $00,$F0,$F3,$F9,$0B,$15,$00,$F0
        .BYTE $11,$0D,$F9,$F2

CKC_CheckDogBounds 
        LDA enemyDying,X
        BNE CKC_DogBoundsDone
        LDA enemyCoarseX,X
        CMP #$22
        BCC CKC_DogBoundsDone
        CLC
        ADC #$0C
        STA knifeHitBoundHigh
        SEC
        SBC #$18
        STA knifeHitBoundLow
        LDA hitPointX
        CMP knifeHitBoundHigh
        BCS CKC_DogBoundsXRetry
        CMP knifeHitBoundLow
        BCS CKC_DogBoundsXOK
CKC_DogBoundsXRetry 
        LDA $026D ;Never written to
        CMP knifeHitBoundLow
        BCS CKC_DogBoundsDone
        CMP knifeHitBoundHigh
        BCC CKC_DogBoundsDone
CKC_DogBoundsXOK 
        LDA enemyUpperY,X
        SEC
        SBC #$0D
        STA knifeHitBoundHigh
        SEC
        SBC #$07
        STA knifeHitBoundLow
        LDA hitPointY
        CMP knifeHitBoundHigh
        BCS CKC_DogBoundsYRetry
        CMP knifeHitBoundLow
        BCS CKC_DogBoundsHit
CKC_DogBoundsYRetry
        LDA $0271 ;Never written to
        CMP knifeHitBoundLow
        BCC CKC_DogBoundsDone
        CMP knifeHitBoundHigh
        BCS CKC_DogBoundsDone
CKC_DogBoundsHit 
        LDA #$80
        STA dogHit-1,X ;Use standard enemy indexing, while dog update offsets by one
        STX tempStoreX
        STY tempStoreY
        JSR PlayEnemyKillSound
        LDX tempStoreX
        LDY tempStoreY
CKC_DogBoundsDone 
        RTS

CheckEnemyToPlayer 
        LDX #$05
        LDA playerCoarseX
        CLC
        STA playerHitCheckX
        LDA spriteY
        CLC
        STA playerHitCheckY
CETP_Loop 
        LDA enemyActive,X
        BNE CETP_CheckEnemy
CETP_Next 
        DEX
        BPL CETP_Loop
        JMP CheckEnemyBulletHits

CETP_CheckEnemy 
        LDA enemyDying,X
        BNE CETP_Next
        LDA enemyCoarseX,X
        CLC 
        ADC #$03
        STA enemyTouchBoundHigh
        LDA enemyCoarseX,X
        SEC
        SBC #$03
        STA enemyTouchBoundLow
        LDA playerHitCheckX
        CMP enemyTouchBoundLow
        BCC CETP_NoEnemyTouch
        CMP enemyTouchBoundHigh
        BCS CETP_NoEnemyTouch
        LDA enemyUpperY,X
        CMP enemyLowerY,X
        BEQ CETP_ProneEnemy
        CLC 
        ADC #$12
CETP_ProneEnemy 
        ADC #$0A
        STA enemyTouchBoundHigh
        LDA enemyUpperY,X
        SEC
        SBC #$15
        STA enemyTouchBoundLow
        LDA playerHitCheckY
        CMP enemyTouchBoundLow
        BCC CETP_NoEnemyTouch
        CMP enemyTouchBoundHigh
        BCS CETP_NoEnemyTouch
        STX temp
        STY temp2
        LDA numAliveGyros
        BNE CETP_NoEnemyTouch
KillPlayer 
        LDY #$29
        JSR PlaySong
        PLA
        PLA
        JMP InitNextLife

CETP_NoEnemyTouch 
        JMP CETP_Next
