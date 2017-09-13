title: "Introduction to Time Series Database"
date: 2017-07-09 01:03:27 +0000
update: 2017-07-09 01:03:27 +0000
author: at15
# NOTE: the image locate in `source` folder
# cover: "-/images/posts/example.png"
tags:
    - tsdb
    - "time series"
    - "time series database"
    - database
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
And the order of data arriving at server is not that important since you can remove the duplicate and sort by client timestamp.
Clients of TSDB send their history to sever and is still functional when the server is down, 
while RDBMS is treated as single source of truth and effect client's decision making. 
This lead to very different read and write pattern. 
For instance, banking application need to query database for user's balance before proceed by reading and updating a single record.
But most TSDB clients are either write only (collectors) or read only (dashboard and alerting system). 
And when they read, they read in large batch, `show CPU usage of last 1h` is used more often than `show CPU usage at 2017-09-03-21:24:44` 
because time series data is not that useful without its context.

Time series data is so different from what popular DBMS used to deal with that people are forced to use their favorite DB in very different ways (i.e. VividCortex with MySQL, Timescale with Postgres). 
Some decided for special problem special solution is needed, so many TSDBs are written from scratch (Graphite, InfluxDB etc.) without dependencies to existing databases.

## Time series data model

Time series data can be split into two parts, **series** and **data points**.
Series is the identifier, like `CPU usage for machine-01 in us-east region`, 
data points are an array of points where each point is a timestamp and value.

For series, the main goal is the extensibility for post processing (searching, filtering etc.).
i.e. If you want `top 10 CPU usage among all machines in us-east region`,
the identifier of `CPU usage for machine-01 in us-east region` is `name=cpu.usage machine=machine-01 region=en-us`, 
and the query becomes `name=cpu.usage machine=* region=en-us order by value desc limit 10`.
It order to deal with large amount of series and wildcard matching, (inverted) index is needed,
some chose to use external search engine like ElasticSearch (Heroic), Solr (KairosDB).
Some chose to write their own (InfluxDB, Prometheus).

For data points there are two models, an array of points `[{t: 2017-09-03-21:24:44, v: 0.1002}, {t: 2017-09-03-21:24:45, v: 0.1012}]` 
or two arrays for timestamp and values respectively `[2017-09-03-21:24:44, 2017-09-03-21:24:45], [0.1002, 0.1012]`.
The former is row store, the latter is column store (not to be confused with column family).
When building TSDB on top of existing databases ([Cassandra](https://xephonhq.github.io/awesome-time-series-database/?language=All&backend=Cassandra), [HBase](https://xephonhq.github.io/awesome-time-series-database/?language=All&backend=HBase) etc.), the former is used more,
while for TSDB written from scratch, the latter is more popular.

## Evolve of Time series database

## Types of Time series databases

Time series databases can be split into two types, existing databases with time series specific special schema or databases designed to for time series data. We use Xephon-K (based on Cassandra modeled after KairosDB) and InfluxDB as example for following discussion.

### Xephon-K

[Xephon-K](https://github.com/xephonhq/xephon-k) is a multi backend time series database 
I wrote for testing out different mechanism of building TSDB.
Its immature Cassandra backend is simple and modeled after [KairosDB](https://kairosdb.github.io/).

Cassandra (C*) is a column family NoSQL database modeled after BigTable, people sometimes call it **wide column**. 
You can think column family as a map of map of map. 
We can match some concept of it to RDBMS.
`Keyspace` in C* is database in RDBMS, i.e. you create different database for you blog and ecommerce application for isolation.
`Table` in C* is a map and `Partition Key` is its key, also known as (physical) row key, which is used to partition data to different nodes.
The value of the top level map is also map, and its key is the `Cluster key` (column), its value is also a map.
When creating a table in CQL, the first column is partition key and the second is cluster key. i.e. In the following CQL, 
`Keyspace` is `naive`, `Table` is `metrics`, `Partition Key` is `metric_name`, `Cluster Key` is `metrics_timestamp`, 
the inner most map is `{value: 10.2}`, we can have more than one keys for it if needed, i.e. `{value: 10.2, annotation: 'new app deployed'}`

````sql
CREATE TABLE IF NOT EXISTS naive.metrics (
    metric_name text, metric_timestamp timestamp, value int, 
    PRIMARY KEY (metric_name, metric_timestamp))
INSERT INTO naive.metrics (metric_name, metric_timestamp, value) VALUES (cpu, 2017/03/17:13:24:00:20, 10.2)    
INSERT INTO naive.metrics (metric_name, metric_timestamp, value) VALUES (mem, 2017/03/17:13:24:00:20, 80.3)   
````

![Cassandra Time Series Data model](images/posts/cassandra-tsdb-model.png)

The figure above shows a naive schema when using Cassandra to store time series data, it is naive because series and Cassandra's physical row is a one-to-one mapping, it won't scale when a single series grows larger than the hard limit of Cassandra (2 billion columns). 
Cluster key is used to store timestamp and column value is the actual value. 
A more mature schema would partition a single series by time range (might not be fixed, KairosDB use fixed 3 week time range) into several physical rows, an extra table is needed to keep this partition info. 
Also the series name in naive schema is just a simple string, in order to filter series by different criteria, attributes (tags) need to be stored, and another table as index is needed to avoid iterate all the series. 

KairosDB's schema is listed below, the `data_points` table is same as `metrics` table in naive schema except `key` is 
not for human like `metric_name` does. The naming of schema looks strange because it is dumped from Cassandra's shell (cqlsh), 
KairosDB didn't use a cql file to create schema like many other does because it was using the old thrift API.

````sql
CREATE TABLE IF NOT EXISTS data_points (
    key blob,
    column1 blob,
    value blob,
    PRIMARY KEY ((key), column1)
) WITH COMPACT STORAGE;
CREATE TABLE IF NOT EXISTS row_key_index (
    key blob,
    column1 blob,
    value blob,
    PRIMARY KEY ((key), column1)
) WITH COMPACT STORAGE;
CREATE TABLE IF NOT EXISTS row_key_time_index (
    metric text,
    row_time timestamp,
    value text,
    PRIMARY KEY ((metric), row_time)
)
CREATE TABLE IF NOT EXISTS row_keys (
    metric text,
    row_time timestamp,
    data_type text,
    tags frozen<map<text, text>>,
    value text,
    PRIMARY KEY ((metric, row_time), data_type, tags)
)
CREATE TABLE IF NOT EXISTS string_index (
    key blob,
    column1 blob,
    value blob,
    PRIMARY KEY ((key), column1)
) WITH COMPACT STORAGE
````

There are many more Cassandra based time series databases, they share very similar schema, you can find in [awesome time series database](https://xephonhq.github.io/awesome-time-series-database/?language=All&backend=Cassandra). I am writing a new blog for more detailed survey on TSDB using Cassandra and how to write your own in Golang, I will update the link here once it's finished.

### InfluxDB

[InfluxDB](https://github.com/influxdata/influxdb) has [struggled a long time for their storage engine](https://docs.influxdata.com/influxdb/v1.3/concepts/storage_engine/) (leveldb, rocksdb, boltdb) before they settled with their time structured merge tree (TSM Tree). It can be separate into two parts, index for series identifiers and store for data points, we only focus on data points.

Time structure merge tree, is a little bit misleading as log structured merge tree. The key concept for both TSM and LSM is nor log or tree or time,
it's **merge**. When write, data is stored in memory and then flushed to disk in large batch. When read, first read from memory, then read from disk and merge the result. When delete a tombstone is added, and data with tombstone. In background, small chunks are merged into big chunks and items marked as deleted are truly removed to save disk space and speed up future query, this background procedure is called compaction. For time series data, compaction may increase compression ratio a lot for very regular data.

A simplified version of TSM file is illustrated below, each chunk contains the series identifier, timestamps and values. 
Note that timestamps and values are stored separately instead of interleaved, which is why InfluxDB say they are using column format.
InfluxDB use adaptive compression for data, it will loop through the data to see if it can be run length encoded, otherwise fallback to 
[Gorilla's](https://github.com/dgryski/go-tsz) or variable length encoding. Timestamps and value use different compression codec because
timestamps are normally very big integers (unix timestamp in millisecond or nanosecond) while value are normally small integer or float.

````
chunk
--------------------------------------------------
| id | compressed timestamps | compressed values |
--------------------------------------------------
tsm file
-------------------------------------------------------------------
| header | chunk 0 | chunk 1 | ... | chunk 10086 | index | footer |
-------------------------------------------------------------------
````

## Hot topics in Time series databases

### Fast response

Time series database is used for analysis, and people don't want to wait in front of dashboard when production system is failing and 
user's complain phone coming in, so fast response is a base requirement for any production ready time series database.

The most straight forward way is to put data into memory as much as possible.
Facebook built Gorilla, now open sourced as [Beringei](https://github.com/facebookincubator/beringei), 
and its main contribution is using time series specific compression to store more data in memory.

Another way for speed up is pre-aggregation, also known as roll up. Because query often involve a long time range with coarse granularity, like
`average daily cpu usage from June 1 to Aug 1`, those aggregations (average, min, max) can be computed when ingesting data, [BtrDB](https://github.com/SoftwareDefinedBuildings/btrdb) and [Akumuli](https://github.com/akumuli/Akumuli) store aggregation in upper level tree nodes so fine grained data won't be loaded when query is coarse grained.

A proper ingest format could also reduce response time for both read and write, JSON is widely used, but Binary format is much better than textual format when a lot of number is involved, [protobuf](https://github.com/golang/protobuf/) could be a good choice.

<!-- ### Compression -->

### Retention

Not all time series data is useful all time, if the system has been working well for the last two month, fine grained data can be dropped and only coarse grained is kept. 
This is the default behavior of [RDDTool](https://oss.oetiker.ch/rrdtool/) and [Graphite](https://graphiteapp.org/), 
but not the case for many newer scaled TSDB.
Delete a file on local disk is easy but update a large amount of data in a distributed environment requires more caution to keep the system up all time, you don't want your monitoring systems failed before the system it is monitoring failed.

<!-- Also should the aggregated data get computed when data comes in or  -->

### Meta data indexing

Series identifier in general is the only meta data in time series database.
Databases like [Heroic](https://github.com/spotify/heroic) use ElasticSearch to store meta data, 
query first goes to elasticsearch to retrieve the id for series, then data is loaded from Cassandra using id.
A full search engine as Elasticsearch is powerful for sure, but the overhead of maintain another system and time spent
coordinating and communicating between two system can't be ignored. 
Also some TSDB specific optimization may not be available when you don't have full control over metadata index building and storage.
So InfluxDB and Prometheus [wrote their own inverted index for indexing meta data](https://fabxc.org/blog/2017-04-10-writing-a-tsdb/).

<!-- ### Reduce write amplification -->
<!-- ### Streaming -->
<!-- Streaming has been hot for a long time, you must have heard Storm, Spark Streaming, Kafka etc. -->

### Tracing

Folks from InfluxDB wrote a blog called [Metrics are dead](https://www.influxdata.com/blog/metrics-are-dead/) 
because during a conference for monitoring called [Monitorama](http://monitorama.com/) people say metrics can't provide enough insight as tracing does. 
(You can go to [OpenTracing](http://opentracing.io/) if you want to know more about tracing, and take a look at google's [Dapper paper](https://research.google.com/pubs/pub36356.html))
Their argument is tracing is for large scale distributed system, but there are many monolithic applications where metrics is enough (so metrics is not dead and you should use InfluxDB).
I agree with them on the over emphasis of micro services, however my argument is **many time series database can be transfered into a tracing database**. 
Trace is a complex version of time series data points, 
if your value in a point is no longer a float value but a json payload with fields like parent span id, duration, it is a trace. 
Of course schema design, compression all need a lot of change, but many popular tracing solution like [Zipkin](https://github.com/openzipkin/zipkin)
, [Uber Jaeger](https://uber.github.io/jaeger/) is also using Cassandra like many TSDB do, there could be a middle ground.

Update: InfluxDB already [tried to integrate Zipkin with their TICK stack](https://www.influxdata.com/blog/tracing-the-journey-of-a-transaction-as-it-propagates-through-a-distributed-system/)
I spent too much time writing this blog.

Because the length of the blog we can't cover other hot topics like Compression, Pull vs Push, Streaming, Reduce write amplification etc,
they will be covered in future blogs.

## Reference

- [Awesome Time Series Database](https://github.com/xephonhq/awesome-time-series-database)

## License

- This article is licensed under [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/).
- Please contact <marketing@dongyue.io> for commerical use.
