#!/bin/sh

DESC="AirVideoServer - daemon"
NAME=avs-daemon
#DAEMON=/usr/bin/java
DAEMON=/usr/bin/python
DAEMON_ARGS="/opt/avs/avs.py"
#DAEMON_ARGS="-jar AirVideoServerLinux.jar test.properties"
PIDFILE=/var/run/$NAME.pid
WORK_PATH=/opt/avs
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WORK_PATH/lib

do_start()
{
  echo -n "Starting $NAME..."
  LD_LIBRARY_PATH=$WORK_PATH/lib start-stop-daemon --chdir $WORK_PATH \
  --make-pidfile --pidfile $PIDFILE \
  --background \
  --start \
  --exec $DAEMON -- $DAEMON_ARGS
  echo "done"
}

do_stop()
{
  PID=`cat $PIDFILE`
  echo -n "Stoping $NAME..."
  start-stop-daemon --chdir $WORK_PATH \
  --pidfile $PIDFILE \
  --stop --exec $DAEMON
  while /bin/true; do
    if [ -z "$PID" ]; then
      break
    fi 
    psline=`ps -fp $PID|grep avs`
    if [ -z "$psline" ]; then
      break
    else
      sleep 1
      echo -n "."
    fi
  done
  echo "done"
}

#rm -f /tmp/mplay
/bin/rm -f /DataVolume/.avs/*.ts
test -x $DAEMON || exit 0

case "$1" in
  start)
      do_start
      ;;
  stop)
      do_stop
      ;;
  restart)
      do_stop
      do_start
      ;;
  *)
  echo "Usage: $0 {start|stop|restart|"
  exit 1
esac
exit 0
