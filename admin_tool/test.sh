here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)
. $here/utils.sh


server_set="$1"
servers=
parse_server_set "$server_set" servers
declare -p servers
