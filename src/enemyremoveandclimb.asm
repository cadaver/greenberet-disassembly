        ; Handle enemies running away from the screen and being removed from the game, and enemy climbing logic.

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
        CMP #ENEMY_PARACHUTE
        BEQ CERA_Next
        LDA spriteX+SPR_ENEMYUPPER,X
        CMP #$50
        BCC CERA_CheckLeft
        LDA spriteXMSB+SPR_ENEMYUPPER,X
        BNE RemoveEnemy
CERA_NoRemove
        DEX
        BPL CERA_Loop
        RTS

CERA_CheckLeft
        CMP #$12
        BCS CERA_NoRemove
        LDA spriteXMSB+SPR_ENEMYUPPER,X
        BNE CERA_NoRemove
        JSR RemoveEnemy
        JMP CERA_NoRemove

RemoveEnemy 
        LDA #$00
        STA spriteY+SPR_ENEMYUPPER,X
        STA spriteY+SPR_ENEMYLOWER,X
        STA enemyClimbing,X
        STA enemyActive,X
        STA enemyFalling,X
        STA enemyTimerActive,X
        STA enemyJumping,X
        STA enemyHit,X
        STA enemyDying,X
        STA enemyClimbingCopy,X
        STA spriteX+SPR_ENEMYUPPER,X
        STA spriteXMSB+SPR_ENEMYUPPER,X
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
        CMP #PLATFORM_TOP
        BNE RE_NotJumping
        DEC platformEnemyCount+PLATFORM_TOP
RE_NotJumping
        DEC platformEnemyCount
        DEC platformEnemyCount+PLATFORM_MIDDLE
        LDA platformEnemyCount,Y
        CLC
        ADC #$01
        STA platformEnemyCount,Y
        LDA #PLATFORM_GROUND
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
        DEC spriteY+SPR_ENEMYUPPER,X
        DEC spriteY+SPR_ENEMYLOWER,X
        DEC spriteY+SPR_ENEMYUPPER,X
        DEC spriteY+SPR_ENEMYLOWER,X
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
        INC spriteY+SPR_ENEMYUPPER,X
        INC spriteY+SPR_ENEMYLOWER,X
        INC spriteY+SPR_ENEMYUPPER,X
        INC spriteY+SPR_ENEMYLOWER,X
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
        DEC platformEnemyCount+PLATFORM_MIDDLE
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
        LDY #PLATFORM_TOP
        LDA spriteY+SPR_ENEMYUPPER,X
UEC_PlatformYLoop 
        CMP platformYTbl,Y
        BEQ UEC_PlatformYFound
        DEY
        BPL UEC_PlatformYLoop
UEC_PlatformYFound 
        RTS
