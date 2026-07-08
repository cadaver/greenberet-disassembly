# Green Beret disassembly

Disassembly and source-level reconstruction of the C64 arcade game conversion "Green Beret."

Green Beret is copyright (C) Konami. C64 version developed and published by Ocean / Imagine. The disassembly in this repository is provided for educational purposes only.

## Disassembly process

The game binary was saved from the disk original using the VICE emulator, after the game had loaded and the intro picture and music had finished, upon which the game
decompresses the actual main code / data over the intro picture, occupying memory locations $03BD-$FFFF, and starts executing from the address $4000.

The binary was examined and source code generated using Regenerator ( https://csdb.dk/release/?id=247992 ), which allows marking sections as code and data, and setting label names.

Meanings of the code sections and routines, data and variables were found piece by piece starting from the player status (score, high score, lives, stage)
and assisted by playing the game in VICE and observing execution flow & variables being changed.

The Martin Galway playroutine variable naming was assisted by his music source code repository https://github.com/MartinGalway/C64_music

## Building

To produce a working .prg executable, 64TASS ( https://csdb.dk/release/?id=252813 ) and Pucrunch ( https://csdb.dk/release/?id=6089 ) or other suitable executable packer
are needed. Execute "make" to build.

## Theory of operation and memory layout

The game starts execution at $4000 (EntryPoint), which is also the game screen area. It sets CIA 1 Timer A to run at a fast rate and copies a routine into the stack which checks $dd0d
every frame, and locks up (JAM instruction) if the timer has not expired in the meanwhile. This is likely a freezer protection. The stack code is also obfuscated by
using illegal instructions. After this initialization, it jumps away from the screen area to continue initialization (InitVideo routine), which falls through to showing the title screen.

The game does not require the low memory $0000-$01FF to be initialized in any particular way to run correctly, rather it initializes all variables it needs.

The gameplay main loop starts from $06E0 (MainLoop), and branches into per-stage custom code if the end-of-stage fight is going on.

Updating the enemies and bullets, scrolling the screen and calling the playroutine's music part all happen in the main program.

Raster interrupts handle the scrolling / non-scrolling screen split, sprite multiplexing, updating the player character, and calling the playroutine's sound effect part.
The main program and interrupts communicate with the frameSyncFlag variable to signal that each part is ready.

All gameplay logic operates in screen coordinates and manipulates "virtual sprites" which act as source data to the sprite multiplexer. The virtual sprite indices are fixed, with the
first 2 used by the player, then the next 12 for enemy upper and lower bodies for a maximum of 6 enemies, then bullets (3 player and 3 enemy) and the weapon pickup. Enemies and bullets also index into additional
6-byte arrays for additional state information. The jet that appears after too much idle time, and the bomb it drops, are also "bullets" according to the sprite indices scheme,
and it does not appear if there aren't at least 2 free enemy bullets. When the screen scrolls, the virtual sprite coordinates are subtracted to make them scroll along with the stage graphics.

The rough memory layout is:

- $0200-$03BF Variables
- $03C0-$06DF Title screen and stage intermission screen data
- $06E0-$3FFF Main game code and data
- $4000-$7FFF Main graphics video bank
- $8000-$BFFF Stage data
- $C000-$DFFF Extra code and data, status panel screen (partial) at $C400 and extra charset data that is swapped in and out of the video bank
- $E000-$FFFF Music/sound player and final pieces of extra code/data

The source code is divided in files according to purpose, while keeping the memory order. greenberet.asm is the main source file that includes the others. The executable load address is
$03BD to initialize the high score counter with the traditionally seen value 0003560. The scores use BCD mode internally and are only 6 digits (3 bytes), the last digit is always 0.

The code will be commented and explained more as an ongoing process.

## Bugs

The original game has two bugs:

- If a grenade explodes a mine that is only half-visible on the screen, the game will lock up.
- After playing for a long time, the game starts to exhibit bugged behavior, such as explosions staying in place, or enemies running backwards.

There is a define in src/defines.s to enable a fix for the first bug. If GRENADE_HANG_FIX is set to nonzero, the code size stays the same, but the flow of the grenade's
"radius destroy" routine becomes different so that it no longer loops infinitely when encountering a half-visible mine.
