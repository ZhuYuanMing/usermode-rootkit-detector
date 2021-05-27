CC       = cc
CFLAGS	 = -DHAVE_LASTLOG_H
STATIC   = -static


SRCS   = checkdirs.c 

OBJS   = checkdirs.o 


all:
	@echo '*** stopping make sense ***'
	@exec make sense
sense: checkdirs
checkproc:   checkproc.c
	${CC} ${LDFLAGS} -o $@ checkproc.c
	@strip $@

chedirs:   checkdirs.c
	${CC} ${LDFLAGS} -o $@ checkdirs.c
	@strip $@


clean: 
	rm -f ${OBJS} core checkproc checkdirs
