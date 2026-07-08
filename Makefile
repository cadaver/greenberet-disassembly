all: greenberet.prg

greenberet.prg: greenberet.asm defines.asm dogandtextdata.asm drawstageandmines.asm enemybulletcollision.asm \
	enemyscoring.asm enemyspecificcode.asm fighterjet.asm irqgameupdate.asm irqhandlerspritesort.asm mainloop.asm \
	musicdata.asm playerenemycollision.asm playerenemyupdate.asm playroutine.asm playroutinecalls.asm screendata.asm  \
	screenprinting.asm scrollandframesync.asm spawnenemies.asm spritemultiplexer.asm stagecompleterestart.asm \
	stagedata.asm stageendfights.asm statusdisplay.asm swapgraphics.asm textprinting.asm titleoutroscreens.asm \
	truckanimation.asm underiodata.asm videobank.asm weaponbulletupdate.asm weaponpickup.asm
	64tass -o greenberet.prg -l labels.txt greenberet.asm
	pucrunch -x16384 greenberet.prg greenberet.prg
                                                                                          