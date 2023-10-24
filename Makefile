# Assign the default target
.DEFAULT_GOAL: all

# Target for building the Docker image
all:
	docker build . -t sdwebui:release || docker logs $(docker ps -l -q)

dev: 
	docker build . -t sdwebui:dev || docker logs $(docker ps -l -q)
