#!/bin/bash
#=======================================================================
#       Functions
#=======================================================================
# Check if a value exists in an array
# @param $1 mixed  Needle  
# @param $2 array  Haystack
# @return  Success (0) if value exists, Failure (1) otherwise
# Usage: in_array "$needle" "${haystack[@]}"
# See: http://fvue.nl/wiki/Bash:_Check_if_array_element_exists
in_array() {
    search_path="$1"
    shift

    while [ -n "${1+defined}" ]
    do
        if [ "$1" = "$search_path" ]
        then
            return 0
        fi
        shift
    done
    return 1
}
#Print script usage
usage() {
    echo "mySQL Backup Tool"
	echo "Usage : $0 [OPTIONS]"
    echo $errmsg
}
#Print options and requirements
options() {
    echo "Requirement : mysqldump
------------------------------------------------------------------------
Options
  Backup mode
    -a, --all-databases-in-one-file  dump all databases in a single file    
    -d, --one-database-by-file       make one file per database
    -t, --one-table-by-file          make a directory for each database
                                     and one file by table  
  Others options
    -h, --host=name                  default value : localhost
    -l, --login=login
    -p, --password=password
    -P, --port=port                  default value : 3306
    --help                           display this menu
    --backup-dir=path                path to backup directory
    --exclude-from=file-path        file containing tables to ignore    
    
Note : you can run all backup mode at once."
}
#=======================================================================
#       INIT
#=======================================================================
host="localhost"
port="3306"
login=""
password=""
backupdir=$PWD
alldbinonefile=false
onedbbyfile=false
onetablebyfile=false
excludedatabases=""
mysqldump=$(which mysqldump)

#check requirements
if [ "$mysqldump" = "" ]
then
    errmsg="mysqldump not found"
    usage
    exit 1
fi
#check arguments
if [ $# -lt  1 ]
then
	errmsg="Missing arguments.
    For more informations, use $0 --help"
	usage
    exit 1
fi

if ! options=$(getopt -o b:e:h:l:P:p:adt -l host:,login:,password:,port:,backup-dir:,exclude-from:,help,all-databases-in-one-file,one-database-by-file,one-table-by-file -- "$@")
then
    errmsg="$0 : arguments error"
    exit 1
fi

eval set -- $options

while [ $# -gt 0 ]
do
    case $1 in
    -a|--all-databases-in-one-file) alldbinonefile=true;;
    -d|--one-database-by-file) onedbbyfile=true;;
    -t|--one-table-by-file) onetablebyfile=true;;
    -b|--backup-dir) backupdir="$2" ; shift;; 
    -e|--exclude-from)
		if [ -f $2 ]
            then
                excludedatabases="$(cat $2)" ;
            else
                errmsg="$2 : Not Found for --exclude-from argument"
                usage; exit 1;
		fi;shift;;
    --help) usage;options;exit 0;;
    -h|--host) host="$2" ; shift;;
    -l|--login) login="$2" ; shift;;
    -p|--password) password="$2" ; shift;;
    -P|--port) port="$2" ; shift;;
    (--) shift; break;;
    (-*) errmsg="$1 : unrecognized option"; usage; exit 1;;
    (*) break;;
    esac
    shift
done
#-----------------------------------------------------------------------
#	Execution
#-----------------------------------------------------------------------
#All databases in one file
if [ "$alldbinonefile" = "true" ] 
then
    if [ -f "$backupdir/all-databases.sql" ]
    then
        rm -f "$backupdir/all-databases.sql"
    fi

    dblist="$(mysql -u $login -h $host -p$password -P$port -Bse 'show databases')"
    for db in $dblist
    do
        in_array $db $excludedatabases
        inarray=$?
        if [ $inarray != 0 ]
        then
            $mysqldump -h $host -P $port -u $login -p$password $db >> "$backupdir/all-databases.sql"
        fi
    done
fi
#One database per file
if [ "$onedbbyfile" = "true" ] 
then
    dblist="$(mysql -u $login -h $host -p$password -P$port -Bse 'show databases')"
    
    for db in $dblist
    do
        in_array $db $excludedatabases
        inarray=$?
        if [ $inarray != 0 ]
        then
            $mysqldump -h $host -P $port -u $login -p$password $db > "$backupdir/$db.sql"
        fi
    done
fi
#One table per file
if [ "$onetablebyfile" = "true" ]
then
    dblist="$(mysql -u $login -h $host -p$password -P$port -Bse 'show databases')"

    for db in $dblist
    do
        in_array $db $excludedatabases
        inarray=$?
        if [ $inarray != 0 ]
        then
            if [ -d "$backupdir/$db" ];
                then
                    rm -rf "$backupdir/$db"
            fi
            mkdir "$backupdir/$db"
            tablelist="$(mysql -u $login -h $host -p$password -P$port $db -Bse 'show tables')"
            for table in $tablelist
            do
                $mysqldump -h $host -P $port -u $login -p$password $db $table > "$backupdir/$db/$table.sql"
            done
        fi
    done
fi
