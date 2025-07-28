all: package

kakoune_version != git -C kakoune describe --tags HEAD | sed 's/^v//'
busybox_version != git -C busybox describe --tags HEAD | sed 's/_/./g'
archive_name = kakoune-$(kakoune_version)-on-busybox-$(busybox_version)

package: $(archive_name).tar.gz

$(archive_name).tar.gz: kak busybox
	$(MAKE) -C kakoune DESTDIR="$(PWD)/pkg" PREFIX="/" install
	$(MAKE) -C busybox CONFIG_PREFIX="$(PWD)/pkg" install
	cygcheck pkg/bin/kak pkg/bin/busybox \
		| awk '/\\bin\\cyg.*\.dll/ {dlls[$$1] = 1} END {for (dll in dlls) printf "%s\0", dll}' \
		| xargs -0 realpath --zero \
		| xargs -0 cp -t pkg/bin
	mv pkg/bin/kak pkg/bin/kak.exe
	mv pkg/bin/busybox pkg/bin/busybox.exe
	cp -t pkg kak.bat
	tar czf $(archive_name).tar.gz -C pkg .

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
