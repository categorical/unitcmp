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
_bld()(
    cd "$thisdir"
    local o=o/b
    [ ! -d "$o" ]||(set -x;rm -r "$o")
    [ -d obj ]||"$dn" restore "$prgn.csproj"
    "$dn" build "$prgn.csproj" --no-restore -c release -o "$o"
)
_release(){
    _release2(){
        [ ! -d "$o2" ]||(set -x;rm -r "$o2")
        "$dn" publish "$prgn.csproj" "${c[@]}" -o "$o2"
        local n="$(basename "$o2")"

        (cd "$o"
        [ ! -f "$n.zip" ]||(set -x;rm "$n.zip")
        7z u "$n.zip" "./$n/*")
    }
    declare -a c c2=(-c release
    -p:publishsinglefile=true
    -p:debugtype=
    );local o=o o2
    (cd "$thisdir"
    [ ! -d "$o" ]||(set -x;rm -r "$o")
    c=("${c2[@]}" -r linux-x64 --no-self-contained);o2="$o/linux64"
    _release2
    c=("${c2[@]}" -r linux-x64);o2="$o/linux64_with_runtime"
    _release2
    c=("${c2[@]}" -r win-x64 --no-self-contained);o2="$o/win64"
    _release2
    c=("${c2[@]}" -r win-x64);o2="$o/win64_with_runtime"
    _release2
    )
}
_main(){ _u(){ cat<<EOF
    $0 --bld
EOF
    exit $1;}
    [ $# -gt 0 ]||_u 1;while [ $# -gt 0 ];do case $1 in
    --new)_new;;
    --bld)_bld;;
    --release)_release;;
    -h)_u 0;;*)_u 1
    esac;shift;done
};_main "$@"
