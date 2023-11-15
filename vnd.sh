#!/bin/bash
set -eu
_inf(){ printf '\e[36mI: \e[0m%s\n' "$(printf "$1" "${@:2}")">&2;}
_Err(){ printf '\e[31mE: \e[0m%s\n' "$(printf "$1" "${@:2}")">&2;exit 1;}
thisdir="$(cd "$(dirname "$0")"&&pwd)"

vnd="$thisdir/vnd"
u='https://github.com/nesrak1/assetstools.net/archive/main.zip'
u='https://github.com/nesrak1/assetstools.net/archive/2207c788da.tar.gz'

dn=dotnet
_get(){
    [ -d "$vnd" ]||(set -x;mkdir "$vnd")
    
    local c="$(mktemp -d)"
    declare -p c
    curl -L "$u" -o"$c/c"
    (cd "$c"
    install -dm755 b
    tar xzf c -Cb --strip-components=1
    local v='b/assettools.net/assetstools.net.csproj'
    "$dn" restore "$v"
    "$dn" build --no-restore "$v" -c release -o o
    )
    local n='assetstools.net.dll'
    install -Tm644 "$c/o/$n" "$vnd/$n"
    [ ! -d "$c" ]||(set -x;rm -r "$c")
}
_clean(){ [ ! -d "$vnd" ]||(set -x;rm -r "$vnd");}
_main(){ _u(){ cat<<EOF
    $0 --get
EOF
    exit $1;}
    [ $# -gt 0 ]||_u 1;while [ $# -gt 0 ];do case $1 in
    --get)_get;;
    --clean)_clean;;
    -h)_u 0;;*)_u 1
    esac;shift;done
};_main "$@"
