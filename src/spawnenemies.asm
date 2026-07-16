        ; Handle spawning of both random and pre-placed enemies. The spawn routines are also reused by the intro prison
        ; screen and the end-of-the-stage fights. The spawn routines (as well as enemy movement) check the enemy counts
        ; on each platform level (ground, middle, top) to avoid overloading the sprite multiplexer. Only 3 enemies are
        ; allowed on each level. The spawn routines also check the screen chars under the spawn positions to avoid
        ; spawning enemies mid-air.

        ; Set next enemy "spawn slot" active. Called from the main loop.

SetEnemyToSpawn
        LDX #$04
SETS_Loop
        LDA spawnEnemyFlag,X
        BNE SETS_Next
        DEC spawnEnemyTimer,X
        BNE SETS_Next
        TXA
        CLC
        ADC spawnTblIndexMod
        TAY
        LDA enemySpawnTypeTbl,Y
        STA spawnEnemyType,X
        LDA spawnEnemyTimerTbl,Y
        STA spawnEnemyTimer,X
        LDA #$01
        STA spawnEnemyFlag,X
        RTS

SETS_Next
        DEX
        BPL SETS_Loop
        RTS

        ; Find next spawn slot to use for spawning.
        ; Return index in X and C=1 if found.

FindNextSpawnType
        LDX #$05
FNST_Loop
        LDA spawnEnemyFlag,X
        BEQ FNST_NoSpawn
        STX nextSpawnTblIndex
        SEC
        RTS

FNST_NoSpawn
        DEX
        BPL FNST_Loop
        CLC
        RTS

spawnEnemyTimerTbl
        .BYTE $C8,$E6,$B4,$BE,$FA,$AA,$A0,$B4,$A0,$96,$A0,$8C,$A0,$A0,$A0,$AA
        .BYTE $8C,$96,$91,$87

enemySpawnTypeTbl
        .BYTE $00,$00,$03,$02,$03,$03,$00,$05,$02,$03,$05,$03,$02,$03,$05,$02
        .BYTE $08,$02,$08,$03

enemySpawnDirTbl
        .BYTE $04,$04,$08,$04,$04,$04,$08,$04,$04,$08,$04,$04,$08,$08,$04,$08
        .BYTE $04,$08,$04,$08

        ; Try to spawn a pre-placed enemy. Called from the main loop.

TrySpawnStaticEnemy
        JSR FindNextStaticEnemy
        LDA numEnemies
        CMP #$06
        BCS TSSE_Fail
        LDA staticSpawnFlag
        BEQ TSSE_Fail
        JSR FindFreeEnemySlot
        JSR TSSE_CheckCounts
TSSE_Fail
        RTS

        .BYTE $02

TSSE_CheckCounts
        LDY staticEnemyPlatform
        LDA platformEnemyCount,Y
        CMP #$03
        BCS TSSE_Fail
        LDA nextSpawnTblIndex
        PHA
        LDA #$00
        STA nextSpawnTblIndex
        JSR CheckCharAtSpawn
        PLA
        STA nextSpawnTblIndex
        PHP
        LDA staticEnemyType
        CMP #ENEMY_PARACHUTE ; Parachute enemy can also spawn into the air
        BNE TSSE_CheckGround
        PLP
        JMP TSSE_DoSpawn

TSSE_DoSpawn 
        JMP SpawnStaticEnemy

TSSE_CheckGround 
        PLP
        BCS SpawnStaticEnemy
        JMP TSSE_AbortSpawn

SpawnStaticEnemy
        LDA platformEnemyCount,Y
        CLC
        ADC #$01
        STA platformEnemyCount,Y
        TYA
        STA enemyPlatformHeight,X
        LDA platformYTbl,Y
        CLC 
        ADC staticUpperYOffset
        STA spriteY+SPR_ENEMYUPPER,X
        LDA platformYTbl,Y
        CLC 
        ADC staticLowerYOffset
        STA spriteY+SPR_ENEMYLOWER,X
        LDA #$01
        STA spriteXMSB+SPR_ENEMYUPPER,X
        STA spriteXMSB+SPR_ENEMYLOWER,X
        LDA #$4F
        CLC
        ADC staticUpperXOffset
        STA spriteX+SPR_ENEMYUPPER,X
        LDA #$4F
        CLC
        ADC staticLowerXOffset
        STA spriteX+SPR_ENEMYLOWER,X
        LDA staticInitFlags
        STA enemyRunSpeed,X
        LDA staticEnemyType
        STA enemyType,X
        TAY
        LDA perTypeUpperColor,Y
        STA spriteColor+SPR_ENEMYUPPER,X
        STA spriteColor+SPR_ENEMYLOWER,X
        LDA perTypeUpperInitFrame,Y
        STA spriteFrame+SPR_ENEMYUPPER,X
        LDA perTypeLowerInitFrame,Y
        STA spriteFrame+SPR_ENEMYLOWER,X
        LDA perTypeTimerInit,Y
        STA enemyTimer,X
        LDA #$01
        STA enemyActive,X
        LDA #$04
        STA enemyHorizMove,X
        LDA staticEnemyTimer
        STA enemyTimerActive,X
        LDA #$00
        STA enemyHit,X
        STA enemyDying,X
        LDA staticEnemyIndex
        STA enemyStaticIndex,X
        INC numEnemies
        DEC staticSpawnFlag
        LDA #$04
        STA enemyControls,X
        RTS 

TSSE_AbortSpawn 
        DEC staticSpawnFlag
        RTS

FindNextStaticEnemy 
        LDY stage
        LDX staticEnemyStartTbl,Y
FNSE_Loop
        LDA staticEnemySpawnFlag,X
        BNE FNSE_Next
        LDA stagePosMSB
        CMP staticEnemyPosMSBTbl,X
        BNE FNSE_Next
        LDA stagePosLSB
        CMP staticEnemyPosLSBTbl,X
        BNE FNSE_Next
        STX staticEnemyIndex
        LDA #$01
        STA staticSpawnFlag
        INC staticEnemySpawnFlag,X
        LDA staticEnemyTypeTbl,X
        STA staticEnemyType
        LDA #$01
        STA staticEnemyTimer
        LDA staticEnemyPlatformTbl,X
        STA staticEnemyPlatform
        LDY staticEnemyType
        LDA staticPerTypeUpperOffsetY,Y
        STA staticUpperYOffset
        LDA staticPerTypeLowerOffsetY,Y
        STA staticLowerYOffset
        LDA staticPerTypeUpperOffsetX,Y
        STA staticUpperXOffset
        LDA staticPerTypeLowerOffsetX,Y
        STA staticLowerXOffset
        LDA perTypeInitFlags,Y
        STA staticInitFlags
        RTS

FNSE_Next
        INX
        TXA
        CMP staticEnemyEndTbl,Y
        BCC FNSE_Loop
        RTS

staticEnemyPosLSBTbl 
        .BYTE $38,$84,$AC,$0C,$64,$D8,$E0,$00,$08,$28,$30,$50,$73,$A0,$CB,$D3
        .BYTE $D9,$03,$32,$58,$60,$F6,$F7,$27,$38,$40,$50,$68,$98,$A0,$A1,$B0
        .BYTE $CE,$E0,$EA,$0F,$2A,$8C,$A0,$D7,$E2,$EA,$F8,$92,$A0,$AA,$AB,$DA
        .BYTE $EA,$F2,$22,$32,$3C,$3D,$49,$51,$93,$AA,$CC,$F2

staticEnemyPosMSBTbl 
        .BYTE $00,$00,$00,$01,$01,$01,$01,$02,$02,$02,$02,$02,$02,$02,$02,$02
        .BYTE $02,$03,$03,$03,$03,$03,$03,$04,$04,$04,$04,$04,$04,$04,$04,$04
        .BYTE $04,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,$06
        .BYTE $06,$06,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07

        ; See types in defines.asm

staticEnemyTypeTbl
        .BYTE $01,$01,$04,$01,$01,$01,$06,$07,$06,$06,$07,$01,$06,$09,$06,$01
        .BYTE $09,$06,$04,$07,$06,$04,$01,$04,$01,$07,$04,$07,$04,$01,$07,$04
        .BYTE $01,$04,$04,$06,$06,$09,$09,$06,$07,$06,$01,$06,$07,$01,$07,$07
        .BYTE $07,$01,$06,$07,$01,$06,$04,$04,$01,$06,$09,$09

        ; Weapon dropped by the commandants (type 1)

staticEnemyWpnType
        .BYTE $04,$04,$00,$04,$04,$02,$00,$00,$00,$00,$00,$02,$00,$00,$00,$02
        .BYTE $00,$00,$00,$00,$00,$00,$03,$00,$03,$00,$00,$00,$00,$03,$00,$00
        .BYTE $02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$00,$03,$00,$00
        .BYTE $00,$03,$00,$00,$02,$00,$00,$00,$02,$00,$00,$00

staticEnemyPlatformTbl
        .BYTE $01,$02,$00,$01,$00,$01,$00,$00,$00,$02,$00,$02,$02,$00,$02,$02
        .BYTE $00,$00,$00,$00,$01,$00,$01,$00,$01,$00,$00,$00,$00,$01,$00,$00
        .BYTE $01,$00,$00,$02,$02,$00,$00,$01,$01,$00,$01,$02,$00,$02,$00,$00
        .BYTE $00,$02,$02,$00,$02,$02,$00,$00,$01,$00,$00,$00

staticPerTypeUpperOffsetY
        .BYTE $00,$15,$00,$00,$00,$00,$15,$15,$00,$33

staticPerTypeLowerOffsetY
        .BYTE $15,$15,$15,$15,$15,$15,$15,$15,$15,$33

staticPerTypeUpperOffsetX
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$18

staticPerTypeLowerOffsetX
        .BYTE $00,$18,$00,$00,$00,$00,$18,$18
        .BYTE $00,$18

staticEnemyStartTbl
        .BYTE $00,$05,$15,$2B

staticEnemyEndTbl
        .BYTE $05,$15,$2B,$3C

staticEnemyType
        .BYTE $00
staticEnemyTimer
        .BYTE $00
staticEnemyPlatform
        .BYTE $00
staticInitFlags
        .BYTE $00
staticUpperYOffset
        .BYTE $00
staticLowerYOffset
        .BYTE $00
staticUpperXOffset
        .BYTE $00
staticLowerXOffset
        .BYTE $00
staticEnemyIndex
        .BYTE $00

        ; Try to spawn a random enemy to the screen edges during the stage. Called from the main loop.
        
TrySpawnEnemy
        JSR FindNextSpawnType
        BCC TSE_Fail
        JSR CheckTooManyEnemies
        BCS TSE_Fail
        JSR FindFreeEnemySlot
        BCS TSE_Fail
        JSR CheckSpawnNewEnemyPY
TSE_Fail
        RTS

CheckSpawnNewEnemyPY
        LDY playerPlatformHeight
        LDA #$03
        STA spawnRetryCount
CheckSpawnNewEnemyY
        LDA platformEnemyCount,Y
        CMP #$03
        BCC CSNE_CountOK
CSNE_FailSpawn
        JMP TSE_NextPlatform

CSNE_CountOK
        LDA stageEndReached
        BNE CSNE_NoStageEnd
        JSR CheckCharAtSpawn
        BCC CSNE_FailSpawn
CSNE_NoStageEnd
        LDA platformEnemyCount,Y
        CLC
        ADC #$01
        STA platformEnemyCount,Y
        TYA
        STA enemyPlatformHeight,X
        LDA stageEndReached
        BEQ CSNE_UsePlatformY
        LDA #$A9
        JMP CSNE_SetEnemyPos

CSNE_UsePlatformY
        LDA platformYTbl,Y
CSNE_SetEnemyPos
        STA spriteY+SPR_ENEMYUPPER,X
        CLC
        ADC #$15
        STA spriteY+SPR_ENEMYLOWER,X
        LDY nextSpawnTblIndex
        LDA enemySpawnDirTbl,Y
CSNE_SetEnemyXPos
        LDY #$00
        CMP #$04
        BEQ CSNE_SpawnRight
        INY
CSNE_SpawnRight
        LDA enemySpawnXMSBTbl,Y
        STA spriteXMSB+SPR_ENEMYUPPER,X
        STA spriteXMSB+SPR_ENEMYLOWER,X
        LDA enemySpawnXTbl,Y
        CPY #$00
        BNE CSNE_NoSpawnXAdjust
        PHA
        LDA temp
        CMP #$C8
        PLA
        BCC CSNE_NoSpawnXAdjust
        SEC
        SBC #$08
CSNE_NoSpawnXAdjust
        CLC
        ADC scrollX
        STA spriteX+SPR_ENEMYUPPER,X
        STA spriteX+SPR_ENEMYLOWER,X
        LDY nextSpawnTblIndex
        LDA spawnEnemyType,Y
        STA enemyType,X
        PHA
        LDA #$00
        STA spawnEnemyFlag,Y
        PLA
        TAY
        LDA perTypeUpperColor,Y
        STA spriteColor+SPR_ENEMYUPPER,X
        LDA perTypeLowerColor,Y
        STA spriteColor+SPR_ENEMYLOWER,X
        LDA perTypeInitFlags,Y
        STA enemyRunSpeed,X
        LDA #$01
        STA enemyActive,X
        INC numEnemies
        LDY nextSpawnTblIndex
        LDA enemySpawnDirTbl,Y
        STA enemyControls,X
        LDA #$00
        STA enemyLastControls,X
        STA enemyHit,X
        STA enemyDying,X
        LDA #$00
        STA nextSpawnTblIndex
        RTS

TSE_NextPlatform
        TYA
        SEC
        SBC #$01
        BCS TSE_NoPlatformWrap
        LDA #$02
TSE_NoPlatformWrap
        TAY
        DEC spawnRetryCount
        BEQ TSE_RetriesExhausted
        JMP CheckSpawnNewEnemyY

TSE_RetriesExhausted
        RTS

CheckCharAtSpawn
        SEC
        CPY #$00
        BEQ CCAS_NoChar
        STY tempStore
        LDY nextSpawnTblIndex
        LDA enemySpawnDirTbl,Y
        LDY tempStore
        DEY
        CMP #$04
        BEQ CCAS_Left
        INY
        INY
CCAS_Left
        LDA spawnScreenPosTblLo,Y
        STA screenPtrLo
        LDA spawnScreenPosTblHi,Y
        STA screenPtrHi
        LDY #$00
        LDA (screenPtrLo),Y
        STA temp
        INY
        LDA (screenPtrLo),Y
        LDY tempStore
        CMP #$C8
        BCC CCAS_NoChar
        SEC
        SBC #$C8
        TAY
        LDA charTypeTbl,Y
        LDY tempStore
        AND #$0C
        CMP #$0C
CCAS_NoChar
        RTS

enemySpawnXMSBTbl
        .BYTE $01,$00

enemySpawnXTbl
        .BYTE $44,$12

spawnScreenPosTblLo
        .BYTE $F6,$06,$D0,$E0

spawnScreenPosTblHi
        .BYTE $42,$42,$42,$41

perTypeUpperColor
        .BYTE $09,$01,$06,$06,$0D,$0D,$09,$09,$0B,$0D

perTypeLowerColor
        .BYTE $09,$01,$06,$06,$0D,$0D,$09,$09,$06,$0D

perTypeInitFlags
        .BYTE $80,$00,$80,$A0,$00,$C0,$00,$00,$40,$C0

perTypeTimerInit
        .BYTE $00,$3C,$00,$00,$00,$00,$1E,$00,$00,$00

perTypeUpperInitFrame
        .BYTE $00,$38,$01,$00,$14,$00,$B7,$5F,$04,$B5

perTypeLowerInitFrame
        .BYTE $00,$39,$01,$00,$6E,$00,$B6,$60,$04,$B6

CheckTooManyEnemies
        LDA numEnemies
        CMP #$05
        RTS

        ; Find free enemy sprite slot based on the Y-coordinate check (0 = inactive)
        ; Return index in X and C=0 if found.

FindFreeEnemySlot
        LDX #$05
FFES_Loop
        LDA spriteY+SPR_ENEMYUPPER,X
        BEQ FFES_Found
        DEX
        BPL FFES_Loop
        SEC
        RTS

FFES_Found
        CLC
        RTS