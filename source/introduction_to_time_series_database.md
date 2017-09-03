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
so its targeted readers are people who have learned database in class and have some interest in time series database (TSDB).

<!-- TODO: toc -->

## Background

**TL;DR** Time series data is immutable so TSDB can solve hard problems like
concurrency control, distributed consensus as RDBMS, NoSQL in easier way.

### What is database

Let's first recap what is database. We know there are different types of databases (RDBMS, NoSQL, NewSQL).
They have different properties, [ACID](https://en.wikipedia.org/wiki/ACID), horizontal scale etc.
They use different storage media (memory, flash, hard drive) with different format (row, column, column-family).

However, the essence of database is simply persistent your data at somewhere with some guarantee.
They become complex because they want to offer better guarantee to meet the growing need from users.
A single json file can be a database when you are the only one modifying it.
When more processes start modifying it, a server is added so no user touch the file directly,
concurrency control is also added so users don't see strange things.
When one machine can no longer hold the data, more machine is added, the database becomes distributed,
along with all the troubles of distributed system, consensus etc.
Concurrency control, consensus etc. are all hard problems, many databases promise they did well,
while they may not ([jepsen](http://jepsen.io/)).

> Don't make a girl a promise if you know you can't keep it (Halo 4)

> Keep the consistency between landing page, documentation and implementation is the new CAP

But users are not expecting TSDB to solve those hard problems,
so what are they expecting exactly?
To answer this question, we first need to know the use cases of TSDB and its characteristics.

### What are Time Series Databases used for

The oldest time series database is round robin database
[RRDtool](https://oss.oetiker.ch/rrdtool/).
Its modern successor [Graphite](https://graphiteapp.org/) is widely adopted by
companies for system monitoring. In fact, almost all time series database were
<!-- TODO: word ...  -->
built for monitoring, from computers running in data centers to smart devices in

## Reference

## License

- This article is licensed under [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/).
- Please contact <marketing@dongyue.io> for commerical use.
