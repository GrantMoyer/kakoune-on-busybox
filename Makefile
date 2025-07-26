all: kak busybox

kak:
	$(MAKE) -C kakoune

busybox:
	$(MAKE) -C busybox

clean:
	$(MAKE) -C kakoune clean
	$(MAKE) -C busybox clean

.PHONY: all kak busybox clean
