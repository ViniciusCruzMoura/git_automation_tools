#!/usr/bin/env bash

python=python3.9
pip=pip3.9
SYSDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAG=$2
NUM_PROCESSES=$(grep ^cpu\\scores /proc/cpuinfo | uniq |  awk '{print $4}')
NUM_TOTAL_THREADS=$(grep -c ^processor /proc/cpuinfo)
NUM_SOCKETS=$(grep -i "physical id" /proc/cpuinfo | sort -u | wc -l)
NUM_TOTAL_PROCESSES=`expr $NUM_SOCKETS \* $NUM_PROCESSES`
NUM_THREADS=`expr $NUM_TOTAL_THREADS / $NUM_TOTAL_PROCESSES`

clone() {
	if [ ! -d ".git" ]; then
		echo ".git doesn't exist."
		exit 0
	fi
    if [[ -z "$TAG" ]]; then
        echo "Unknown option, Try -help for more information."
		exit 0
    fi
	git fetch --all
	git checkout $TAG
    git reset --hard origin/$TAG
}

build() {
	if [ ! -d "$SYSDIR/venv/" ]; then
		echo 'Making virtual environment'
		$python -m venv venv
	fi
	echo 'Activate virtual environment'
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		source venv/bin/activate
	else
		echo 'Operating system unknown'
		echo 'Aborting build'
		exit 0
	fi
	echo 'Upgrading pip, wheel and setuptools'
	$pip install --upgrade pip wheel setuptools
	echo 'Downloading requirements'
	$pip install -r requirements.txt
	echo 'Doing collectstatic'
	mkdir -p staticfiles;
	$python manage.py collectstatic --noinput
}

run() {
	echo 'Rebooting'
	redis-cli FLUSHALL
	pkill -9 -f celery
	pkill -9 -f uwsgi
	uwsgi --socket mysite.sock --module captura.wsgi --master --processes $NUM_TOTAL_PROCESSES --threads $NUM_THREADS --chmod-socket=666 &
	sleep 4
	celery -A captura worker --pool=threads -l INFO -B --scheduler django_celery_beat.schedulers:DatabaseScheduler &
	sleep 4
	echo 'Process finished'
}

case $1 in
	-help|--help|help)
		echo "These are common commands used in various situations:"
		echo "COMMAND help"
		echo "COMMAND start master"
		echo "COMMAND stop"
		exit 0
		;;
	-start|--start|start)
		clone
		build
		run
		while [ true ]; do
			cd $SYSDIR
			git fetch --all > /dev/null
			if [[ ! -z "$(git diff $TAG origin/$TAG)" ]]; then
				clone
				build
				run
			fi
			sleep 60
		done
		exit 0
		;;
	-stop|--stop|stop)
		pkill -9 -f celery
		pkill -9 -f uwsgi
		kill `ps -aux | grep $0 | grep -v grep | awk '{ print $2}'`
		redis-cli FLUSHALL
		exit 0
		;;
	*)
		echo "Unknown option, Try -help for more information."
		exit 0
		;;
esac
