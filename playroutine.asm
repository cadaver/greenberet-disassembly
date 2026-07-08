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

fEC08   .BYTE $1E,$00,$E2,$FF,$1E,$00,$11,$01,$04,$08,$04,$00,$19
fEC15   .BYTE $07
aEC16   .BYTE $05
aEC17   .BYTE $05
aEC18   .BYTE $19
fEC19   .BYTE $05
aEC1A   .BYTE $32
aEC1B   .BYTE $00
aEC1C   .BYTE $CE
aEC1D   .BYTE $FF
fEC1E   .BYTE $00
fEC1F   .BYTE $08
aEC20   .BYTE $41
aEC21   .BYTE $86
aEC22   .BYTE $FA
aEC23   .BYTE $41
aEC24   .BYTE $4B
fEC25   .BYTE $00
fEC26   .BYTE $00,$00,$00,$14,$11,$82,$5E
fEC2D   .BYTE $00
fEC2E   .BYTE $00,$00,$00,$F7,$F7,$F7,$F4
fEC35   .BYTE $00
fEC36   .BYTE $00,$00,$00,$00,$00,$01,$03
fEC3D   .BYTE $0F,$00,$F1,$FF,$0F,$00,$00,$00,$03,$06,$03,$00,$07
aEC4A   .BYTE $00
aEC4B   .BYTE $08
aEC4C   .BYTE $FF
aEC4D   .BYTE $03
aEC4E   .BYTE $00
aEC4F   .BYTE $40
aEC50   .BYTE $00
aEC51   .BYTE $FB
aEC52   .BYTE $FF
aEC53   .BYTE $00
aEC54   .BYTE $08
aEC55   .BYTE $49
aEC56   .BYTE $18
aEC57   .BYTE $77
aEC58   .BYTE $03
aEC59   .BYTE $1E
fEC5A   .BYTE $00
fEC5B   .BYTE $00,$00,$00,$A4,$96,$8F,$D3
fEC62   .BYTE $00
fEC63   .BYTE $00,$00,$00,$F8,$F8,$F8,$F0
fEC6A   .BYTE $00
fEC6B   .BYTE $00,$00,$00,$00,$00,$01,$00
fEC72   .BYTE $1E,$00,$E2,$FF,$1E,$00,$11,$01,$04,$08,$04,$00,$19
aEC7F   .BYTE $07
aEC80   .BYTE $05
aEC81   .BYTE $05
aEC82   .BYTE $19
aEC83   .BYTE $05
aEC84   .BYTE $32
aEC85   .BYTE $00
aEC86   .BYTE $CE
aEC87   .BYTE $FF
aEC88   .BYTE $00
aEC89   .BYTE $08
aEC8A   .BYTE $41
aEC8B   .BYTE $86
aEC8C   .BYTE $FA
aEC8D   .BYTE $41
aEC8E   .BYTE $4B
fEC8F   .BYTE $00
fEC90   .BYTE $00,$00,$C0,$BB,$89,$B3,$B0
fEC97   .BYTE $00
fEC98   .BYTE $00,$00,$F1,$F1,$F2,$F1,$F1
fEC9F   .BYTE $00
fECA0   .BYTE $00,$00,$00,$02,$00,$00
fECA6   .BYTE $03,$03,$06,$09,$0C,$0F,$12,$15,$18,$1B,$1E,$21,$24,$27,$2A,$2D
        .BYTE $30
fECB7   .BYTE $1E
fECB8   .BYTE $00
fECB9   .BYTE $E2
fECBA   .BYTE $FF
fECBB   .BYTE $1E
fECBC   .BYTE $00
aECBD   .BYTE $97
aECBE   .BYTE $FF
aECBF   .BYTE $04
aECC0   .BYTE $08
aECC1   .BYTE $04
aECC2   .BYTE $00
aECC3   .BYTE $FB
aECC4   .BYTE $07
aECC5   .BYTE $05
aECC6   .BYTE $05
aECC7   .BYTE $00
aECC8   .BYTE $05
aECC9   .BYTE $32
aECCA   .BYTE $00
aECCB   .BYTE $CE
aECCC   .BYTE $FF
aECCD   .BYTE $00
aECCE   .BYTE $08
aECCF   .BYTE $D2
aECD0   .BYTE $03
aECD1   .BYTE $41
aECD2   .BYTE $00
aECD3   .BYTE $46
aECD4   .BYTE $B9
aECD5   .BYTE $1C
aECD6   .BYTE $00
aECD7   .BYTE $03
aECD8   .BYTE $04
aECD9   .BYTE $00
aECDA   .BYTE $FA
aECDB   .BYTE $08
aECDC   .BYTE $00
aECDD   .BYTE $05
fECDE   .BYTE $0F
aECDF   .BYTE $00
aECE0   .BYTE $F1
aECE1   .BYTE $FF
aECE2   .BYTE $0F
aECE3   .BYTE $00
aECE4   .BYTE $00
aECE5   .BYTE $00
aECE6   .BYTE $03
aECE7   .BYTE $06
aECE8   .BYTE $03
aECE9   .BYTE $00
aECEA   .BYTE $00
aECEB   .BYTE $05
aECEC   .BYTE $08
aECED   .BYTE $FF
aECEE   .BYTE $00
aECEF   .BYTE $04
aECF0   .BYTE $40
aECF1   .BYTE $00
aECF2   .BYTE $FB
aECF3   .BYTE $FF
aECF4   .BYTE $00
aECF5   .BYTE $07
aECF6   .BYTE $8D
aECF7   .BYTE $1E
aECF8   .BYTE $40
aECF9   .BYTE $00
aECFA   .BYTE $00
aECFB   .BYTE $60
aECFC   .BYTE $1E
aECFD   .BYTE $00
aECFE   .BYTE $00
aECFF   .BYTE $03
aED00   .BYTE $00
aED01   .BYTE $33
aED02   .BYTE $08
aED03   .BYTE $00
aED04   .BYTE $D6
fED05   .BYTE $1E
aED06   .BYTE $00
aED07   .BYTE $E2
aED08   .BYTE $FF,$1E
aED0A   .BYTE $00
aED0B   .BYTE $97,$FF
aED0D   .BYTE $04
aED0E   .BYTE $08
aED0F   .BYTE $04
aED10   .BYTE $00
aED11   .BYTE $FB
aED12   .BYTE $07
aED13   .BYTE $05
aED14   .BYTE $05
aED15   .BYTE $00
aED16   .BYTE $05
aED17   .BYTE $32
aED18   .BYTE $00
aED19   .BYTE $CE
aED1A   .BYTE $FF
aED1B   .BYTE $00
aED1C   .BYTE $08
aED1D   .BYTE $0C
aED1E   .BYTE $04
aED1F   .BYTE $41
aED20   .BYTE $00
aED21   .BYTE $46
aED22   .BYTE $F3
aED23   .BYTE $1C
aED24   .BYTE $00
aED25   .BYTE $03
aED26   .BYTE $04
aED27   .BYTE $00
aED28   .BYTE $FA
aED29   .BYTE $08
aED2A   .BYTE $00
aED2B   .BYTE $05
fED2C   .BYTE $17,$3E,$65
fED2F   .BYTE $02,$09,$10
fED32   .BYTE $00,$35,$6A

dogBarkSoundTbl 
        .BYTE $01

fED36   .BYTE $02
fED37   .BYTE $00
fED38   .BYTE $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02
        .BYTE $02,$02,$03,$03,$03,$03,$03,$04,$04,$04
fED52   .BYTE $04
fED53   .BYTE $05,$05,$05,$06,$06,$06,$07,$07,$08,$08,$09,$09,$0A,$0A,$0B,$0C
        .BYTE $0C,$0D,$0E,$0F,$10,$11,$12,$13,$14,$15,$16
fED6E   .BYTE $18
fED6F   .BYTE $19,$1B,$1C,$1E,$20,$22,$24,$26,$28,$2B,$2D,$30,$33,$36,$39,$3D
        .BYTE $40,$44,$48,$4C,$51,$56,$5B,$60,$66,$6C,$73,$7A,$81,$89,$91,$99
        .BYTE $A3,$AC,$B7,$C1,$CD,$D9,$E6,$00
fED97   .BYTE $12,$23,$34,$46,$5A,$6E,$84,$9B,$B3,$CD,$E9,$06,$25,$45,$68,$8C
        .BYTE $B3,$DC,$08,$36,$67,$9B,$D2,$0C,$49,$8B,$D0,$19,$67,$B9,$10,$6C
        .BYTE $CE,$35,$A3,$17
aEDBB   .BYTE $93,$15,$9F,$3C,$CD,$72,$20,$D8,$9C,$6B,$46,$2F,$25,$2A,$3F,$64
        .BYTE $9A,$E3,$3F,$B1,$38,$D6,$8D,$5E,$4B,$55,$7E,$C8,$34,$C6,$7F,$61
        .BYTE $6F,$AC,$7E,$BC,$95,$A9,$FC,$A1,$69,$8C,$FE,$C2,$DF,$58,$34,$78
        .BYTE $2B
fEDEC   .BYTE $53,$F7,$1F,$D2,$19,$FC,$85,$BD,$B0,$00,$1C,$E2,$2C,$E3,$F4,$E2
        .BYTE $02,$E3,$E1,$E2,$3C,$E3,$34,$E2,$52,$E2,$BE,$E2,$A1,$E2,$84,$E2
        .BYTE $6D,$E2,$49,$E3,$32,$E3,$C9,$E5,$D9,$E6,$A1,$E6,$AF,$E6,$8E,$E6
        .BYTE $E9,$E6,$E1,$E5,$FF,$E5,$6B,$E6,$4E,$E6,$31,$E6,$1A,$E6,$F6,$E6
        .BYTE $DF,$E6,$75,$E9,$85,$EA,$4D,$EA,$5B,$EA,$3A,$EA,$95,$EA,$8D,$E9
        .BYTE $AB,$E9,$17,$EA,$FA,$E9,$DD,$E9,$C6,$E9,$A2,$EA,$8B,$EA,$FB,$F1
        .BYTE $09,$DD,$01,$02,$03,$04,$05,$06,$07,$08,$23,$09,$00,$0D,$0F,$FF
        .BYTE $00,$04,$64,$00,$CE,$FF,$00,$04,$41,$16,$67,$13,$06,$17,$08,$64
        .BYTE $00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$03,$85,$0F,$FF,$00
        .BYTE $05,$32,$00,$FB,$FF,$00,$08,$41,$90,$F0,$1E,$02,$E8,$03,$64,$00
        .BYTE $9C,$FF,$00,$00,$03,$00,$04,$04,$00,$00,$0A,$07,$05,$05,$05,$05
        .BYTE $05,$00,$FB,$FF,$00,$08,$43,$90,$F0,$1E,$02,$D0,$07,$48,$F4,$00
        .BYTE $00,$A0,$0F,$CE,$FF,$01,$06,$01,$FF,$04,$04,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$81,$00,$C8,$19,$19,$B8,$0B,$D0,$8A,$20,$4E
        .BYTE $C0,$63,$30,$75,$03,$03,$03,$03,$0C,$05,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$15,$11,$D8,$11,$14,$00,$00,$EC,$FA,$00,$00,$A4
        .BYTE $06,$F1,$FF,$01,$06,$01,$FF,$04,$04,$FF,$00,$00,$04,$28,$00,$00
        .BYTE $00,$00,$08,$43
aEF00   .BYTE $00,$C8,$14,$1E,$14,$05,$CE,$FF,$00,$00
aEF0A   .BYTE $00,$00,$00,$00,$FF,$00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$81,$A4,$AA,$46,$28,$5E,$1A,$2C,$01,$CE,$FF,$00
        .BYTE $00,$03,$00,$0A,$FF,$00,$00,$14,$07,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$81,$A4,$AA,$46,$28,$E8,$03,$C8,$00,$00,$00,$00,$00
        .BYTE $00,$00,$FF,$00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$81,$00,$F0,$09,$01,$DC,$05,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$81,$00,$D9,$02,$1C,$EC,$2C,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $81,$00,$D9,$02,$1C,$1C,$25,$32,$00,$CE,$FF,$9C,$FF,$64,$00,$02
        .BYTE $02,$02,$02,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$15
        .BYTE $00,$D9,$08,$0E,$E8,$FD,$92,$FF,$00,$00,$00,$00,$00,$00,$FF,$00
        .BYTE $00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$81,$00
        .BYTE $98,$08,$0E,$4C,$9A,$98,$3A,$68,$C5,$00,$00
fEFE5   .BYTE $00,$00,$01,$01,$00,$00,$0A,$05,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$15,$00,$D9,$08,$0E,$40,$9C,$EC,$FF,$00,$00,$00,$00,$00
        .BYTE $00,$FF,$00,$00,$00,$00,$04,$08,$FF,$00,$04,$00,$FF,$64,$00,$01
        .BYTE $00,$41,$11,$89,$0A,$14,$C4,$09,$CE,$FF,$00,$00,$00,$00,$00,$00
        .BYTE $FF,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $15,$33,$F9,$08,$14,$D0,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$15
        .BYTE $00,$D9,$08,$0E,$B8,$0B,$05,$0A,$0F,$14,$19,$1E,$23,$28,$2D,$32
        .BYTE $37,$3C,$41,$46,$4B,$50,$04,$08,$0C,$10,$14,$18,$1C,$20,$24,$28
        .BYTE $2C,$30,$34,$38,$3C,$40,$D0,$1C,$0E,$94,$F4
fF080   .BYTE $D4,$89,$F6,$C0,$C2,$7B,$F0,$C6,$04,$AD,$F0,$DA,$00,$32,$02,$34
        .BYTE $01,$35,$02,$35,$01,$35,$03,$34,$01,$35,$01,$34,$01,$C6,$04,$AD
        .BYTE $F0,$DA,$00,$32,$01,$37,$01,$3A,$01,$C8,$04,$D9,$F0,$2E,$02,$2E
        .BYTE $01,$2D,$06,$2E,$02,$2E,$01,$2D,$03,$C0,$C2,$7B,$F0,$C2,$AD,$F0
        .BYTE $2E,$02,$31,$01,$32,$02,$32,$01,$32,$03,$31,$01,$32,$01,$31,$01
        .BYTE $C2,$AD,$F0,$2E,$01,$32,$01,$37,$01,$CA,$1A,$77,$3A,$04,$C0,$1F
        .BYTE $02,$1F,$01,$26,$03,$1A,$02,$C0,$D0,$44,$0F,$B3,$F2,$C2,$7B,$F0
        .BYTE $C2,$DF,$F0,$1A,$01,$1F,$02,$1F,$01,$26,$03,$1F,$02,$21,$01,$22
        .BYTE $02,$22,$01,$22,$03,$21,$01,$22,$01,$21,$01,$C2,$DF,$F0,$1A,$01
        .BYTE $1F,$02,$1F,$01,$26,$02,$1A,$01,$1F,$02,$1D,$01,$C8,$E1,$D9,$F0
        .BYTE $1E,$00,$E2,$FF,$1E,$00,$2C,$01,$04,$08,$04,$00,$19,$07,$05,$05
        .BYTE $19,$05,$32,$00,$CE,$FF,$00,$08,$41,$A6,$F8,$5A,$0A,$D0,$1C,$1C
        .BYTE $20,$F1,$CC,$03,$6A,$5C,$CE,$C0,$D0,$1C,$1C,$20,$F1,$CA,$06,$2E
        .BYTE $CC,$03,$6D,$5C,$CE,$C0,$2D,$00,$D3,$FF,$14,$00,$EC,$FF,$05,$05
        .BYTE $05,$05,$50,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$21,$BB
        .BYTE $5A,$FF,$32,$D0,$1C,$1C,$56,$F1,$85,$0A,$BF,$05,$D8,$1B,$0A,$C4
        .BYTE $7A,$F1,$9C,$FF,$EE,$FB,$00,$00,$00,$00,$07,$01,$02,$00,$00,$85
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$81,$AA,$DA,$FF,$32,$D0
        .BYTE $1C,$1C,$82,$F1,$80,$0A,$BF,$05,$D8,$1B,$0A,$C4,$A6,$F1,$CC,$03
        .BYTE $C2,$7A,$F4,$BF,$3C,$CE,$C4,$82,$F2,$CC,$02,$DC,$5F,$04,$CC,$02
        .BYTE $DC,$5F,$02,$CE,$CE,$CC,$03,$DC,$5F,$04,$CE,$CC,$04,$DC,$5F,$01
        .BYTE $CE,$C0,$DC,$5F,$04,$CC,$06,$DC,$5F,$02,$CE,$DC,$5F,$04,$C2,$CB
        .BYTE $F1,$DC,$5F,$08,$C0,$CC,$02,$DC,$5F,$04,$DC,$5F,$0C,$CE,$CC,$10
        .BYTE $DC,$5F,$01,$CE,$DC,$5F,$04,$DC,$5F,$0C,$C0,$A5,$F8,$25,$F9,$25
        .BYTE $FA,$F0,$75,$A9,$00,$8D,$C4,$EC,$8D,$EB,$EC,$8D,$12,$ED,$8D,$C8
        .BYTE $EC,$8D,$EF,$EC,$8D,$16,$ED,$A2,$10,$A0,$27,$8E,$00,$D4,$8C,$01
        .BYTE $D4,$A2,$88,$A0,$13,$8E,$07,$D4,$8C,$08,$D4,$A2,$E8,$A0,$03,$8E
        .BYTE $0E,$D4,$8C,$0F,$D4,$8D,$05,$D4,$A9,$03,$8D,$0C,$D4,$8D,$13,$D4
        .BYTE $8D,$D2,$EC,$8D,$F9,$EC,$8D,$20,$ED,$A9,$86,$8D,$06,$D4,$A2,$C4     
        .BYTE $8D,$0D,$D4,$CA,$8D,$14,$D4,$A2,$11,$8E,$12,$D4,$8E,$0B,$D4,$8E
        .BYTE $1F,$ED,$8E,$F8,$EC,$A2,$81,$8E,$04,$D4,$8E,$D1,$EC,$A9,$08,$8D
        .BYTE $D3,$EC,$8D,$FA,$EC,$8D,$21,$ED,$A9,$01,$4C,$67,$E8,$C2,$7A,$F4
        .BYTE $BF,$3C,$CC,$02,$CC,$03,$C2,$B9,$F1,$CE,$C2,$D2,$F1,$CE,$C2,$B9
        .BYTE $F1,$C2,$B9,$F1,$C2,$E5,$F1,$C4,$82,$F2,$C2,$C3,$F2,$9E,$06,$9A
        .BYTE $06,$99,$06,$97,$06,$95,$06,$97,$06,$95,$06,$94,$06,$D4,$89,$F6
        .BYTE $92,$01,$C0,$06,$0C,$12,$18,$1E,$24,$2A,$30,$36,$3C,$42,$48,$4E
        .BYTE $54,$5A,$60,$D0,$1C,$0E,$94,$F4,$CA,$18,$41,$CA,$1B,$19,$C0,$C2
        .BYTE $C3,$F2,$92,$06,$8E,$06,$8D,$06,$8B,$06,$89,$06,$8B,$06,$89,$06
        .BYTE $88,$06,$C8,$F7,$AD,$F2,$C2,$C3,$F2,$81,$06,$7F,$06,$7D,$06,$7C
        .BYTE $06,$81,$06,$82,$06,$81,$06,$7F,$06,$C8,$EB,$AD,$F2,$C2,$7B,$F0
        .BYTE $35,$09,$38,$02,$35,$01,$3C,$09,$38,$02,$35,$01,$3F,$03,$3E,$06
        .BYTE $3A,$02,$35,$01,$3A,$06,$3A,$03,$3C,$03,$3D,$06,$38,$03,$35,$03
        .BYTE $3F,$02,$3A,$01,$37,$03,$35,$01,$33,$01,$2E,$01,$2B,$01,$2E,$01
        .BYTE $33,$01,$35,$01,$30,$01,$2E,$01,$2D,$08,$C0,$C2,$7B,$F0,$30,$09
        .BYTE $35,$02,$30,$01,$35,$09,$35,$02,$30,$01,$3A,$03,$3A,$06,$35,$02
        .BYTE $2E,$01,$35,$06,$35,$03,$37,$03,$38,$06,$35,$03,$31,$03,$C8,$0C
        .BYTE $20,$F3,$22,$03,$CC,$03,$22,$01,$CE,$22,$03,$C0,$D0,$44,$0F,$B3
        .BYTE $F2,$D0,$1C,$1C,$E3,$F3,$CC,$02,$1D,$03,$1D,$01,$1D,$01,$1D,$01
        .BYTE $1D,$03,$1D,$03,$CE,$C2,$62,$F3,$22,$03,$C2,$62,$F3,$24,$03,$25
        .BYTE $03,$CC,$03,$25,$01,$CE,$25,$03,$25,$03,$CC,$04,$27,$03,$CE,$CA
        .BYTE $1B,$32,$1D,$01,$C0,$5F,$02,$D0,$1C,$1C,$E3,$F3,$CA,$1B,$28,$38
        .BYTE $04,$35,$02,$31,$06,$35,$06,$38,$06,$3D,$0C,$41,$04,$3F,$02,$3D
        .BYTE $06,$35,$06,$37,$06,$38,$0C,$38,$06,$41,$09,$3F,$03,$3D,$06,$3C
        .BYTE $0C,$3A,$04,$3C,$02,$3D,$06,$3D,$06,$38,$06,$35,$06,$CA,$1B,$14
        .BYTE $31,$01,$C0,$0F,$00,$F1,$FF,$0F,$00,$00,$00,$03,$06,$03,$00,$07
        .BYTE $05,$08,$FF,$03,$04,$40,$00,$FB,$FF,$00,$07,$41,$18,$79,$08,$1E
        .BYTE $D0,$44,$0F,$6B,$F0,$D0,$1C,$1C,$E3,$F3,$CA,$1B,$1E,$2C,$04,$29
        .BYTE $02,$25,$06,$25,$06,$24,$06,$22,$0C,$21,$06,$22,$06,$29,$06,$27
        .BYTE $06,$20,$0A,$1E,$02,$1D,$04,$1B,$02,$19,$0A,$1B,$02,$1D,$04,$1E
        .BYTE $02,$20,$0C,$22,$04,$24,$02,$CA,$1B,$28,$C8,$F4,$D5,$F3,$1E,$00
        .BYTE $E2,$FF,$1E,$00,$11,$01,$04,$08,$04,$00,$19,$07,$05,$05,$19,$05
        .BYTE $32,$00,$CE,$FF,$00,$08,$41
aF457   .BYTE $86,$FA,$41,$4B,$C2,$65,$F4,$BF,$3C,$C2,$65,$F4,$BF,$3C,$BF,$01
        .BYTE $D0,$1C,$1C,$3E,$F4,$BF,$01,$76,$42,$D8,$0C,$FF,$D8,$06,$97,$D8
        .BYTE $07,$FF,$C0,$BF,$01,$D0,$1C,$1C,$3E,$F4,$D0,$44,$0F,$C0,$F6,$BF
        .BYTE $01,$77,$42,$D8,$0C,$FF,$D8,$06,$97,$D8,$07,$FF,$C0,$08,$FF,$03
        .BYTE $04,$40,$00,$FB,$FF,$00,$07,$49,$18,$79,$03,$1E,$C2,$7B,$F0,$33
        .BYTE $04,$33,$04,$3A,$06,$35,$01,$37,$01,$38,$02,$37,$02,$35,$02,$33
        .BYTE $02,$35,$04,$2E,$04,$30,$04,$30,$03,$2C,$01,$38,$02,$37,$02,$35
        .BYTE $02,$33,$02,$3A,$08,$35,$04,$32,$03,$32,$01,$2C,$02,$30,$02,$33
        .BYTE $02,$30,$02,$2E,$02,$32,$02,$35,$02,$32,$02,$33,$08,$C0,$C2,$C3
        .BYTE $F2,$D4,$89,$F6,$33,$04,$33,$04,$3A,$06,$38,$01,$3A,$01,$3C,$02
        .BYTE $37,$02,$35,$02,$33,$02,$35,$04,$2E,$04,$30,$04,$30,$03,$2C,$01
        .BYTE $38,$02,$37,$02,$35,$02,$33,$02,$35,$08,$35,$04,$32,$03,$32,$01
        .BYTE $2C,$01,$30,$01,$33,$01,$38,$01,$3C,$01,$38,$01,$33,$01,$30,$01
        .BYTE $2E,$01,$32,$01,$35,$01,$3A,$01,$3E,$01,$3A,$01,$35,$01,$32,$01
        .BYTE $CA,$1A,$7A,$CA,$1B,$0F,$37,$01,$C0,$D0,$44,$0F,$6B,$F0,$D0,$1C
        .BYTE $1C,$E3,$F3,$27,$04,$22,$04,$27,$04,$22,$04,$24,$02,$22,$02,$20
        .BYTE $02,$1F,$02,$22,$02,$24,$02,$22,$04,$24,$04,$20,$04,$24,$04,$20
        .BYTE $04,$22,$04,$24,$04,$22,$04,$1F,$04,$CA,$0D,$00,$20,$08,$22,$08
        .BYTE $1F,$01,$C0,$33,$02,$33,$01,$38,$03,$33,$03,$3A,$03,$33,$01,$37
        .BYTE $01,$3A,$01,$3F,$02,$3C,$01,$38,$05,$DA,$00,$38,$01,$3C,$02,$38
        .BYTE $01,$35,$03,$C0,$C2,$7B,$F0,$C2,$7A,$F5,$3D,$06,$3A,$02,$37,$01
        .BYTE $38,$08,$C0,$C2,$7B,$F0,$C6,$0C,$7A,$F5,$3A,$06,$37,$02,$33,$01
        .BYTE $30,$08,$C0,$D0,$44,$0F,$B3,$F2,$D0,$1C,$1C,$E3,$F3,$5F,$03,$20
        .BYTE $03,$20,$03,$1B,$03,$1B,$03,$CC,$03,$20,$03,$CE,$1B,$03,$19,$03
        .BYTE $19,$03,$1B,$03,$1B,$03,$20,$03,$1B,$03,$20,$01,$C0,$BF,$0C,$C2
        .BYTE $7B,$F0,$36,$02,$36,$01,$3B,$04,$33,$01,$36,$01,$3F,$01,$3B,$01
        .BYTE $3F,$01,$42,$03,$3F,$03
fF5FD   .BYTE $3F,$02,$3F,$01,$40,$03,$3B,$02,$3B,$01,$40,$01,$3F,$01,$3D,$01
        .BYTE $3B,$03,$3A,$03,$36,$01,$36,$01,$36,$01,$3B,$03,$36,$02,$3B,$01
        .BYTE $3F,$01,$3D,$01,$3B,$01,$42,$03,$3F,$03,$40,$02,$40,$01,$42,$03
        .BYTE $3A,$02,$3D,$01,$42,$01,$42,$01,$42,$01,$3B,$06,$C0,$23,$03,$CC
        .BYTE $03,$23,$01,$CE,$C0,$D0,$44,$0F,$B3,$F2,$D0,$1C,$1C,$E3,$F3,$5F
        .BYTE $03,$C2,$3A,$F6,$23,$02,$23,$01,$23,$03,$23,$03,$20,$02,$20,$01
        .BYTE $1C,$03,$1C,$02,$1C,$01,$1D,$02,$1D,$01,$1E,$02,$19,$01,$1E,$03
        .BYTE $22,$03,$C2,$3A,$F6,$CC,$03,$23,$03,$CE,$1C,$03,$1E,$03,$1E,$02
        .BYTE $CC,$04,$1E,$01,$CE,$23,$02,$1E,$01,$23,$01,$C0,$0F,$00,$F1,$FF
        .BYTE $0F,$00,$00,$00,$03,$06,$03,$00,$07,$05,$06,$FF,$01,$04,$64,$00
        .BYTE $CE,$FF,$00,$06,$41,$06,$D7,$0A,$0A,$00,$08,$05,$0C,$00,$07,$04
        .BYTE $0C,$00,$08,$03,$0C,$F6,$FF,$00,$00,$00,$00,$00,$00,$09,$00,$00
        .BYTE $00,$03,$04,$03,$06,$09,$0C,$0F,$12,$15,$18,$1B,$1E,$21,$24,$27
        .BYTE $2A,$2D,$30,$CA,$1A,$F9,$00,$04,$CA,$1A,$B9,$00,$02,$00,$02,$0C        
        .BYTE $02,$00,$04,$00,$02,$C0,$C6,$22,$0F,$F7,$5F,$01,$C6,$26,$0F,$F7                  
        .BYTE $5F,$01,$C6,$20,$0F,$F7,$5F,$01,$C6
aF6F6   .BYTE $27,$0F,$F7,$5F,$01,$C6,$22
fF6FD   .BYTE $0F,$F7,$5F,$01,$C6,$26
fF703   .BYTE $0F,$F7,$5F,$01,$C6,$20,$0F,$F7,$DA,$27,$5F,$01,$CC,$03,$C2,$D0
        .BYTE $F6,$CE,$CA,$1A,$F9,$00,$04,$CA,$1A,$B9,$00,$02,$00,$02,$CA,$1A
        .BYTE $F9,$0C,$02,$CA,$1A,$B9,$00,$02,$CA,$1A,$F9,$0A,$02,$0C,$01,$C0
        .BYTE $5F,$01,$C4,$0F,$F7,$D0,$1C,$1C,$A3,$3F,$D2,$A6,$F6,$5F,$04,$CC
        .BYTE $02,$C6,$37,$E4,$FA,$C2,$E4,$FA,$C6,$32,$E4,$FA,$C2,$E4,$FA,$CE
        .BYTE $D2,$AA,$F6,$CC,$02,$C6,$32,$E4,$FA,$C2,$E4,$FA,$D2,$A6,$F6,$CE
        .BYTE $CA,$0D,$00,$BF,$01,$CC,$03,$C6,$1F,$0F,$F7,$C2,$33,$F7,$C6,$1D
        .BYTE $33,$F7,$5F,$01,$C6,$1E,$D0,$F6,$C2,$D0,$F6,$C6,$1A,$D0,$F6,$C2
        .BYTE $15,$F7,$5F,$01,$CE,$C6,$1F,$0F,$F7,$C2,$33,$F7,$5F,$01,$C2,$FB
        .BYTE $F6,$D0,$1C,$0E,$16,$F8,$5F,$01,$C2,$E3,$F6,$5F,$01,$C2,$E3,$F6
        .BYTE $DA,$00,$CA,$1A,$AD,$CA,$1B,$32,$D4,$D8,$3F,$BF,$04,$82,$BD,$CC
        .BYTE $08,$D8,$1C,$FF,$BF,$C0,$CE,$BF,$B7,$C4,$38,$F7,$09,$00,$01,$02
        .BYTE $03,$04,$05,$06,$07,$08,$00,$09,$00,$0D,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$08,$41,$03,$78,$05,$12,$32,$00,$CE,$FF,$32,$00,$20
        .BYTE $00,$03,$06,$03,$00,$90,$07,$30,$30,$00,$05,$1E,$00,$E2,$FF,$20
        .BYTE $08,$41,$DD,$FD,$FF,$FF,$28,$00,$D8,$FF,$28,$00
fF7FF   .BYTE $00
fF800   .BYTE $00,$03,$06,$03,$00,$14,$07,$50,$50,$09,$05,$14,$00,$EC,$FF,$80
        .BYTE $08,$49,$DD,$DB,$1E,$C8,$0A,$FF,$00,$05,$C8,$00,$EC,$FF,$00,$04
        .BYTE $41,$00,$D9,$05,$FF,$CA,$06,$33,$8E,$C0,$CA,$06,$23,$8D,$C0,$CA
        .BYTE $06,$20,$86,$60,$CA,$06,$1B,$CA,$1B,$14,$30,$10,$CA,$06,$00,$90
        .BYTE $2F,$CA,$06,$29,$CA,$1B,$1E,$BF,$01,$86,$C0,$C0,$D2,$E6,$3F,$C6
        .BYTE $35,$66,$F8,$D2,$A6,$F6,$C6,$39,$66,$F8,$D2,$AA,$F6,$C6,$38,$66
        .BYTE $F8,$D2,$AE,$F6,$DA,$37,$CA,$1A,$F9,$00,$02,$CA,$1A,$B9,$CC,$03
        .BYTE $00,$02,$CE,$00,$04,$00,$02,$00,$04,$CC,$03,$00,$02,$CE,$CC,$04
        .BYTE $00,$01,$CE,$00,$04,$CA,$1A,$F9,$00,$04,$CA,$1A,$B9,$CC,$05,$00
        .BYTE $02,$CE,$00,$04,$CC,$03,$00,$02,$CE,$00,$04,$00,$01,$00,$01,$5F
        .BYTE $02,$C0,$CC,$03,$28,$08,$32,$08,$CE,$C0,$C2,$A2,$F8,$28,$06,$28
        .BYTE $02,$32,$04,$28,$04,$C2,$A2,$F8,$32,$02,$32,$02,$32,$04,$CC,$04
        .BYTE $32,$02,$CE,$C0,$CC,$03,$28,$10,$CE,$28,$08,$32,$08,$C0,$CC,$03
        .BYTE $28,$10,$CE,$32,$04,$32,$06,$32,$06,$C0,$D0,$1C,$1C,$2C,$FA,$13
        .BYTE $02,$16,$02,$78,$AE,$CA,$06,$06,$CA,$07,$00,$CA,$0D,$07,$75,$0B
        .BYTE $D8,$06,$D2,$D8,$07,$03,$BF,$07,$D4,$B2,$F6,$CA,$1B,$0C,$CA,$1C
        .BYTE $02,$BF,$01,$73,$B4,$D4,$2C,$FA,$CA,$1B,$FF,$CA,$1C,$14,$13,$02
        .BYTE $16,$02,$78,$60,$CA,$0D,$07,$21,$10,$CA,$0D,$05,$21,$10,$CA,$1B
        .BYTE $0C,$CA,$1C,$02,$76,$B4,$CA,$1B,$FF,$CA,$1C,$14,$2A,$02,$28,$02
        .BYTE $86,$60,$21,$10,$7E,$2F,$CA,$1B,$0C,$CA,$1C,$02,$BF,$01,$7F,$2F
        .BYTE $D0,$1C,$1C,$DC,$F7,$BF,$01,$62,$8F,$D8,$1B,$FF,$D8,$1D,$3F,$D8
        .BYTE $1E,$13,$BF,$00,$BF,$E1,$D8,$1C,$FF,$D0,$1C,$1C,$F9,$F7,$CA,$10
        .BYTE $28,$BF,$F0,$5F,$08,$8B,$D8,$C2,$25,$F8,$C2,$25,$F8,$BF,$60,$D0
        .BYTE $1C,$0E,$16,$F8,$CA,$0D,$00,$1F,$04,$2B,$02,$2B,$04,$1F,$04,$1F
        .BYTE $04,$2B,$04,$1F,$02,$2A,$02,$2B,$02,$2C,$02,$2D,$01,$D4,$A3,$3F
        .BYTE $D6,$BB,$3F,$CA,$11,$00,$5F,$01,$C2,$4C,$F8,$C2,$4C,$F8,$5F,$02
        .BYTE $D0,$1C,$1C,$49,$FA,$C6,$00,$3B,$FB,$BF,$42,$3F,$0C,$D8,$06,$CF
        .BYTE $D8,$07,$FF,$D8,$0C,$0C,$D8,$0D,$07,$5F,$04,$BF,$C0,$D4,$A3,$3F
        .BYTE $D6,$BB,$3F,$CA,$11,$00,$CA,$17,$04,$C2,$53,$F8,$D0,$1C,$1C,$BF
        .BYTE $F7,$CC,$03,$C6,$00,$AA,$F8,$CE,$C2,$C4,$F8,$C2,$CE,$F8,$C2,$C4
        .BYTE $F8,$32,$06,$32,$04,$28,$04,$32,$04,$2F,$06,$2F,$04,$2F,$04,$32
        .BYTE $06,$32,$04,$28,$04,$32,$04,$2B,$06,$2B,$04,$2B,$04,$C2,$C4,$F8
        .BYTE $C2,$CE,$F8,$C2,$C4,$F8,$32,$05,$32,$02,$32,$05,$32,$04,$2F,$04
        .BYTE $32,$02,$32,$02,$2F,$02,$2F,$02,$32,$02,$2F,$02,$28,$04,$28,$06
        .BYTE $28,$06,$CC,$04,$28,$02,$CE,$92,$0D,$C4,$DA,$F8,$1E,$00,$E2,$FF
        .BYTE $1E,$00,$0B,$00,$03,$06,$03,$00,$0B,$05,$0A,$0A,$05,$05,$0F,$00
        .BYTE $F6,$FF,$00,$07,$41,$03,$C9,$FF,$14,$46,$00,$BA,$FF,$46,$00,$A6
        .BYTE $FF,$03,$06,$03,$00,$14,$05,$0B,$FF,$01,$05,$C8,$00,$FB,$FF,$00
        .BYTE $00,$41,$09,$EB,$78,$64,$49,$09,$E7,$08,$0A,$EC,$FF,$00,$00,$00
        .BYTE $00,$00,$00,$09,$00,$00,$00,$03,$04,$14,$00,$EC,$FF,$14,$00,$64
        .BYTE $FE,$03,$06,$03,$00,$97,$07,$30,$30,$00,$05,$1E,$00,$E2,$FF,$20
        .BYTE $08,$41,$DD,$FD,$FF,$FF,$5F,$01,$CA,$06,$29,$8B,$BD,$CA,$06,$33
        .BYTE $89,$C0,$CA,$06,$27,$8A,$60,$CA,$06,$0F
fFAAA   .BYTE $CA,$1B,$14,$2D,$10,$CA,$06,$00,$8D,$2F,$CA,$06,$29,$CA,$1B,$1E
        .BYTE $BF,$01,$8B,$C0
fFABE   .BYTE $C0,$D2,$E6,$3F,$C6,$35,$E4,$FA,$C2,$E4,$FA,$D2,$A6,$F6,$C6,$39
        .BYTE $E4,$FA,$C2,$E4,$FA,$D2,$AA,$F6,$C6,$38,$E4,$FA,$C2,$E4,$FA,$D2
        .BYTE $AE,$F6,$C6,$37,$E4,$FA,$CA,$1A,$E9,$00,$02,$CA
fFAEA   .BYTE $1A,$B9,$CC,$04,$00,$02,$CE,$00,$04,$00,$02,$CA,$1A,$E9,$00,$04
        .BYTE $CA,$1A,$B9,$00,$04,$00,$02,$00,$02,$00,$04,$C0,$BF,$01,$9A,$30
        .BYTE $3E,$10,$41,$10,$46,$10,$A5,$3C,$41,$04,$3E,$04,$3A,$04,$99,$60
        .BYTE $38,$08,$3C,$08,$3F,$08,$3C,$08,$44,$10,$A4,$10,$A6,$10,$A8,$10
        .BYTE $A3,$3C,$41,$04,$3F,$04,$3E,$04,$3C,$0C,$3E,$02,$3C,$02,$3A,$02
        .BYTE $C0,$A1,$60,$46,$08,$41,$08,$3F,$08,$CA,$0C,$24,$3E,$04,$D8,$0D
        .BYTE $07,$5F,$04,$D8,$06,$5A,$D8,$07,$00,$CA,$0C,$14,$CA,$0D,$05,$BF
        .BYTE $54,$9E,$04,$9F,$04,$9E,$04,$9C,$60,$D6,$66,$FA,$98,$10,$93,$10
        .BYTE $98,$10,$9C,$10,$9F,$10,$A3,$10,$44,$10,$A8,$10,$A6,$10,$A4,$10
        .BYTE $D6,$61,$FA,$A8,$48,$D8,$06,$B8,$D8,$07,$FF,$D8,$0C,$18,$D8,$0D
        .BYTE $07,$C0,$5F,$08,$32,$10,$32,$10,$32,$0E,$28,$06,$28,$04,$C0,$5F
        .BYTE $08,$32,$10,$32,$10,$32,$0A,$32,$06,$32,$04,$32,$04,$C0,$D0,$44
        .BYTE $0F,$C0,$F6,$D0,$1C,$1C,$2C,$FA,$1F,$02,$22,$02,$84,$AE,$CA,$0D
        .BYTE $07,$21,$05,$D4,$6B,$FA,$CA,$1B,$0C,$CA,$1C,$02,$5F,$01,$7F,$B4
        .BYTE $D4,$2C,$FA,$CA,$1B,$FF,$CA,$1C,$14,$1F,$02,$22,$02,$84,$60,$CA
        .BYTE $06,$16,$CA,$0D,$07,$2D,$10,$CA,$0D,$05,$2D,$10,$CA,$1B,$0C,$CA
        .BYTE $1C,$02,$82,$B4,$CA,$1B,$FF,$CA,$1C,$14,$2D,$02,$2B,$02,$8A,$60
        .BYTE $26
sFBFB   .BYTE $10,$84,$30,$CA,$1B,$0C,$CA,$1C,$02,$82,$30,$D0,$1C,$1C,$79,$FA
        .BYTE $BE,$01,$D8,$1D,$FC,$D8,$1E,$F2,$BF,$8F,$D8,$0D,$05,$D8,$1B,$FF
        .BYTE $BF,$00,$BF,$E0,$D8,$1C,$FF,$D0,$1C,$1C,$F9,$F7,$CA,$0C,$0F,$BF
        .BYTE $F0,$5F,$08,$8E,$D8,$C2,$96,$FA,$C2,$96,$FA,$D0,$1C,$1C,$BF,$F7
        .BYTE $BF,$60,$CC,$04,$28,$02,$CE,$32,$02,$28
aFC45   .BYTE $01,$28
sFC47   .BYTE $01,$28,$02,$28,$02,$CC,$02,$32,$04,$32,$02,$CE,$32,$04,$D0,$1C
sFC57   .BYTE $1C,$49,$FA,$C2,$06,$FB,$5F,$0E,$C2,$06,$FB,$5F,$08,$3C,$02,$3E
        .BYTE $02,$3F,$02,$C2,$3B,$FB,$BF,$48,$43,$0C,$D8,$06,$88,$D8,$07,$FF
        .BYTE $D8,$0C,$0C,$D8,$0D,$07,$D0,$1C,$1C,$A3,$3F,$BF,$0B,$C2,$BF,$FA
        .BYTE $C2,$BF,$FA,$D0,$1C,$0E
aFC8D   .BYTE $16,$F8,$CA,$1A,$AD,$CA,$1B,$32,$D4,$D8,$3F,$DA,$00,$86,$C0,$D8
        .BYTE $1C,$FF,$D0,$1C,$1C,$BF,$F7,$BF,$C0,$C2,$8C,$FB,$C2,$99,$FB
aFCAC   .BYTE $C2,$8C,$FB,$5F,$02,$32,$06,$32,$04,$32,$04,$2F,$06,$2F,$04,$28
        .BYTE $04,$2F,$04,$32,$06,$32,$04,$32,$04,$2B,$06,$2B,$04,$28,$04,$2B
        .BYTE $02,$C2,$8C,$FB,$C2,$99,$FB,$C2,$8C,$FB,$5F,$04,$32,$02,$32,$02
        .BYTE $32,$02,$32,$04,$32,$04,$2F,$03,$2F,$02,$2F,$02,$2F,$02,$2F,$02
        .BYTE $32,$02,$2F,$03,$28,$04,$28,$08,$28,$03,$28,$02,$28,$02,$28,$02
aFCFC   .BYTE $88,$10,$C4,$AD,$FB
