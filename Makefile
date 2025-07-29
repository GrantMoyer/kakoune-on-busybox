all: package

kakoune_version != git -C kakoune describe --tags HEAD | sed 's/^v//'
busybox_version != git -C busybox describe --tags HEAD | sed 's/_/./g'
archive_name = kakoune-$(kakoune_version)-on-busybox-$(busybox_version)

package: $(archive_name).tar.gz

$(archive_name).tar.gz: kak busybox
	mkdir -p pkg/bin
	$(MAKE) -C kakoune DESTDIR="$(PWD)/pkg" PREFIX="/usr" install
	mv pkg/usr/bin/kak pkg/bin/kak.exe
	cp -t pkg kak.bat LICENSE.txt
	cp busybox/busybox pkg/bin/busybox.exe
	sed -n '/^License/,$$p' README.txt >pkg/README.txt
	pkg/bin/busybox --list | xargs -i ln -s busybox.exe 'pkg/bin/{}'
	cygcheck pkg/bin/kak.exe pkg/bin/busybox.exe \
		| awk '/\\bin\\cyg.*\.dll/ {dlls[$$1] = 1} END {for (dll in dlls) printf "%s\0", dll}' \
		| xargs -0 realpath --zero \
		| xargs -0 cp -t pkg/bin
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
