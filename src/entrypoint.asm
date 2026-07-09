        ; Beginning of game execution. Copy a routine to stack (likely freezer protection-related) and jump to VIC-II
        ; initialization and the title screen.

        * = $4000

EntryPoint
        LDA #$00
        STA $DD05
        LDA #$02
        STA $DD04
        LDA #$7F
        STA $DD0D
        LDA #$C1
        STA $DD0E
        LDA $DD0D
        STA $DD0C
        LDX #$14
CopyStackCode
        LDA StackCode,X
        STA $0100,X
        DEX
        BPL CopyStackCode
        LDA #$00
        STA a3DFF
        STA a3DFE
        JMP InitVideo

StackCode .BYTE $AF,$0D,$DD ;LAX $DD0D
        .BYTE $4B,$08 ;ALR #$08
        BEQ StackCodeJam
        .BYTE $8F,$0C,$DD ;SAX $DD0C
        RTS
StackCodeJam .BYTE $02    ;JAM

