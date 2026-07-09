all: greenberet.prg

greenberet.prg: greenberet.asm \
	data/dogandtextdata.asm data/musicdata.asm data/screendata.asm data/stagedata.asm data/underiodata.asm data/videobankdata.asm \
	src/defines.asm src/drawstageandmines.asm src/enemybulletcollision.asm src/enemyremoveandclimb.asm src/enemyscoring.asm \
	src/enemyspecificcode.asm src/entrypoint.asm src/fighterjet.asm src/irqgameupdate.asm src/irqhandlerspritesort.asm \
	src/mainloop.asm src/playerenemycollision.asm src/playerenemyupdate.asm src/playroutine.asm src/playroutinecalls.asm \
	src/screenprinting.asm src/scrollandframesync.asm src/spawnenemies.asm src/spritemultiplexer.asm src/stagecompleterestart.asm \
	src/stageendfights.asm src/statusdisplay.asm src/swapgraphics.asm src/textprinting.asm src/titleoutroscreens.asm \
	src/truckanimation.asm src/weaponbulletupdate.asm src/weaponpickup.asm
	64tass -o greenberet.prg -l labels.txt greenberet.asm
	pucrunch -x16384 greenberet.prg greenberet.prg
