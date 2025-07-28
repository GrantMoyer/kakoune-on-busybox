all: package

package: kakoune-on-busybox.tar.gz

kakoune-on-busybox.tar.gz: kak busybox
	$(MAKE) -C kakoune DESTDIR="$(PWD)/pkg" PREFIX="/" install
	$(MAKE) -C busybox CONFIG_PREFIX="$(PWD)/pkg" install
	cygcheck pkg/bin/kak pkg/bin/busybox | awk '/\\bin\\cyg.*\.dll/ {print $1}' | xargs cp -t pkg/bin
	mv pkg/bin/kak pkg/bin/kak.exe
	mv pkg/bin/busybox pkg/bin/busybox.exe
	cp -t pkg kak.bat
	tar czf kakoune-on-busybox.tar.gz -C pkg .

kak:
	$(MAKE) -C kakoune

busybox: busybox/.config
	patch --directory=busybox --input=../busybox.patch --forward --strip=0 || :
	$(MAKE) -C busybox

busybox/.config: busybox_config
	cp busybox_config busybox/.config

clean:
	rm --recursive --force pkg
	$(MAKE) -C kakoune clean
	rm --force busybox/.config
	patch --directory=busybox --input=../busybox.patch --reverse --force --strip=0 || :
	$(MAKE) -C busybox clean

.PHONY: all busybox clean kak package
