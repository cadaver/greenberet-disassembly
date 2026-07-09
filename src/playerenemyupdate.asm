        ; Movement, animation and world collision for both the player and enemies. For both the player and enemies,
        ; the current platform height (ground, middle, top) is calculated and enemy counts on each level are maintained.
        ; This is used both for AI logic and to avoid overloading the sprite multiplexer. Additionally, the sprite X
        ; coordinates are converted to half-resolution (8-bit only) coarse coordinates for faster hitbox collisions.
        ; Only the chars $c8-$ff are solid for platforms and ladders, the rest are ignored (backdrops). Both the
        ; player and enemy logic use the joystick direction bits (1 = up, 2 = down, 4 = left, 8 = right) for movement 
        ; logic and state bookkeeping.

FindPlayerPlatform
        LDX #$02
        LDA spriteY
FPP_Loop
        CMP platformYTbl,X
        BEQ FPP_Found
        DEX
        BPL FPP_Loop
        RTS

FPP_Found STX playerPlatformHeight
        RTS

UpdatePlatformCounts
        LDX #$05
UPC_Loop
        LDY #$02
        LDA enemyClimbing,X
        ORA enemyTimerActive,X
        ORA enemyJumping,X
        ORA enemyFalling,X
        BNE UPC_Next
        LDA spriteY+SPR_ENEMYUPPER,X
UPC_PlatformLoop
        CMP platformYTbl,Y
        BEQ UPC_AtPlatform
        DEY
        BPL UPC_PlatformLoop
UPC_Next
        DEX
        BPL UPC_Loop
        RTS

UPC_AtPlatform
        TYA
        LDA enemyPlatformHeight,X
        STA platformTemp
        TYA
        STA enemyPlatformHeight,X
        LDA platformTemp
        BEQ UPC_Next
        LDA enemyJumpPlatformHeight,X
        BEQ UPC_Next
        CMP #PLATFORM_TOP
        BNE UPC_DecBottomOrMid
        TYA
        CMP platformTemp
        BEQ UPC_DecMidAndBottom
        CPY #PLATFORM_GROUND
        BEQ UPC_DecMidAndTop
        DEC platformEnemyCount
        DEC platformEnemyCount+PLATFORM_TOP
        JMP UPC_ResetJump

UPC_DecMidAndBottom
        DEC platformEnemyCount
        DEC platformEnemyCount+PLATFORM_MIDDLE
        JMP UPC_ResetJump

UPC_DecMidAndTop
        DEC platformEnemyCount+PLATFORM_MIDDLE
        DEC platformEnemyCount+PLATFORM_TOP
UPC_ResetJump
        LDA #PLATFORM_GROUND
        STA enemyJumpPlatformHeight,X
        JMP UPC_Next

        JMP UPC_Next

UPC_DecBottomOrMid
        TYA
        CMP platformTemp
        BEQ UPC_DecBottom
        DEC platformEnemyCount+PLATFORM_MIDDLE
        JMP UPC_ResetJump

UPC_DecBottom
        DEC platformEnemyCount
        JMP UPC_ResetJump

ScrollEnemies 
        LDA lastScrollSpeed
        BNE SE_HasScrolling
        RTS

platformYTbl
        .BYTE $CD,$9D,$6D

SE_HasScrolling 
        LDX #$05
SE_Loop LDA enemyActive,X
        BNE SE_ScrollEnemy
        DEX
        BPL SE_Loop
        RTS

SE_ScrollEnemy 
        LDA spriteX+SPR_ENEMYUPPER,X
        SEC
        SBC lastScrollSpeed
        STA spriteX+SPR_ENEMYUPPER,X
        BCS SE_NoUpperMSBClear
        LDA #$00
        STA spriteXMSB+SPR_ENEMYUPPER,X
SE_NoUpperMSBClear 
        LDA spriteX+SPR_ENEMYLOWER,X
        SEC
        SBC lastScrollSpeed
        STA spriteX+SPR_ENEMYLOWER,X
        BCS SE_NoLowerMSBClear
        LDA #$00
        STA spriteXMSB+SPR_ENEMYLOWER,X
SE_NoLowerMSBClear 
        DEX
        BPL SE_Loop
        RTS

ScrollBullets 
        LDA lastScrollSpeed
        BNE SB_HasScrolling
        RTS

SB_HasScrolling 
        LDX #$05
SB_Loop LDA bulletActive,X
        BNE SB_ScrollBullet
        DEX
        BPL SB_Loop
        RTS

SB_ScrollBullet 
        LDA spriteX+SPR_BULLET,X
        SEC
        SBC lastScrollSpeed
        STA spriteX+SPR_BULLET,X
        BCS SB_NoMSBClear
        LDA #$00
        STA spriteXMSB+SPR_BULLET,X
SB_NoMSBClear
        DEX
        BPL SB_Loop
        RTS

UpdateEnemyPathing 
        LDX #$05
UEP_Loop 
        LDA enemyActive,X
        BNE UEP_EnemyActive
UEP_Next 
        DEX
        BPL UEP_Loop
        RTS

UEP_EnemyActive 
        LDA enemyTimerActive,X
        BNE UEP_Next
        LDA enemyType,X
        BNE UEP_TypeCheck
        JMP UEP_Next

UEP_TypeCheck 
        CMP #$05
        BNE UEP_TypeOK
        JMP UEP_Next

UEP_TypeOK 
        LDA enemyClimbing,X
        BNE UEP_Next
        LDA enemyJumpPlatformHeight,X
        BNE UEP_Next
        LDA charBelowEnemy,X
        CMP #$C8
        BCC UEP_NoClimbDown
        SBC #$C8
        TAY
        LDA charTypeTbl,Y
        AND #$02
        BEQ UEP_NoClimbDown
        LDA playerPlatformHeight
        CMP enemyPlatformHeight,X
        BCS UEP_NoClimbing
        LDA charTypeTbl,Y
        AND #$02
        BEQ UEP_NoClimbing
        STA tempStore
        LDY enemyPlatformHeight,X
        DEY
        LDA platformEnemyCount,Y
        CMP #$03
        BCS UEP_NoClimbing
        CPY #PLATFORM_MIDDLE
        BNE UEP_ClimbDownOK
        LDA stage
        CMP #$02
        BNE UEP_ClimbDownOK
        LDA platformEnemyCount
        CMP #$03
        BCS UEP_NoClimbing
        INC platformEnemyCount
        LDA #$01
        STA enemyLongLadderClimb,X
UEP_ClimbDownOK
        LDA tempStore
        STA enemyControls,X
        DEC enemyPlatformHeight,X
        INY
        LDA platformEnemyCount,Y
        SEC
        SBC #$01
        STA platformEnemyCount,Y
        DEY
        LDA platformEnemyCount,Y
        CLC
        ADC #$01
        STA platformEnemyCount,Y
UEP_InitClimb
        LDA #$01
        STA enemyClimbing,X
        LDA #PLATFORM_GROUND
        STA enemyJumpPlatformHeight,X
UEP_NoClimbing 
        DEX
        BMI UEC_Done
        JMP UEP_Loop

UEC_Done
        RTS

        PLA
        JMP UEP_NoClimbing

UEP_NoClimbDown 
        LDA charAtEnemy,X
        CMP #$C8
        BCC UEP_NoClimbing
        SBC #$C8
        TAY
        LDA charTypeTbl,Y
        AND #$01
        BEQ UEP_NoClimbing
        LDA enemyPlatformHeight,X
        CMP playerPlatformHeight
        BCS UEP_NoClimbing
        LDA charTypeTbl,Y
        AND #$01
        STA tempStore
        LDY enemyPlatformHeight,X
        INY
        LDA platformEnemyCount,Y
        CMP #$03
        BCS UEP_NoClimbing
        LDA stage
        CMP #$02
        BNE UEP_NoLongLadderUp
        CPY #PLATFORM_MIDDLE
        BNE UEP_NoLongLadderUp
        LDA platformEnemyCount+PLATFORM_TOP
        CMP #$03
        BCS UEP_NoClimbing
        INC platformEnemyCount+PLATFORM_TOP
        LDA #$03
        STA enemyLongLadderClimb,X
UEP_NoLongLadderUp
        LDA tempStore
        STA enemyControls,X
        INC enemyPlatformHeight,X
        DEY
        LDA platformEnemyCount,Y
        SEC
        SBC #$01
        STA platformEnemyCount,Y
        INY
        LDA platformEnemyCount,Y
        CLC
        ADC #$01
        STA platformEnemyCount,Y
        JMP UEP_InitClimb

UEP_InitJump 
        LDA enemyPlatformHeight,X
        CMP #PLATFORM_MIDDLE
        BNE UEP_InitJumpNotMid
        LDA #PLATFORM_MIDDLE
        STA enemyJumpPlatformHeight,X
UEP_InitJumpCommon
        INC platformEnemyCount
        JSR InitEnemyJump
        RTS

UEP_InitJumpNotMid 
        INC platformEnemyCount+PLATFORM_MIDDLE
        LDA #PLATFORM_TOP
        STA enemyJumpPlatformHeight,X
        JMP UEP_InitJumpCommon

FindFirstSprite
        LDX #$14
FFS_Loop LDY spriteOrder,X
        LDA spriteY,Y
        BNE FFS_Found
        DEX
        BPL FFS_Loop
        LDX #$00
FFS_Found STX sprIrqIndex
        RTS

AP_KnifeAnim 
        DEC playerKnifeTimer
        BNE AP_KnifeAnimDone
        LDA playerJumping
        ORA playerFalling
        BEQ AP_KnifeAnimDone
        LDA playerFacingDir
        ORA #$01
        JMP AP_SetAnim

InitEnemyJump 
        LDY enemyType,X
        LDA enemyCanJumpTbl,Y
        BEQ IEJ_Fail
        LDA enemyControls,X
        ORA #$01
        STA enemyControls,X
        LDA #$00
        STA enemyFalling,X
IEJ_Fail 
        RTS

enemyCanJumpTbl 
        .BYTE $00,$01,$01,$01,$00,$01,$00,$00,$00,$00

AP_KnifeAnimDone
        RTS

AnimatePlayer
        LDA playerKnifeTimer
        BNE AP_KnifeAnim
        LDA playerControls
        BEQ AP_Idle
        LDA playerJumping
        ORA playerFalling
        BNE AP_Done
        LDA charTypeBelowPlayer
        AND playerControls
        BEQ AP_AtLadderEnd
        TAY
        LDA playerControls
        AND #$02
        BEQ AP_NoProne
        LDA charTypeBelowPlayer
        AND #$02
        BEQ AP_AtLadderEnd
        TAY
AP_NoProne
        TYA
        CMP playerAnimState
        BNE AP_SetAnimAndReset
        DEC playerRunAnimTimer
        BNE AP_Done
        LDA #$06
        STA playerRunAnimTimer
        LDY playerRunFrame
AP_SetSpriteFrames 
        LDA playerUpperFrameTbl,Y
        BEQ AP_RestartAnimation
        LDX activeExtraWeapon
        BEQ AP_FrameOK
        TYA
        CLC
        ADC weaponFrameTblOffset,X
        TAX
        LDA playerUpperFrameTbl,X
        BEQ AP_SkipWeaponFrame
        BNE AP_FrameOK
AP_SkipWeaponFrame 
        LDA playerUpperFrameTbl,Y
AP_FrameOK 
        STA spriteFrame
        LDA playerLowerFrameTbl,Y
        STA spriteFrame+SPR_PLRLOWER
        INY
        STY playerRunFrame
AP_Done RTS

AP_NotDown
        LDA playerControls
        AND #$01
        BEQ AP_Done
AP_Idle LDA playerClimbingCopy
        ORA playerJumping
        ORA playerFalling
        BNE AP_Done
        LDA playerFacingDir
        JMP AP_SetAnim

AP_AtLadderEnd 
        LDA playerControls
        AND #$02
        BEQ AP_NotDown
        LDA playerClimbingCopy
        BNE AP_Done
        LDA playerControls
        AND #$0C
        BEQ AP_NoTurn
        STA playerFacingDir
AP_NoTurn 
        LDA playerFacingDir
        ORA #$02
        JMP AP_SetAnimAndReset

AP_RestartAnimation 
        LDA playerAnimState
        JMP AP_SetAnim

AP_SetAnimAndReset PHA
        LDA #$01
        STA playerRunAnimTimer
        PLA
AP_SetAnim 
        STA playerAnimState
        AND #$1F
        TAY
        LDA playerAnimTypeTbl,Y
        TAY
        LDX #$06
AP_FindOffsetLoop 
        CMP plrOffsetIndexTbl,X
        BEQ AP_OffsetFound
        DEX
        BNE AP_FindOffsetLoop
AP_OffsetFound 
        LDA spriteY+SPR_PLRLOWER
        SEC
        SBC plrUpperYOffsetTbl,X
        STA spriteY
        LDA spriteX+SPR_PLRLOWER
        CLC
        ADC plrUpperXOffsetTbl,X
        STA spriteX
        STX plrAnimOffsetIndex
        JMP AP_SetSpriteFrames

plrUpperYOffsetTbl
        .BYTE $15,$00,$00,$15,$15,$00,$00

plrUpperXOffsetTbl 
        .BYTE $00,$18,$18,$F8,$08,$18,$18

plrOffsetIndexTbl 
        .BYTE $00,$0F,$11,$13,$15,$19,$1B

weaponFrameTblOffset
        .BYTE $00,$00,$20,$00,$40

playerUpperFrameTbl 
        .BYTE $14,$15,$16,$17,$00,$25,$27,$00,$18,$00,$1D,$1E,$1F,$20,$00,$2E
        .BYTE $00,$2D,$00,$29,$00,$2B,$00,$21,$00,$2E,$00,$C3,$00,$A2,$A4,$00
        .BYTE $9E,$9F,$9E,$9F,$00,$00,$00,$00,$9E,$00,$A0,$A1,$A0,$A1,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$A0,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $A8,$A9,$A8,$A9,$00,$00,$00,$00,$A8,$00,$AA,$AB,$AA,$AB,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$AA,$00,$00,$00,$00,$00,$00,$00,$00

playerLowerFrameTbl 
        .BYTE $10,$11,$12,$13,$00,$24,$26,$00,$22,$00,$19,$1A,$1B,$1C,$00,$2F
        .BYTE $00,$2C,$00,$12,$00,$1B,$00,$23,$00,$C4,$00,$2C,$00,$A3,$28,$00

playerAnimTypeTbl 
        .BYTE $00,$05,$05,$00,$00,$08,$0F,$00,$0A,$17,$11,$00,$00,$00,$00,$1D
        .BYTE $00,$00,$00,$00,$13,$00,$19,$00,$15,$00,$1B,$00,$00,$00,$00,$00

AnimateEnemies
        LDX #$05
AE_Loop LDA enemyActive,X
        BNE AE_EnemyActive
        DEX
        BPL AE_Loop
        RTS

AE_EnemyActive 
        LDA enemyControls,X
        BEQ AE_NoCurrentMove
        LDA enemyFalling,X
        ORA enemyTimerActive,X
        BNE AE_Next
        LDA enemyControls,X
        CMP enemyLastControls,X
        BNE AE_ResetDelay
        DEC enemyRunAnimTimer,X
        BNE AE_Next
        LDA #$05
        STA enemyRunAnimTimer,X
        LDY enemyRunAnimFrame,X
AE_SetRunFrame 
        LDA enemyUpperFrameTbl,Y
        BEQ AE_AnimEnd
        STA spriteFrame+SPR_ENEMYUPPER,X
        LDA enemyLowerFrameTbl,Y
        STA spriteFrame+SPR_ENEMYLOWER,X
        INY
        TYA
        STA enemyRunAnimFrame,X
AE_Next DEX
        BPL AE_Loop
        RTS

AE_NoCurrentMove 
        LDA playerClimbingCopy
        ORA playerJumping
        ORA playerFalling
        BNE AE_Next
        LDA enemyHorizMove,X
        JMP AE_RestartAnimation

AE_AnimEnd
        LDA enemyLastControls,X
        JMP AE_RestartAnimation

AE_ResetDelay
        PHA
        LDA #$01
        STA enemyRunAnimTimer,X
        PLA
AE_RestartAnimation
        STA enemyLastControls,X
        AND #$1F
        PHA
        LDY enemyType,X
        LDA perTypeAnimTblOffset,Y
        STA tempStore
        PLA
        CLC
        ADC tempStore
        TAY
        LDA enemyFirstFrameIndex,Y
        TAY
        JMP AE_SetRunFrame

enemyUpperFrameTbl
        .BYTE $14,$15,$16,$17,$00,$3B,$3D,$00,$3E,$00,$1D,$1E,$1F,$20,$00,$40
        .BYTE $00,$46,$47,$48,$49,$00,$3B,$3D,$00,$3E,$00,$4E,$4F,$50,$51,$00
        .BYTE $40,$00,$7C,$7D,$7E,$7F,$00,$3B,$3D,$00,$84,$00,$80,$81,$82,$83
        .BYTE $00,$85,$00,$88,$89,$88,$89,$00,$3B,$3D,$00,$90,$00,$8C,$8D,$8C
        .BYTE $8D,$00,$91,$00,$9C,$9D,$9C,$9D,$00,$AD,$AF,$00,$3E,$00,$A5,$A6
        .BYTE $A5,$A6,$00,$40,$00

enemyLowerFrameTbl
        .BYTE $30,$31,$32,$33,$00,$3A,$3C,$00,$92,$00,$34,$35,$36,$37,$00,$93
        .BYTE $00,$42,$43,$44,$45,$00,$3A,$3C,$00,$92,$00,$4A,$4B,$4C,$4D,$00
        .BYTE $93,$00,$42,$43,$44,$45,$00,$3A,$3C,$00,$86,$00,$4A,$4B,$4C,$4D
        .BYTE $00,$87,$00,$30,$31,$32,$33,$00,$3A,$3C,$00,$92,$00,$34,$35,$36
        .BYTE $37,$00,$93,$00,$42,$43,$44,$45,$00,$AC,$AE,$00,$92,$00,$4A,$4B
        .BYTE $4C,$4D,$00,$93,$00

enemyFirstFrameIndex 
        .BYTE $00,$05,$05,$00,$00,$08,$0F,$00,$0A,$0F,$11,$00,$00,$00,$00,$00
        .BYTE $00,$16,$16,$00,$11,$19,$00,$00,$1B,$20,$00,$00,$00,$00,$00,$00
        .BYTE $00,$27,$27,$00,$22,$2A,$00,$00,$2C,$31,$00,$00,$00,$00,$00,$00
        .BYTE $00,$38,$38,$00,$33,$3B,$00,$00,$3D,$42,$00,$00,$00,$00,$00,$00
        .BYTE $00,$49,$49,$00,$44,$4C,$00,$00,$4E,$53,$00,$00,$00,$00,$00,$00

perTypeAnimTblOffset 
        .BYTE $10,$00,$30,$30,$00,$20,$40,$00,$00,$00

PlayerWorldCollision
        LDA spriteY+SPR_PLRLOWER
        SEC
playerYAdjust   =*+$01
        SBC #$2A
        LDY #$00
        STY screenPtrHi
        AND #$F8
        STA srcPtrLo
        ASL
        ROL screenPtrHi
        ASL
        ROL screenPtrHi
        CLC
        ADC srcPtrLo
        STA screenPtrLo
        LDA screenPtrHi
        ADC #$40
        STA screenPtrHi
        LDA spriteX+SPR_PLRLOWER
        SEC
        SBC #$0A
        SEC
        SBC scrollX
        LSR
        LSR
        LSR
        TAY
        LDA (screenPtrLo),Y
        STA charAtPlayer
        TYA
        CLC
        ADC #$28
        TAY
        LDA (screenPtrLo),Y
        STA charBelowPlayer
        RTS

EnemyWorldCollision
        LDX #$05
EWC_Loop
        LDA enemyActive,X
        BNE EWC_EnemyActive
EWC_Next 
        DEX
        BPL EWC_Loop
        RTS

EWC_EnemyActive 
        LDA enemyTimerActive,X
        BNE EWC_Next
        LDA spriteY+SPR_ENEMYUPPER,X
        SEC
        SBC enemyYAdjust,X
        LDY #$00
        STY screenPtrHi
        AND #$F8
        STA srcPtrLo
        ASL
        ROL screenPtrHi
        ASL
        ROL screenPtrHi
        CLC
        ADC srcPtrLo
        STA screenPtrLo
        LDA screenPtrHi
        ADC #$40
        STA screenPtrHi
        LDA spriteX+SPR_ENEMYUPPER,X
        SEC
        SBC #$0A
        BCS EWC_NoLeftUnderflow
        INY
EWC_NoLeftUnderflow 
        SEC
        SBC lastScrollX
        BCC EWC_XPosDone
        CPY #$00
        BEQ EWC_AddXPosMSB
        CLC
        BCC EWC_XPosDone
EWC_AddXPosMSB 
        PHA
        LDA spriteXMSB+SPR_ENEMYUPPER,X
        LSR
        PLA
EWC_XPosDone 
        ROR
        LSR
        LSR
        TAY
        CPY #$28
        BCC EWC_NoRightOverflow
        LDY #$27
EWC_NoRightOverflow 
        LDA (screenPtrLo),Y
        STA charAtEnemy,X
        TYA 
        CLC
        ADC #$28
        TAY
        LDA #$00
        STA charTypeAtEnemy,X
        STA charTypeBelowEnemy,X
        LDA (screenPtrLo),Y
        STA charBelowEnemy,X
        CMP #$C8
        BCC EWC_NoCharBelow
        SBC #$C8
        TAY 
        LDA charTypeTbl,Y
        STA charTypeBelowEnemy,X
EWC_NoCharBelow 
        LDA charAtEnemy,X
        CMP #$C8
        BCC EWC_NoCharAt
        SBC #$C8
        TAY
        LDA charTypeTbl,Y
        STA charTypeAtEnemy,X
EWC_NoCharAt 
        LDA stageEndReached
        BEQ EWC_NoStageEnd
        LDA charBelowEnemy,X
        CMP #$C8
        BCC EWC_JumpToNext
EWC_JumpToNext
        JMP EWC_Next

EWC_NoStageEnd 
        LDA enemyJumpPlatformHeight,X
        ORA enemyJumping,X
        BNE EWC_NoJump
        LDA charBelowEnemy,X
        CMP #$C8
        BCC EWC_NotOnGround
EWC_NoJump
        JMP EWC_Next

EWC_NotOnGround
        LDY enemyPlatformHeight,X
        DEY
        BNE EWC_NotInMiddle
EWC_CheckJumpOK
        LDA platformEnemyCount,Y
        CMP #$03
        BCS EWC_TurnAtEdge
        JSR UEP_InitJump
        JMP EWC_Next

EWC_NotInMiddle
        LDA platformEnemyCount-1,Y
        CMP #$03
        BCS EWC_TurnAtEdge
        BCC EWC_CheckJumpOK
EWC_TurnAtEdge
        LDA #$FA
        STA charBelowEnemy,X
        LDA enemyControls,X
        EOR #$0C
        STA enemyControls,X
        TAY
        JSR UE_HorizMovement
        JMP EWC_Next

enemyYAdjust
        .BYTE $15,$15,$15,$15,$15,$15

        ; Calculate coarse X coords (8 bit only, half resolution) for the enemies and player for faster hitbox collision checks.

SetCoarseXCoords
        LDX #$13
SCXC_Loop LDA spriteXMSB+SPR_ENEMYUPPER,X
        LSR
        LDA spriteX+SPR_ENEMYUPPER,X
        ROR
        STA enemyCoarseX,X
        DEX
        BPL SCXC_Loop
        LDA spriteX+SPR_PLRLOWER
        LSR
        STA playerCoarseX
        RTS

ReadControls
        LDA $DC00
        EOR #$FF
        AND #$1F
        STA joystickBits
        AND #$10
        CMP playerLastFire
        BEQ RC_HoldingFire
        LDA joystickBits
        STA playerControls
        AND #$10
        STA playerLastFire
        JMP RC_NoFireHeldDown

RC_HoldingFire
        LDA joystickBits
        AND #$0F
        STA playerControls
RC_NoFireHeldDown 
        LDA playerControls
        AND #$01
        CMP playerLastUp
        BEQ RC_HoldingUp
        STA playerLastUp
        LDA #$00
        STA playerJumpInhibit
RC_HoldingUp 
        LDA #$00
        STA charTypeBelowPlayer
        STA charTypeAtPlayer
        LDA charBelowPlayer
        CMP #$C8
        BCC RC_NoSolidCharAt
        SEC
        SBC #$C8
        TAX
        LDA charTypeTbl,X
        STA charTypeBelowPlayer
RC_NoSolidCharAt 
        LDA charAtPlayer
        CMP #$C8
        BCC RC_NoSolidCharBelow
        SEC
        SBC #$C8
        TAX 
        LDA charTypeTbl,X
        STA charTypeAtPlayer
RC_NoSolidCharBelow RTS 

charTypeTbl 
        .BYTE $0E,$0E,$0C,$0E,$0E,$03,$03,$0E,$0E,$03,$03,$0C,$03,$03,$03,$03
        .BYTE $03,$03,$03,$03,$03,$03,$03,$0F,$03,$0C,$0C,$0C,$03,$0C,$0E,$0C
        .BYTE $03,$0C,$03,$0C,$03,$03,$0E,$0E,$0C,$03,$03,$0E,$0E,$03,$0C,$0C
        .BYTE $0E,$03,$0C,$0C,$0C,$0C,$0C,$0C

MP_Falling 
        LDA playerFalling
        BEQ MP_InitFall
        STA plrFallSpeedSubPixel
        LDA charBelowPlayer
        CMP #$C8
        BCC MP_NoLanding
        LDA spriteY
        SEC 
        SBC #$04
        AND #$F8
        ORA #$05
        STA spriteY
        CLC
        ADC #$15
        STA spriteY+SPR_PLRLOWER
        LDA #$00
        STA playerFalling
        LDA #$80
        STA playerRunSpeed
        STA playerJumpInhibit
        RTS

MP_InitFall 
        LDA #$01
        STA playerFalling
        LDA #$80
        STA plrFallSpeedSubPixel
        LDA #$00
        STA playerRunSpeed
MP_NoLanding 
        LDA plrFallSpeedSubPixel
        CLC
        ADC playerYSubPixel
        STA playerYSubPixel
        LDA spriteY
        ADC #$04
        STA spriteY
        CLC 
        ADC #$15
        STA spriteY+SPR_PLRLOWER
        LDA playerFacingDir
        TAY 
        JMP MP_CheckMoveRight

MP_NoMove
        RTS

MovePlayer
        LDA playerFalling
        BEQ MP_NotFalling
        BNE MP_Falling
MP_NotFalling 
        LDA playerControls
        BNE MP_HasMovement
        LDA playerJumping
        BNE MP_IsJumping
        LDA charBelowPlayer
        CMP #$C8
        BCS MP_IsJumping
        JMP MP_Falling

MP_IsJumping
        JMP MP_HandleJump

MP_HasMovement 
        LDY playerJumping
        BNE MP_IsJumping
        LDY charBelowPlayer
        CPY #$C8
        BCS MP_HasCharBelow
        JMP MP_Falling

MP_HasCharBelow 
        AND #$13
        BEQ MP_NoLadderOrAttack
        JMP MP_CanClimbOrAttack

MP_NoLadderOrAttack 
        LDA playerKnifeTimer
        BNE MP_NoMove
        LDA playerControls
        AND charTypeBelowPlayer
        TAY 
MP_CheckMoveRight AND #$08
        BEQ MP_NoMoveRight
        LDA spriteX
playerRightLimit   =*+$01
        CMP #$88
        BCS MP_CheckScroll
        LDA playerRunSpeed
        CLC 
        ADC playerRunSubPixel
        STA playerRunSubPixel
        BCC MP_MoveRight
        JSR MP_MoveRight
MP_MoveRight 
        INC spriteX
        INC spriteX+SPR_PLRLOWER
        JMP MP_ExitLadderRight

MP_NoMoveRight 
        TYA
        AND #$04
        BEQ MP_IsJumping
        LDA spriteX
        CMP #$20
        BCC MP_NoMove
        LDA playerRunSpeed
        CLC
        ADC playerRunSubPixel
        STA playerRunSubPixel
        BCC MP_MoveLeft
        JSR MP_MoveLeft
MP_MoveLeft 
        DEC spriteX
        DEC spriteX+SPR_PLRLOWER
        LDA #$00
        STA playerClimbing
        STA playerClimbingCopy
        LDA #$04
        STA playerFacingDir
        RTS 

MP_CheckScroll 
        JSR CheckScroll
MP_ExitLadderRight 
        LDA #$00
        STA playerClimbing
        STA playerClimbingCopy
        LDA #$08
        STA playerFacingDir
        RTS 

MP_HasFirePress
        LDA playerClimbingCopy
        BNE MP_NoKnifeAttack
        LDA #$05
        STA playerKnifeTimer
        LDA playerControls
        AND #$02
        BEQ MP_KnifeNoProne
        LDA playerJumping
        ORA playerFalling
        BNE MP_KnifeNoProne
        LDA playerControls
        AND #$0C
        BNE MP_KnifeProneTurn
        LDA playerFacingDir
        ORA #$12
        PHA 
        JSR CheckKnifeCollisions
        PLA
        JMP AP_SetAnim

MP_KnifeProneTurn 
        LDA playerControls
        AND #$0C
        STA playerFacingDir
        LDA playerControls
        AND #$1E
        PHA
        JSR CheckKnifeCollisions
        PLA
        JMP AP_SetAnim

MP_KnifeNoProne 
        LDA playerJumping
        ORA playerFalling
        BNE MP_KnifeAirborne
        LDA playerControls
        AND #$0C
        BNE MP_KnifeOnGroundTurn
MP_KnifeAirborne 
        LDA playerFacingDir
        ORA #$10
        PHA
        JSR CheckKnifeCollisions
        PLA 
        JMP AP_SetAnim

MP_KnifeOnGroundTurn 
        LDA playerControls
        AND #$1C
        PHA 
        JSR CheckKnifeCollisions
        PLA 
        JMP AP_SetAnim

MP_HandleJump 
        LDA playerJumping
        BNE MP_JumpCheckLadder
        RTS

MP_CanClimbOrAttack 
        LDA playerControls
        AND #$10
        BNE MP_HasFirePress
MP_NoKnifeAttack 
        LDA playerJumping
        BNE MP_JumpCheckLadder
        LDA charTypeAtPlayer
        AND #$03
        BEQ MP_NoLadderAbove
        AND playerControls
        BEQ MP_NoInitClimb
        JMP MP_PlayerClimbing

MP_NoLadderAbove 
        LDA charTypeBelowPlayer
        AND #$03
        BEQ MP_NoInitClimb
        AND playerControls
        BEQ MP_NoInitClimb
        JMP MP_PlayerClimbing

MP_NoInitClimb 
        LDA playerClimbing
        BEQ MP_NotClimbing
        JMP MP_PlayerClimbing

MP_NotClimbing 
        LDA playerControls
        AND #$01
        BNE MP_HasUpPress
        RTS

MP_HasUpPress 
        LDA playerJumpInhibit
        BEQ MP_OKToJump
        JMP MP_NoLadderOrAttack

MP_OKToJump
        LDA #$01
        STA playerJumping
        STA playerJumpInhibit
        LDA playerControls
        STA playerJumpControls
        AND #$0C
        BEQ MP_JumpNoTurn
        STA playerFacingDir
MP_JumpNoTurn
        LDA playerFacingDir
        ORA #$01
        JSR AP_SetAnimAndReset
        LDY #$14
        STY playerJumpArcIndex
        LDA spriteY+SPR_PLRLOWER
        SEC 
        SBC jumpArcTbl,Y
        STA playerBaseY
MP_JumpCheckLadder 
        LDA charTypeAtPlayer
        AND #$03
        BEQ MP_JumpNoLadder
        AND playerControls
        BNE MP_GrabLadder
MP_JumpNoLadder 
        LDY playerJumpArcIndex
        LDA playerBaseY
        CLC 
        ADC jumpArcTbl,Y
        STA spriteY+SPR_PLRLOWER
        SEC 
        SBC #$15
        STA spriteY
        LDA playerJumping
        BPL MP_DecJumpArc
        INY
        CPY #$15
        BCC MP_JumpArcNotDone
        LDA #$00
        STA playerJumping
        LDA #$01
        STA playerJumpInhibit
        STA playerFalling
        JMP MP_CheckJumpAttack

MP_DecJumpArc
        DEY
        BPL MP_JumpArcNotDone
        LDA #$80
        STA playerJumping
        INY
MP_JumpArcNotDone     
        STY playerJumpArcIndex
MP_CheckJumpAttack 
        LDA playerControls
        AND #$10
        BEQ MP_NoJumpAttack
        JMP MP_HasFirePress

MP_NoJumpAttack     
        LDA playerJumpControls
        AND #$0C
        BEQ MP_JumpNoHoriz
        TAY
        JMP MP_CheckMoveRight

MP_JumpNoHoriz
        RTS

MP_GrabLadder 
        LDA spriteY
        SEC 
        SBC #$04
        AND #$F8
        ORA #$05
        STA spriteY
        CLC
        ADC #$15
        STA spriteY+SPR_PLRLOWER
MP_PlayerClimbing 
        LDA playerControls
        AND #$03
        TAY
        AND charTypeAtPlayer
        AND #$01
        BEQ MP_NoClimbUp
MP_ClimbUp 
        DEC spriteY
        DEC spriteY+SPR_PLRLOWER
        DEC spriteY
        DEC spriteY+SPR_PLRLOWER
        LDA #$00
        STA playerJumping
        LDA #$01
        STA playerClimbing
        STA playerClimbingCopy
        RTS 

MP_NoClimbUp 
        LDA charTypeAtPlayer
        AND #$01
        BNE MP_CheckClimbDown
        TYA 
        AND #$01
        BEQ MP_CheckClimbDown
        LDA playerYAdjust
        CMP #$1B
        BEQ MP_NoClimbDown
        LDA charAtPlayer
        CMP #$C8
        BCC MP_AtLadderTop
        LDA #$1B
        STA playerYAdjust
        JMP MP_ClimbUp

MP_CheckClimbDown
        TYA
        AND charTypeBelowPlayer
        AND #$02
        BEQ MP_NoClimbDown
        INC spriteY
        INC spriteY+SPR_PLRLOWER
        INC spriteY
        INC spriteY+SPR_PLRLOWER
        LDA #$00
        STA playerJumping
        LDA #$01
        STA playerClimbingCopy
        STA playerClimbing
MP_NoClimbDown 
        LDA #$2A
        STA playerYAdjust
        RTS

MP_AtLadderTop 
        LDA #$2A
        STA playerYAdjust
        LDA #$01
        STA playerLastUp
        STA playerJumpInhibit
        JMP MP_NoLadderOrAttack

jumpArcTbl 
        .BYTE $00,$00,$01,$01,$02,$03,$04,$05,$06,$07,$09,$0B,$0D,$0F,$11,$13
        .BYTE $15,$17,$19,$1B,$1E,$21,$24,$28,$2C,$30,$34,$38,$3C,$3C,$3C,$3C

UpdateEnemies
        LDX #$05
UE_Loop LDA enemyActive,X
        BNE UE_EnemyActive
UE_Next DEX 
        BPL UE_Loop
        RTS 

UE_EnemyActive 
        LDA enemyTimerActive,X
        BEQ UE_TimerNotActive
        LDA enemyType,X
        CMP #$09
        BEQ UE_Next
        JSR RunEnemyCustomCode
        JMP UE_Next

UE_TimerNotActive 
        LDA enemyFalling,X
        BEQ UE_NotFalling
        BNE UE_UpdateFall
UE_NotFalling 
        JSR RunEnemyCustomCode
        LDA enemyTimerActive,X
        BNE UE_Next
        LDA enemyControls,X
        BNE UE_HasControls
        LDA enemyJumping,X
        BNE UE_Jumping
        LDA charBelowEnemy,X
        CMP #$C8
        BCS UE_Jumping
        JMP UE_UpdateFall

UE_Jumping 
        LDA enemyJumping,X
        BEQ UE_Next
        JMP UE_UpdateJumpArc

UE_HasControls 
        LDY enemyJumping,X
        BNE UE_Jumping
        LDY charBelowEnemy,X
        CPY #$C8
        BCS UE_HasGroundBelow
        LDA enemyControls,X
        AND #$01
        BNE UE_HasGroundBelow
        JMP UE_UpdateFall

UE_HasGroundBelow 
        TAY
        AND #$01
        BEQ UE_DoHorizMoveOnly
        JMP UE_CheckJumpOrClimb

UE_DoHorizMoveOnly
        LDA enemyControls,X
        JSR UE_HorizMovement
        DEX 
        BPL UE_Loop
        RTS

UE_UpdateFall 
        LDA enemyFalling,X
        BEQ UE_InitFall
        LDA enemyJumpSpeed,X
        CLC
        ADC #$08
        BCS UE_FallingMotion
        STA enemyJumpSpeed,X
UE_FallingMotion 
        LDA charBelowEnemy,X
        CMP #$C8
        BCC UE_NoLanding
        LDA spriteY+SPR_ENEMYUPPER,X
        SEC
        SBC #$04
        AND #$F8
        ORA #$05
        STA spriteY+SPR_ENEMYUPPER,X
        CLC
        ADC #$15
        STA spriteY+SPR_ENEMYLOWER,X
        LDA #$00
        STA enemyFalling,X
        LDY enemyType,X
        LDA perTypeInitFlags,Y
        STA enemyRunSpeed,X
        JMP UE_Next

UE_InitFall 
        LDA #$01
        STA enemyFalling,X
        LDA #$80
        STA enemyJumpSpeed,X
        LDA #$00
        STA enemyRunSpeed,X
UE_NoLanding
        LDA enemyJumpSpeed,X
        CLC 
        ADC enemyJumpSubPixel,X
        STA enemyJumpSubPixel,X
        LDA spriteY+SPR_ENEMYUPPER,X
        ADC #$04
        STA spriteY+SPR_ENEMYUPPER,X
        CLC 
        ADC #$15
        STA spriteY+SPR_ENEMYLOWER,X
        LDA enemyHorizMove,X
        TAY
        JSR UE_HorizMovement
        DEX 
        BMI UE_Done
        JMP UE_Loop

UE_Done RTS

UE_HorizMovement 
        TAY
        AND #$08
        BEQ UE_HorizMovementLeft
        LDA enemyRunSpeed,X
        CLC 
        ADC enemyRunSubPixel,X
        STA enemyRunSubPixel,X
        BCC UE_MoveRight
        JSR UE_MoveRight
UE_MoveRight 
        INC spriteX+SPR_ENEMYUPPER,X
        INC spriteX+SPR_ENEMYLOWER,X
        BNE UE_RightNoMSB
        LDA #$01
        STA spriteXMSB+SPR_ENEMYUPPER,X
        STA spriteXMSB+SPR_ENEMYLOWER,X
UE_RightNoMSB 
        LDA #$08
        STA enemyHorizMove,X
        LDA #$00
        STA enemyClimbingCopy,X
        RTS 

UE_HorizMovementLeft
        TYA
        AND #$04
        BEQ UE_NoHorizMove
        LDA enemyRunSpeed,X
        CLC
        ADC enemyRunSubPixel,X
        STA enemyRunSubPixel,X
        BCC UE_MoveLeft
        JSR UE_MoveLeft
UE_MoveLeft
        LDA spriteX+SPR_ENEMYUPPER,X
        BNE UE_LeftNoMSB
        LDA #$00
        STA spriteXMSB+SPR_ENEMYUPPER,X
        STA spriteXMSB+SPR_ENEMYLOWER,X
UE_LeftNoMSB 
        DEC spriteX+SPR_ENEMYUPPER,X
        DEC spriteX+SPR_ENEMYLOWER,X
        LDA #$04
        STA enemyHorizMove,X
        LDA #$00
        STA enemyClimbingCopy,X
        RTS

UE_NoHorizMove 
        JSR UpdateEnemyClimb
        JMP UE_Next

UE_CheckJumpOrClimb
        LDA enemyJumping,X
        BNE UE_UpdateJumpArc
        LDA charTypeAtEnemy,X
        AND #$03
        BEQ UE_NoLadderAt
        AND enemyControls,X
        BEQ UE_NoLadderBelow
        LDA enemyType,X
        CMP #$05
        BEQ UE_NoLadderBelow
        JMP UE_NoHorizMove

UE_NoLadderAt 
        LDA charTypeBelowEnemy,X
        AND #$03
        BEQ UE_NoLadderBelow
        AND enemyControls,X
        BEQ UE_NoLadderBelow
        JMP UpdateEnemyClimb

UE_NoLadderBelow 
        LDA enemyClimbingCopy,X
        BEQ UE_NotClimbing
UE_EnemyGrabLadder 
        JMP UE_NoHorizMove

UE_NotClimbing 
        LDA enemyControls,X
        AND #$01
        BNE UE_InitJumpArc
        JMP UE_Next

UE_InitJumpArc 
        LDA #$01
        STA enemyJumping,X
        LDA enemyControls,X
        LDA enemyHorizMove,X
        ORA #$01
        STX platformTemp
        JSR AE_RestartAnimation
        LDX platformTemp
        LDY #$12
        TYA
        STA enemyJumpArcIndex,X
        LDA spriteY+SPR_ENEMYLOWER,X
        SEC 
        SBC jumpArcTbl,Y
        STA enemyBaseY,X
UE_UpdateJumpArc
        LDA charTypeAtEnemy,X
        AND #$03
        BEQ UE_JumpNoLadder
        LDY enemyType,X
        CPY #$05
        BEQ UE_JumpNoLadder
        AND enemyControls,X
        BNE UE_EnemyGrabLadder
UE_JumpNoLadder 
        LDY enemyJumpArcIndex,X
        LDA enemyBaseY,X
        CLC 
        ADC jumpArcTbl,Y
        STA spriteY+SPR_ENEMYLOWER,X
        SEC 
        SBC #$15
        STA spriteY+SPR_ENEMYUPPER,X
        LDA enemyJumping,X
        BPL UE_DecJumpArc
        INY
        CPY #$13
        BCC UE_JumpArcNotDone
        LDA #$00
        STA enemyJumping,X
        LDA enemyHorizMove,X
        STA enemyControls,X
        LDA #$01
        STA enemyFalling,X
        JMP UE_CheckJumpHorizMove

UE_DecJumpArc 
        DEY
        BPL UE_JumpArcNotDone
        LDA #$80
        STA enemyJumping,X
        INY
UE_JumpArcNotDone
        TYA
        STA enemyJumpArcIndex,X
UE_CheckJumpHorizMove
        LDA enemyControls,X
        AND #$0C
        BEQ UE_NoJumpHorizMove
        TAY
        JSR UE_HorizMovement
UE_NoJumpHorizMove 
        JMP UE_Next

