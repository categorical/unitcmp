#!/bin/bash
set -eu
_inf(){ printf '\e[36mI: \e[0m%s\n' "$(printf "$1" "${@:2}")">&2;}
_Err(){ printf '\e[31mE: \e[0m%s\n' "$(printf "$1" "${@:2}")">&2;exit 1;}
thisdir="$(cd "$(dirname "$0")"&&pwd)"


prgn="$(basename "$thisdir")"
dn=dotnet
_new(){
    local u="$(find "$thisdir" -mindepth 1 -maxdepth 1 -type f -name '*.csproj')"
    [ -z "$u" ]||_Err 'found %s' "$(head -n1<<<"$u")"
    "$dn" new console -o "$(cygpath -w "$thisdir")"
}
_bld(){
    [ ! -d "$thisdir/o" ]||(set -x;rm -r "$thisdir/o")
    (cd "$thisdir"
    [ -d obj ]||"$dn" restore "$prgn.csproj"
    "$dn" build "$prgn.csproj" --no-restore -c release -o o)
}
_main(){ _u(){ cat<<EOF
    $0 --bld
EOF
    exit $1;}
    [ $# -gt 0 ]||_u 1;while [ $# -gt 0 ];do case $1 in
    --new)_new;;
    --bld)_bld;;
    -h)_u 0;;*)_u 1
    esac;shift;done
};_main "$@"
