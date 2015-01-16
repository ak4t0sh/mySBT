
#mySQL Backup Tool
## Usage
    $ ./mysbt.sh [BACKUP_MODE_OPTIONS][OPTIONS]
The current running directory is used if not specified.

## Requirements
The following dependencies are required :

* mysqldump

## Script Arguments
The following options can be passed to the script for connecting to mysql.

    Backup mode
        -a, --all-databases-in-one-file  dump all databases in a single file
        -d, --one-database-by-file       make one file per database
        -t, --one-table-by-file          make a directory for each database and one file by table

    Others options
        -b, --backup-dir=path            path to backup directory
        -e, --exclude-from=file-path     file containing tables to ignore
        -h, --host=name                  default value : localhost
        -l, --login=login
        -p, --password=password
        -P, --port=port                  default value : 3306
        --help                           display this menu
__Note :__ you can run all backup mode at once.

## Example
* Script call

        $ ./mysbt.sh -a u login -p password #dump all database in one file in current directory
        $ ./mysbt.sh -d -u login -p password --backup-dir=/backup/directory #dump all database in /backup/directory. One database per file.
        $ ./mysbt.sh -t -u login -p password --backup-dir=/backup/directory --exclude-from=/path/to/database.exclude #dump all database (except defined in /path/to/database.exclude) in /backup/directory. For each database a directory is created and all tables are dumped separatly .

* Exclude file content

        information_schema
        mysql
        performance_schema