# sptrans_cassandra_client

Sample cassandra client of consuming SPTrans to colelct the city buses location

This sample uses 2 containers to run the sample.
- 1st is `sample_cassandra` that is simple Cassandra DB
- 2nd is `sample_cassandra_sptrans_app` that is the SPtrans collector app.

The separation is meant to allow better separation of code and to allow the cassandra(`cassandra_host`) to be shared by multiple apps.


# Running from DockerHub


```bash
docker run --name sample_cassandra -d cassandra:3.10
#sleep is used to allow cassandra to start properly
sleep 30

docker run --name sample_cassandra_sptrans_app --link sample_cassandra:cassandra_host  --tmpfs /root/RAM:size=32M -e API_TOKEN_OLHOVIVO="API_KEY_GET_FROM_STRANS_SITE"   -e SPLIT_LINES=200 -d  it4poster/sptrans_cassandra_client
```

- `API_TOKEN_OLHOVIVO`: Your SPTrans Developer Key API key, to get one access <http://www.sptrans.com.br/desenvolvedores/>. Subscription willl be required.
- `SPLIT_LINES`: Max size of each batch size.
