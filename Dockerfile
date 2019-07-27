## --------------------
## Using MongoDB Image

FROM mongo:latest


## ---------------------------------
## Exposing the Default MongoDB Port

EXPOSE 27017

## -------------------------------
## Copying the Initial Collection 

COPY origami_initial_list.json /origami_initial_list.json


## ------------------------------------------------
## Initial Container Command: Import the collection

# Modify child mongo to use /data/mydb as dbpath (because /data/mydb wont persist the build)
RUN mkdir -p /data/mydb \
    && echo "dbpath = /data/mydb" > /etc/mongodb.conf \
    && chown -R mongodb:mongodb /data/mydb

RUN mongod --fork --logpath /var/log/mongodb.log --dbpath /data/mydb --smallfiles \ 
	&& mongoimport --verbose --host=127.0.0.1 --port 27017 --db zalbystuff --collection origami --type json --file origami_initial_list.json \
    && mongod --dbpath /data/mydb --shutdown \
    && chown -R mongodb /data/mydb

## ---------------------------------------
# Make the new dir a VOLUME to persists it 
VOLUME /data/mydb

## ---------------------------------------
## Initial Container Command: Run MongoDb

CMD ["mongod", "--config", "/etc/mongodb.conf", "--smallfiles"]

## -----------------------------------
## Build the image with this command: 
## docker build -t zalbystuffmongo:v1 .

# ---------------------------------------------------------------------
# Run the image with this command: 
# docker run --name mongotest -p <<host_port>>:27017 zalbystuffmongo:v1