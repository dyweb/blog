title: "How Elasticsearch uses Lucene index time join to handle nested objects"
date: 2022-12-21 22:12:45 +0000
update: 2022-12-21 22:12:45 +0000
author: at15
tags:
- database
- search
- elasticsearch
- lucene
preview: "Elasticsearch's nested type uses Lucene's index time join to filter on nested objects to avoid invalid result from flattening."
---

## TODO

- [ ] index time join
- [ ] es code walk through, this is not the main goal though ...

Example code is [dyweb/blog-code/2022-12-21-elasticsearch-lucene-index-time-join-nested-object](https://github.com/dyweb/blog-code/blob/main/2022-12-21-elasticsearch-lucene-index-time-join-nested-object/src/test/java/lucenejoin/LuceneIndexTimeJoinTest.java)

## Why

### Why write another blog

There are several blog posts on this topic (see appendix), but most of them have outdated example using deprecated classes.
Elasticsearch's doc [on nested](https://www.elastic.co/guide/en/elasticsearch/reference/current/nested.html)
does provide a good explanation but does not mention how lucene does it.

### Why use nested

It is common to have a list of documents nested under one document. For example, a book can have several authors,
a shirt can have multiple color and sizes. When indexing these documents in Elasticsearch, you can send the document
directly, but the default index flatten the nested array of document/object and the search result is not expected.
Take shirt [from Michael's blog](https://blog.mikemccandless.com/2012/01/searching-relational-content-with.html)  as example:

The document in your application looks like this, one shirt have different sizes.

```json
{ // shirt
   "name": "wolf",
   "specs": [ // shirt specs
      { "color": "blue", "size": "small" },
      { "color": "green", "size": "medium" }
   ]
}
```

Sending this payload to Elasticsearch directly result in flattened document:

```json
{
   "name": "wolf",
  "specs.color": ["blue", "red"],
  "specs.size": ["small", "medium"]
}
```

There are a few interesting things here for people coming from a relational/document database background:

- One document field can have multiple values, in RDBMS and NoSQL database (e.g. MongoDB), 
  each row/document's column/field can only have one value. But if you about searching text,
  every field is made from tokens broken from a long sentence/paragraph.

```json
{
   "title": ["How", "to", "foo"],
   "content": ["bar", "boar"]
}
```

- You cannot nest document directly like MongoDB (and other NoSQL databases).

### What happens when searching on flattened document

Now what happens when you search for `name = wolf & color = blue & size = medium`?
From customer perspective, there should be no result, because the only blue shirt has size small
while the only medium shirt has color green. However, the flattened document would match because
it has both `blue` and `medium` pointing to it. Let's check how the query works:

When there is a boolean query on multiple fields, first step is check inverted index of each field
then do a intersect/union on the result list. The inverted index after inserting flat document looks like this:


```text
Dictionary for field spec.color:
        root
red: [1]   blue: [1]

Dictionary for field spec.size:
        root
small: [1]  medium: [1]
```

`red` is the `term` and `[1]` is the posting list, `1` is the id of document that includes the term.
`color = blue` returns `[1]`, `size = medium` also returns `[1]`, the intersection is still `[1]`.

## How nested works

Now we understand flatten does not yield expected search experience. How does the recommended `nested` work under the hood.
Elasticsearch's doc [on nested](https://www.elastic.co/guide/en/elasticsearch/reference/current/nested.html) says the following:

> Internally, nested objects index each object in the array as a separate hidden document, meaning that each nested object can be queried independently of the others with the nested query

This causes another confusion for people coming from a relational database background.
Does Elasticsearch create another 'table' for child document (i.e. normalize) and do a join at query time.
There are actually [two types of join in Lucene](https://github.com/apache/lucene/blob/3bc8cd5c20218821a50786b05ecfb0a01a1e3e2a/lucene/join/src/java/org/apache/lucene/search/join/package-info.java#L19),
one is index time join, another is query time join. `nested` is using index time join.
Index time join is NOT another 'table' (index file), both parent and child live in same index file (Lucene Segment).
Lucene is schemaless, document in same index file can have different fields, e.g. put a book and a shirt is same index is fine.
To distinguish parent and child in same index, application need to manually add extra field, e.g. `docType: parent`.

TODO: explain more on the id etc. https://github.com/apache/lucene/blob/6cde41c9fd8c40a468fbeb32016a210f696b378e/lucene/join/src/java/org/apache/lucene/search/join/ToParentBlockJoinQuery.java#L236


## Links

## Example Code

TODO: create a sample code repo, or just use same repo to save sample code