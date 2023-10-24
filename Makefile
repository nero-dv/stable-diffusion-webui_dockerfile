# Assign the default target
.DEFAULT_GOAL: all

# Target for building the Docker image
all:
	docker build . -t sdwebui:release