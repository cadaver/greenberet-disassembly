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
        LDA playerLowerY
        CLC 
        ADC #$14
        CMP extraPickupY
        BCC UWP_Move
        SEC 
        SBC #$28
        CMP extraPickupY
        BCS UWP_Move
        LDY weaponPickupType
        STY collectedExtraWeapon
        STY activeExtraWeapon
        LDA extraWeaponShotsTbl,Y
        STA extraWeaponShotsLeft
        JSR PlayCollectSound
        LDA #$00
        STA weaponPickupType
        STA extraPickupY
        JSR FormatWeaponShots
UWP_AtRest  
		RTS

extraWeaponShotsTbl 
		.BYTE $00,$00,$04,$03,$03

UWP_Move 
		LDA lastScrollSpeed
        BEQ UWP_NotScrolledOff
        LDA weaponPickupX
        SEC
        SBC lastScrollSpeed
        STA weaponPickupX
        BCS UWP_NoMSBClear
        LDA #$00
        STA weaponPickupXMSB
UWP_NoMSBClear 
		LDA weaponPickupCoarseX
        CMP #$0A
        BCS UWP_NotScrolledOff
        LDA #$00
        STA extraPickupY
        STA weaponPickupType
        RTS

UWP_NotScrolledOff 
		LDA weaponPickupRestFlag
        BNE UWP_AtRest
        LDA weaponPickupX
        CLC
        ADC #$02
        STA weaponPickupX
        BCC UWP_NoMSBSet
        LDA #$01
        STA weaponPickupXMSB
UWP_NoMSBSet 
		INC extraPickupY
        LDY #$00
        STY screenPtrHi
        LDA extraPickupY
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
