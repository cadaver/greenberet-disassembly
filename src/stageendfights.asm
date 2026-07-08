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
        .BYTE $03,$06,$05,$08

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
        LDA #$05
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
        STA enemyUpperY
        CLC 
        ADC #$15
        STA enemyLowerY
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
        STA enemyUpperFrame
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
        STA dogXMSB,X
        STA dogX,X
        STA dogCoarseX,X
        DEC platformEnemyCount
        STA dogY,X
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
        LDA dogFrame,X
        CLC
        ADC #$01
        CMP #$CC
        BCC AD_RightDone
        LDA #$C9
AD_RightDone 
        STA dogFrame,X
        JMP AD_Next

AD_AnimateLeft 
        LDA dogFrame,X
        CLC
        ADC #$01
        CMP #$CF
        BCC AD_LeftDone
        LDA #$CC
AD_LeftDone 
        STA dogFrame,X
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
        LDA dogX,X
        CLC 
        ADC #$04
        STA dogX,X
        LDA dogXMSB,X
        ADC #$00
        STA dogXMSB,X
        BEQ MD_RightNoMSB
        LDA dogX,X
        CMP #$50
        BCS MD_RemoveOffScreen
MD_RightNoMSB
        JSR DogJump
        JMP MD_Next

MD_MoveLeft 
        LDA dogX,X
        SEC
        SBC #$04
        STA dogX,X
        LDA dogXMSB,X
        SBC #$00
        STA dogXMSB,X
        BNE MD_LeftHasMSB
        LDA dogX,X
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
        STA dogX,X
        STA dogXMSB,X
        DEC platformEnemyCount
        STA dogY,X
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
        STA dogColor,X
        LDA #$E2
        STA dogY,X
        INC platformEnemyCount
        INC dogActive,X
        LDA staticEnemyType
        CMP #$04
        BNE SND_SpawnOnLeft
        LDA #$01
        STA dogXMSB,X
        LDA #$4E
        STA dogX,X
        LDA #$CD
        STA dogFrame,X
SND_Common 
        LDA #$01
        STA enemyAuxTimer,X
        STA dogCoarseX,X
        JSR PlayDogBarkSound
        RTS

SND_SpawnOnLeft 
        LDA #$00
        STA dogXMSB,X
        LDA #$10
        STA dogX,X
        LDA #$CA
        STA dogFrame,X
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
        STA dogFrame,X
        INC dogJumping,X
        LDY #$11
        LDA dogY,X
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
        STA dogY,X
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
CDH_Loop LDA enemyHit,X
        BNE CDH_DoDestroy
CDH_Next DEX 
        BPL CDH_Loop
        RTS

CDH_DoDestroy 
        STX temp
        JSR DestroyGyrocopter
        LDX temp
        JMP CDH_Next

UpdateGyroGrenades
        LDX #$02
UHG_Loop JSR CheckBulletExploded
        DEX
        BPL UHG_Loop
        RTS 

UpdateGyroFlight
        LDY #$01
UHF_Loop 
        LDA gyroYPathDir,Y
        BNE UHF_YPathActive
        LDA gyrosAliveFlag
        BEQ UHF_DescendLow
        LDA gyroY,Y
        CMP #$58
        BCS UHF_SetActive
UHF_DescendLow 
        LDA gyroY,Y
        CMP #$90
        BCS UHF_SetActiveLow
        LDA gyroY,Y
        BEQ UHF_Next
        CLC
        ADC #$02
        STA gyroY,Y
UHF_Next 
        JSR UHF_HorizMoveLogic
        DEY
        BPL UHF_Loop
        RTS 

UHF_SetActive 
        LDA #$01
        STA gyroYPathDir,Y
        LDA #$58
        STA gyroBaseY,Y
        LDA #$00
        STA gyroYPathIndex,Y
        JMP UHF_Next

UHF_SetActiveLow 
        LDA #$01
        STA gyroYPathDir,Y
        STA gyrosAliveFlag
        LDA #$90
        STA gyroBaseY,Y
        LDA #$00
        STA gyroYPathIndex,Y
        JMP UHF_Next

UHF_YPathActive 
        LDX gyroYPathIndex,Y
        LDA gyroYPathTbl,X
        BMI UHF_GyroYPathEnd
        CLC 
        ADC gyroBaseY,Y
        STA gyroY,Y
        LDA gyroYPathDir,Y
        BMI UHF_GyroYPathReverse
        INX 
        TXA
        STA gyroYPathIndex,Y
        JMP UHF_Next

UHF_GyroYPathEnd
        STA gyroYPathDir,Y
UHF_GyroYPathReverse
        DEX
        BMI UHF_GyroYPathWrap
        TXA
        STA gyroYPathIndex,Y
        JMP UHF_Next

UHF_GyroYPathWrap
        LDA #$01
        STA gyroYPathDir,Y
        JMP UHF_Next

UHF_HorizMoveLogic 
        LDA gyroBaseY,Y
        CMP #$58
        BEQ UHF_HighGyroHorizMove
        LDA gyroCoarseX,Y
        ADC #$14
        CMP playerCoarseX
        BCC UHF_CheckHorizTurn
        SEC
        SBC #$28
        CMP playerCoarseX
        BCS UHF_CheckHorizTurn
UHF_GyroXMove
        LDA gyroXSpeed,Y
        CLC
        ADC gyroCoarseX,Y
        STA gyroCoarseX,Y
        RTS

UHF_CheckHorizTurn 
        LDA gyroCoarseX,Y
        CMP playerCoarseX
        BCC UHF_CheckTurnRight
        LDA gyroXSpeed,Y
        BMI UHF_NoHorizTurn
        LDA #$FF
        STA gyroXSpeed,Y
        JSR SetGyroMidFrame
UHF_NoHorizTurn 
        JMP UHF_GyroXMove

UHF_CheckTurnRight
        LDA gyroXSpeed,Y
        BPL UHF_NoHorizTurn
        LDA #$01
        STA gyroXSpeed,Y
        JSR SetGyroMidFrame
        JMP UHF_GyroXMove

UHF_HighGyroHorizMove
        LDA gyroCoarseX,Y
        CMP #$14
        BCC UHF_HighGyroLeftEdge
        CMP #$8C
        BCS UHF_HighGyroRightEdge
        JMP UHF_GyroXMove

UHF_HighGyroLeftEdge 
        LDA gyroXSpeed,Y
        BPL UHF_NoHorizTurn
        LDA #$01
        STA gyroXSpeed,Y
        JSR SetGyroMidFrame
        JMP UHF_GyroXMove

UHF_HighGyroRightEdge
        LDA gyroXSpeed,Y
        BMI UHF_NoHorizTurn
        LDA #$FF
        STA gyroXSpeed,Y
        JSR SetGyroMidFrame
        JMP UHF_GyroXMove

gyroYPathTbl 
        .BYTE $00,$00,$01,$02,$03,$04,$06,$08,$0A,$0C,$0E,$10,$12,$14,$16,$18
        .BYTE $1A,$1C,$1E,$20,$22,$23,$24,$25,$26,$27,$28,$28,$FF

SetGyroMidFrame 
        LDA gyroEnemyIndexTbl,Y
        TAX
        STY temp2
        LDY #$00
SHMF_Loop 
        LDA gyroUpperMidFrameTbl,Y
        STA enemyUpperFrame,X
        LDA gyroLowerMidFrameTbl,Y
        STA enemyLowerFrame,X
        INX
        INY
        CPY #$03
        BCC SHMF_Loop
        LDY temp2
        LDA #$06
        STA gyroAnimDelay,Y
        RTS

ThrowGyroGrenade 
        INX
        LDA gyroXSpeed,Y
        BPL THG_HasDir
        LDA #$04
        .BYTE $2C
THG_HasDir 
        LDA #$08
        STA enemyHorizMove,X
        LDA #$08
        STA enemyType,X
        LDA gyroY,Y
THG_GyroNotActive 
        BEQ THG_Done
        STX temp
        STY temp2
        JSR DEF_DoFire
        LDY temp2
        LDX temp
        LDA #$09
        STA enemyType,X
        DEX
THG_Done 
        RTS

AH_MovingRight 
        LDA #$00
        BEQ AH_GetFrame
AH_Done RTS 

DestroyGyrocopter 
        CPX #$03
        BCC DH_NoIndexClamp
        LDX #$03
        .BYTE $2C
DH_NoIndexClamp 
        LDX #$00
        TXA
        CLC 
        ADC #$03
        STA tempStore
DH_PieceLoop
        LDA #$00
        STA enemyActive,X
        STA enemyHit,X
        STA enemyDying,X
        STA enemyUpperY,X
        STA enemyLowerY,X
        INX
        CPX tempStore
        BNE DH_PieceLoop
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
AH_Loop LDA gyroAnimDelay,Y
        BEQ AH_NoDelay
        SEC
        SBC #$01
        STA gyroAnimDelay,Y
        CPY #$01
        BEQ AH_Done
        LDX #$03
        JMP AH_MoveToNext

AH_NoDelay 
        LDA gyroAnimFrame,Y
        CLC 
        ADC #$01
        AND #$03
        STA gyroAnimFrame,Y
        STA temp2
        LDA gyroXSpeed,Y
        BPL AH_MovingRight
        LDA #$18
        CLC
AH_GetFrame
        LDY temp2
        ADC gyroFrameBaseTbl,Y
        TAY
AH_SpriteLoop
        LDA gyroUpperFrameTbl,Y
        STA enemyUpperFrame,X
        LDA gyroLowerFrameTbl,Y
        STA enemyLowerFrame,X
        INY
        INX
gyroSprEndCmp   =*+$01
        CPX #$03
        BNE AH_SpriteLoop
        CPX #$06
        BEQ AH_Done2
AH_MoveToNext
        LDA #$06
        STA gyroSprEndCmp
        LDY #$01
        JMP AH_Loop

AH_Done2 RTS

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
MHXC_Loop 
        LDA enemyUpperX,X
        ASL
        STA enemyUpperX,X
        LDA #$00
        ADC #$00
        STA enemyUpperXMSB,X
        DEX
        BPL MHXC_Loop
        RTS

UpdateGyroSprites 
        LDY numAliveGyros
        BEQ UHS_NoGyrosActive
        LDY #$02
        DEY
UHS_Loop
        LDA gyroY,Y
        BEQ UHS_Next
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
        BCC UHS_NoGrenade
        JSR ThrowGyroGrenade
UHS_NoGrenade 
        PLA
        STA tempStore
        LDA gyroCoarseX,Y
        SEC
        SBC #$0C
UHS_SpriteLoop 
        STA enemyUpperX,X
        STA enemyLowerX,X
        CLC
        ADC #$0C
        INX
        CPX tempStore
        BNE UHS_SpriteLoop
        TXA
        SEC
        SBC #$03
        TAX
UHS_SpriteYLoop 
        LDA enemyUpperX,X
        CMP #$AC
        BCS UHS_ClipRight
        LDA gyroY,Y
        STA enemyUpperY,X
        CLC
        ADC #$15
        STA enemyLowerY,X
        JMP UHS_YDone

UHS_ClipRight 
        LDA #$00
        STA enemyUpperY,X
        STA enemyLowerY,X
UHS_YDone 
        INX
        CPX tempStore
        BNE UHS_SpriteYLoop
UHS_Next
        DEY
        BPL UHS_Loop
UHS_NoGyrosActive
        RTS

SpawnGyrocopters 
        LDA endFightEnemiesLeft
        BEQ SH_NoMoreGyros
        CMP #$03
        BNE SH_InitDone
        JSR CheckEnemiesOnScreen
        BPL SH_Wait
        LDA #$00
        LDX #$05
SH_InitLoop 
        STA enemyDying,X
        STA enemyHit,X
        DEX
        BPL SH_InitLoop
        STA gyroYPathDir
        LDY #$2F
        JSR PlaySong
        INC stageEndReached
SH_InitDone 
        LDA numAliveGyros
        BEQ SH_FindFreeEnemy
        CMP #$02
        BEQ SH_Wait
        DEC gyroSpawnTimer
        BNE SH_Wait
SH_FindFreeEnemy 
        LDX #$00
SH_FindFreeLoop 
        LDA enemyActive,X
        BEQ SH_FreeFound
        INX
        CPX #$06
        BCC SH_FindFreeLoop
        RTS

SH_FreeFound 
        TXA
        LSR
        TAY
        JSR SpawnGyrocopter
SH_Wait RTS

SH_NoMoreGyros 
        LDA numAliveGyros
        BNE SH_Wait
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
SH_SpriteLoop LDA #$09
        STA enemyActive,X
        STA enemyType,X
        LDA #$00
        STA enemyDying,X
        LDA #$01
        STA enemyUpperColor,X
        LDA #$06
        STA enemyLowerColor,X
        INX
        CPX tempStore
        BNE SH_SpriteLoop
        INC numAliveGyros
        DEC endFightEnemiesLeft
        LDA #$20
        STA gyroSpawnTimer
        LDA #$00
        STA gyroYPathDir,Y
        RTS

gyroXSpeedInitTbl .BYTE $01,$FF

gyroXInitTbl .BYTE $01,$B4

gyroYInitTbl .BYTE $46,$46

S1EF_WaitBegin 
        JMP Main_NoStageEndFight

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