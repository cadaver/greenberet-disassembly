        ; Special per-enemy type code using a jump table. Enemy firing and other special attacks are also handled here,
        ; checking difficulty timers that make the attacks more frequent the longer the player proceeds and stays alive.
        ; The parachute soldier creates extra sprites that reuse the enemy upper/lower sprites, but cannot be hit.

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

        ; Unarmed

EnemyCodeType0
        RTS

        ; Commandant

EnemyCodeType1
        RTS

        ; Rifleman who shoots

EnemyCodeType2
        JMP EnemyCodeType6

        ; Prison guard (does not shoot)

EnemyCodeType3
        RTS

        ; Parachute

EnemyCodeType9 JSR UpdateParachute
        LDA parachuteActiveFlag
        CMP #$02
        BEQ EnemyCodeType8
        RTS

        ; Grenadier

EnemyCodeType8
        JMP EnemyCodeType6

        ; Bazooka

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
        STA spriteFrame+SPR_ENEMYUPPER,X
        LDA enemyFireLowerFrTbl,Y
        STA spriteFrame+SPR_ENEMYLOWER,X
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
        CMP #ENEMY_AIM_TIME
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
        STA spriteFrame+SPR_ENEMYUPPER,X
DEF_NotGrenadier
        RTS

DEF_SetFireDelay
        LDA #$48
        STA gameTimer,X
        RTS

        ; Mortar

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
        STA spriteFrame+SPR_ENEMYUPPER,X
        LDA enemyAuxTimer,X
        BEQ ECT4_UpperFrameDone
        LDA mortarUpperFrame2Tbl,Y
        STA spriteFrame+SPR_ENEMYUPPER,X
ECT4_UpperFrameDone 
        LDA mortarLowerFrameTbl,Y
        STA spriteFrame+SPR_ENEMYLOWER,X
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
        STA spriteColor+SPR_BULLET,X
        LDX temp
        LDA spriteY+SPR_ENEMYUPPER,X
        CLC 
        ADC #$10
        LDX bulletIndex
        STA spriteY+SPR_BULLET,X
        LDX temp
        LDA enemyCoarseX,X
        CLC
        ADC bulletOffset
        LDX bulletIndex
        STA bulletCoarseX,X
        ASL
        STA spriteX+SPR_BULLET,X
        LDA #$00
        ROL 
        STA spriteXMSB+SPR_BULLET,X
        LDA bulletXDir,X
        CMP #$04
        BEQ IEB_InitFrameLeft
        LDA extraWpnRightFrTbl,Y
        STA spriteFrame+SPR_BULLET,X
        JMP InitBulletSpeed

IEB_InitFrameLeft 
        LDA extraWpnLeftFrameTbl,Y
        STA spriteFrame+SPR_BULLET,X
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
        LDA spriteY+SPR_BULLET,X
        SEC 
        SBC jumpArcTbl,Y
        STA bulletBaseY,X
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
        .BYTE BULLET_RIFLE,BULLET_RIFLE,BULLET_RIFLE,BULLET_RIFLE
        .BYTE BULLET_RIFLE,BULLET_RIFLE,BULLET_BAZOOKA,BULLET_RIFLE
        .BYTE BULLET_GRENADE,BULLET_PARACHUTE

enemyFireFrameOfsTbl
        .BYTE $00,$00,$02,$00,$00,$00,$00,$00,$04,$06

enemyFireUpperFrTbl
        .BYTE $B8,$B9,$94,$95,$41,$3F

enemyFireLowerFrTbl
        .BYTE $BA,$BB,$96,$97,$31,$35

throwAnimTbl 
        .BYTE $3F,$41

        ; Crawler

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
        LDA spriteX+SPR_ENEMYUPPER,X
        SEC
        SBC #$01
        STA spriteX+SPR_ENEMYUPPER,X
        BCS ECT7_NoUpperMSB
        LDA #$00
        STA spriteXMSB+SPR_ENEMYUPPER,X
ECT7_NoUpperMSB 
        LDA spriteX+SPR_ENEMYLOWER,X
        SEC
        SBC #$01
        STA spriteX+SPR_ENEMYLOWER,X
        BCS ECT7_NoLowerMSB
        LDA #$00
        STA spriteXMSB+SPR_ENEMYLOWER,X
ECT7_NoLowerMSB 
        LDA #$5F
        STA spriteFrame+SPR_ENEMYUPPER,X
        LDA #$5E
        STA spriteFrame+SPR_ENEMYLOWER,X
ECT7_Done 
        RTS

ECT7_DeadOrIdle 
        LDA #$61
        STA spriteFrame+SPR_ENEMYUPPER,X
        LDA #$60
        STA spriteFrame+SPR_ENEMYLOWER,X
        RTS 

UpdateParachute
        LDA parachuteActiveFlag
        BNE UP_InitDone
        LDA platformEnemyCount+PLATFORM_TOP
        CLC 
        ADC #$02
        STA platformEnemyCount+PLATFORM_TOP
        LDA platformEnemyCount+PLATFORM_MIDDLE
        CLC 
        ADC #$02
        STA platformEnemyCount+PLATFORM_MIDDLE
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
        STA spriteX+SPR_ENEMYUPPER,X
        STA spriteX+SPR_ENEMYLOWER,X
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
        INC spriteY+SPR_ENEMYUPPER,X
        INC spriteY+SPR_ENEMYLOWER,X
UP_SkipYMove 
        LDA spriteY+SPR_ENEMYUPPER,X
        CMP #$CE
        BCS CleanupParachute
        CPY #$02
        BNE UP_AllowLowerSprite
        LDA #$00
        STA spriteY+SPR_ENEMYLOWER,X
UP_AllowLowerSprite 
        LDA spriteX+SPR_ENEMYUPPER,X
        SEC 
        SBC parachuteXSpeed
        STA spriteX+SPR_ENEMYUPPER,X
        LDA parachuteXSpeed
        BPL UP_UpperMSBPosSpd
        LDA spriteXMSB+SPR_ENEMYUPPER,X
        SBC #$FF
        STA spriteXMSB+SPR_ENEMYUPPER,X
        JMP UP_UpperMSBDone

UP_UpperMSBPosSpd 
        LDA spriteXMSB+SPR_ENEMYUPPER,X
        SBC #$00
        STA spriteXMSB+SPR_ENEMYUPPER,X
UP_UpperMSBDone 
        LDA spriteX+SPR_ENEMYLOWER,X
        SEC 
        SBC parachuteXSpeed
        STA spriteX+SPR_ENEMYLOWER,X
        LDA parachuteXSpeed
        BPL UP_LowerMSBPosSpd
        LDA spriteXMSB+SPR_ENEMYLOWER,X
        SBC #$FF
        STA spriteXMSB+SPR_ENEMYLOWER,X
        JMP UP_LowerMSBDone

UP_LowerMSBPosSpd 
        LDA spriteXMSB+SPR_ENEMYLOWER,X
        SBC #$00
        STA spriteXMSB+SPR_ENEMYLOWER,X
UP_LowerMSBDone 
        DEY
        BPL UP_LoopParts
        RTS

CleanupParachute 
        LDA platformEnemyCount+PLATFORM_MIDDLE
        SEC
        SBC #$02
        STA platformEnemyCount+PLATFORM_MIDDLE
        LDA platformEnemyCount+PLATFORM_TOP
        SEC
        SBC #$02
        STA platformEnemyCount+PLATFORM_TOP
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
        STA spriteY+SPR_ENEMYUPPER,X
        STA spriteY+SPR_ENEMYLOWER,X
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
        STA spriteY+SPR_ENEMYUPPER,X
        LDA paraLowerYTbl,Y
        STA spriteY+SPR_ENEMYLOWER,X
        LDA paraUpperXTbl,Y
        STA spriteX+SPR_ENEMYUPPER,X
        LDA paraLowerXTbl,Y
        STA spriteX+SPR_ENEMYLOWER,X
        LDA #$01
        STA spriteXMSB+SPR_ENEMYUPPER,X
        STA spriteXMSB+SPR_ENEMYLOWER,X
        LDA paraUpperFrameTbl,Y
        STA spriteFrame+SPR_ENEMYUPPER,X
        LDA paraLowerFrameTbl,Y
        STA spriteFrame+SPR_ENEMYLOWER,X
        LDA paraUpperColorTbl,Y
        STA spriteColor+SPR_ENEMYUPPER,X
        LDA paraLowerColorTbl,Y
        STA spriteColor+SPR_ENEMYLOWER,X
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

        ; Martial artist / dog handler

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
