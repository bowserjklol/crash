# make true if you want to build speedport/fritzbox images
ifeq (true,false)
# put this tree inside "userapps/opensource" directory
TOOLCHAIN=/opt/toolchains/uclibc-crosstools
CROSS_COMPILE = $(TOOLCHAIN)/bin/mips-linux-uclibc-
CXX=$(CROSS_COMPILE)c++
CFLAGS=-Wall -O2 -DEMBEDDED -ansi -I../openssl/include
INC=
LD=$(CROSS_COMPILE)c++
LIBS=../openssl/libssl.a ../openssl/libcrypto.a -lutil
STRIP=$(CROSS_COMPILE)strip
else

#SSL=/opt/ssl/openssl-1.1.1
INC=

ifeq ($(shell uname), Linux)
	LIBS+=-lssl -lcrypto -Wl,--rpath=$(SSL)/lib
	CFLAGS+=-DHAVE_UNIX98
else ifeq ($(shell uname), Solaris)
	LIBS+=-lssl -lcrypto -lsocket -lnsl
else ifeq ($(shell uname), Darwin)
	SSL=/usr/local/ssl
	LIBS+=-lssl -lcrypto
	CFLAGS+=-DHAVE_UNIX98
else
	LIBS+=-lssl -lcrypto -lutil
endif

endif

CXX=c++
INC+=-I$(SSL)/include
CFLAGS+=-Wall -O2 -std=c++11 -pedantic $(INC)
LIBS+=-L$(SSL)/lib
LD=c++
STRIP=strip

all: crashd crashc

clean:
	rm -rf *.o

keys:
	umask 066
	@echo "***** Generating Keys ****"
	@echo
	@echo "Whatever you enter for Country/Organization etc is not important (press enter)."
	@echo "Just the passphrase is important"
	@echo
	@echo "**************************"
	sleep 3
	openssl genrsa -out serverkey.priv 4096
	openssl req -new -x509 -nodes -sha1 -key serverkey.priv -out serverkey.pub
	openssl x509 -in serverkey.pub -pubkey -noout > HK_127.0.0.1
	openssl genrsa -out authkey.priv -aes256 4096
	openssl rsa -in authkey.priv -pubout -out authkey.pub
	@echo
	@echo
	@echo "Your serverkey is in serverkey.{priv,pub} and authentication (user-) key in"
	@echo "authkey.{priv,pub}. Copy authkey.pub to ~/.crash/authorized_keys on remote server"
	@echo "and use '-i authkey.priv' on the client to connect to it"
	@echo
	@echo "Your known-host key which belongs to serverkey.priv is in HK_127.0.0.1"
	@echo "and you can use it with '-K HK_127.0.0.1' on the client (taking 127.0.0.1 as example)"
	@echo
	@echo "For example you can start './crashd' as root on localhost and use"
	@echo "'./crashc -K ./HK_127.0.0.1 -H 127.0.0.1 -l user -i authkey.priv'"
	@echo "to login."
	@echo

crashc: net.o misc.o crashc.o config.o global.o
	$(LD) net.o misc.o crashc.o config.o pty.o global.o pty98.o $(LIBS) -o crashc
	$(STRIP) crashc

crashd: server.o session.o net.o misc.o crashd.o config.o pty.o pty98.o global.o log.o dh.o iobox.o
	$(LD) server.o session.o net.o misc.o crashd.o config.o pty.o pty98.o global.o log.o dh.o iobox.o $(LIBS) -o crashd
	$(STRIP) crashd

iobox.o: iobox.cc
	$(CXX) $(CFLAGS) -c iobox.cc

server.o: server.cc
	$(CXX) $(CFLAGS) -c server.cc

session.o: session.cc
	$(CXX) $(CFLAGS) -c session.cc

net.o: net.cc
	$(CXX) $(CFLAGS) -c net.cc

misc.o: misc.cc
	$(CXX) $(CFLAGS) -c misc.cc

config.o: config.cc
	$(CXX) $(CFLAGS) -c config.cc

pty.o: pty.cc
	$(CXX) $(CFLAGS) -c pty.cc

pty98.o: pty98.cc
	$(CXX) $(CFLAGS) -c pty98.cc

global.o: global.cc
	$(CXX) $(CFLAGS) -c global.cc

log.o: log.cc
	$(CXX) $(CFLAGS) -c log.cc

crashd.o: crashd.cc
	$(CXX) $(CFLAGS) -c crashd.cc

crashc.o: crashc.cc
	$(CXX) $(CFLAGS) -c crashc.cc

dh.o: dh.cc dh2048.cc
	$(CXX) $(CFLAGS) -c dh.cc

