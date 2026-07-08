all: greenberet.prg

greenberet.prg: greenberet.asm defines.asm maincode.asm videobank.asm stagedata.asm extracodedata.asm playroutine.asm finalcodedata.asm
	64tass -o greenberet.prg -l labels.txt greenberet.asm
	pucrunch -x16384 greenberet.prg greenberet.prg
