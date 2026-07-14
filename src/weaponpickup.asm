        ; Handle moving and collecting the weapon pickup. Called from the main loop. When collected, it will give the
        ; player the associated extra weapon and initialize the shot counter. When the screen scrolls, the pickup 
        ; sprite is moved manually along with the scrolling, as otherwise it would appear to float in place.

UpdateWeaponPickup
        LDA weaponPickupType
        BNE UWP_CheckCollect
        RTS

UWP_CheckCollect
        LDA weaponPickupCoarseX
        CLC
        ADC #$06
        CMP playerCoarseX
        BCC UWP_Move
        SEC
        SBC #$0C
        CMP playerCoarseX
        BCS UWP_Move
        LDA spriteY+SPR_PLRLOWER
        CLC 
        ADC #$14
        CMP spriteY+SPR_PICKUP
        BCC UWP_Move
        SEC 
        SBC #$28
        CMP spriteY+SPR_PICKUP
        BCS UWP_Move
        LDY weaponPickupType
        STY collectedExtraWeapon
        STY activeExtraWeapon
        LDA extraWeaponShotsTbl,Y
        STA extraWeaponShotsLeft
        JSR PlayCollectSound
        LDA #$00
        STA weaponPickupType
        STA spriteY+SPR_PICKUP
        JSR FormatWeaponShots
UWP_AtRest
        RTS

extraWeaponShotsTbl
        .BYTE $00,$00,$04,$03,$03

UWP_Move
        LDA lastScrollSpeed
        BEQ UWP_NotScrolledOff
        LDA spriteX+SPR_PICKUP
        SEC
        SBC lastScrollSpeed
        STA spriteX+SPR_PICKUP
        BCS UWP_NoMSBClear
        LDA #$00
        STA spriteXMSB+SPR_PICKUP
UWP_NoMSBClear 
        LDA weaponPickupCoarseX
        CMP #$0A
        BCS UWP_NotScrolledOff
        LDA #$00
        STA spriteY+SPR_PICKUP
        STA weaponPickupType
        RTS

UWP_NotScrolledOff 
        LDA weaponPickupRestFlag
        BNE UWP_AtRest
        LDA spriteX+SPR_PICKUP
        CLC
        ADC #$02
        STA spriteX+SPR_PICKUP
        BCC UWP_NoMSBSet
        LDA #$01
        STA spriteXMSB+SPR_PICKUP
UWP_NoMSBSet 
        INC spriteY+SPR_PICKUP
        LDY #$00
        STY screenPtrHi
        LDA spriteY+SPR_PICKUP
        SEC
        SBC #$15
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
        LDA weaponPickupCoarseX
        SBC #$0C
        LSR
        LSR
        TAY
        LDA (screenPtrLo),Y
        CMP #$C8
        BCC UWP_NoLanding
        SBC #$C8
        TAY 
        LDA charTypeTbl,Y
        AND #$0C
        CMP #$0C
        BNE UWP_NoLanding
        STA weaponPickupRestFlag
UWP_NoLanding 
        RTS
