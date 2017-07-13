#! /bin/bash
function Trace()
{
    if [ "${VERBOSE_PRE_BLD}" != "" ]; then
        echo "$1" 1>&2
    fi
}

function Update_Sources()
{
    if [ -f ${BLD_DIR}/${STAMP_UNPACK} ]; then
        Trace "Skipped @ ${BLD_DIR}/${STAMP_UNPACK}"
        return 0
    fi
    if [ "${PKG_SWITCH}" = "" ]; then
        Trace "Skipped @ CONFIG_${MODULE} = '${PKG_SWITCH}'"
        return 0
    fi

    for FILE in \
        $(find ${SRC_DIR}/ -type f -o -type l -name "*.[ch]" -o -name "*.mk" -o -name "*.cpp") \
        $(find ${SRC_DIR}/ -maxdepth 1 -name "*.patch" -o -name "lib*.a" -o -name "lib*.so") \
    ; \
    do
        FILE_DIR=.$(echo $(dirname ${FILE})|sed "s:${SRC_DIR}::")
        FILE_BASE=$(basename ${FILE})
        FILE_COPY=${BLD_DIR}/${FILE_DIR}/${FILE_BASE}
        Trace "Check: ${FILE_DIR}: ${FILE_BASE}"

        if [ ! -e ${FILE_COPY} -o \
             ${FILE} -nt ${FILE_COPY} ]; then
             mkdir -p ${BLD_DIR}/${FILE_DIR}
             cp -f ${FILE} ${FILE_COPY}
        fi
    done

    TARBALL=$(find ${PACKAGE_DIR} -type f -name "$(basename ${MODULE})-[0-9]**" \
                                  -o -name "$(basename ${MODULE}).*"| head -1)
    if echo ${MODULE}|grep -q "libubox"; then
        tar xf ${TARBALL} -C ${BLD_DIR}
    fi
}

function Update_Makefile()
{
    BLD_MFILE=${BLD_DIR}/${HD_MAKEFILE}

    if  [ ${BLD_MFILE} -nt ${SRC_DIR}/${MAKE_SEGMENT} ] && \
        [ ${BLD_MFILE} -nt ${STAMP_BLD_ENV} ]; then
        return 0;
    fi

    rm -f ${BLD_MFILE}

    echo "MODULE_NAME := ${MODULE}" >> ${BLD_MFILE}
    cat ${STAMP_BLD_ENV} >> ${BLD_MFILE}
    cat << EOB >> ${BLD_MFILE}

include \$(TOP_DIR)/build-rules/settings.mk
include \$(CONFIG_TPL)

all:

EOB

    cp -f ${SRC_DIR}/${MAKE_SEGMENT} ${BLD_DIR}/${MAKE_SEGMENT}
    cat ${BLD_DIR}/${MAKE_SEGMENT} >> ${BLD_MFILE}

    cat << EOB >> ${BLD_MFILE}

env:
	@echo ""
	@printf -- "-----------------------------------------------------------------\n"
	@\$(foreach var,\$(SHOW_ENV_VARS),\$(call Dump_Var,\$(var)))
	@printf -- "-----------------------------------------------------------------\n"
	@echo ""

include \$(RULE_DIR)/rules.mk
EOB

    Trace "Updated: ${BLD_MFILE}"
}

if [ "$#" != "1" -a "$#" != "2" ]; then exit 12; fi

MODULE=${1}
BLD_DIR=${OUTPUT_DIR}/${MODULE}
SRC_DIR=${TOP_DIR}/${MODULE}

if [ ! -d ${SRC_DIR} ]; then
    exit 0
fi

# [ "${VERBOSE_PRE_BLD}" != "" ] && set -x

mkdir -p ${BLD_DIR}

MSG=$(printf "%-28s%s" "${MODULE}" "[..]")
echo -ne "\r                                                    "
echo -ne "\e[0;37;0;44m""\r[..] o ${MSG}""\e[0;m"
Trace ""

if [ "$#" = "1" ]; then
    Update_Sources
fi
Update_Makefile