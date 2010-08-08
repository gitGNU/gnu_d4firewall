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
# d4firewall  Makefile
#
# Author: d4lamar <d4lamar@gmail.com>
#
#
# 07/07/2010 - 0.4 Added Manpage  
# 29/05/2010 - 0.4 Changes for WorldWide Distribution  
#

VERSION=0.4
PACKAGE_NAME=d4firewall
SOURCES_DIR=src
PACKAGES_DIR=packages
INSTALL_CONF_DIR=${DESTDIR}/etc/${PACKAGE_NAME}
INSTALL_LIB_DIR=${DESTDIR}/usr/share/${PACKAGE_NAME}/libs
INSTALL_MAN_DIR=${DESTDIR}/usr/share/man/
ENABLED_CONFIG=enabled-rules.conf
DISABLED_CONFIG=disabled-rules.conf
INIT_SCRIPT=d4firewall

all: ${SOURCES_DIR}/${ENABLED_CONFIG} ${SOURCES_DIR}/${DISABLED_CONFIG} \
     ${SOURCES_DIR}/${INIT_SCRIPT} ${SOURCES_DIR}/${PACKAGE_NAME}.conf  \
     ${SOURCES_DIR}/functions.sh ${SOURCES_DIR}/utils.sh
	
${SOURCES_DIR}/${INIT_SCRIPT}: configure
	./configure 

configure:
	autoconf ${SOURCES_DIR}/configure.ac > configure
	chmod +x configure

install: all
	mkdir -p ${DESTDIR}/etc/init.d 
	mkdir -p ${INSTALL_CONF_DIR} 
	mkdir -p ${INSTALL_LIB_DIR} 
	install -m 755 ${SOURCES_DIR}/${INIT_SCRIPT} ${DESTDIR}/etc/init.d/${INIT_SCRIPT}
	install -m 644 ${SOURCES_DIR}/${ENABLED_CONFIG} ${INSTALL_CONF_DIR}/${ENABLED_CONFIG}
	install -m 644 ${SOURCES_DIR}/${DISABLED_CONFIG} ${INSTALL_CONF_DIR}/${DISABLED_CONFIG}
	install -m 644 ${SOURCES_DIR}/${PACKAGE_NAME}.conf ${INSTALL_CONF_DIR}/
	install -m 644 ${SOURCES_DIR}/utils.sh ${INSTALL_LIB_DIR}/
	install -m 644 ${SOURCES_DIR}/functions.sh ${INSTALL_LIB_DIR}/
	install -m 644 ${SOURCES_DIR}/man/${PACKAGE_NAME}.8 ${INSTALL_MAN_DIR}/man8/

uninstall:
	rm -f /etc/init.d/${INIT_SCRIPT}
	rm -rf ${INSTALL_LIB_DIR}
	rm -f ${INSTALL_MAN_DIR}/man8/${PACKAGE_NAME}.8
	rm -f /etc/logrotate.d/${PACKAGE_NAME}
	rm -f /etc/rsyslog.d/${PACKAGE_NAME}.conf

purge: uninstall
	rm -rf ${INSTALL_CONF_DIR}

pkg-tar:
	cd .. && tar cvvzf ${PACKAGE_NAME}-${VERSION}.src.tar.gz ${PACKAGE_NAME}-${VERSION}/* 

clean:
	rm -rf autom4te.cache
	rm -f configure-stamp
	rm -f build-stamp
	rm -f config.log
	rm -f config.status
	rm -f configure
	rm -f ${SOURCES_DIR}/${INIT_SCRIPT}
