if ($?prompt) then
    umask 022
    set notify
    set history = 100
    setenv HOSTNAME "`hostname`"
    tset -Q
    set prompt = "$LOGNAME@%m% "
endif

# check and run all package environment scripts
#
glob /etc/pkg.d/*.csh >& /dev/null
if ( $status == 0 ) then
    foreach x ( /etc/pkg.d/*.csh )
	source $x
	rehash
    end
endif
