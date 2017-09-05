title: "Introduction to Time Series Database"
date: 2017-07-09 01:03:27 +0000
update: 2017-07-09 01:03:27 +0000
author: at15
# NOTE: the image locate in `source` folder
# cover: "-/images/posts/example.png"
tags:
    - tsdb
    - "time series database"
    - introduction
preview: "A shallow introduction of time series database and comparison between popular time series databases"

---

This blog is written for fellow students at [dongyueweb](https://github.com/dyweb),
so its targeted readers are people who have taken database class and want to know about time series database (TSDB).

<!-- TODO: toc -->

## What is time series database

Time series database (TSDB) is relative new compared with RDBMS, NoSQL, even NewSQL.
However it is becoming trending with the growth of system monitoring and internet of things.
The [wiki](https://en.wikipedia.org/wiki/Time_series) definition of time series data is *a series of data points indexed (or listed or graphed) in time order*. When it comes to TSDB, I prefer my own definition: **store client history in server for analysis**.
Time series data is history, it's **immutable**, **unique** and **sortable**. 
For instance, the CPU usage at 2017-09-03-21:24:44 is 10.02% for machine-01 in us-east region, 
it won't change overtime like bank account balance, there will be no update on it, 
the CPU usage at next second, or from different machine are different data points. 
And the order of arriving at server is not that important since you can remove the duplicate and sort by client timestamp.
The history is from client and is used for analysis, while RDBMS is treated as single source of truth and effect client's decision making. 
This lead to very different read and write pattern. 
For instance, banking application need to query database for user's balance before proceed by reading and updating a single record.
But most TSDB clients are either write only (collectors) or read only (dashboard and alerting system). And when they read, they read in large batch,
`show CPU usage of last 1h` is used more often than `show CPU usage at 2017-09-03-21:24:44` because time series data is not that useful without its context.

Time series data is so different from what popular DBMS used to deal with that people are forced to use their favorite DB in unexpected ways (i.e. VividCortex with MySQL, Timescale with Postgres). Some decided for special problem special solution is needed, so many TSDBs are written from scratch (Graphite, InfluxDB etc.) without dependencies to existing databases.

## Time series data model

Time series data can be split into two parts, **series** and **data points**.
Series is the identifier, like `CPU usage for machine-01 in us-east region`, 
data points are an array of points where each point is a timestamp and value.

For series, the main goal is to make it friendly to post processing (searching, filtering etc.), 
like `top 10 CPU usage among all machines in us-east region`.
So `CPU usage for machine-01 in us-east region` becomes `name=cpu.usage machine=machine-01 region=en-us`, 
and the query becomes `name=cpu.usage machine=* region=en-us order desc limit 10`.
It order to deal with large amount of series and wildcard matching, (inverted) index is needed, 
some chose to use external search engine like ElasticSearch (Heroic), Solr (KairosDB).
Some chose to write their own (InfluxDB, Prometheus).

For data points there are two models, an array of points `[{t: 2017-09-03-21:24:44, v: 0.1002}, {t: 2017-09-03-21:24:45, v: 0.1012}]` 
or two arrays for timestamp and values respectively `[2017-09-03-21:24:44, 2017-09-03-21:24:45], [0.1002, 0.1012]`.
The former is row store, the latter is column store (not to be confused with column family).
When using existing database ([Cassandra](https://xephonhq.github.io/awesome-time-series-database/?language=All&backend=Cassandra), [HBase](https://xephonhq.github.io/awesome-time-series-database/?language=All&backend=HBase) etc.) as backend, the former is used more,
while for TSDB written from scratch, the latter is more popular.

## Types of Time series databases

Time series databases can be split into two types, existing databases with special schema to store time series data and databases designed to for time series data. We use KairosDB (based on Cassandra) and InfluxDB as example for following discussion.

## Reference

## License

- This article is licensed under [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/).
- Please contact <marketing@dongyue.io> for commerical use.
