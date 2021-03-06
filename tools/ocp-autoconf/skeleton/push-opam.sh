#!/bin/sh -e

#############################################################################
#
#          This file is managed by ocp-autoconf.
#
#  Remove it from `manage_files` in 'ocp-autoconf.config' if you want to
#  modify it manually.
#
#############################################################################

# To use this script:
# * Check that ocp-autoconf.config contains the correct version
# * Call 'ocp-autoconf' to generate 'opam'
# * Call './configure' to generate autoconf/Makefile.config
# * Call './push-opam -k' to check variables
# * Verify that the sources are available at the download url
#    (on github, it means releasing the current commit with the version as tag)
# * Run './push-opam', go on your fork, and do a pull-request
# In case of error, use './push-opam -r' to revert changes locally and remotely

echo Reading information from ./autoconf/Makefile.config
echo "    (generated by ./configure)"
. ./autoconf/Makefile.config
echo PACKAGE_VERSION=${PACKAGE_VERSION}
echo PACKAGE_NAME=${PACKAGE_NAME}
echo OPAM_REPO=${OPAM_REPO}
echo OPAM_REPO_FORK_REMOTE=${OPAM_REPO_FORK_REMOTE}
echo OPAM_REPO_OFFICIAL_REMOTE=${OPAM_REPO_OFFICIAL_REMOTE}
echo DOWNLOAD_URL_PREFIX=${DOWNLOAD_URL_PREFIX}
echo

VERSION=${PACKAGE_VERSION}
PACKAGE=${PACKAGE_NAME}

case "$1" in
    "") break;;
    -k) exit 0;;
    -r)
        echo Reverting changes to opam-repo
        cd ${OPAM_REPO} && \
                git checkout master &&
                git branch -D ${PACKAGE}.${VERSION} &&
                git push ${OPAM_REPO_FORK_REMOTE} :${PACKAGE}.${VERSION};
        echo You can now restart.
        echo
        exit 0
        ;;
esac

if test -f ${OPAM_REPO}/.git/refs/heads/${PACKAGE}.${VERSION}; then
    echo "Error: branch ${PACKAGE}.${VERSION} already exists in OPAM_REPO."
    echo "    Use './push-opam.sh -r' to remove it locally and remotely."
    echo
    exit 2
fi



if test -f ocp-autoconf.d/descr ; then :; else
    echo Missing required file 'descr'
    echo
    exit 2
fi


echo Upgrading HEAD of OPAM_REPO...
(cd ${OPAM_REPO} && git checkout master && git pull ${OPAM_REPO_OFFICIAL_REMOTE} master)
echo

if [ ! -e ${OPAM_REPO}/packages ]; then
    echo "Error: directory ${OPAM_REPO}/packages does not exist";
    echo
    exit 2
fi

if [ -e ${OPAM_REPO}/packages/${PACKAGE}/${PACKAGE}.${VERSION} ]; then
    echo "Error: directory for ${VERSION} already exists"
    echo ${OPAM_REPO}/packages/${PACKAGE}/${PACKAGE}.${VERSION}
    echo
    exit 2
fi

URL=${DOWNLOAD_URL_PREFIX}${VERSION}.tar.gz
echo Downloading archive from ${URL}...
TMPFILE=/tmp/push-ocaml.tmp
rm -f ${TMPFILE}

CMD="wget -q -O ${TMPFILE} ${URL}"
echo $CMD
$CMD || (echo "Error: could not download archive."; echo; exit 2)
echo

echo "Copying files in ${OPAM_REPO}/packages/${PACKAGE}/${PACKAGE}.${VERSION}"
echo

CMD="mkdir -p ${OPAM_REPO}/packages/${PACKAGE}/${PACKAGE}.${VERSION}"
echo $CMD
$CMD

CMD="cp opam ${OPAM_REPO}/packages/${PACKAGE}/${PACKAGE}.${VERSION}/"
echo $CMD
$CMD

CMD="cp ocp-autoconf.d/descr ${OPAM_REPO}/packages/${PACKAGE}/${PACKAGE}.${VERSION}/"
echo $CMD
$CMD || echo OK

if test -f ocp-autoconf.d/findlib; then
  CMD="cp ocp-autoconf.d/findlib ${OPAM_REPO}/packages/${PACKAGE}/${PACKAGE}.${VERSION}/"
  echo $CMD
  $CMD || echo OK
fi

echo Computing checksum on ${TMPFILE}...
md5sum ${TMPFILE}
MD5SUM=$(md5sum ${TMPFILE} | cut -b 1-32)
echo 'archive: "'${URL}'"' > ${OPAM_REPO}/packages/${PACKAGE}/${PACKAGE}.${VERSION}/url
echo 'checksum: "'${MD5SUM}'"' >> ${OPAM_REPO}/packages/${PACKAGE}/${PACKAGE}.${VERSION}/url
echo

echo Generated url file:
cat ${OPAM_REPO}/packages/${PACKAGE}/${PACKAGE}.${VERSION}/url
echo

(cd ${OPAM_REPO} &&
        git checkout -b ${PACKAGE}.${VERSION} &&
        git add packages/${PACKAGE}/${PACKAGE}.${VERSION} &&
        git commit -m "Add ${PACKAGE}.${VERSION}" packages/${PACKAGE}/${PACKAGE}.${VERSION} &&
        git push ${OPAM_REPO_FORK_REMOTE} ${PACKAGE}.${VERSION}) || echo "Error: cleanup with git branch -D ${PACKAGE}.${VERSION}"
