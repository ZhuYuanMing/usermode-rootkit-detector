CC       = gcc
CFLAGS	 = -DHAVE_LASTLOG_H
STATIC   = -static


SRCS   = checkdirs.c 

OBJS   = checkdirs 


all:
	${CC} ${CFLAGS} checkdirs.c -o ${OBJS}


clean: 
	rm -f ${OBJS} core 
