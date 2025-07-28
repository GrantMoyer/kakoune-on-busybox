all: package

package: kakoune-on-busybox.tar.gz

kakoune-on-busybox.tar.gz: kak busybox
	$(MAKE) -C kakoune DESTDIR="$(PWD)/pkg" PREFIX="/" install
	$(MAKE) -C busybox CONFIG_PREFIX="$(PWD)/pkg" install
	tar czf kakoune-on-busybox.tar.gz -C pkg .

kak:
	$(MAKE) -C kakoune

busybox: busybox/.config
	patch --directory=busybox --input=../busybox.patch --forward --strip=0 || :
	$(MAKE) -C busybox

busybox/.config: busybox_config
	cp busybox_config busybox/.config

clean:
	$(MAKE) -C kakoune clean
	rm --force busybox/.config
	$(MAKE) -C busybox clean
	patch --directory=busybox --input=../busybox.patch --reverse --force --strip=0 || :

.PHONY: all busybox clean kak package
