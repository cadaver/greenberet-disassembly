         * = $E000

PlaySoundChannel1 LDX #$00
PlaySound STA playRoutineLo
        STY playRoutineHi
        STX playRoutineTemp
        LDA #$00
        STA chn1SoundFlag,X
        LDA fED2F,X
        STA aE01F
        TAX 
        LDA #$02
        STA $D402,X
        LDY #$1A
        LDX #$04
bE01C   LDA (playRoutineLo),Y
aE01F   =*+$01
        STA $D409,X
        DEY 
        DEX 
        BPL bE01C
        LDY #$1D
        LDX aE01F
        LDA (playRoutineLo),Y
        STA $D3FE,X
        INY 
        LDA (playRoutineLo),Y
        STA $D3FF,X
        LDY playRoutineTemp
        LDX fED2C,Y
        LDY #$1B
        LDA (playRoutineLo),Y
        STA fECBB,X
        INY 
        LDA (playRoutineLo),Y
        STA fECBC,X
        LDY #$18
        LDA (playRoutineLo),Y
        STA fECBA,X
        LDY #$1E
        LDA (playRoutineLo),Y
        STA fECB9,X
        DEY
        LDA (playRoutineLo),Y
        STA fECB8,X
        LDY #$17
bE05D   LDA (playRoutineLo),Y
        STA fECB7,X
        DEX
        DEY 
        BPL bE05D
        INX 
        BNE bE09B
        LDA aECC8
        BEQ bE076
        JSR s3F58
        LDA aECC4
        BEQ bE09A
bE076   LDX aECCF
        LDY aECD0
        STX aECD4
        STY aECD5
sE082   LDA aECC2
        STA aECD9
        LDA aECC1
        STA aECD8
        LDA aECC0
        STA aECD7
        LDA aECBF
        STA aECD6
bE09A   RTS

bE09B   CPX #$4E
        BEQ bE0D1
        LDA aECEF
        BEQ bE0A7
        JSR s3F71
bE0A7   LDA aECEB
        BEQ bE0D0
sE0AC   LDX aECF6
        LDY aECF7
        STX aECFB
        STY aECFC
sE0B8   LDA aECE9
        STA aED00
        LDA aECE8
        STA aECFF
        LDA aECE7
        STA aECFE
        LDA aECE6
        STA aECFD
bE0D0   RTS

bE0D1   LDA aED16
        BEQ bE0D9
        JSR s3F8A
bE0D9   LDA aED12
        BEQ bE102
sE0DE   LDX aED1D
        LDY aED1E
        STX aED22
        STY aED23
sE0EA   LDA aED10
        STA aED27
        LDA aED0F
        STA aED26
        LDA aED0E
        STA aED25
        LDA aED0D
        STA aED24
bE102   RTS 

UpdateMusicChannel1 LDA chn1MusicFlag
        BEQ bE102
        DEC chn1Timer
        BEQ bE117
        RTS 

jE10C   LDA #$03
jE10E   CLC
        ADC chn1Lo
        STA chn1Lo
        BCC bE117
        INC chn1Hi
bE117   LDY #$00
        LDA (chn1Lo),Y
        CMP #$C0
        BCC bE132
        TAX 
        LDA fED36,X
        STA aE12D
        LDA fED37,X
        STA aE12E
aE12D   =*+$01
aE12E   =*+$02
        JMP jE21C

bE12F   JMP jE200

bE132   STA playRoutineTemp
        CMP #$60
        BCC bE13A
        SBC #$60
bE13A   CMP #$5F
        BEQ bE12F
        ADC chn1Trans
        TAX
        LDA chn1SoundFlag
        BEQ bE12F
        LDA #$08
        STA $D404
        LDA aEC22
        STA $D406
        LDA aEC21
        STA $D405
        LDA aEC20
        STA aECD1
        AND #$F7
        STA $D404
        LDA fEC1F
        STA $D403
        LDA fEC1E
        STA $D402
        LDY fED38,X
        LDA fED97,X
        STA aECCF
        STY aECD0
        STA $D400
        STY $D401
        LDA fEC19
        STA aECC8
        BEQ bE1C9
        LDY fEC1F
        STY aECCE
        LDX fEC1E
        STX fEC1E
        STX aECDA
        STY aECDB
        LDA aEC1D
        STA aECCC
        LDA aEC1C
        STA aECCB
        LDA aEC1B
        STA aECCA
        LDA aEC1A
        STA aECC9
        LDA aEC18
        STA aECC7
        LDY aEC17
        STY aECC6
        LDX aEC16
        STX aECC5
        STX aECDC
        STY aECDD
bE1C9   LDX fEC15
        STX aECC4
        BEQ bE1F4
        LDY #$0C
bE1D3   LDA fEC08,Y
        STA fECB7,Y
        DEY
        BPL bE1D3
        TXA 
        AND #$08
        BEQ bE1F1
        LDA playRoutineTemp
        CMP #$60
        BCC bE1EA
        SBC #$60
        CLC 
bE1EA   ADC chn1Trans
        STA aECC1
        BNE bE1F4
bE1F1   JSR bE076
bE1F4   LDX aEC23
        LDY aEC24
        STX aECD2
        STY aECD3
jE200   LDY #$01
        LDA (chn1Lo),Y
        LDX playRoutineTemp
        CPX #$60
        BCS bE20E
        TAX
        LDA fECA6,X
bE20E   STA chn1Timer
        LDA #$02
        CLC
        ADC chn1Lo
        STA chn1Lo
        BCC bE21B
        INC chn1Hi
bE21B   RTS 

jE21C   INC chn1StackPtr
        LDY chn1StackPtr
        CPY #$08
        BEQ bE231
        LDX fEC25,Y
        LDA fEC2D,Y
        STX chn1Lo
        STA chn1Hi
        JMP bE117

bE231   DEC chn1MusicFlag
        RTS

        LDX chn1StackPtr
        CLC 
        LDA #$02
        ADC chn1Lo
        STA fEC25,X
        LDA #$00
        ADC chn1Hi
        STA fEC2D,X
        INY 
        LDA (chn1Lo),Y
        STA fEC35,X
        DEC chn1StackPtr
        LDA #$02
        JMP jE10E

        LDX chn1StackPtr
        DEC fEC36,X
        BEQ bE266
        LDY fEC26,X
        LDA fEC2E,X
        STY chn1Lo
        STA chn1Hi
        JMP bE117

bE266   INC chn1StackPtr
        LDA #$01
        JMP jE10E

        INY 
        LDA (chn1Lo),Y
        STA playRoutineLo
        INY 
        LDA (chn1Lo),Y
        STA playRoutineHi
        LDY #$04
bE279   LDA (playRoutineLo),Y
        STA aEC20,Y
        DEY
        BPL bE279
        JMP jE10C

        INY 
        LDA (chn1Lo),Y
        STA playRoutineLo
        INY 
        LDA (chn1Lo),Y
        STA playRoutineHi
        LDY #$0D
bE290   LDA (playRoutineLo),Y
        STA fEC08,Y
        DEY 
        LDA (playRoutineLo),Y
        STA fEC08,Y
        DEY 
        BPL bE290
        JMP jE10C

        INY 
        LDA (chn1Lo),Y
        STA playRoutineLo
        INY 
        LDA (chn1Lo),Y
        STA playRoutineHi
        LDY #$09
bE2AD   LDA (playRoutineLo),Y
        STA fEC08,Y
        DEY 
        LDA (playRoutineLo),Y
        STA fEC08,Y
        DEY
        BPL bE2AD
        JMP jE10C

        INY
        LDA (chn1Lo),Y
        TAX
        INY 
        LDA (chn1Lo),Y
        STA playRoutineTemp
        INY 
        LDA (chn1Lo),Y
        STA playRoutineLo
        INY
        LDA (chn1Lo),Y
        STA playRoutineHi
        LDY playRoutineTemp
bE2D3   LDA (playRoutineLo),Y
        STA fEC08,X
        DEX 
        DEY
        BPL bE2D3
        LDA #$05
        JMP jE10E

        INY 
        LDA (chn1Lo),Y
        STA chn1Trans
        INY
        LDA (chn1Lo),Y
        TAX 
        INY
        LDA (chn1Lo),Y
        STX chn1Lo
        STA chn1Hi
        JMP bE117

        INY 
        LDA (chn1Lo),Y
        TAX 
        INY 
        LDA (chn1Lo),Y
        STX chn1Lo
        STA chn1Hi
        JMP bE117

        LDY #$01
        LDX #$02
        LDA (chn1Lo),Y
        STA chn1Trans
        LDA #$04
bE30C   LDY chn1StackPtr
        CLC 
        ADC chn1Lo
        STA fEC25,Y
        LDA #$00
        ADC chn1Hi
        STA fEC2D,Y
        DEC chn1StackPtr
        TXA 
        TAY 
        LDA (chn1Lo),Y
        TAX
        INY 
        LDA (chn1Lo),Y
        STX chn1Lo
        STA chn1Hi
        JMP bE117

        LDA #$03
        LDX #$01
        BNE bE30C
        INY 
        LDA (chn1Lo),Y
        STA chn1Trans
        LDA #$02
        JMP jE10E

        INY 
        LDA (chn1Lo),Y
        TAX
        INY
        LDA (chn1Lo),Y
        STA fEC08,X
        JMP jE10C

        INY 
        LDA (chn1Lo),Y
        TAX 
        INY 
        LDA (chn1Lo),Y
        STA fECB7,X
        JMP jE10C

bE356   RTS 

UpdateSoundChannel1 LDX aECD3
        BEQ bE356
        LDA aECD1
        AND #$08
        BEQ bE379
        LDA chn1Timer
        CMP aECD2
        BCS bE39B
        LDA #$00
        STA aECD2
        LDA aECD1
        AND #$F6
        STA aECD1
        BNE bE398
bE379   LDA aECD2
        BNE bE38E
        DEC aECD3
        BNE bE39B
        LDX #$06
bE385   STA $D400,X
        DEX
        BPL bE385
        STX chn1SoundFlag
        RTS 

bE38E   DEC aECD2
        BNE bE39B
        LDA aECD1
        AND #$F6
bE398   STA $D404
bE39B   LDA aECC8
        BEQ bE3FD
        LDA aECC7
        BEQ bE3AB
        DEC aECC7
        JMP bE3FD

bE3AB   CLC 
        LDX aECDA
        LDY aECDB
        LDA aECDC
        BEQ bE3C7
        TXA 
        ADC aECC9
        TAX 
        TYA 
        ADC aECCA
        TAY 
        DEC aECDC
        JMP jE3F1

bE3C7   LDA aECDD
        BEQ bE3DC
        TXA 
        ADC aECCB
        TAX
        TYA
        ADC aECCC
        TAY 
        DEC aECDD
        JMP jE3F1

bE3DC   LDA aECC8
        AND #$81
        BEQ jE3F1
        BPL bE3EB
        JSR s3F58
        JMP bE3AB

bE3EB   JSR s3F64
        JMP bE3AB

jE3F1   STX aECDA
        STY aECDB
        STX $D402
        STY $D403
bE3FD   LDA aECC4
        BEQ bE41C
        AND #$08
        BNE bE41D
        LDX aECD4
        LDY aECD5
        CLC
        LDA aECC3
        BEQ bE43F
        DEC aECC3
        LDA aECC4
        AND #$02
        BNE bE484
bE41C   RTS

bE41D   LDX aECC3
        BPL bE425
        LDX aECC2
bE425   LDA aECC1
        CLC
        ADC fECB7,X
        DEX 
        STX aECC3
        TAY
        LDX fED97,Y
        LDA fED38,Y
        STX $D400
        STA $D401
        RTS

jE43E   CLC
bE43F   LDA aECD6
        BEQ bE454
        DEC aECD6
        TXA 
        ADC fECB7
        TAX 
        TYA
        ADC fECB8
        JMP jE48D

        RTS

bE454   LDA aECD7
        BEQ bE468
        DEC aECD7
        TXA 
        ADC fECB9
        TAX 
        TYA 
        ADC fECBA
        JMP jE48D

bE468   LDA aECD8
        BEQ bE47C
        DEC aECD8
        TXA
        ADC fECBB
        TAX 
        TYA 
        ADC fECBC
        JMP jE48D

bE47C   LDA aECD9
        BEQ bE49B
        DEC aECD9
bE484   TXA 
        ADC aECBD
        TAX
        TYA 
        ADC aECBE
jE48D   TAY
bE48E   STX $D400
        STY $D401
        STX aECD4
        STY aECD5
        RTS 

bE49B   LDA aECC4
        AND #$81
        BEQ bE48E
        BPL bE4AA
        JSR bE076
        JMP jE43E

bE4AA   JSR sE082
        JMP jE43E

UpdateMusicChannel2 LDA chn2MusicFlag
        BEQ bE4B8
        DEC chn2Timer
        BEQ bE4C4
bE4B8   RTS

jE4B9   LDA #$03
jE4BB   CLC 
        ADC chn2Lo
        STA chn2Lo
        BCC bE4C4
        INC chn2Hi
bE4C4   LDY #$00
        LDA (chn2Lo),Y
        CMP #$C0
        BCC bE4DF
        TAX
        LDA fED52,X
        STA aE4DA
        LDA fED53,X
        STA aE4DB
aE4DA   =*+$01
aE4DB   =*+$02
        JMP jE5C9

bE4DC   JMP jE5AD

bE4DF   STA playRoutineTemp
        CMP #$60
        BCC bE4E7
        SBC #$60
bE4E7   CMP #$5F
        BEQ bE4DC
        ADC chn2Trans
        TAX
        LDA chn2SoundFlag
        BEQ bE4DC
        LDA #$08
        STA $D40B
        LDA aEC57
        STA $D40D
        LDA aEC56
        STA $D40C
        LDA aEC55
        STA aECF8
        AND #$F7
        STA $D40B
        LDA aEC54
        STA $D40A
        LDA aEC53
        STA $D409
        LDY fED38,X
        LDA fED97,X
        STA aECF6
        STY aECF7
        STA $D407
        STY $D408
        LDA aEC4E
        STA aECEF
        BEQ bE576
        LDY aEC54
        STY aECF5
        LDX aEC53
        STX aECF4
        STX aED01
        STY aED02
        LDA aEC52
        STA aECF3
        LDA aEC51
        STA aECF2
        LDA aEC50
        STA aECF1
        LDA aEC4F
        STA aECF0
        LDA aEC4D
        STA aECEE
        LDY aEC4C
        STY aECED
        LDX aEC4B
        STX aECEC
        STX aED03
        STY aED04
bE576   LDX aEC4A
        STX aECEB
        BEQ bE5A1
        LDY #$0C
bE580   LDA fEC3D,Y
        STA fECDE,Y
        DEY 
        BPL bE580
        TXA
        AND #$08
        BEQ bE59E
        LDA playRoutineTemp
        CMP #$60
        BCC bE597
        SBC #$60
        CLC 
bE597   ADC chn2Trans
        STA aECE8
        BNE bE5A1
bE59E   JSR sE0AC
bE5A1   LDX aEC58
        LDY aEC59
        STX aECF9
        STY aECFA
jE5AD   LDY #$01
        LDA (chn2Lo),Y
        LDX playRoutineTemp
        CPX #$60
        BCS bE5BB
        TAX 
        LDA fECA6,X
bE5BB   STA chn2Timer
        LDA #$02
        CLC
        ADC chn2Lo
        STA chn2Lo
        BCC bE5C8
        INC chn2Hi
bE5C8   RTS 

jE5C9   INC chn2StackPtr
        LDY chn2StackPtr
        CPY #$08
        BEQ bE5DE
        LDX fEC5A,Y
        LDA fEC62,Y
        STX chn2Lo
        STA chn2Hi
        JMP bE4C4

bE5DE   DEC chn2MusicFlag
        RTS 

        LDX chn2StackPtr
        CLC 
        LDA #$02
        ADC chn2Lo
        STA fEC5A,X
        LDA #$00
        ADC chn2Hi
        STA fEC62,X
        INY
        LDA (chn2Lo),Y
        STA fEC6A,X
        DEC chn2StackPtr
        LDA #$02
        JMP jE4BB

        LDX chn2StackPtr
        DEC fEC6B,X
        BEQ bE613
        LDY fEC5B,X
        LDA fEC63,X
        STY chn2Lo
        STA chn2Hi
        JMP bE4C4

bE613   INC chn2StackPtr
        LDA #$01
        JMP jE4BB

        INY
        LDA (chn2Lo),Y
        STA playRoutineLo
        INY
        LDA (chn2Lo),Y
        STA playRoutineHi
        LDY #$04
bE626   LDA (playRoutineLo),Y
        STA aEC55,Y
        DEY 
        BPL bE626
        JMP jE4B9

        INY
        LDA (chn2Lo),Y
        STA playRoutineLo
        INY
        LDA (chn2Lo),Y
        STA playRoutineHi
        LDY #$0D
bE63D   LDA (playRoutineLo),Y
        STA fEC3D,Y
        DEY 
        LDA (playRoutineLo),Y
        STA fEC3D,Y
        DEY
        BPL bE63D
        JMP jE4B9

        INY
        LDA (chn2Lo),Y
        STA playRoutineLo
        INY 
        LDA (chn2Lo),Y
        STA playRoutineHi
        LDY #$09
bE65A   LDA (playRoutineLo),Y
        STA fEC3D,Y
        DEY 
        LDA (playRoutineLo),Y
        STA fEC3D,Y
        DEY 
        BPL bE65A
        JMP jE4B9

        INY 
        LDA (chn2Lo),Y
        TAX 
        INY 
        LDA (chn2Lo),Y
        STA playRoutineTemp
        INY 
        LDA (chn2Lo),Y
        STA playRoutineLo
        INY
        LDA (chn2Lo),Y
        STA playRoutineHi
        LDY playRoutineTemp
bE680   LDA (playRoutineLo),Y
        STA fEC3D,X
        DEX 
        DEY 
        BPL bE680
        LDA #$05
        JMP jE4BB

        INY
        LDA (chn2Lo),Y
        STA chn2Trans
        INY
        LDA (chn2Lo),Y
        TAX 
        INY 
        LDA (chn2Lo),Y
        STX chn2Lo
        STA chn2Hi
        JMP bE4C4

        INY
        LDA (chn2Lo),Y
        TAX 
        INY 
        LDA (chn2Lo),Y
        STX chn2Lo
        STA chn2Hi
        JMP bE4C4

        LDY #$01
        LDX #$02
        LDA (chn2Lo),Y
        STA chn2Trans
        LDA #$04
bE6B9   LDY chn2StackPtr
        CLC 
        ADC chn2Lo
        STA fEC5A,Y
        LDA #$00
        ADC chn2Hi
        STA fEC62,Y
        DEC chn2StackPtr
        TXA 
        TAY
        LDA (chn2Lo),Y
        TAX
        INY 
        LDA (chn2Lo),Y
        STX chn2Lo
        STA chn2Hi
        JMP bE4C4

        LDA #$03
        LDX #$01
        BNE bE6B9
        INY 
        LDA (chn2Lo),Y
        STA chn2Trans
        LDA #$02
        JMP jE4BB

        INY
        LDA (chn2Lo),Y
        TAX 
        INY
        LDA (chn2Lo),Y
        STA fEC3D,X
        JMP jE4B9

        INY
        LDA (chn2Lo),Y
        TAX 
        INY 
        LDA (chn2Lo),Y
        STA fECDE,X
        JMP jE4B9

bE703   RTS

UpdateSoundChannel2 LDX aECFA
        BEQ bE703
        LDA aECF8
        AND #$08
        BEQ bE726
        LDA chn2Timer
        CMP aECF9
        BCS bE748
        LDA #$00
        STA aECF9
        LDA aECF8
        AND #$F6
        STA aECF8
        BNE bE745
bE726   LDA aECF9
        BNE bE73B
        DEC aECFA
        BNE bE748
        LDX #$06
bE732   STA $D407,X
        DEX 
        BPL bE732
        STX chn2SoundFlag
        RTS

bE73B   DEC aECF9
        BNE bE748
        LDA aECF8
        AND #$F6
bE745   STA $D40B
bE748   LDA aECEF
        BEQ bE7AA
        LDA aECEE
        BEQ bE758
        DEC aECEE
        JMP bE7AA

bE758   CLC 
        LDX aED01
        LDY aED02
        LDA aED03
        BEQ bE774
        TXA 
        ADC aECF0
        TAX 
        TYA
        ADC aECF1
        TAY
        DEC aED03
        JMP jE79E

bE774   LDA aED04
        BEQ bE789
        TXA 
        ADC aECF2
        TAX 
        TYA 
        ADC aECF3
        TAY 
        DEC aED04
        JMP jE79E

bE789   LDA aECEF
        AND #$81
        BEQ jE79E
        BPL bE798
        JSR s3F71
        JMP bE758

bE798   JSR s3F7D
        JMP bE758

jE79E   STX aED01
        STY aED02
        STX $D409
        STY $D40A
bE7AA   LDA aECEB
        BEQ bE7C9
        AND #$08
        BNE bE7CA
        LDX aECFB
        LDY aECFC
        CLC 
        LDA aECEA
        BEQ bE7EC
        DEC aECEA
        LDA aECEB
        AND #$02
        BNE bE830
bE7C9   RTS 

bE7CA   LDX aECEA
        BPL bE7D2
        LDX aECE9
bE7D2   LDA aECE8
        CLC 
        ADC fECDE,X
        DEX 
        STX aECEA
        TAY 
        LDX fED97,Y
        LDA fED38,Y
        STX $D407
        STA $D408
        RTS 

jE7EB   CLC 
bE7EC   LDA aECFD
        BEQ bE800
        DEC aECFD
        TXA 
        ADC fECDE
        TAX 
        TYA
        ADC aECDF
        JMP jE839

bE800   LDA aECFE
        BEQ bE814
        DEC aECFE
        TXA 
        ADC aECE0
        TAX 
        TYA 
        ADC aECE1
        JMP jE839

bE814   LDA aECFF
        BEQ bE828
        DEC aECFF
        TXA 
        ADC aECE2
        TAX
        TYA
        ADC aECE3
        JMP jE839

bE828   LDA aED00
        BEQ bE847
        DEC aED00
bE830   TXA 
        ADC aECE4
        TAX 
        TYA
        ADC aECE5
jE839   TAY
bE83A   STX $D407
        STY $D408
        STX aECFB
        STY aECFC
        RTS 

bE847   LDA aECEB
        AND #$81
        BEQ bE83A
        BPL bE856
        JSR sE0AC
        JMP jE7EB

bE856   JSR sE0B8
        JMP jE7EB

UpdateMusicChannel3 LDA chn3MusicFlag
        BEQ bE864
        DEC chn3Timer
        BEQ bE870
bE864   RTS

jE865   LDA #$03
jE867   CLC 
        ADC chn3Lo
        STA chn3Lo
        BCC bE870
        INC chn3Hi
bE870   LDY #$00
        LDA (chn3Lo),Y
        CMP #$C0
        BCC bE88B
        TAX
        LDA fED6E,X
        STA chn2Lo86
        LDA fED6F,X
        STA chn2Lo87
chn2Lo86   =*+$01
chn2Lo87   =*+$02
        JMP jE975

bE888   JMP jE959

bE88B   STA playRoutineTemp
        CMP #$60
        BCC bE893
        SBC #$60
bE893   CMP #$5F
        BEQ bE888
        ADC chn3Trans
        TAX 
        LDA chn3SoundFlag
        BEQ bE888
        LDA #$08
        STA $D412
        LDA aEC8C
        STA $D414
        LDA aEC8B
        STA $D413
        LDA aEC8A
        STA aED1F
        AND #$F7
        STA $D412
        LDA aEC89
        STA $D411
        LDA aEC88
        STA $D410
        LDY fED38,X
        LDA fED97,X
        STA aED1D
        STY aED1E
        STA $D40E
        STY $D40F
        LDA aEC83
        STA aED16
        BEQ bE922
        LDY aEC89
        STY aED1C
        LDX aEC88
        STX aED1B
        STX aED28
        STY aED29
        LDA aEC87
        STA aED1A
        LDA aEC86
        STA aED19
        LDA aEC85
        STA aED18
        LDA aEC84
        STA aED17
        LDA aEC82
        STA aED15
        LDY aEC81
        STY aED14
        LDX aEC80
        STX aED13
        STX aED2A
        STY aED2B
bE922   LDX aEC7F
        STX aED12
        BEQ bE94D
        LDY #$0C
bE92C   LDA fEC72,Y
        STA fED05,Y
        DEY 
        BPL bE92C
        TXA
        AND #$08
        BEQ bE94A
        LDA playRoutineTemp
        CMP #$60
        BCC bE943
        SBC #$60
        CLC 
bE943   ADC chn3Trans
        STA aED0F
        BNE bE94D
bE94A   JSR sE0DE
bE94D   LDX aEC8D
        LDY aEC8E
        STX aED20
        STY aED21
jE959   LDY #$01
        LDA (chn3Lo),Y
        LDX playRoutineTemp
        CPX #$60
        BCS bE967
        TAX
        LDA fECA6,X
bE967   STA chn3Timer
        LDA #$02
        CLC 
        ADC chn3Lo
        STA chn3Lo
        BCC bE974
        INC chn3Hi
bE974   RTS 

jE975   INC chn3StackPtr
        LDY chn3StackPtr
        CPY #$08
        BEQ bE98A
        LDX fEC8F,Y
        LDA fEC97,Y
        STX chn3Lo
        STA chn3Hi
        JMP bE870

bE98A   DEC chn3MusicFlag
        RTS 

        LDX chn3StackPtr
        CLC 
        LDA #$02
        ADC chn3Lo
        STA fEC8F,X
        LDA #$00
        ADC chn3Hi
        STA fEC97,X
        INY
        LDA (chn3Lo),Y
        STA fEC9F,X
        DEC chn3StackPtr
        LDA #$02
        JMP jE867

        LDX chn3StackPtr
        DEC fECA0,X
        BEQ bE9BF
        LDY fEC90,X
        LDA fEC98,X
        STY chn3Lo
        STA chn3Hi
        JMP bE870

bE9BF   INC chn3StackPtr
        LDA #$01
        JMP jE867

        INY
        LDA (chn3Lo),Y
        STA playRoutineLo
        INY
        LDA (chn3Lo),Y
        STA playRoutineHi
        LDY #$04
bE9D2   LDA (playRoutineLo),Y
        STA aEC8A,Y
        DEY 
        BPL bE9D2
        JMP jE865

        INY 
        LDA (chn3Lo),Y
        STA playRoutineLo
        INY
        LDA (chn3Lo),Y
        STA playRoutineHi
        LDY #$0D
bE9E9   LDA (playRoutineLo),Y
        STA fEC72,Y
        DEY 
        LDA (playRoutineLo),Y
        STA fEC72,Y
        DEY
        BPL bE9E9
        JMP jE865

        INY
        LDA (chn3Lo),Y
        STA playRoutineLo
        INY 
        LDA (chn3Lo),Y
        STA playRoutineHi
        LDY #$09
bEA06   LDA (playRoutineLo),Y
        STA fEC72,Y
        DEY 
        LDA (playRoutineLo),Y
        STA fEC72,Y
        DEY 
        BPL bEA06
        JMP jE865

        INY 
        LDA (chn3Lo),Y
        TAX 
        INY
        LDA (chn3Lo),Y
        STA playRoutineTemp
        INY 
        LDA (chn3Lo),Y
        STA playRoutineLo
        INY 
        LDA (chn3Lo),Y
        STA playRoutineHi
        LDY playRoutineTemp
bEA2C   LDA (playRoutineLo),Y
        STA fEC72,X
        DEX 
        DEY 
        BPL bEA2C
        LDA #$05
        JMP jE867

        INY 
        LDA (chn3Lo),Y
        STA chn3Trans
        INY 
        LDA (chn3Lo),Y
        TAX 
        INY 
        LDA (chn3Lo),Y
        STX chn3Lo
        STA chn3Hi
        JMP bE870

        INY
        LDA (chn3Lo),Y
        TAX
        INY 
        LDA (chn3Lo),Y
        STX chn3Lo
        STA chn3Hi
        JMP bE870

        LDY #$01
        LDX #$02
        LDA (chn3Lo),Y
        STA chn3Trans
        LDA #$04
bEA65   LDY chn3StackPtr
        CLC
        ADC chn3Lo
        STA fEC8F,Y
        LDA #$00
        ADC chn3Hi
        STA fEC97,Y
        DEC chn3StackPtr
        TXA 
        TAY
        LDA (chn3Lo),Y
        TAX 
        INY 
        LDA (chn3Lo),Y
        STX chn3Lo
        STA chn3Hi
        JMP bE870

        LDA #$03                
        LDX #$01
        BNE bEA65
        INY 
        LDA (chn3Lo),Y
        STA chn3Trans
        LDA #$02
        JMP jE867

        INY 
        LDA (chn3Lo),Y
        TAX 
        INY 
        LDA (chn3Lo),Y
        STA fEC72,X
        JMP jE865

        INY
        LDA (chn3Lo),Y
        TAX
        INY 
        LDA (chn3Lo),Y
        STA fED05,X
        JMP jE865

bEAAF   RTS 

UpdateSoundChannel3 LDX aED21
        BEQ bEAAF
        LDA aED1F
        AND #$08
        BEQ bEAD2
        LDA chn3Timer
        CMP aED20
        BCS bEAF4
        LDA #$00
        STA aED20
        LDA aED1F
        AND #$F6
        STA aED1F
        BNE bEAF1
bEAD2   LDA aED20
        BNE bEAE7
        DEC aED21
        BNE bEAF4
        LDX #$06
bEADE   STA $D40E,X
        DEX 
        BPL bEADE
        STX chn3SoundFlag
        RTS

bEAE7   DEC aED20
        BNE bEAF4
        LDA aED1F
        AND #$F6
bEAF1   STA $D412
bEAF4   LDA aED16
        BEQ bEB56
        LDA aED15
        BEQ bEB04
        DEC aED15
        JMP bEB56

bEB04   CLC 
        LDX aED28
        LDY aED29
        LDA aED2A
        BEQ bEB20
        TXA 
        ADC aED17
        TAX 
        TYA 
        ADC aED18
        TAY 
        DEC aED2A
        JMP jEB4A

bEB20   LDA aED2B
        BEQ bEB35
        TXA 
        ADC aED19
        TAX 
        TYA
        ADC aED1A
        TAY 
        DEC aED2B
        JMP jEB4A

bEB35   LDA aED16
        AND #$81
        BEQ jEB4A
        BPL bEB44
        JSR s3F8A
        JMP bEB04

bEB44   JSR s3F96
        JMP bEB04

jEB4A   STX aED28
        STY aED29
        STX $D410
        STY $D411
bEB56   LDA aED12
        BEQ bEB75
        AND #$08
        BNE bEB76
        LDX aED22
        LDY aED23
        CLC 
        LDA aED11
        BEQ bEB98
        DEC aED11
        LDA aED12
        AND #$02
        BNE bEBDC
bEB75   RTS 

bEB76   LDX aED11
        BPL bEB7E
        LDX aED10
bEB7E   LDA aED0F
        CLC 
        ADC fED05,X
        DEX 
        STX aED11
        TAY 
        LDX fED97,Y
        LDA fED38,Y
        STX $D40E
        STA $D40F
        RTS 

jEB97   CLC
bEB98   LDA aED24
        BEQ bEBAC
        DEC aED24
        TXA 
        ADC fED05
        TAX 
        TYA 
        ADC aED06
        JMP jEBE5

bEBAC   LDA aED25
        BEQ bEBC0
        DEC aED25
        TXA 
        ADC aED07
        TAX
        TYA 
        ADC aED08
        JMP jEBE5

bEBC0   LDA aED26
        BEQ bEBD4
        DEC aED26
        TXA 
        ADC $ED09
        TAX 
        TYA
        ADC aED0A
        JMP jEBE5

bEBD4   LDA aED27
        BEQ bEBF3
        DEC aED27
bEBDC   TXA 
        ADC aED0B
        TAX 
        TYA 
        ADC $ED0C
jEBE5   TAY 
bEBE6   STX $D40E
        STY $D40F
        STX aED22
        STY aED23
        RTS 

bEBF3   LDA aED12
        AND #$81
        BEQ bEBE6
        BPL bEC02
        JSR sE0DE
        JMP jEB97

bEC02   JSR sE0EA
        JMP jEB97

