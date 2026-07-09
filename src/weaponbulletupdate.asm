        ; Routines for firing the player's extra weapon and updating bullets. Only enemy bullets store their type to
        ; perform the correct kind of update; player bullets behave instead according to the last collected weapon,
        ; which means that they can change behavior mid-air when a new weapon is collected. Grenades and player /
        ; enemy jumps all use a lookup table for the vertical motion arc instead of affecting speed by gravity and
        ; then adding to position.

FlashBullets
        LDA gameTimer
        AND #$04
        LSR
        LSR
        TAY
        LDX #$05
        LDA colorFlashTbl,Y
FB_Loop STA spriteColor+SPR_BULLET,X
        DEX
        BPL FB_Loop
        RTS

colorFlashTbl
        .BYTE $07,$02

UpdateBullets
        JSR CheckRemoveBullets
        JSR CheckGrenadeHitEnemy
        JSR CheckDestroyMines
        JSR CheckFireExtraWeapon
        BEQ UB_NoFireExtraWeapon
        JSR FindFreeBullet
        BCS UB_NoFireExtraWeapon
        JSR FireExtraWeapon

    .if INFINITE_SHOTS_CHEAT = 0

        ; Original code, extra weapon shots will be decremented by one
        DEC extraWeaponShotsLeft

    .else

        ; Cheat code, no decrement
        LDA extraWeaponShotsLeft

    .endif

        BNE UB_ShotsNotExhausted
        LDA #$00
        STA activeExtraWeapon
UB_ShotsNotExhausted 
        JSR FormatWeaponShots
UB_NoFireExtraWeapon 
        JSR ScrollBullets
        LDX #$05
UB_XMoveLoop 
        LDA bulletActive,X
        BNE UB_DoXMove
UB_XMoveNext
        DEX
        BPL UB_XMoveLoop
        LDA collectedExtraWeapon
        CMP #$04
        BNE UB_NoFlameThrower
        LDA flameDetachedTimer
        BEQ UB_NoFlameThrower
        LDA spriteX+SPR_BULLET
        SEC 
        SBC spriteX+SPR_BULLET+2
        CMP #$17
        BCS UB_NoFlameThrower
        LDA #$00
        STA spriteY+SPR_BULLET+1
        LDA #$06
        STA bulletXSpeed+2
UB_NoFlameThrower 
        JSR FlashBullets
        RTS 

UB_DoXMove 
        LDA bulletXDir,X
        CMP #$08
        BNE UB_XMoveLeft
        LDA spriteX+SPR_BULLET,X
        CLC 
        ADC bulletXSpeed,X
        STA spriteX+SPR_BULLET,X
        BCC UB_NoMSBSet
        LDA #$01
        STA spriteXMSB+SPR_BULLET,X
UB_NoMSBSet 
        JMP UB_XMoveNext

UB_XMoveLeft 
        LDA spriteX+SPR_BULLET,X
        SEC
        SBC bulletXSpeed,X
        STA spriteX+SPR_BULLET,X
        BCS UB_NoMSBClear
        LDA #$00
        STA spriteXMSB+SPR_BULLET,X
UB_NoMSBClear 
        JMP UB_XMoveNext

CheckGrenadeHitEnemy
        LDY #$02
CGHE_Loop 
        LDA bulletActive,Y
        BEQ CGHE_Next
        LDA collectedExtraWeapon
        CMP #$03
        BNE CGHE_IsBazooka
CGHE_Next 
        DEY
        BPL CGHE_Loop
        RTS 

CGHE_IsBazooka 
        LDX #$05
        STY temp2
CGHE_EnemyLoop 
        LDA enemyActive,X
        BNE CGHE_EnemyActive
        LDA stage
        CMP #$01
        BNE CGHE_NextEnemy
        CPX #$04
        BCS CGHE_NextEnemy
        LDA dogActive-1,X ;Use standard enemy indexing, dog update code offsets by one
        BEQ CGHE_NextEnemy
CGHE_EnemyActive 
        LDA enemyType,X
        CMP #$09
        BNE CHGE_EnemyOK
        LDA numAliveGyros
        BNE CHGE_CheckGyroHit
        CPX paraEnemyIndices
        BEQ CHGE_EnemyOK
CGHE_NextEnemy 
        LDY temp2
        DEX
        BPL CGHE_EnemyLoop
        JMP CGHE_Next

CHGE_CheckGyroHit
        CPX #$01
        BEQ CHGE_EnemyOK
        CPX #$04
        BEQ CHGE_EnemyOK
        JMP CGHE_NextEnemy

CHGE_EnemyOK
        LDA spriteY+SPR_BULLET,Y
        SEC
        SBC #$13
        STA playerHitCheckY
        LDA bulletCoarseX,Y
        STA playerHitCheckX
        LDA enemyDying,X
        BNE CGHE_NextEnemy
        LDY enemyRunAnimFrame,X
        LDA enemyCoarseX,X
        CLC
        ADC #$03
        STA enemyTouchBoundHigh
        LDA enemyCoarseX,X
        SEC
        SBC #$03
        STA enemyTouchBoundLow
        LDA playerHitCheckX
        CMP enemyTouchBoundHigh
        BCS CGHE_Done
        CMP enemyTouchBoundLow
        BCC CGHE_Done
        LDA spriteY+SPR_ENEMYUPPER,X
        CLC
        ADC #$10
        STA enemyTouchBoundHigh
        LDA spriteY+SPR_ENEMYUPPER,X
        SEC 
        SBC #$10
        STA enemyTouchBoundLow
        LDA playerHitCheckY
        CMP enemyTouchBoundHigh
        BCS CGHE_Done
        CMP enemyTouchBoundLow
        BCC CGHE_Done
        LDA enemyActive,X
        BNE CGHE_IsHumanEnemy
        LDA #$80
        STA dogHit-1,X ;Use standard enemy indexing, dog update code offsets by one
        JMP CGHE_SkipEnemyHit

CGHE_IsHumanEnemy 
        LDA #$80
        STA enemyHit,X
CGHE_SkipEnemyHit 
        STX temp
        STY tempStoreY2
        LDA enemyType,X
        CMP #$09
        BNE CGHE_NoParachuteHit
        LDA numAliveGyros
        BNE CGHE_NoParachuteHit
        JSR CleanupParachute
        JSR PlayEnemyKillSound
CGHE_NoParachuteHit 
        LDX temp
        LDY tempStoreY2
        LDA numAliveGyros
        BEQ CGHE_Done
        STX temp
        LDX temp2
        JSR ExplodeGrenade
        LDX temp
        JSR DestroyGyrocopter
        LDX temp
CGHE_Done 
        JMP CGHE_NextEnemy

CheckFireExtraWeapon 
        LDA collectedExtraWeapon
        BEQ CFEW_NoFire
        LDX playerClimbingCopy
        BNE CFEW_IsClimbing
        LDA extraWeaponShotsLeft
        BEQ CFEW_NoFire
        LDA $DC01
        AND #$10
        EOR #$10
        CMP extraWeaponFireFlag
        BEQ CFEW_NoFire
        STA extraWeaponFireFlag
        CMP #$00
CFEW_NoFire 
        RTS

CFEW_IsClimbing 
        LDA #$00
        RTS

UpdateExtraWeapon 
        LDY collectedExtraWeapon
        BEQ UEW_NoWeapon
        DEY
        TYA
        ASL
        TAY
        LDA extraWeaponJumpTblLo,Y
        STA extraWeaponJumpLo
        LDA extraWeaponJumpTblHi,Y
        STA extraWeaponJumpHi
extraWeaponJumpLo   =*+$01
extraWeaponJumpHi   =*+$02
UEW_Jump JMP UEW_Jump

extraWeaponJumpTblHi   =*+$01
extraWeaponJumpTblLo 
        .WORD UpdateUnusedWeapon, UpdateBazooka, UpdateGrenade, UpdateFlameThrower

UEW_NoWeapon 
        RTS

UpdateUnusedWeapon
        RTS

UpdateGrenade
        LDX #$02
UG_Loop LDA bulletActive,X
        BNE UG_GrenadeActive
        DEX
        BPL UG_Loop
        RTS

UG_GrenadeActive
        LDA bulletYDir,X
        BNE UG_YMove
        JSR UG_CheckLanding
        DEX
        BPL UG_Loop
        RTS

UG_YMove
        LDY bulletJumpArcIndex,X
        LDA bulletBaseY,X
        CLC
        ADC jumpArcTbl,Y
        STA spriteY+SPR_BULLET,X
        LDA bulletYDir,X
        BPL UG_YMoveDecSpeed
        LDA spriteY+SPR_BULLET,X
        CMP #$E2
        BCS UG_YMoveAtBottom
        INY
        CPY #$13
        BCC UG_StoreNewSpeed
UG_YMoveAtBottom 
        LDA #$00
        STA bulletYDir,X
        DEX
        BPL UG_Loop
        RTS 

UG_YMoveDecSpeed 
        DEY
        BPL UG_StoreNewSpeed
        LDA #$80
        STA bulletYDir,X
        INY
UG_StoreNewSpeed 
        TYA
        STA bulletJumpArcIndex,X
        DEX
        BPL UG_Loop
        RTS

UG_CheckLanding 
        JSR CheckCharAtBullet
        LDA bulletLastChar,X
        CMP #$C8
        BCC UG_NoCharLanding
        SEC
        SBC #$C8
        TAY
        LDA charTypeTbl,Y
        AND #$0C
        BEQ UG_NoCharLanding
UG_Explode 
        JSR ExplodeGrenade
        JSR CheckBulletExploded
        RTS

UG_NoCharLanding 
        LDA spriteY+SPR_BULLET,X
        CLC 
        ADC #$04
        CMP #$E2
        BCS UG_Explode
        STA spriteY+SPR_BULLET,X
        RTS

CheckCharAtBullet 
        LDA spriteY+SPR_BULLET,X
        SEC
        SBC #$26
        LDY #$00
        STY screenPtrHi
        AND #$F8
        STA tempStore
        ASL 
        ROL screenPtrHi
        ASL 
        ROL screenPtrHi
        CLC
        ADC tempStore
        STA screenPtrLo
        LDA screenPtrHi
        ADC #$40
        STA screenPtrHi
        LDA bulletCoarseX,X
        SEC 
        SBC #$08
        LSR 
        LSR
        CLC
        ADC #$28
        TAY
        LDA (screenPtrLo),Y
        STA bulletLastChar,X
        RTS

ExplodeGrenade 
        LDA bulletExploded,X
        BEQ EG_NotExplodedYet
        RTS

EG_NotExplodedYet 
        LDA #$00
        STA bulletXSpeed,X
        LDA #$01
        STA bulletExploded,X
        STA spriteColor+SPR_BULLET,X
        LDA #$62
        STA spriteFrame+SPR_BULLET,X
        LDA #$05
        STA bulletTimer,X
        STX bulletIndex
        JSR PlayExplosionSound
        LDX bulletIndex
        CPX #$03
        BCS EG_IsEnemyGrenade
        JSR CheckGrenadeAreaKill
EG_IsEnemyGrenade 
        RTS

CheckBulletExploded 
        LDA bulletExploded,X
        BNE UpdateExplosion
        RTS 

UpdateExplosion
        DEC bulletTimer,X
        BNE UE_NoNewFrame
        LDA #$05
        STA bulletTimer,X
        LDA spriteFrame+SPR_BULLET,X
        CMP #$64
        BCS UE_Remove
        INC spriteFrame+SPR_BULLET,X
UE_NoNewFrame
        RTS

UE_Remove 
        LDA #$00
        STA bulletActive,X
        STA spriteY+SPR_BULLET,X
        STA bulletExploded,X
UpdateBazooka 
        RTS

CheckGrenadeAreaKill 
        LDY #$05
CGAK_Loop 
        LDA enemyActive,Y
        BEQ CGAK_Next
        JSR CGAK_EnemyBoundCheck
        BCC CGAK_Next
        LDA enemyType,Y
        CMP #$09
        BNE CGAK_NotParachute
        LDA numAliveGyros
        BNE CGAK_NotParachute
        LDA #$01
        STA parachuteKillFlag
        CPY paraEnemyIndices
        BNE CGAK_Next
CGAK_NotParachute
        LDA #$80
        STA enemyHit,Y
CGAK_Next 
        DEY
        BPL CGAK_Loop
        RTS

CGAK_EnemyBoundCheck 
        LDA enemyCoarseX,Y
        CLC 
        ADC #$28
        CMP bulletCoarseX,X
        BCC CGAK_BoundsFail
        SEC
        SBC #$50
        BCS CGAK_NoXUnderFlow
        LDA #$08
CGAK_NoXUnderFlow
        CMP bulletCoarseX,X
        BCS CGAK_BoundsFail
        LDA spriteY+SPR_ENEMYUPPER,Y
        CLC 
        ADC #$46
        BCC CGAK_NoYOverFlow
        LDA #$FF
CGAK_NoYOverFlow 
        CMP spriteY+SPR_BULLET,X
        BCC CGAK_BoundsFail
        SEC 
        SBC #$46
        CMP spriteY+SPR_BULLET,X
        BCS CGAK_BoundsFail
        SEC 
        RTS

CGAK_BoundsFail 
        CLC
        RTS

UpdateFlameThrower 
        LDA flameDetachedTimer
        BEQ UFT_NotDetached
        RTS

UFT_NotDetached 
        LDX #$02
UFT_FlameLoop 
        LDA bulletActive,X
        BNE UFT_FlamePieceActive
        DEX
        BPL UFT_FlameLoop
        RTS

UFT_FlamePieceActive 
        LDA playerControls
        AND #$02
        BEQ UFT_PlayerStanding
        LDA spriteY
        CLC
        ADC #$05
        JMP UFT_StoreY

UFT_PlayerStanding 
        LDA spriteY
        CLC 
        ADC #$0A
UFT_StoreY
        STA spriteY+SPR_BULLET,X
        DEX 
        BPL UFT_FlameLoop
        LDA bulletCoarseX
        SEC
        SBC bulletCoarseX+2
        BMI UFT_NegXDistance
UFT_XDistanceCheck 
        CMP #$14
        BCS UFT_FlameWasDetached
        RTS

UFT_NegXDistance 
        EOR #$FF
        CLC 
        ADC #$01
        JMP UFT_XDistanceCheck

UFT_FlameWasDetached 
        LDA #$08
        STA bulletXSpeed+2
        LDA #$07
        STA bulletXSpeed+1
        LDA #$06
        STA bulletXSpeed
        STA flameDetachedTimer
        RTS

CheckRemoveBullets 
        LDX #$05
CRB_Loop LDA bulletActive,X
        BEQ CRB_Next
        LDA bulletCoarseX,X
        CMP #$AA
        BCS CRB_Remove
        CMP #$08
        BCC CRB_Remove
CRB_Next DEX 
        BPL CRB_Loop
        RTS

CRB_Remove 
        LDA #$00
        STA bulletActive,X
        STA spriteY+SPR_BULLET,X
        STA bulletYDir,X
        LDA collectedExtraWeapon
        CMP #$04
        BEQ CRB_RemoveFlame
        JMP CRB_Next

CRB_RemoveFlame 
        CPX #$03
        BCS CRB_Next
        LDA #$08
        STA bulletXSpeed+2
        STA bulletXSpeed+1
        STA bulletXSpeed
        JMP CRB_Next

FindFreeBullet 
        LDX #$02
FFB_Loop 
        LDA bulletActive,X
        BEQ FFB_Found
        DEX
        BPL FFB_Loop
        SEC 
        RTS 

FFB_Found 
        CLC
        RTS

FireExtraWeapon 
        LDY collectedExtraWeapon
        DEY 
        CPY #$03
        BNE FEW_OKTOFire
        CPX #$02
        BEQ FEW_OKTOFire
        RTS

FEW_OKTOFire 
        LDA playerFacingDir
        PHA 
        AND #$04
        BEQ FEW_FireRight
        LDA #$E0
        CLC
FEW_FireRight 
        ADC #$10
        STA bulletOffset
        PLA 
        STA bulletXDir,X
        LDA extraWpnColorTbl,Y
        STA spriteColor+SPR_BULLET,X
        LDA spriteY
        CLC
        ADC #$0A
        STA spriteY+SPR_BULLET,X
        LDA spriteX
        CLC 
        ADC bulletOffset
        STA spriteX+SPR_BULLET,X
        LDA #$00
        STA flameDetachedTimer
        STA spriteXMSB+SPR_BULLET,X
        LDA bulletXDir,X
        CMP #$04
        BEQ FEW_UseLeftFrame
        LDA extraWpnRightFrTbl,Y
        STA spriteFrame+SPR_BULLET,X
        JMP FEW_InitCommon

FEW_UseLeftFrame 
        LDA extraWpnLeftFrameTbl,Y
        STA spriteFrame+SPR_BULLET,X
FEW_InitCommon 
        LDA extraWpnSpeedTbl,Y
        STA bulletXSpeed,X
        LDA #$01
        STA bulletActive,X
        CPY #$03
        BEQ FEW_InitFlame
        CPY #$02
        BEQ FEW_InitGrenade
        RTS

FEW_InitGrenade 
        LDY #$12
        TYA 
        STA bulletJumpArcIndex,X
        LDA spriteY+SPR_BULLET,X
        SEC 
        SBC jumpArcTbl,Y
        STA bulletBaseY,X
        LDA #$01
        STA bulletYDir,X
        RTS 

FEW_InitFlame 
        DEX
FEW_FlamePieceLoop
        LDA playerFacingDir
        STA bulletXDir,X
        LDA extraWpnColorTbl,Y
        STA spriteColor+SPR_BULLET,X
        LDA spriteY+SPR_BULLET+1,X
        STA spriteY+SPR_BULLET,X
        LDA bulletXDir,X
        AND #$04
        BEQ FEW_InitFlameRight
        LDA spriteX+SPR_BULLET+1,X
        STA spriteX+SPR_BULLET,X
        LDA #$00
        STA spriteXMSB+SPR_BULLET,X
        JMP FEW_InitFlameCommon

FEW_InitFlameRight
        LDA spriteX+SPR_BULLET+1,X
        CLC
        STA spriteX+SPR_BULLET,X
        LDA spriteXMSB+SPR_BULLET+1,X
        ADC #$00
        STA spriteXMSB+SPR_BULLET,X
FEW_InitFlameCommon
        LDA spriteFrame+SPR_BULLET+1,X
        CLC 
        ADC #$01
        STA spriteFrame+SPR_BULLET,X
        LDA bulletXSpeed+1,X
        CLC 
        ADC #$02
        STA bulletXSpeed,X
        LDA #$01
        STA bulletActive,X
        DEX
        BPL FEW_FlamePieceLoop
        JMP PlayFlameSound

RunEnemyBulletCode
        LDX #$05
REBC_Loop
        LDA bulletActive,X
        BNE REBC_BulletActive
REBC_Next
        DEX
        CPX #$02
        BNE REBC_Loop
        RTS

REBC_BulletActive
        LDA bulletType,X
        ASL
        TAY
        LDA bulletCodeJumpTblLo,Y
        STA bulletCodeJumpLo
        LDA bulletCodeJumpTblHi,Y
        STA bulletCodeJumpHi
bulletCodeJumpLo   =*+$01
bulletCodeJumpHi   =*+$02
REBC_Jump
        JSR REBC_Jump
        JMP REBC_Next

bulletCodeJumpTblHi   =*+$01
bulletCodeJumpTblLo
        .WORD BulletCodeType0,BulletCodeType1,BulletCodeType2,BulletCodeType3,BulletCodeType0,BulletCodeType6,BulletCodeType6,BulletCodeType7

BulletCodeType7
        CPX fighterJetIndex
        BEQ BulletCodeType0
        LDA spriteY+SPR_BULLET,X
        BEQ BulletCodeType0
        CLC
        ADC #$04
        PHA
        LDA spriteX+SPR_PLRLOWER
        CLC
        ADC #$09
        STA spriteX+SPR_BULLET,X
        PLA
        JMP BCT6_CheckY

BulletCodeType6 LDA spriteY+SPR_BULLET,X
        CLC
        ADC #$02
BCT6_CheckY
        CMP #$F3
        BCS BC_Remove
        STA spriteY+SPR_BULLET,X
        RTS

BC_Remove
        LDA #$01
        STA spriteY+SPR_BULLET,X
        LDA #$00
        STA bulletActive,X
BulletCodeType0 RTS

BulletCodeType1 RTS

BulletCodeType3 RTS

BulletCodeType2
        LDA bulletYDir,X
        BNE EnemyGrenadeArc
        JSR UG_CheckLanding
        RTS

EnemyGrenadeArc
        LDY bulletJumpArcIndex,X
        LDA bulletBaseY,X
        CLC
        ADC jumpArcTbl,Y
        STA spriteY+SPR_BULLET,X
        LDA bulletYDir,X
        BPL EGA_DecSpeed
        INY
        CPY #$1A
        BCC EGA_StoreNewSpeed
        LDA #$00
        STA bulletYDir,X
        RTS

EGA_DecSpeed 
        DEY
        BPL EGA_StoreNewSpeed
        LDA #$80
        STA bulletYDir,X
        INY
EGA_StoreNewSpeed 
        TYA
        STA bulletJumpArcIndex,X
        RTS 

extraWpnColorTbl 
        .BYTE $07,$0F,$05,$07,$05,$07

extraWpnSpeedTbl
         .BYTE $03,$04,$03,$00,$00,$00,$01

extraWpnRightFrTbl
        .BYTE $8E,$66,$67,$69,$67,$67,$8E

extraWpnLeftFrameTbl
        .BYTE $8E,$65,$67,$98,$67,$67,$8E