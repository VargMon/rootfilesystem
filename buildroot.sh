#! /bin/sh
#
# Build the prototype root filesystem for a Mastodon distribution.
#

if [ ! -d $DESTDIR ]; then
    echo "$DESTDIR: not a directory"
    exit 1
fi
rm -rf $DESTDIR/*

ETC="etc/csh.login etc/gettydefs etc/group etc/ld.so.conf"
ETC="$ETC etc/mail.rc etc/passwd etc/profile etc/protocols etc/services"
ETC="$ETC etc/shells etc/sendmail.cf etc/aliases"

PMAKE="usr/share/mk/Makefile usr/share/mk/bsd.README usr/share/mk/bsd.doc.mk"
PMAKE="$PMAKE usr/share/mk/bsd.lib.mk usr/share/mk/bsd.man.mk"
PMAKE="$PMAKE usr/share/mk/bsd.prog.mk usr/share/mk/bsd.subdir.mk"
PMAKE="$PMAKE usr/share/mk/sys.mk"

installdir() {
    install -d -o ${2-bin} -g ${3-bin} -m ${4-755} $1
}

mkmandirs() {
    installdir $1/$2 man man 711
    chown man.man $1/$2
    VAR=`echo $2 | sed -e 's~/man~/~' -e 's~^usr/~var/man/~'`
    for x in 1 2 3 3f 4 5 6 7 8;do
	installdir $1/$2/man$x man man
	installdir $1/$VAR/cat$x man man
	chown man.man $1/$2/man$x
	chown man.man $1/$VAR/cat$x
	ln -s /${VAR}cat$x $1/$2/cat$x
    done
}

# check to make sure all the template files exist.
umask 0
echo "checking installation kit..."
echo -n "< etc "
unset aarg
for x in $ETC;do
    if [ ! -r $x ]; then
	echo "<$x> is missing"
	aarg=1
    fi
done
[ "$aarg" ] && exit 1

echo -n "usr/share/mk "
unset aarg
for x in $PMAKE; do
    if [ ! -r $x ]; then
	echo "<$x> is missing"
	aarg=1
    fi
done
[ "$aarg" ] && exit 1
echo "> all ok!"

# found all the prototype files, so we can start populating like
# there's no tomorrow.
#

set -e	# if any command fails from here on in, it's the apocolypse

echo -n "building"

# build top-level directories
#
echo -n " ."
for x in etc lib boot dev cdrom home mnt proc sbin tmp usr var floppy;do
    case $x in
    tmp)                installdir $DESTDIR/$x root root 1777 ;;
    bin|sbin|cdrom|mnt) installdir $DESTDIR/$x bin bin 755 ;;
    *)                  installdir $DESTDIR/$x root root 755 ;;
    esac
done

# populate /etc
#
echo -n " /etc"
find etc -depth -print | cpio -pdum $DESTDIR >/dev/null
chmod -w $DESTDIR/etc/services $DESTDIR/etc/protocols
ln -s /sbin/shutdown $DESTDIR/etc/shutdown
ln -s /var/log/utmp $DESTDIR/etc/utmp
ln -s /var/log/wtmp $DESTDIR/etc/wtmp
ln -s . $DESTDIR/etc/inet
install -d -m 444 -o 0 -g 0 $DESTDIR/etc/pkg.d

# populate /lib
#
echo -n " /lib"
mkdir $DESTDIR/lib/modules

# populate /usr
#
echo -n " /usr"
installdir $DESTDIR/usr/ia32-linuxaout
installdir $DESTDIR/usr/ia32-linuxaout
ln -s ia32-linuxaout $DESTDIR/usr/aout
ln -s ia32-linuxaout $DESTDIR/usr/i486-linuxaout
installdir $DESTDIR/usr/ia32-glibc
installdir $DESTDIR/usr/ia32-glibc/lib
installdir $DESTDIR/usr/ia32-linux
ln -s ia32-linux $DESTDIR/usr/elf
ln -s ia32-linux $DESTDIR/usr/i486-linux
installdir $DESTDIR/usr/ia32-linux/lib
installdir $DESTDIR/usr/X11R6/lib
ln -s /etc $DESTDIR/usr/etc
installdir $DESTDIR/usr/games games games
installdir $DESTDIR/usr/include
installdir $DESTDIR/usr/lib/lilo
installdir $DESTDIR/usr/lib/yp
ln -s ../share/zoneinfo $DESTDIR/usr/lib/zoneinfo
installdir $DESTDIR/usr/local/bin
installdir $DESTDIR/usr/local/lib
installdir $DESTDIR/usr/local/include
installdir $DESTDIR/usr/sbin
installdir $DESTDIR/usr/share/terminfo
installdir $DESTDIR/usr/share/zoneinfo
installdir $DESTDIR/usr/share/tabset
installdir $DESTDIR/usr/share/mk
for x in $PMAKE; do
    cp $x $DESTDIR/$x
done
mkmandirs $DESTDIR usr/man
mkmandirs $DESTDIR usr/local/man

ln -s /var/spool $DESTDIR/usr/spool
installdir $DESTDIR/usr/src

# populate /var
#
echo -n " /var "
installdir $DESTDIR/var/games games games
installdir $DESTDIR/var/lib/zoneinfo
installdir $DESTDIR/var/lock
ln -s lock $DESTDIR/var/locks
installdir $DESTDIR/var/log
ln -s log $DESTDIR/var/adm
(   cd $DESTDIR/var/log
    for x in debug diagnostics lastlog mail messages syslog utmp wtmp;do
	touch $x
	case $x in
	mail|security) chmod go-rw $x ;;
	*)             chmod go-w $x ;;
	esac
    done
    installdir packages
    installdir OLD )

installdir $DESTDIR/var/pid
installdir $DESTDIR/var/preserve
installdir $DESTDIR/var/run
ln -s spool/rwho $DESTDIR/var/rwho
installdir $DESTDIR/var/spool/locate
installdir $DESTDIR/var/spool/mail root root 1777
installdir $DESTDIR/var/spool/mqueue
installdir $DESTDIR/var/spool/rwho
installdir $DESTDIR/var/yp/binding
ln -s ../tmp $DESTDIR/var/spool/tmp
ln -s ../lock $DESTDIR/var/spool/locks
installdir $DESTDIR/var/tmp root root 1777
(cd var/spool;find * -depth -print | cpio -pdum $DESTDIR/var/spool >/dev/null)

echo

exit 0
