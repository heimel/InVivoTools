#
# mexopts.sh   Shell script for configuring MEX-file creation script,
#               mex.
#
# usage:        Do not call this file directly; it is sourced by the
#               mex shell script.  Modify only if you don't like the
#               defaults after running mex.  No spaces are allowed
#               around the '=' in the variable assignment.
#
# SELECTION_TAGs occur in template option files and are used by MATLAB
# tools, such as mex and mbuild, to determine the purpose of the contents
# of an option file. These tags are only interpreted when preceded by '#'
# and followed by ':'.
#
#SELECTION_TAG_MEX_OPT: Template Options file for building MEXfiles using the system ANSI compiler
#
# Copyright (c) 1984-1998 by The MathWorks, Inc.
# All Rights Reserved.
# $Revision: 1.58 $  $Date: 1998/12/16 23:29:14 $
#----------------------------------------------------------------------------
#
    case "$Arch" in
        Undetermined)
#----------------------------------------------------------------------------
# Change this line if you need to specify the location of the MATLAB
# root directory.  The cmex script needs to know where to find utility
# routines so that it can determine the architecture; therefore, this
# assignment needs to be done while the architecture is still
# undetermined.
#----------------------------------------------------------------------------
            MATLAB="$MATLAB"
            ;;
        alpha)
#----------------------------------------------------------------------------
            CC='cc'
            CFLAGS='-ieee -std1'
            CLIBS=''
            COPTIMFLAGS='-O2 -DNDEBUG'
            CDEBUGFLAGS='-g'
#
            FC='f77'
            FFLAGS='-shared'
            FLIBS='-lUfor -lfor -lFutil'
            FOPTIMFLAGS='-O2'
            FDEBUGFLAGS='-g'
#
            LD='ld'
            LDFLAGS="-expect_unresolved '*' -shared -hidden -exported_symbol $ENTRYPOINT -exported_symbol mexVersion"
            LDOPTIMFLAGS=''
            LDDEBUGFLAGS=''
#----------------------------------------------------------------------------
            ;;
        hp700)
#----------------------------------------------------------------------------
            CC='cc'
#
# Remove +DAportable from CFLAGS if you wish to optimize for target machine
#
            CFLAGS='+z -D_HPUX_SOURCE -Aa +DAportable'
            CLIBS=''
            COPTIMFLAGS='-O -DNDEBUG'
            CDEBUGFLAGS='-g'
#
            FC='f77'
            FFLAGS='+z +DAportable'
            FLIBS=''
            FOPTIMFLAGS='-O'
            FDEBUGFLAGS='-g'
#
            LD='ld'
            LDFLAGS="-b +e $ENTRYPOINT +e mexVersion"
            LDOPTIMFLAGS=''
            LDDEBUGFLAGS=''
#----------------------------------------------------------------------------
            ;;
        ibm_rs)
#----------------------------------------------------------------------------
            CC='cc'
            CFLAGS='-qlanglvl=ansi'
            CLIBS="-L$MATLAB/bin/$Arch -lmatlbmx -lm"
            COPTIMFLAGS='-O -DNDEBUG'
            CDEBUGFLAGS='-g'
#
            FC='f77'
            FFLAGS=''
            FLIBS="$MATLAB/extern/lib/ibm_rs/fmex1.o -lm"
            FOPTIMFLAGS='-O'
            FDEBUGFLAGS='-g'
#
            LD='cc'
            LDFLAGS="-bI:$MATLAB/extern/lib/ibm_rs/exp.ibm_rs -bE:$MATLAB/extern/lib/ibm_rs/$MAPFILE -bM:SRE -e $ENTRYPOINT"
            LDOPTIMFLAGS='-s'
            LDDEBUGFLAGS=''
#----------------------------------------------------------------------------
            ;;
        lnx86)   # gcc version 2.7.2.1
#----------------------------------------------------------------------------
#
# Default to libc5 based development (ie. RedHat4.2)
#
	    CC='gcc'
            if [ -f /etc/redhat-release ]; then
		OS=`cat /etc/redhat-release`
		version=`expr "$OS" : '.*\([0-9][0-9]*\)\.'`
#
# Use this compiler for RedHat5.* systems
#
		if [ "$version" = "5" ]; then
		    CC='gcc'
		fi
	    elif [ -f /etc/debian_version ]; then
	        OS=`cat /etc/debian_version`
		version=`expr "$OS" : '.*\([0-9][0-9]*\)\.'`
#
# Use this compiler for Debian 2.* systems
#
		if [ "$version" = "2" ]; then
		    CC='i486-linuxlibc1-gcc'
		fi
	    fi
            CFLAGS='-nostdlib'
            CLIBS='/usr/i486-linux-libc5/lib/libc.so.5.3.12 /usr/i486-linux-libc5/lib/ld-linux.so.1.7.14'
            COPTIMFLAGS='-O -DNDEBUG'
            CDEBUGFLAGS='-g'
#
# These flags use f2c and gcc for building FORTRAN MEX-Files
# The fort77 script invokes the f2c command transparently,
# so it can be used like a real FORTRAN compiler.
#
            FC='fort77'
            FFLAGS=''
            FLIBS='-lf2c -Wl,--defsym,MAIN__=mexfunction_'
#
# Use these flags for the Absoft F77 Fortran Compiler
#
        #   FC='f77'
        #   FFLAGS='-f -N1 -B24 -B108 -N90'
        #   FLIBS='-lU77 -lV77 -lfio -lf77math'
#
            FOPTIMFLAGS='-O'
            FDEBUGFLAGS='-g'
#
            LD=$CC
            LDFLAGS='-shared -nostdlib'
            LDOPTIMFLAGS=''
            LDDEBUGFLAGS=''
#----------------------------------------------------------------------------
            ;;
        sgi)
#----------------------------------------------------------------------------
            CC='cc'
            CFLAGS='-o32'
            CLIBS=''
            COPTIMFLAGS='-O -DNDEBUG'
            CDEBUGFLAGS='-g'
#
            FC='f77'
            FFLAGS='-o32'
            FLIBS=''
            FOPTIMFLAGS='-O'
            FDEBUGFLAGS='-g'
#
            LD='ld'
            LDFLAGS="-o32 -shared -exported_symbol $ENTRYPOINT -exported_symbol mexVersion"
            LDOPTIMFLAGS=''
            LDDEBUGFLAGS=''
            ;;
#----------------------------------------------------------------------------
        sgi64)
#----------------------------------------------------------------------------
            CC='cc'
            CFLAGS='-64'
            CLIBS=''
            COPTIMFLAGS='-O -DNDEBUG'
            CDEBUGFLAGS='-g'
#
            FC='f77'
            FFLAGS='-64'
            FLIBS=''
            FOPTIMFLAGS='-O'
            FDEBUGFLAGS='-g'
#
            LD='ld'
            LDFLAGS="-64 -shared -exported_symbol $ENTRYPOINT -exported_symbol mexVersion"
            LDOPTIMFLAGS=''
            LDDEBUGFLAGS=''
            ;;
#----------------------------------------------------------------------------
        sol2)
#----------------------------------------------------------------------------
            CC='cc'
            CFLAGS='-dalign -KPIC'
            CLIBS=''
            COPTIMFLAGS='-O -DNDEBUG'
            CDEBUGFLAGS='-g'
#
            FC='f77'
            FFLAGS='-dalign -KPIC'
            FLIBS=''
            FOPTIMFLAGS='-O'
            FDEBUGFLAGS='-g'
#
            LD='/usr/ccs/bin/ld'
            LDFLAGS="-G -M $MATLAB/extern/lib/sol2/$MAPFILE"
            LDOPTIMFLAGS=''
            LDDEBUGFLAGS=''
#----------------------------------------------------------------------------
            ;;
    esac
#############################################################################
#
# Architecture independent lines:
#
#     Set and uncomment any lines which will apply to all architectures.
#
#----------------------------------------------------------------------------
#           CC="$CC"
#           CFLAGS="$CFLAGS"
#           COPTIMFLAGS="$COPTIMFLAGS"
#           CDEBUGFLAGS="$CDEBUGFLAGS"
#           CLIBS="$CLIBS"
#
#           FC="$FC"
#           FFLAGS="$FFLAGS"
#           FOPTIMFLAGS="$FOPTIMFLAGS"
#           FDEBUGFLAGS="$FDEBUGFLAGS"
#           FLIBS="$FLIBS"
#
#           LD="$LD"
#           LDFLAGS="$LDFLAGS"
#           LDOPTIMFLAGS="$LDOPTIMFLAGS"
#           LDDEBUGFLAGS="$LDDEBUGFLAGS"
#----------------------------------------------------------------------------
#############################################################################
