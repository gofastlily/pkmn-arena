# Remove possible existing container
docker rm pkmn-arena

# Build all as one set of chained commands
docker build -t pkmn-arena . && \
docker run --name pkmn-arena pkmn-arena && \
docker cp pkmn-arena:/output/. ./output
