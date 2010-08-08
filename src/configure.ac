##########################################################################
#     This file is part of d4firewall
#
#     d4firewall is free software; you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation; either version 2 of the License, or
#     (at your option) any later version.
#
#     d4firewall is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program; if not, write to the Free Software
#     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
##########################################################################
#     Copyright (C) 2010 Matteo Chesi
##########################################################################
#
# Author: Matteo Chesi < d4lamar(at)gmail.com >
#

AC_INIT([d4firewall], [0.4])
AC_CONFIG_FILES([src/d4firewall])

#IPTABLES_BIN=@IPTABLES_BIN@
#IPTABLES_SAVE_BIN=@IPTABLES_SAVE_BIN@
#IPTABLES_RESTORE_BIN=@IPTABLES_RESTORE_BIN@

AC_PATH_PROG(iptables_bin,iptables)
if test -z "$iptables_bin"; then
	echo "*** ERROR!"
	exit 1 
fi
AC_SUBST(IPTABLES_BIN,$iptables_bin)

AC_PATH_PROG(iptables_save_bin,iptables-save)
if test -z "$iptables_save_bin"; then
	echo "*** ERROR!"
	exit 1 
fi
AC_SUBST(IPTABLES_SAVE_BIN,$iptables_save_bin)

AC_PATH_PROG(iptables_restore_bin,iptables-restore)
if test -z "$iptables_restore_bin"; then
	echo "*** ERROR!"
	exit 1 
fi
AC_SUBST(IPTABLES_RESTORE_BIN,$iptables_restore_bin)

AC_OUTPUT
