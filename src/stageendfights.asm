        ; Handling of the stage-specific end fights using a jump table. Called from the main loop.
        ; Each of them calls CompleteStage when the fight is over (typically, all enemies to spawn are exhausted.) The
        ; third stage completion has a stack leak bug which causes sprite corruption after completing the game several 
        ; times. See defines.asm for the define that enables the fix.

UpdateStageEndFight
        LDA stage
        ASL
        TAY
        LDA stageEndJumpTblHi,Y
        PHA
        LDA stageEndJumpTblLo,Y
        PHA
        RTS

stageEndJumpTblHi   =*+$01
stageEndJumpTblLo 
        .WORD Stage1EndFight-1,Stage2EndFight-1,Stage3EndFight-1,Stage4EndFight-1

        ; Stage 4. Spawned enemies from both left and right.

Stage4EndFight
        JSR Stage4NextEnemy
        JSR TrySpawnEnemy
        JSR StageEndFightCalls
        JSR RunEnemyBulletCode
        JSR AnimateEnemiesOnly
        LDA endFightEnemiesLeft
        BPL Stage4NotDone
        JSR CheckEnemiesOnScreen
        BPL Stage4NotDone
        JMP CompleteStage

Stage4NotDone
        JSR SortSprites
        JMP MainLoop

Stage4NextEnemy
        LDA endFightResetFlag
        BNE S4NE_NoReset
        JSR CheckEnemiesOnScreen
        BPL S4NE_Done
        LDA #$00
        STA platformEnemyCount
        INC endFightResetFlag
S4NE_NoReset 
        LDA endFightEnemiesLeft
        BMI S4NE_Done
        LDA platformEnemyCount
        CMP #$03
        BCS S4NE_Done
        LDA spawnEnemyFlag
        BNE S4NE_Done
        INC spawnEnemyFlag
        LDA endFightEnemiesLeft
        AND #$03
        TAY
        LDA finaleSpawnTypeTbl,Y
        STA spawnEnemyType
        TYA
        AND #$01
        TAY
        LDA enemyDirTbl,Y
        STA enemySpawnDirTbl
        DEC endFightEnemiesLeft
S4NE_Done
        RTS

finaleSpawnTypeTbl
        .BYTE ENEMY_PRISONGUARD,ENEMY_BAZOOKA,ENEMY_MARTIALARTIST,ENEMY_GRENADIER

        ; Stage 2. Dog handlers and waves of 3 dogs from both left and right.

Stage2EndFight
        JSR InitDogFight
        JSR UpdateDogHandler
        JSR StageEndFightCalls
        JSR UpdateDogs
        JSR AnimateEnemiesOnly
        JSR UpdateEnemyTimers
        LDA endFightEnemiesLeft
        BPL S2EF_NotDone
        LDA enemyActive
        BNE S2EF_NotDone
        LDX #$02
S2EF_DogLoop
        LDA dogActive,X
        BNE S2EF_NotDone
        DEX
        BPL S2EF_DogLoop
        LDA #$07
        JSR SwapGraphicsData
        JMP CompleteStage

S2EF_NotDone 
        JSR SortSprites
        JMP MainLoop

UpdateDogHandler 
        LDX #$00
        LDA stageEndReached
        BEQ UDH_Done
        LDA enemyActive
        BNE UDH_IsActive
        LDA #$00
        STA nextSpawnTblIndex
        STA enemyJumping
        LDA #ENEMY_MARTIALARTIST
        STA spawnEnemyType
        LDA nextDogHandlerDir
        EOR #$0C
        STA nextDogHandlerDir
        JSR CSNE_SetEnemyXPos
        LDA #$00
        STA enemyPlatformHeight
        INC platformEnemyCount
        STA enemyCoarseX
        LDA #$CD
        STA spriteY+SPR_ENEMYUPPER
        CLC 
        ADC #$15
        STA spriteY+SPR_ENEMYLOWER
        LDA nextDogHandlerDir
        STA enemyControls
        LDA #$1E
        STA dogHandlerDelayTimer
UDH_IsActive 
        DEC dogHandlerDelayTimer
        BNE UDH_Done
        LDA nextDogHandlerDir
        CMP #$04
        BEQ UDH_OnLeft
        LDA playerCoarseX
        CMP enemyCoarseX
        BCC UDH_Done
        JMP UDH_CommandDogsAnim

UDH_OnLeft
        LDA playerCoarseX
        CMP enemyCoarseX
        BCS UDH_Done
UDH_CommandDogsAnim 
        LDA #$3C
        STA dogHandlerDelayTimer
        LDA #$01
        STA enemyTimerActive
        LDA #$19
        STA enemyTimer
        LDA playerCoarseX
        CMP enemyCoarseX
        LDA #$00
        ROL
        TAY
        LDA dogHandlerFrameTbl,Y
        STA spriteFrame+SPR_ENEMYUPPER
UDH_Done
        RTS

dogHandlerFrameTbl 
        .BYTE $C8,$C7

CheckEnemiesOnScreen 
        LDX #$05
CEOS_EnemyLoop 
        LDA enemyActive,X
        BNE CEOS_Found
        DEX
        BPL CEOS_EnemyLoop
        LDX #$02
CEOS_BulletLoop 
        LDA bulletActive+3,X
        BNE CEOS_Found
        DEX
        BPL CEOS_BulletLoop
CEOS_Found
        CPX #$00
        RTS

InitDogFight 
        LDA stageEndReached
        BNE IDF_Done
        JSR CheckEnemiesOnScreen
        BPL IDF_Done
        LDA #$00
        STA platformEnemyCount
        INC stageEndReached
        LDA #$04
        STA nextDogHandlerDir
        LDA #$07
        JSR SwapGraphicsData
IDF_Done 
        RTS

UpdateDogs
        LDA platformEnemyCount
        CMP #$04
        BCS UD_NoSpawnNew
        JSR SpawnNewDogs
UD_NoSpawnNew 
        JSR MoveDogs
        JSR CheckKilledDogs
        JSR AnimateDogs
        RTS 

CheckKilledDogs
        LDX #$02
CKD_Loop 
        LDA dogDead,X
        BNE CKD_CheckRemove
        LDA dogHit,X
        BEQ CKD_Next
        LDA #$1E
        STA enemyAuxTimer,X
        STA dogDead,X
        LDA dogDir,X
        PHA
        EOR #$0C
        STA dogDir,X
        PLA
        AND #$04
        BNE CKD_SetFrame
        LDA #$CF
        .BYTE $2C
CKD_SetFrame
        LDA #$D0
        JSR DJ_SetFrameAndInit
CKD_CheckRemove
        JSR RemoveDeadDog
CKD_Next 
        DEX
        BPL CKD_Loop
        RTS

RemoveDeadDog 
        DEC enemyAuxTimer,X
        BNE RDD_HasDelay
        LDA #$00
        STA dogJumping,X
        STA dogActive,X
        STA dogHit,X
        STA dogDead,X
        STA spriteXMSB+SPR_ENEMYDOG,X
        STA spriteX+SPR_ENEMYDOG,X
        STA dogCoarseX,X
        DEC platformEnemyCount
        STA spriteY+SPR_ENEMYDOG,X
RDD_HasDelay
        RTS

AnimateDogs 
        LDX #$02
AD_Loop LDA dogActive,X
        BEQ AD_Next
        LDA dogDead,X
        BEQ AD_IsActiveAndAlive
AD_Next DEX
        BPL AD_Loop
        RTS

AD_IsActiveAndAlive     
        LDA dogJumping,X
        BNE AD_Next
        LDA endFightResetFlag,X
        CMP #$03
        BCS AD_DoAnimate
        INC endFightResetFlag,X
        JMP AD_Next

AD_DoAnimate 
        LDA #$00
        STA endFightResetFlag,X
        LDA dogDir,X
        CMP #$08
        BNE AD_AnimateLeft
        LDA spriteFrame+SPR_ENEMYDOG,X
        CLC
        ADC #$01
        CMP #$CC
        BCC AD_RightDone
        LDA #$C9
AD_RightDone
        STA spriteFrame+SPR_ENEMYDOG,X
        JMP AD_Next

AD_AnimateLeft
        LDA spriteFrame+SPR_ENEMYDOG,X
        CLC
        ADC #$01
        CMP #$CF
        BCC AD_LeftDone
        LDA #$CC
AD_LeftDone 
        STA spriteFrame+SPR_ENEMYDOG,X
        JMP AD_Next

MoveDogs
        LDX #$02
MD_Loop LDA dogActive,X
        BNE MD_IsActive
MD_Next DEX
        BPL MD_Loop
        RTS

MD_IsActive
        LDA dogDir,X
        CMP #$04
        BEQ MD_MoveLeft
        LDA spriteX+SPR_ENEMYDOG,X
        CLC
        ADC #$04
        STA spriteX+SPR_ENEMYDOG,X
        LDA spriteXMSB+SPR_ENEMYDOG,X
        ADC #$00
        STA spriteXMSB+SPR_ENEMYDOG,X
        BEQ MD_RightNoMSB
        LDA spriteX+SPR_ENEMYDOG,X
        CMP #$50
        BCS MD_RemoveOffScreen
MD_RightNoMSB
        JSR DogJump
        JMP MD_Next

MD_MoveLeft
        LDA spriteX+SPR_ENEMYDOG,X
        SEC
        SBC #$04
        STA spriteX+SPR_ENEMYDOG,X
        LDA spriteXMSB+SPR_ENEMYDOG,X
        SBC #$00
        STA spriteXMSB+SPR_ENEMYDOG,X
        BNE MD_LeftHasMSB
        LDA spriteX+SPR_ENEMYDOG,X
        CMP #$12
        BCC MD_RemoveOffScreen
MD_LeftHasMSB
        LDA dogJumping,X
        BEQ MD_NextJump
        JSR DJ_AlreadyJumping
MD_NextJump
        JMP MD_Next

MD_RemoveOffScreen
        LDA #$00
        STA dogActive,X
        STA dogJumping,X
        STA dogDead,X
        STA dogHit,X
        STA spriteX+SPR_ENEMYDOG,X
        STA spriteXMSB+SPR_ENEMYDOG,X
        DEC platformEnemyCount
        STA spriteY+SPR_ENEMYDOG,X
        STA dogCoarseX,X
        JMP MD_Next

SpawnNewDogs
        LDA endFightEnemiesLeft
        BPL SND_HasDogsLeft
        RTS

SND_HasDogsLeft
        LDA dogSpawnTimer
        BEQ SpawnNewDog
        DEC dogSpawnTimer
        RTS

SpawnNewDog
        LDY endFightEnemiesLeft
        LDA dogSpawnDirTbl,Y
        STA staticEnemyType
        LDA dogSpawnColorTbl,Y
        STA staticInitFlags
        LDX #$02
SND_FindFreeLoop
        LDA dogActive,X
        BEQ SND_FoundFree
        DEX
        BPL SND_FindFreeLoop
        RTS

SND_FoundFree
        DEY
        STY endFightEnemiesLeft
        LDA dogSpawnDelayTbl,Y
        STA dogSpawnTimer
        LDA staticEnemyType
        STA dogDir,X
        LDA staticInitFlags
        STA spriteColor+SPR_ENEMYDOG,X
        LDA #$E2
        STA spriteY+SPR_ENEMYDOG,X
        INC platformEnemyCount
        INC dogActive,X
        LDA staticEnemyType
        CMP #$04
        BNE SND_SpawnOnLeft
        LDA #$01
        STA spriteXMSB+SPR_ENEMYDOG,X
        LDA #$4E
        STA spriteX+SPR_ENEMYDOG,X
        LDA #$CD
        STA spriteFrame+SPR_ENEMYDOG,X
SND_Common
        LDA #$01
        STA enemyAuxTimer,X
        STA dogCoarseX,X
        JSR PlayDogBarkSound
        RTS

SND_SpawnOnLeft
        LDA #$00
        STA spriteXMSB+SPR_ENEMYDOG,X
        LDA #$10
        STA spriteX+SPR_ENEMYDOG,X
        LDA #$CA
        STA spriteFrame+SPR_ENEMYDOG,X
        JMP SND_Common

DJ_Done RTS

DogJump LDA dogJumping,X
        BNE DJ_AlreadyJumping
        JSR CheckDogJumpDistance
        BCS DJ_Done
        LDA playerControls
        AND #$02
        BNE DJ_Done
        LDA #$CA
DJ_SetFrameAndInit
        STA spriteFrame+SPR_ENEMYDOG,X
        INC dogJumping,X
        LDY #$11
        LDA spriteY+SPR_ENEMYDOG,X
        SEC
        SBC jumpArcTbl,Y
        STA dogBaseY,X
        TYA
        STA dogJumpArcIndex,X
DJ_AlreadyJumping
        LDY dogJumpArcIndex,X
        LDA dogBaseY,X
        CLC
        ADC jumpArcTbl,Y
        STA spriteY+SPR_ENEMYDOG,X
        LDA dogJumping,X
        BPL DJ_Fall
        INY
        TYA
        STA dogJumpArcIndex,X
        CPY #$12
        BNE DJ_FallDone
        LDA #$00
        STA dogJumping,X
DJ_FallDone
        RTS

DJ_Fall DEY
        TYA
        STA dogJumpArcIndex,X
        BPL DJ_FallDone
        LDA #$80
        STA dogJumping,X
        INC dogJumpArcIndex,X
        RTS

CheckDogJumpDistance
        LDA dogCoarseX,X
        CMP playerCoarseX
        BCS DJ_Done
        CLC
        ADC #$14
        CMP playerCoarseX
        BCC CDJD_Fail
        CLC
        RTS

CDJD_Fail SEC
        RTS

dogSpawnDelayTbl
        .BYTE $14,$14,$19,$14,$14,$19,$14,$14,$19,$14,$14,$19,$14,$14,$19,$14
        .BYTE $14,$19

dogSpawnDirTbl
        .BYTE $04,$04,$04,$08,$08,$08,$04,$04,$04,$08,$08,$08,$04,$04,$04,$08
        .BYTE $08,$08

dogSpawnColorTbl
        .BYTE $09,$09,$09,$08,$08,$08,$09,$09,$09,$08,$08,$08,$09,$09,$09,$08
        .BYTE $08,$08

        ; Common subroutine calls during end fights.

StageEndFightCalls
        JSR SetCoarseXCoords
        JSR PlayerWorldCollision
        JSR CheckEnemiesRunAway
        JSR CheckEnemyToPlayer
        JSR CheckKillEnemies
        JSR UpdateEnemyTimers
        JSR UpdateBullets
        JMP UpdateExtraWeapon

AnimateEnemiesOnly
        JSR AnimateEnemies
        JSR EnemyWorldCollision
        JMP UpdateEnemies

Stage3EndFightCalls
        JSR SetCoarseXCoords
        JSR PlayerWorldCollision
        JSR CheckEnemiesRunAway
        JSR CheckEnemyToPlayer
        JSR UpdateGyroGrenades
        JSR CheckDestroyGyros
        JSR UpdateEnemyTimers
        JSR UpdateBullets
a1020   =*+$02
        JMP UpdateExtraWeapon

         ; Stage 3. Three gyrocopters, with 2 active at the same time.

Stage3EndFight
        JSR SpawnGyrocopters
        LDA stageEndReached
        BEQ S3EF_WaitForStart
        JSR UpdateGyroSprites
        JSR MultiplyGyroXCoords
        JSR AnimateGyrocopters
        JSR UpdateGyroFlight
        JSR Stage3EndFightCalls
S3EF_FinishCommon
        JSR RunEnemyBulletCode
        JSR SortSprites
        JMP MainLoop

S3EF_WaitForStart
        JSR StageEndFightCalls
        JSR AnimateEnemiesOnly
        JMP S3EF_FinishCommon

CheckDestroyGyros
        LDX #$05
CDG_Loop LDA enemyHit,X
        BNE CDG_DoDestroy
CDG_Next DEX
        BPL CDG_Loop
        RTS

CDG_DoDestroy
        STX temp
        JSR DestroyGyrocopter
        LDX temp
        JMP CDG_Next

UpdateGyroGrenades
        LDX #$02
UHG_Loop JSR CheckBulletExploded
        DEX
        BPL UHG_Loop
        RTS

UpdateGyroFlight
        LDY #$01
UGF_Loop
        LDA gyroYPathDir,Y
        BNE UGF_YPathActive
        LDA gyrosAliveFlag
        BEQ UGF_DescendLow
        LDA gyroY,Y
        CMP #$58
        BCS UGF_SetActive
UGF_DescendLow
        LDA gyroY,Y
        CMP #$90
        BCS UGF_SetActiveLow
        LDA gyroY,Y
        BEQ UGF_Next
        CLC
        ADC #$02
        STA gyroY,Y
UGF_Next
        JSR UGF_HorizMoveLogic
        DEY
        BPL UGF_Loop
        RTS

UGF_SetActive
        LDA #$01
        STA gyroYPathDir,Y
        LDA #$58
        STA gyroBaseY,Y
        LDA #$00
        STA gyroYPathIndex,Y
        JMP UGF_Next

UGF_SetActiveLow
        LDA #$01
        STA gyroYPathDir,Y
        STA gyrosAliveFlag
        LDA #$90
        STA gyroBaseY,Y
        LDA #$00
        STA gyroYPathIndex,Y
        JMP UGF_Next

UGF_YPathActive 
        LDX gyroYPathIndex,Y
        LDA gyroYPathTbl,X
        BMI UGF_GyroYPathEnd
        CLC 
        ADC gyroBaseY,Y
        STA gyroY,Y
        LDA gyroYPathDir,Y
        BMI UGF_GyroYPathReverse
        INX 
        TXA
        STA gyroYPathIndex,Y
        JMP UGF_Next

UGF_GyroYPathEnd
        STA gyroYPathDir,Y
UGF_GyroYPathReverse
        DEX
        BMI UGF_GyroYPathWrap
        TXA
        STA gyroYPathIndex,Y
        JMP UGF_Next

UGF_GyroYPathWrap
        LDA #$01
        STA gyroYPathDir,Y
        JMP UGF_Next

UGF_HorizMoveLogic 
        LDA gyroBaseY,Y
        CMP #$58
        BEQ UGF_HighGyroHorizMove
        LDA gyroCoarseX,Y
        ADC #$14
        CMP playerCoarseX
        BCC UGF_CheckHorizTurn
        SEC
        SBC #$28
        CMP playerCoarseX
        BCS UGF_CheckHorizTurn
UGF_GyroXMove
        LDA gyroXSpeed,Y
        CLC
        ADC gyroCoarseX,Y
        STA gyroCoarseX,Y
        RTS

UGF_CheckHorizTurn 
        LDA gyroCoarseX,Y
        CMP playerCoarseX
        BCC UGF_CheckTurnRight
        LDA gyroXSpeed,Y
        BMI UGF_NoHorizTurn
        LDA #$FF
        STA gyroXSpeed,Y
        JSR SetGyroMidFrame
UGF_NoHorizTurn 
        JMP UGF_GyroXMove

UGF_CheckTurnRight
        LDA gyroXSpeed,Y
        BPL UGF_NoHorizTurn
        LDA #$01
        STA gyroXSpeed,Y
        JSR SetGyroMidFrame
        JMP UGF_GyroXMove

UGF_HighGyroHorizMove
        LDA gyroCoarseX,Y
        CMP #$14
        BCC UGF_HighGyroLeftEdge
        CMP #$8C
        BCS UGF_HighGyroRightEdge
        JMP UGF_GyroXMove

UGF_HighGyroLeftEdge 
        LDA gyroXSpeed,Y
        BPL UGF_NoHorizTurn
        LDA #$01
        STA gyroXSpeed,Y
        JSR SetGyroMidFrame
        JMP UGF_GyroXMove

UGF_HighGyroRightEdge
        LDA gyroXSpeed,Y
        BMI UGF_NoHorizTurn
        LDA #$FF
        STA gyroXSpeed,Y
        JSR SetGyroMidFrame
        JMP UGF_GyroXMove

gyroYPathTbl
        .BYTE $00,$00,$01,$02,$03,$04,$06,$08,$0A,$0C,$0E,$10,$12,$14,$16,$18
        .BYTE $1A,$1C,$1E,$20,$22,$23,$24,$25,$26,$27,$28,$28,$FF

SetGyroMidFrame 
        LDA gyroEnemyIndexTbl,Y
        TAX
        STY temp2
        LDY #$00
SGMF_Loop
        LDA gyroUpperMidFrameTbl,Y
        STA spriteFrame+SPR_ENEMYUPPER,X
        LDA gyroLowerMidFrameTbl,Y
        STA spriteFrame+SPR_ENEMYLOWER,X
        INX
        INY
        CPY #$03
        BCC SGMF_Loop
        LDY temp2
        LDA #$06
        STA gyroAnimDelay,Y
        RTS

ThrowGyroGrenade 
        INX
        LDA gyroXSpeed,Y
        BPL TGG_HasDir
        LDA #$04
        .BYTE $2C
TGG_HasDir
        LDA #$08
        STA enemyHorizMove,X
        LDA #ENEMY_GRENADIER
        STA enemyType,X
        LDA gyroY,Y
TGG_GyroNotActive
        BEQ TGG_Done
        STX temp
        STY temp2
        JSR DEF_DoFire
        LDY temp2
        LDX temp
        LDA #ENEMY_PARACHUTE
        STA enemyType,X
        DEX
TGG_Done
        RTS

AG_MovingRight
        LDA #$00
        BEQ AG_GetFrame
AG_Done RTS

DestroyGyrocopter
        CPX #$03
        BCC DG_NoIndexClamp
        LDX #$03
        .BYTE $2C
DG_NoIndexClamp
        LDX #$00
        TXA
        CLC
        ADC #$03
        STA tempStore
DG_PieceLoop
        LDA #$00
        STA enemyActive,X
        STA enemyHit,X
        STA enemyDying,X
        STA spriteY+SPR_ENEMYUPPER,X
        STA spriteY+SPR_ENEMYLOWER,X
        INX
        CPX tempStore
        BNE DG_PieceLoop
        DEC numAliveGyros
        LDA #$00
        STA gyrosAliveFlag
        LDA #$20
        STA gyroSpawnTimer
        TXA
        LSR
        LSR
        TAY
        LDA #$00
        STA gyroY,Y
        STA gyroYPathDir
        STA secondGyroYPathDir
        RTS

AnimateGyrocopters
        LDY #$00
        LDX #$00
        LDA #$03
        STA gyroSprEndCmp
AG_Loop LDA gyroAnimDelay,Y
        BEQ AG_NoDelay
        SEC
        SBC #$01
        STA gyroAnimDelay,Y
        CPY #$01
        BEQ AG_Done
        LDX #$03
        JMP AG_MoveToNext

AG_NoDelay
        LDA gyroAnimFrame,Y
        CLC
        ADC #$01
        AND #$03
        STA gyroAnimFrame,Y
        STA temp2
        LDA gyroXSpeed,Y
        BPL AG_MovingRight
        LDA #$18
        CLC
AG_GetFrame
        LDY temp2
        ADC gyroFrameBaseTbl,Y
        TAY
AG_SpriteLoop
        LDA gyroUpperFrameTbl,Y
        STA spriteFrame+SPR_ENEMYUPPER,X
        LDA gyroLowerFrameTbl,Y
        STA spriteFrame+SPR_ENEMYLOWER,X
        INY
        INX
gyroSprEndCmp   =*+$01
        CPX #$03
        BNE AG_SpriteLoop
        CPX #$06
        BEQ AG_Done2
AG_MoveToNext
        LDA #$06
        STA gyroSprEndCmp
        LDY #$01
        JMP AG_Loop

AG_Done2 RTS

gyroEnemyIndexTbl
        .BYTE $00,$03

gyroAnimDelay
        .BYTE $00,$00

gyroFrameBaseTbl
        .BYTE $00,$06,$0C,$12

gyroUpperFrameTbl
        .BYTE $C5,$C6,$C7

gyroLowerFrameTbl
        .BYTE $C8,$C9,$CA,$CB,$C6,$CD,$D0,$C9,$CA,$CC,$CF,$CE,$D1,$C9,$CA,$CC
        .BYTE $CF,$CE,$D1,$C9,$CA,$D4,$D3,$C5,$D7,$D6,$D5,$D9,$D3,$D8,$D7,$D6
        .BYTE $DC,$DA,$DB,$CC,$D7,$D6,$DD,$DA,$DB,$CC,$D7,$D6,$DC

gyroUpperMidFrameTbl
        .BYTE $CC,$DF,$CC

gyroLowerMidFrameTbl
        .BYTE $CC,$DE,$CC

MultiplyGyroXCoords LDX #$0B
MGXC_Loop
        LDA spriteX+SPR_ENEMYUPPER,X
        ASL
        STA spriteX+SPR_ENEMYUPPER,X
        LDA #$00
        ADC #$00
        STA spriteXMSB+SPR_ENEMYUPPER,X
        DEX
        BPL MGXC_Loop
        RTS

UpdateGyroSprites
        LDY numAliveGyros
        BEQ UGS_NoGyrosActive
        LDY #$02
        DEY
UGS_Loop
        LDA gyroY,Y
        BEQ UGS_Next
        STY tempStore
        TYA
        ASL
        CLC
        ADC tempStore
        TAX
        CLC
        ADC #$03
        PHA
        JSR TimerCheck
        BCC UGS_NoGrenade
        JSR ThrowGyroGrenade
UGS_NoGrenade
        PLA
        STA tempStore
        LDA gyroCoarseX,Y
        SEC
        SBC #$0C
UGS_SpriteLoop
        STA spriteX+SPR_ENEMYUPPER,X
        STA spriteX+SPR_ENEMYLOWER,X
        CLC
        ADC #$0C
        INX
        CPX tempStore
        BNE UGS_SpriteLoop
        TXA
        SEC
        SBC #$03
        TAX
UGS_SpriteYLoop 
        LDA spriteX+SPR_ENEMYUPPER,X
        CMP #$AC
        BCS UGS_ClipRight
        LDA gyroY,Y
        STA spriteY+SPR_ENEMYUPPER,X
        CLC
        ADC #$15
        STA spriteY+SPR_ENEMYLOWER,X
        JMP UGS_YDone

UGS_ClipRight 
        LDA #$00
        STA spriteY+SPR_ENEMYUPPER,X
        STA spriteY+SPR_ENEMYLOWER,X
UGS_YDone 
        INX
        CPX tempStore
        BNE UGS_SpriteYLoop
UGS_Next
        DEY
        BPL UGS_Loop
UGS_NoGyrosActive
        RTS

SpawnGyrocopters
        LDA endFightEnemiesLeft
        BEQ SG_NoMoreGyros
        CMP #$03
        BNE SG_InitDone
        JSR CheckEnemiesOnScreen
        BPL SG_Wait
        LDA #$00
        LDX #$05
SG_InitLoop 
        STA enemyDying,X
        STA enemyHit,X
        DEX
        BPL SG_InitLoop
        STA gyroYPathDir
        LDY #$2F
        JSR PlaySong
        INC stageEndReached
SG_InitDone
        LDA numAliveGyros
        BEQ SG_FindFreeEnemySlot
        CMP #$02
        BEQ SG_Wait
        DEC gyroSpawnTimer
        BNE SG_Wait
SG_FindFreeEnemySlot
        LDX #$00
SG_FindFreeLoop
        LDA enemyActive,X
        BEQ SG_FreeFound
        INX
        CPX #$06
        BCC SG_FindFreeLoop
        RTS

SG_FreeFound
        TXA
        LSR
        TAY
        JSR SpawnGyrocopter
SG_Wait RTS

SG_NoMoreGyros
        LDA numAliveGyros
        BNE SG_Wait

    .if THIRD_STAGE_STACK_FIX > 0

        ; We are in 1 subroutine call deep, so must pop off bytes to not leak on each playthrough
        ; (which finally leads to sprite corruption)
        PLA
        PLA

     .endif

        JMP CompleteStage

SpawnGyrocopter LDA gyroXInitTbl,Y
        STA gyroCoarseX,Y
        LDA gyroYInitTbl,Y
        STA gyroY,Y
        LDA gyroXSpeedInitTbl,Y
        STA gyroXSpeed,Y
        TXA
        CLC 
        ADC #$03
        STA tempStore
SG_SpriteLoop LDA #ENEMY_PARACHUTE
        STA enemyActive,X
        STA enemyType,X

    .if THIRD_STAGE_STACK_FIX = 0

        ; Original code

        LDA #$00
        STA enemyDying,X
        LDA #$01
        STA spriteColor+SPR_ENEMYUPPER,X
        LDA #$06
        STA spriteColor+SPR_ENEMYLOWER,X
        INX
        CPX tempStore
        BNE SG_SpriteLoop
        INC numAliveGyros
        DEC endFightEnemiesLeft
        LDA #$20
        STA gyroSpawnTimer
        LDA #$00
        STA gyroYPathDir,Y
        RTS

    .else

        ; Shortened code for the stack fix above

        LDA #$01
        STA spriteColor+SPR_ENEMYUPPER,X
        LDA #$06
        STA spriteColor+SPR_ENEMYLOWER,X
        LDA #$00
        STA enemyDying,X
        INX
        CPX tempStore
        BNE SG_SpriteLoop
        INC numAliveGyros
        DEC endFightEnemiesLeft
        STA gyroYPathDir,Y
        LDA #$20
        STA gyroSpawnTimer
        RTS

    .endif

gyroXSpeedInitTbl .BYTE $01,$FF

gyroXInitTbl .BYTE $01,$B4

gyroYInitTbl .BYTE $46,$46

S1EF_WaitBegin 
        JMP Main_NoStageEndFight

        ; Stage 1. An indestructible truck which drives past the screen right edge, after which waves of enemies are
        ; spawned from the right.

Stage1EndFight
        LDA stageEndReached
        BNE S1EF_Started
        JSR CheckEnemiesOnScreen
        BPL S1EF_WaitBegin
S1EF_Started
        JSR TruckAnimation
        JSR StageEndFightCalls
        LDA stageEndReached
        BEQ S1EF_NotFinished
        JSR Stage1EndEnemySpawn
        JSR AnimateEnemiesOnly
        LDA endFightEnemiesLeft
        BNE S1EF_NotFinished
        LDA platformEnemyCount
        BNE S1EF_NotFinished
        JSR FadeMotorSound
        JSR WaitSongToEnd
        JMP CompleteStage

S1EF_NotFinished
        JSR SortSprites
        JMP MainLoop

        ; Check for starting the end fight. Called from the main loop.
        
CheckStartEndFight
        LDA playerRightLimit
        CMP #$E0
        BNE CSEF_Fail
        JSR CheckSongEnd
        BNE CSEF_Fail
        LDA #$01
        STA stageEndFightActive
        LDA #$FA
        STA gameTimer
CSEF_Fail RTS