RunEnemyCustomCode
        LDY enemyType,X
        TYA
        ASL
        TAY
        LDA enemyJumpTblLo,Y
        STA enemyJumpLo
        LDA enemyJumpTblHi,Y
        STA enemyJumpHi
enemyJumpLo   =*+$01
enemyJumpHi   =*+$02
RECC_Jump JMP $FFFF

enemyJumpTblHi   =*+$01
enemyJumpTblLo
        .WORD EnemyCodeType0,EnemyCodeType1,EnemyCodeType2,EnemyCodeType3,EnemyCodeType4
        .WORD EnemyCodeType5,EnemyCodeType6,EnemyCodeType7,EnemyCodeType8,EnemyCodeType9

EnemyCodeType0
        RTS

EnemyCodeType1
        RTS

EnemyCodeType2
        JMP EnemyCodeType6

EnemyCodeType3
        RTS

EnemyCodeType9 JSR UpdateParachute
        LDA parachuteActiveFlag
        CMP #$02
        BEQ EnemyCodeType8
        RTS

EnemyCodeType8
        JMP EnemyCodeType6

EnemyCodeType6 LDA enemyDying,X
        BEQ ECT6_NotDying
        RTS

ECT6_NotDying
        STX temp
        LDA enemyFireFlag,X
        BNE DoEnemyFire
        LDA enemyType,X
        CMP #$09
        BEQ ECT6_SkipChecks
        LDA enemyPlatformHeight,X
        CMP playerPlatformHeight
        BNE ECT6_NoFire
        LDA enemyClimbing,X
        ORA enemyFalling,X
        ORA enemyTimerActive,X
        ORA enemyJumping,X
        BNE ECT6_NoFire
        LDA charTypeBelowEnemy,X
        AND #$0C
        BEQ ECT6_NoFire
ECT6_SkipChecks 
        JSR TimerCheck
        BCC ECT6_NoFire
        LDA #$01
        STA enemyFireFlag,X
        JMP DoEnemyFire

ECT6_NoFire 
        RTS

TimerCheck LDA gameTimer,X
        CMP #$50
        BEQ TC_AtMax
difficultyMod1   =*+$01
        CMP #$50
        BEQ TC_AtMax
difficultyMod2   =*+$01
        CMP #$50
        BEQ TC_AtMax
        CLC 
TC_AtMax
        RTS

DoEnemyFire 
        CMP #$01
        BNE DEF_CheckDelayFinish
        LDY enemyType,X
        CPY #$09
        BEQ DEF_NoTurn
        STA enemyTimerActive,X
        LDA #$3C
        STA enemyTimer,X
        LDA playerCoarseX
        CMP enemyCoarseX,X
        LDA #$00
        ROL 
        TAY 
        LDA enemyDirTbl,Y
        STA enemyHorizMove,X
        STA enemyControls,X
        TYA
        PHA
        LDY enemyType,X
        PLA 
        CLC
        ADC enemyFireFrameOfsTbl,Y
        TAY
        LDA enemyFireUpperFrTbl,Y
        STA enemyUpperFrame,X
        LDA enemyFireLowerFrTbl,Y
        STA enemyLowerFrame,X
DEF_NoTurn 
        INC enemyFireFlag,X
DEF_Wait 
        LDX temp
        LDA enemyTimer,X
        BEQ DEF_CheckResetFire
        RTS

DEF_CheckResetFire 
        LDA enemyType,X
        CMP #$09
        BNE DEF_ResetFireFlag
        RTS

DEF_ResetFireFlag 
        LDA #$00
        STA enemyFireFlag,X
        RTS

DEF_CheckDelayFinish 
        CMP #$05
        BCS DEF_DoFire
        INC enemyFireFlag,X
        JMP DEF_Wait

DEF_DoFire 
        LDX #$05
        JSR FFB_Loop
        BCS DEF_Wait
        CPX #$03
        BCC DEF_Wait
        LDY temp
        LDA enemyType,Y
        TAY
        LDA enemyBulletTypeTbl,Y
        TAY
        STA bulletType,X
        JSR InitEnemyBullet
        LDX temp
        LDA enemyType,X
        CMP #$02
        BNE DEF_NotRifleman
        JSR PlayEnemyFireSound
        JMP DEF_NotBazookaMan

DEF_NotRifleman 
        CMP #$06
        BNE DEF_NotBazookaMan
        JSR PlayBazookaSound
DEF_NotBazookaMan 
        LDX temp
        LDA #$00
        STA enemyFireFlag,X
        LDA enemyType,X
        CMP #$09
        BEQ DEF_SetFireDelay
        LDA #$0F
        STA enemyTimer,X
        LDY enemyType,X
        CPY #$08
        BNE DEF_NotGrenadier
        LDA numAliveGyros
        BNE DEF_NotGrenadier
        LDA enemyHorizMove,X
        CMP #$08
        LDA #$00
        ROL 
        TAY
        LDA throwAnimTbl,Y
        STA enemyUpperFrame,X
DEF_NotGrenadier 
        RTS

DEF_SetFireDelay 
        LDA #$48
        STA gameTimer,X
        RTS 

EnemyCodeType4
        LDA enemyDying,X
        BEQ ECT4_NotDying
        RTS

ECT4_NotDying 
        STX temp
        LDA enemyAuxTimer,X
        BNE ECT4_PrepareFire
        LDA playerCoarseX
        CLC
        ADC #$28
        CMP enemyCoarseX,X
        BCC ECT4_NoFire
        SEC
        SBC #$50
        BCC ECT4_NoFire
        CMP enemyCoarseX,X
        BCS ECT4_NoFire
        JSR TimerCheck
        BCC ECT4_PrepareFire
        LDA #$01
        STA enemyAuxTimer,X
        JMP ECT4_PrepareFire

ECT4_NoFire 
        RTS

ECT4_PrepareFire 
        LDA playerCoarseX
        CMP enemyCoarseX,X
        LDA #$00
        ROL
        TAY
        LDA mortarUpperFrame1Tbl,Y
        STA enemyUpperFrame,X
        LDA enemyAuxTimer,X
        BEQ ECT4_UpperFrameDone
        LDA mortarUpperFrame2Tbl,Y
        STA enemyUpperFrame,X
ECT4_UpperFrameDone 
        LDA mortarLowerFrameTbl,Y
        STA enemyLowerFrame,X
        LDA enemyDirTbl,Y
        STA enemyHorizMove,X
        LDA enemyAuxTimer,X
        BNE ECT4_WaitFireDelay
        RTS

ECT4_WaitFireDelay
        CMP #$10
        BCS ECT4_FiringNow
        INC enemyAuxTimer,X
ECT4_FireFail 
        LDX temp
        RTS

ECT4_FiringNow 
        STX temp
        LDX #$05
        JSR FFB_Loop
        BCS ECT4_FireFail
        CPX #$03
        BCC ECT4_FireFail
        LDY #$02
InitEnemyBullet 
        STX bulletIndex
        LDX temp
        LDA enemyHorizMove,X
        PHA 
        CPY #$05
        BNE IEB_NoOppositeDir
        EOR #$0C
IEB_NoOppositeDir 
        AND #$04
        BEQ IEB_FiringRight
        LDA #$F0
        CLC
IEB_FiringRight 
        ADC #$0C
        STA bulletOffset
        PLA
        LDX bulletIndex
        STA bulletXDir,X
        LDA extraWpnColorTbl,Y
        STA bulletColor,X
        LDX temp
        LDA enemyUpperY,X
        CLC 
        ADC #$10
        LDX bulletIndex
        STA bulletY,X
        LDX temp
        LDA enemyCoarseX,X
        CLC 
        ADC bulletOffset
        LDX bulletIndex
        STA bulletCoarseX,X
        ASL
        STA bulletX,X
        LDA #$00
        ROL 
        STA bulletXMSB,X
        LDA bulletXDir,X
        CMP #$04
        BEQ IEB_InitFrameLeft
        LDA extraWpnRightFrTbl,Y
        STA bulletFrame,X
        JMP InitBulletSpeed

IEB_InitFrameLeft 
        LDA extraWpnLeftFrameTbl,Y
        STA bulletFrame,X
InitBulletSpeed 
        LDA bulletXSpeedTbl,Y
        STA bulletXSpeed,X
        LDA #$01
        STA bulletActive,X
        CPY #$02
        BEQ InitGrenadeArc
        CPY #$05
        BEQ InitGrenadeArc
        RTS 

InitGrenadeArc
        LDY #$19
        TYA
        STA bulletJumpArcIndex,X
        LDA bulletY,X
        SEC 
        SBC jumpArcTbl,Y
        STA bulletYBase,X
        LDA #$01
        STA bulletYDir,X
        LDA #$02
        STA bulletType,X
        LDX temp
        LDA #$00
        STA enemyAuxTimer,X
        TXA 
        PHA 
        TYA 
        PHA 
        JSR PlayBazookaSound
        PLA 
        TAY 
        PLA 
        TAX
        RTS

bulletXSpeedTbl 
        .BYTE $04,$04,$01,$06,$02,$02,$01

mortarUpperFrame1Tbl 
        .BYTE $14,$1D

mortarLowerFrameTbl 
        .BYTE $6E,$9B

mortarUpperFrame2Tbl 
        .BYTE $2A,$79

enemyDirTbl 
        .BYTE $04,$08

enemyBulletTypeTbl
        .BYTE $00,$00,$00,$00,$00,$00,$01,$00,$05,$06

enemyFireFrameOfsTbl 
        .BYTE $00,$00,$02,$00,$00,$00,$00,$00,$04,$06

enemyFireUpperFrTbl
        .BYTE $B8,$B9,$94,$95,$41,$3F

enemyFireLowerFrTbl
        .BYTE $BA,$BB,$96,$97,$31,$35

throwAnimTbl 
        .BYTE $3F,$41

EnemyCodeType7 
        LDA enemyDying,X
        BNE ECT7_DeadOrIdle
        INC enemyCrawlTimer,X
        LDA enemyCrawlTimer,X
        AND #$01
        BNE ECT7_Done
        LDA enemyCrawlTimer,X
        AND #$10
        BNE ECT7_DeadOrIdle
        LDA enemyUpperX,X
        SEC
        SBC #$01
        STA enemyUpperX,X
        BCS ECT7_NoUpperMSB
        LDA #$00
        STA enemyUpperXMSB,X
ECT7_NoUpperMSB 
        LDA enemyLowerX,X
        SEC
        SBC #$01
        STA enemyLowerX,X
        BCS ECT7_NoLowerMSB
        LDA #$00
        STA enemyLowerXMSB,X
ECT7_NoLowerMSB 
        LDA #$5F
        STA enemyUpperFrame,X
        LDA #$5E
        STA enemyLowerFrame,X
ECT7_Done 
        RTS

ECT7_DeadOrIdle 
        LDA #$61
        STA enemyUpperFrame,X
        LDA #$60
        STA enemyLowerFrame,X
        RTS 

UpdateParachute
        LDA parachuteActiveFlag
        BNE UP_InitDone
        LDA topPlatformCount
        CLC 
        ADC #$02
        STA topPlatformCount
        LDA midPlatformCount
        CLC 
        ADC #$02
        STA midPlatformCount
        LDA numEnemies
        CLC
        ADC #$03
        STA numEnemies
        INC parachuteActiveFlag
        LDA #$00
        LDY #$04
UP_PreventSpawnLoop 
        STA spawnEnemyFlag,Y
        DEY 
        BPL UP_PreventSpawnLoop
        JMP MakeEnemiesRunAway

UP_InitDone 
        LDA parachuteActiveFlag
        CMP #$02
        BEQ UP_ExtrasCreated
        LDA numEnemies
        CMP #$06
        BCS UP_FailCreateExtras
        INC parachuteActiveFlag
        LDA #$46
        STA gameTimer,X
        JSR SpawnParachuteExtras
        RTS

UP_FailCreateExtras
        LDA #$66
        STA enemyUpperX,X
        STA enemyLowerX,X
        RTS

UP_ExtrasCreated 
        LDX paraEnemyIndices
        LDA parachuteXSpeed
        BMI UP_NegSpeed
        LDA enemyCoarseX,X
        LDY #$04
UP_PosSpdTargetLoop
        CMP paraTargetXTbl,Y
        BCS UP_PosSpdTargetOK
        DEY
        BNE UP_PosSpdTargetLoop
UP_PosSpdTargetOK 
        LDA paraNewSpeedTbl,Y
        STA parachuteXSpeed
UP_NegSpeed 
        LDY #$03
        LDA parachuteXSpeed
        BPL UP_PosSpd
        LDA enemyCoarseX,X
        CMP #$5A
UP_NegSpdNoTarget 
        BCC UP_LoopParts
        LDA #$01
        STA parachuteYGlideFlag
        LDA #$FF
        STA parachuteXSpeed
        BMI UP_LoopParts
UP_PosSpd 
        LDA #$00
        STA parachuteYGlideFlag
UP_LoopParts 
        LDX paraEnemyIndices,Y
        LDA parachuteYGlideFlag
        BNE UP_MoveY
        LDA gameTimer
        AND #$03
        BNE UP_SkipYMove
UP_MoveY 
        INC enemyUpperY,X
        INC enemyLowerY,X
UP_SkipYMove 
        LDA enemyUpperY,X
        CMP #$CE
        BCS CleanupParachute
        CPY #$02
        BNE UP_AllowLowerSprite
        LDA #$00
        STA enemyLowerY,X
UP_AllowLowerSprite 
        LDA enemyUpperX,X
        SEC 
        SBC parachuteXSpeed
        STA enemyUpperX,X
        LDA parachuteXSpeed
        BPL UP_UpperMSBPosSpd
        LDA enemyUpperXMSB,X
        SBC #$FF
        STA enemyUpperXMSB,X
        JMP UP_UpperMSBDone

UP_UpperMSBPosSpd 
        LDA enemyUpperXMSB,X
        SBC #$00
        STA enemyUpperXMSB,X
UP_UpperMSBDone 
        LDA enemyLowerX,X
        SEC 
        SBC parachuteXSpeed
        STA enemyLowerX,X
        LDA parachuteXSpeed
        BPL UP_LowerMSBPosSpd
        LDA enemyLowerXMSB,X
        SBC #$FF
        STA enemyLowerXMSB,X
        JMP UP_LowerMSBDone

UP_LowerMSBPosSpd 
        LDA enemyLowerXMSB,X
        SBC #$00
        STA enemyLowerXMSB,X
UP_LowerMSBDone 
        DEY
        BPL UP_LoopParts
        RTS

CleanupParachute 
        LDA midPlatformCount
        SEC 
        SBC #$02
        STA midPlatformCount
        LDA topPlatformCount
        SEC
        SBC #$02
        STA topPlatformCount
        LDA numEnemies
        SEC
        SBC #$03
        STA numEnemies
        LDY #$03
CP_Loop LDX paraEnemyIndices,Y
        LDA #$00
        STA enemyActive,X
        LDA #$00
        STA enemyTimerActive,X
        STA enemyType,X
        STA enemyUpperY,X
        STA enemyLowerY,X
        DEY
        BNE CP_Loop
        LDX paraEnemyIndices
        LDA #$05
        STA enemyType,X
        LDA #$00
        STA enemyTimerActive,X
        LDA #$00
        STA parachuteActiveFlag
        RTS

SpawnParachuteExtras 
        STX paraEnemyIndices
        LDY #$00
        JSR InitParachuteSprites
        JSR FindFreeEnemySlot
        LDY #$01
        STX paraEnemyIndex1
        JSR InitParachuteSprites
        JSR FindFreeEnemySlot
        LDY #$02
        STX paraEnemyIndex2
        JSR InitParachuteSprites
        JSR FindFreeEnemySlot
        LDY #$03
        STX paraEnemyIndex3
        JSR InitParachuteSprites
        LDA #$04
        STA parachuteXSpeed
        RTS 

InitParachuteSprites 
        LDA paraUpperYTbl,Y
        STA enemyUpperY,X
        LDA paraLowerYTbl,Y
        STA enemyLowerY,X
        LDA paraUpperXTbl,Y
        STA enemyUpperX,X
        LDA paraLowerXTbl,Y
        STA enemyLowerX,X
        LDA #$01
        STA enemyUpperXMSB,X
        STA enemyLowerXMSB,X
        LDA paraUpperFrameTbl,Y
        STA enemyUpperFrame,X
        LDA paraLowerFrameTbl,Y
        STA enemyLowerFrame,X
        LDA paraUpperColorTbl,Y
        STA enemyUpperColor,X
        LDA paraLowerColorTbl,Y
        STA enemyLowerColor,X
        LDA #$01
        STA enemyTimerActive,X
        STA enemyActive,X
        LDA #$00
        STA enemyTimer,X
        LDA #$09
        STA enemyType,X
        RTS

paraUpperYTbl 
        .BYTE $67,$5F,$4A,$4A

paraLowerYTbl 
        .BYTE $7C,$4A,$4A,$5F

paraUpperXTbl 
        .BYTE $63,$5B,$67,$7F

paraLowerXTbl
        .BYTE $63,$4F,$67,$73

paraUpperFrameTbl 
        .BYTE $84,$BF,$BD,$BE

paraLowerFrameTbl 
        .BYTE $86,$BC,$BD,$C0

paraUpperColorTbl 
        .BYTE $0D,$09,$08,$09

paraLowerColorTbl 
        .BYTE $0D,$09,$08,$09

paraTargetXTbl 
        .BYTE $14,$3C,$50,$64,$80

paraNewSpeedTbl 
        .BYTE $FE,$01,$02,$03,$05

paraEnemyIndices 
        .BYTE $00
paraEnemyIndex1 
        .BYTE $00
paraEnemyIndex2
         .BYTE $00
paraEnemyIndex3 
        .BYTE $00

CheckParachuteEnemy 
        LDX #$05
CPE_Loop 
        LDA enemyType,X
        CMP #$09
        BEQ CPE_Found
        DEX
        BPL CPE_Loop
        RTS

CPE_Found 
        JMP RunEnemyCustomCode

MakeEnemiesRunAway 
        LDX #$05
MERA_Loop 
        LDA enemyFalling,X
        ORA enemyClimbing,X
        ORA enemyJumping,X
        BNE MERA_Skip
        LDA #$04
        STA enemyControls,X
MERA_Skip 
        DEX
        BPL MERA_Loop
        RTS

EnemyCodeType5 
        LDA enemyJumping,X
        ORA enemyFalling,X
        BNE ECT5_NoKarateJump
        LDA stage
        CMP #$01
        BNE ECT5_IsNotDogHandler
        LDA stageEndReached
        BEQ ECT5_IsNotDogHandler
        JMP ECT5_NoKarateJump

ECT5_IsNotDogHandler 
        LDA enemyCoarseX,X
        CMP playerCoarseX
        BCC ECT5_NoKarateJump
        SEC
        SBC playerCoarseX
        CMP #$1E
        BCS ECT5_NoKarateJump
        LDA enemyControls,X
        CMP #$08
        BEQ ECT5_NoKarateJump
        AND #$01
        BNE ECT5_NoKarateJump
        LDY enemyPlatformHeight,X
        BEQ ECT5_KarateJumpOK
        CPY playerPlatformHeight
        BNE ECT5_NoKarateJump
        DEY
        BNE ECT5_EnemyCheckBelow
ECT5_EnemyCheckAt
        LDA platformEnemyCount,Y
        CMP #$03
        BCS ECT5_NoKarateJump
        JSR UEP_InitJump
        RTS

ECT5_EnemyCheckBelow 
        LDA platformEnemyCount-1,Y
        CMP #$03
        BCS ECT5_NoKarateJump
        BCC ECT5_EnemyCheckAt
ECT5_NoKarateJump 
        RTS

ECT5_KarateJumpOK 
        CPY playerPlatformHeight
        BNE ECT5_NoKarateJump
        LDA enemyControls,X
        ORA #$01
        STA enemyControls,X
        LDA #$00
        STA enemyFalling,X
        RTS 

CheckEnemiesRunAway
        LDX #$05
CERA_Loop 
        LDA enemyActive,X
        BNE CERA_EnemyActive
CERA_Next 
        DEX
        BPL CERA_Loop
        RTS

CERA_EnemyActive 
        LDA enemyType,X
        CMP #$09
        BEQ CERA_Next
        LDA enemyUpperX,X
        CMP #$50
        BCC CERA_CheckLeft
        LDA enemyUpperXMSB,X
        BNE RemoveEnemy
CERA_NoRemove 
        DEX
        BPL CERA_Loop
        RTS

CERA_CheckLeft
        CMP #$12
        BCS CERA_NoRemove
        LDA enemyUpperXMSB,X
        BNE CERA_NoRemove
        JSR RemoveEnemy
        JMP CERA_NoRemove

RemoveEnemy 
        LDA #$00
        STA enemyUpperY,X
        STA enemyLowerY,X
        STA enemyClimbing,X
        STA enemyActive,X
        STA enemyFalling,X
        STA enemyTimerActive,X
        STA enemyJumping,X
        STA enemyHit,X
        STA enemyDying,X
        STA enemyClimbingCopy,X
        STA enemyUpperX,X
        STA enemyUpperXMSB,X
        STA enemyCoarseX,X
        STA enemyAuxTimer,X
        LDY enemyLongLadderClimb,X
        BEQ RE_NoLongLadderClimb
        DEY 
        LDA platformEnemyCount,Y
        SEC 
        SBC #$01
        STA platformEnemyCount,Y
        LDA #$00
        STA enemyLongLadderClimb,X
RE_NoLongLadderClimb 
        LDA #$15
        STA enemyYAdjust,X
        LDY enemyPlatformHeight,X
        LDA platformEnemyCount,Y
        SEC
        SBC #$01
        STA platformEnemyCount,Y
        DEC numEnemies
        LDA enemyJumpPlatformHeight,X
        BEQ RE_Done
        CMP #$02
        BNE RE_NotJumping
        DEC topPlatformCount
RE_NotJumping
        DEC platformEnemyCount
        DEC midPlatformCount
        LDA platformEnemyCount,Y
        CLC
        ADC #$01
        STA platformEnemyCount,Y
        LDA #$00
        STA enemyJumpPlatformHeight,X
RE_Done RTS

UpdateEnemyClimb
        LDA enemyControls,X
        TAY
        AND #$03
        BNE UEC_IsClimbing
        RTS

UEC_IsClimbing
        AND charTypeAtEnemy,X
        AND #$01
        BEQ UEC_CheckClimbDown
UEC_ClimbUp 
        DEC enemyUpperY,X
        DEC enemyLowerY,X
        DEC enemyUpperY,X
        DEC enemyLowerY,X
        LDA #$01
        STA enemyClimbingCopy,X
        RTS 

UEC_CheckClimbDown 
        LDA charTypeAtEnemy,X
        AND #$01
        BNE UEC_ClimbDown
        TYA
        AND #$01
        BEQ UEC_ClimbDown
        LDA enemyYAdjust,X
        CMP #$06
        BEQ UEC_SetClimbing
        LDA charAtEnemy,X
        CMP #$C8
        BCC UEC_TerminateClimb
        LDA #$06
        STA enemyYAdjust,X
        JMP UEC_ClimbUp

UEC_ClimbDown 
        TYA
        AND charTypeBelowEnemy,X
        AND #$02
        BEQ UEC_TerminateClimb
        INC enemyUpperY,X
        INC enemyLowerY,X
        INC enemyUpperY,X
        INC enemyLowerY,X
UEC_SetClimbing 
        LDA #$15
        STA enemyYAdjust,X
        LDA #$01
        STA enemyClimbingCopy,X
        RTS 

UEC_TerminateClimb 
        LDA #$15
        STA enemyYAdjust,X
        LDA enemyCoarseX,X
        CMP playerCoarseX
        BCC UEC_PlayerOnRight
        LDA #$04
UEC_SetDirAfterClimb 
        STA enemyControls,X
        LDA #$00
        STA enemyClimbing,X
        LDA enemyLongLadderClimb,X
        BEQ UEC_NoLongLadder
        JSR UEC_CheckPlatformY
        CPY #$01
        BEQ UEC_IsMidPlatform
        DEC midPlatformCount
        LDY enemyLongLadderClimb,X
        DEY
        TYA 
        STA enemyPlatformHeight,X
        JMP UEC_ResetLongLadder

UEC_IsMidPlatform 
        LDY enemyLongLadderClimb,X
        DEY
        LDA platformEnemyCount,Y
        SEC
        SBC #$01
        STA platformEnemyCount,Y
UEC_ResetLongLadder 
        LDA #$00
        STA enemyLongLadderClimb,X
UEC_NoLongLadder 
        RTS

UEC_PlayerOnRight
        LDA #$08
        BNE UEC_SetDirAfterClimb
UEC_CheckPlatformY 
        LDY #$02
        LDA enemyUpperY,X
UEC_PlatformYLoop 
        CMP platformYTbl,Y
        BEQ UEC_PlatformYFound
        DEY
        BPL UEC_PlatformYLoop
UEC_PlatformYFound 
        RTS