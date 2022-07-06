PROG=windmaker-infiniterecorder

prefix = /usr/local
bindir = $(prefix)/bin
sharedir = $(prefix)/share
mandir = $(sharedir)/man
man1dir = $(mandir)/man1

all: build

build:
	( cp -R lib clean_lib )
	( find clean_lib -type f -exec sed  -i '/^\#.*$$/d' {} \; )
	( find clean_lib -type f -exec sed  -i '/source .*$$/d' {} \; )
	( perl -pe 's/source lib\/(.*)$$/`cat clean_lib\/$$1`/e'  src/windmaker-infiniterecorder > windmaker-infiniterecorder )
	( perl -pe 's/source lib\/(.*)$$/`cat clean_lib\/$$1`/e'  src/windmaker-infiniterecorder-video-manager > windmaker-infiniterecorder-video-manager )
	( chmod 755 windmaker-infiniterecorder )
	( chmod 755 windmaker-infiniterecorder-video-manager )
	( rm -rf clean_lib )

clean:
	( rm -f windmaker-infiniterecorder )
	( rm -f windmaker-infiniterecorder-video-manager )

install:
	install windmaker-infiniterecorder $(DESTDIR)$(bindir)
	install windmaker-infiniterecorder-video-manager $(DESTDIR)$(bindir)

uninstall:
	( rm $(DESTDIR)$(bindir)windmaker-infiniterecorder )
	( rm $(DESTDIR)$(bindir)windmaker-infiniterecorder-video-manager )

