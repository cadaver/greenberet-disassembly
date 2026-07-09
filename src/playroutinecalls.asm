        ; Interface for the actual playroutine code for triggering songs and sound effects, and waiting for songs to
        ; complete.

PlaySong LDX #$05
PS_SongPointerLoop 
        LDA songPointerTbl,Y
        STA chn1Lo,X
        DEY
        DEX
        BPL PS_SongPointerLoop
        LDX #$02
PS_ChannelLoop
        LDY fED32,X
        LDA #$00
        STA chn1Trans,X
        STA fEC15,Y
        STA fEC19,Y
        STA fEC1E,Y
        LDA #$01
        STA chn1Timer,X
        STA chn1MusicFlag,X
        STA chn1SoundFlag,X
        LDA #$07
        STA chn1StackPtr,X
        LDA #$08
        STA fEC1F,Y
        DEX
        BPL PS_ChannelLoop
        RTS

CheckSongEnd 
        LDA chn1MusicFlag
        ORA chn2MusicFlag
        ORA chn3MusicFlag
        ORA aECD3
        ORA aECFA
        ORA aED21
        RTS

ResetSong 
        LDX #$00
        STX chn1MusicFlag
        STX chn2MusicFlag
        STX chn3MusicFlag
        STX aECD3
        STX aECFA
        STX aED21
        DEX
        STX chn1SoundFlag
        STX chn2SoundFlag
        STX chn3SoundFlag
        RTS

ResetSID 
        JSR ResetSong
        LDX #$14
RS_Loop LDA #$08
        STA $D400,X
        LDA #$00
        STA $D400,X
        DEX
        BPL RS_Loop
        RTS

songPointerTbl   
        .BYTE $84,$F0,$BA,$F0,$E8,$F0,$5B,$F4,$DE,$F0,$AE,$F1,$A7,$F3,$A5,$F3
        .BYTE $00,$F4,$A3,$F4,$E5,$F4,$40,$F5,$9B,$F5,$AA,$F5,$BA,$F5,$FD,$F2
        .BYTE $3B,$F3,$6C,$F3,$9A,$F2,$CF,$F2,$E6,$F2,$9F,$F1,$DE,$F0,$DE,$F0
        .BYTE $38,$F7,$DA,$F8,$A8,$FB,$E6,$F5,$E4,$F5,$42,$F6,$65,$F4,$DE,$F0
        .BYTE $7D,$F2,$3D,$F1,$DE,$F0,$48,$F1,$73,$F1,$DE,$F0,$DE,$F0

PlayFlameSound 
        LDA #$6B
        LDY #$EE
        LDX #$01
        JSR PlaySound
        LDA #$8A
        LDY #$EE
        LDX #$02
        JMP PlaySound

PlayDogBarkSound 
        LDY dogSoundIndex
        LDX dogBarkSoundTbl,Y
        STX dogSoundIndex
        LDA #$4C
        LDY #$EE
        JMP PlaySound

dogSoundIndex 
        .BYTE $01

FadeMotorSound
        LDA #$00
        STA chn1MusicFlag
        RTS

PlayFighterJetSound 
        LDA #$25
        LDY #$EF
        LDX #$01
        JSR PlaySound
        LDA #$06
        LDY #$EF
        JMP PlaySoundChannel1

PlayEnemyKillSound 
        LDA #$44
        LDY #$EF
        LDX #$01
        JMP PlaySound

PlayEnemyFireSound 
        LDA #$82
        LDY #$EF
        LDX #$01
        JSR PlaySound
        LDA #$63
        LDY #$EF
        JMP PlaySoundChannel1

PlayExplosionSound 
        LDA #$A9
        LDY #$EE
        JSR PlaySoundChannel1
        LDA #$C8
        LDY #$EE
        LDX #$01
        JSR PlaySound
        LDA #$E7
        LDY #$EE
        LDX #$02
        JMP PlaySound

PlayCollectSound
        LDA #$A1
        LDY #$EF
        JSR PlaySoundChannel1
        LDA #$C0
        LDY #$EF
        LDX #$01
        JSR PlaySound
        LDA #$DF
        LDY #$EF
        LDX #$02
        JMP PlaySound

PlayBazookaSound
        LDA #$FE
        LDY #$EF
        JSR PlaySoundChannel1
        LDA #$1D
        LDY #$F0
        LDX #$01
        JSR PlaySound
        LDA #$3C
        LDY #$F0
        LDX #$02
        JMP PlaySound

s3F58   LDX aECCD
        LDY aECCE
        STX aECDA
        STY aECDB
s3F64   LDA aECC5
        STA aECDC
        LDA aECC6
        STA aECDD
        RTS

s3F71   LDX aECF4
        LDY aECF5
        STX aED01
        STY aED02
s3F7D   LDA aECEC
        STA aED03
        LDA aECED
        STA aED04
        RTS

s3F8A   LDX aED1B
        LDY aED1C
        STX aED28
        STY aED29
s3F96   LDA aED13
        STA aED2A
        LDA aED14
        STA aED2B
        RTS 

        .BYTE $00,$07,$03,$0C,$00,$00,$00,$00,$00,$00,$00,$03,$00,$0D,$FF,$00
        .BYTE $05,$04,$0A,$00,$00,$00,$00,$07,$41,$05,$B9,$04,$32,$14,$00,$EC
        .BYTE $FF,$14,$00,$00,$00,$03,$06,$03,$00,$0A,$05,$50,$50,$09,$00,$14
        .BYTE $00,$EC,$FF,$80,$08,$00,$00,$9C,$FF,$00,$00,$00,$00,$0A,$0A,$00
        .BYTE $00,$01,$85,$00,$09,$05,$0C,$01,$85,$00,$09,$05,$0C

        ; Flags to tell which graphics blocks have been swapped in memory, to allow resetting on new game

graphicsSwapFlags
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
