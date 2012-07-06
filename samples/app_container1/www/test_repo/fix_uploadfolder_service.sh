#! /bin/sh

case "$1" in
  start|"")

	/data/app_containers/app_container1/www/test_repo/fix_uploadfolder_permissions.sh /tmp/files_to_watch vagrant >/var/log/fix_uploadfolder.log 2>&1 &
	echo "Started successfully"
	;;
  restart|reload|force-reload)
        $0 stop
        sleep 0.1
        $0 start
    ;;
  stop)
	killall -v inotifywait
	;;
  *)
	echo "Usage: fix_uploadfolder_service.sh [start|stop|restart]" >&2
	exit 3
	;;
esac

: