# Newsbeuter RSS Client
# "The Mutt of the RSS clients"

# Important files are
# /data/urls
# /data/news.db
# /data/news.db.lock
# /data/news.error.log


FROM	ubuntu:latest

ENV		RUN_DEPS \
		curl \
		newsbeuter


RUN		apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		$RUN_DEPS

RUN 	mkdir /root/.newsbeuter /data


WORKDIR	/root/
COPY	config /root/.newsbeuter/


# Dispatcher
COPY	fulltextfeed /root/
RUN		chmod -Rfv 755 /root/fulltextfeed
	

# Clean up
# Taken from https://www.dajobe.org/blog/2015/04/18/making-debian-docker-images-smaller/
RUN		apt-get remove -y $BUILD_DEPS && \
		rm -rf /var/lib/apt/lists/


# How often RSS feeds are queried, time in $(sleep)-format
ENV		RELOAD_EVERY=10m

# Ask newsbeuter to refresh all (and then terminate), log to STDOUT
ENTRYPOINT	while newsbeuter -u /data/urls -d /dev/fd/1 -l 5 -x reload; echo "Waiting $RELOAD_EVERY to reload..."; do sleep $RELOAD_EVERY; done


#HEALTHCHECK	--interval=30m --timeout=30m \
#		CMD curl -f http://localhost/ || exit 1
