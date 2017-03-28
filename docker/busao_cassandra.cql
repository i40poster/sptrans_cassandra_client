CREATE KEYSPACE  IF NOT EXISTS Bus
  WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };

CREATE TABLE IF NOT EXISTS Bus.readings (
      key varchar ,
      hr varchar,
      codigoLinha varchar,
      p int,
      px double,
      py double,
      day varchar,
      collectedEpoch bigint,
      hr_converted bigint,
      PRIMARY KEY(p,hr_converted)
    ) WITH CLUSTERING ORDER BY (hr_converted DESC);
/*
Reviewing table:

America/Sao Paulo (BRT)
hr_converted - it is the epoch from the collected data converted to the Sao paulo timezone;

Data is in Sao Paulo Timezone
*/

CREATE TABLE IF NOT EXISTS Bus.routesInfo (
      codigoLinha int,
      letreiro varchar,
      sentido int,
      denominacaoTPTS varchar,
      denominacaoTSTP varchar,
      PRIMARY KEY(codigoLinha)
    );

CREATE TABLE IF NOT EXISTS Bus.reading_total (
      collected_epoch bigint,
      file varchar,
      count int,
      PRIMARY KEY(collected_epoch, file)
    );
