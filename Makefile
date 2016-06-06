#Makefile for Docker container control

# define docker container
CONTAINER_REPO = hobbsau/openhab1
CONTAINER_RUN = openhab1-service

# define the exportable volumes for the data container
CONFIG_VOL = /opt/openhab

# This should point to the host directory containing the openhab config. The host directory must be owned by UID:GID 1000:1000. The format is /host/directory:
CONFIG_BIND = /srv/openhab1:

TRIGGER_URL = https://registry.hub.docker.com/u/hobbsau/openhab1/trigger/f88d187e-e22c-498e-a78e-3c68b41992f5/

build:
	@curl --data build=true -X POST $(TRIGGER_URL) 


run: 
	@if [ -z "`docker ps -q -f name=$(CONTAINER_RUN)`" ]; \
	then \
		docker pull $(CONTAINER_REPO); \
		docker run -d \
 		--restart=always \
 		--net="host" \
 		-v $(CONFIG_BIND)$(CONFIG_VOL) \
 		--name $(CONTAINER_RUN) \
 		$(CONTAINER_REPO); \
	else \
		echo "$(CONTAINER_RUN) already running!"; \
	fi

# Service container is ephemeral so let's delete on stop. Data container is persistent so we do not touch
stop:
	@if [ -z "`docker ps -q -f name=$(CONTAINER_RUN)`" ]; \
        then \
		echo "Nothing to stop as container $(CONTAINER_RUN) isn't running!"; \
	else \
	docker stop $(CONTAINER_RUN); \
	docker rm $(CONTAINER_RUN); \
	fi

clean: stop
	@if [ -z "`docker ps -a -q -f name=$(CONTAINER_RUN)`" ]; \
        then \
		echo "Nothing to remove as container $(CONTAINER_RUN) doesn't exist!"; \
	else \
	echo "Removing container..."; \
	docker rm $(CONTAINER_RUN); \
	fi

upgrade: clean build run
