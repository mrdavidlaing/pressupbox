#!/bin/sh
# $1 - the folder to watch for changes (recursively)
# $2 - file owner - should be app_container user (group is hardcoded to www-data)
export WATCHED_FOLDER_LIST="$1"
export FILE_OWNER="$2"
export FILE_GROUP="www-data"

create_readme() 
{
	export CURRENT_ATTRIBS=`stat -c %A[%U:%G] "$FILE"`
	cat > "${WATCHED}README.pressupbox" <<EOL
A hosting_setup.pressupbox.yaml has designated $WATCHED (or its parent) as an upload_folder.
As a result, the file permissons are automatically set.
Most recently, a $EVENT event caused $FILE to be modified to $CURRENT_ATTRIBS
EOL
    chmod 660 "${WATCHED}README.pressupbox"
	chown ${FILE_OWNER}:${FILE_GROUP} "${WATCHED}README.pressupbox"
}

inotifywait -mr -e create -e modify -e attrib -e moved_to \
	--format '%e %w %w%f' --exclude '.*pressupbox' --fromfile "$WATCHED_FOLDER_LIST" | while read EVENT WATCHED FILE
do
	sleep 0.5 #wait until we're sure the creating process has finished
	if [ -f "$FILE" ];	then
		if [ `stat -c %U%G%a "$FILE"` != "${FILE_OWNER}${FILE_GROUP}660" ]; then
			echo "fixing permissions for folder: $FILE"
	  		chmod 660 "$FILE" #Files get -rw-rw---
	  		chown ${FILE_OWNER}:${FILE_GROUP} "$FILE"
	  		create_readme
	  	fi
	elif [ -d "$FILE" ]; then 
		if [ `stat -c %U%G%a "$FILE"` != "${FILE_OWNER}${FILE_GROUP}770" ]; then
			echo "fixing permissions for directory: $FILE"
			chmod 770 "$FILE"  #Directories get drwxrwx---
			chown ${FILE_OWNER}:${FILE_GROUP} "$FILE"
	  		create_readme
	  	fi
	fi

done