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

<!-- TODO: TOC does not work, the generated HTML does not have id on headers ...-->

## Overview

Elasticsearch allows indexing nested object/document such as authors of a book `{name: Potato Slice, authors: [{name: Victor, dob: 1978}, {name: Sharon, dob: 1987}]`.
Under the hood it is using Lucene's index time join `ToParentBlockJoinQuery`. This blog talks about why
and how this work in Lucene and provides [example code that compiles in 2022](https://github.com/dyweb/blog-code/blob/main/2022-12-21-elasticsearch-lucene-index-time-join-nested-object/src/test/java/lucenejoin/LuceneIndexTimeJoinTest.java).

## Why

### Why write another blog

There are several blog posts on this topic (see appendix), but most of them have outdated example using deprecated classes.
Elasticsearch's doc [on nested](https://www.elastic.co/guide/en/elasticsearch/reference/current/nested.html)
does provide a good explanation on why and how to use but does not mention how lucene does it under the hood,
which is useful if you want to build a simple solution that cost less than using Elasticsearch.

### Why use nested

It is common to have a list of documents nested under one document. For example, a book can have several authors,
a shirt can have multiple color and sizes. When indexing these documents in Elasticsearch, you can send the document
directly, but the default index flatten the nested array of document/object and the search result is not expected.
Take shirt [from Michael's blog](https://blog.mikemccandless.com/2012/01/searching-relational-content-with.html)  as example:

The document in your application looks like this, one shirt have different sizes. `wolf` has two sizes, `dog` has one size.

```json
[{ // shirt
   "name": "wolf",
   "specs": [ // shirt specs
      { "color": "blue", "size": "small" },
      { "color": "green", "size": "medium" }
   ]
},
{ // shirt
  "name": "dog",
  "specs": [ // shirt specs
    { "color": "blue", "size": "small" }
  ]
}]
```

Sending this payload to Elasticsearch directly result in flattened document:

```json
[{
  "name": "wolf",
  "specs.color": ["blue", "red"],
  "specs.size": ["small", "medium"]
},
{
  "name": "dog",
  "specs.color": ["blue"],
  "specs.size": ["small"]
}]
```

There are a few interesting things here for people coming from a relational/document database background:

- One document field can have multiple values, in RDBMS and NoSQL database (e.g. MongoDB), 
  each row/document's column/field can only have one value. But if you consider searching text,
  every field is made from tokens broken from a long sentence/paragraph.

```json
{
  "title": ["How", "to", "foo"],
  "content": ["bar", "boar"]
}
```

- You cannot nest document directly like other NoSQL databases such as MongoDB.

### What happens when searching on flattened document

Now what happens when you search for `name = wolf & color = blue & size = medium` with the documents flattened?
From customer perspective, there should be no result, because the only blue shirt has size small
while the only medium shirt has color green. However, the first flattened document would match because
it has both `blue` and `medium` pointing to it. Let's check how the query works:

When there is a boolean query on multiple fields, first step is check inverted index of each field
then do a intersect/union on the result list. The inverted index after inserting flat document looks like this:

```text
index on spec.color:
blue: [0, 1]  green: [0]  

index on spec.size:
small: [0, 1]  medium: [0]
```

`blue` is the `term` and `[0, 1]` is the posting list, `0` is the id of document that includes the term.
`color = blue` returns `[0, 1]`, `size = medium` also returns `[0]`, the intersection is `[0]`.

## How nested works

Now we understand flatten does not yield expected search experience. How does the recommended `nested` works under the hood?
Elasticsearch's doc [on nested](https://www.elastic.co/guide/en/elasticsearch/reference/current/nested.html) says the following:

> Internally, nested objects index each object in the array as a separate hidden document, meaning that each nested object can be queried independently of the others with the nested query

This causes another confusion for people coming from a relational database background.
Does Elasticsearch create another 'table' for child document (i.e. normalize), save id of parent in child and do a join at query time?
The answer is no, `nested` is using index time join.
There are actually [two types of join in Lucene](https://github.com/apache/lucene/blob/3bc8cd5c20218821a50786b05ecfb0a01a1e3e2a/lucene/join/src/java/org/apache/lucene/search/join/package-info.java#L19),
one is index time join, another is query time join.
[Parent and child join](https://stackoverflow.com/questions/49941244/elastic-search-parent-child-vs-nested-document) in ES is using query time join,
which we skip due to length of the blog post.

Index time join is NOT another 'table' (index file),
both parent and child live in same index file (Lucene Segment).
Lucene is schemaless, document in same index file can have different fields, e.g. put a book and a shirt is same index is fine
(ES used to have [mapping types](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/removal-of-types.html)).
Parent and child are written into same index as individual documents in children-parent order
(why order like this is explained later). To distinguish parent and child in same index, application need to manually add extra field, e.g. `docType: shirt`, 
Lucene itself does not have any magical types or internal identifiers. The documents and inverted index look like following:

```text
0: { color: blue, size: small }
1: { color: green, size: medium }
2: { name: wolf, docType: shirt } // parent
-------- block ------------------
3: { color: blue, size: small }
4: { name: dog, docType: shirt } // parent
-------- block ------------------

index on docType:
shirt: [2, 4]      

index on name:
wolf: [2]   dog: [4]     

index on color:
blue: [0, 3] green: [1]

index on size:
small: [0, 3]  medium: [1]
```

To get the parent documents in the index, simply run a `Query` e.g. `docType = shirt` returns `{2, 4}`.
Child query is same, another `Query` on child specific fields to return list of matched children.
In the end do a join from child to parent to return the matched parent document via `ToParentBlockJoinQuery`.
The full code snippet looks like following:

```java
public class LuceneIndexTimeJoinTest {
    public void testSearchNestedMatch() throws IOException {
        // ...
      
        // Insert docs as block
        List<Shirt> shirts = makeShirts();
        for (Shirt shirt : shirts) {
          List<Document> block = new ArrayList<>();
          // First insert children
          for (ShirtSpec spec : shirt.specs) {
            block.add(spec.toDocument());
          }
          // Add parent in the end
          block.add(shirt.toDocument());
          // Write children and parent in one transaction
          indexWriter.addDocuments(block);
        }
        indexWriter.commit();

        // ...
      
        // Filter out parent document using this query
        BitSetProducer parentsFilter = new QueryBitSetProducer(new TermQuery(new Term("docType", "shirt")));
        // Should match some child
        BooleanQuery childQuery = new BooleanQuery.Builder()
                .add(new BooleanClause(new TermQuery(new Term("color", "blue")), BooleanClause.Occur.MUST))
                .add(new BooleanClause(new TermQuery(new Term("size", "small")), BooleanClause.Occur.MUST))
                .build();
    
        // Join matched children to their parent document, search result is parent document, NOT matched children.
        ToParentBlockJoinQuery childJoinQuery = new ToParentBlockJoinQuery(childQuery, parentsFilter, ScoreMode.Avg);
        Query parentQuery = new TermQuery(new Term("name", "wolf"));
    
        BooleanQuery fullQuery = new BooleanQuery.Builder()
                .add(new BooleanClause(parentQuery, BooleanClause.Occur.MUST))
                .add(new BooleanClause(childJoinQuery, BooleanClause.Occur.MUST))
                .build();
        // ...
    }
}
```

### How to find parent id without saving it in child

Query either parent or child alone is trivial and has no difference with normal queries.
The hard part is combining query results from both parent and child to get intersection. 
The join `ToParentBlockJoinQuery` is called index time join because inside child document there is NO parent document id,
i.e. it is `{ color: blue, size: small}` NOT `{ parentShirtId: 1, color: blue, size: small}`.
So how does Lucene know the parent doc id from a matched child doc?
The code is [parentBits.nextSetBit](https://github.com/apache/lucene/blob/6cde41c9fd8c40a468fbeb32016a210f696b378e/lucene/join/src/java/org/apache/lucene/search/join/ToParentBlockJoinQuery.java#L236).
The iterator is looking at a bitset of parents to determine the parent from child doc id.

```java
private static class ParentApproximation extends DocIdSetIterator {
  @Override
  public int advance(int target) throws IOException {
    final int firstChildTarget = target == 0 ? 0 : parentBits.prevSetBit(target - 1) + 1;
    int childDoc = childApproximation.docID();
    if (childDoc < firstChildTarget) {
      childDoc = childApproximation.advance(firstChildTarget);
    }
    if (childDoc >= parentBits.length() - 1) {
      return doc = NO_MORE_DOCS;
    }
    return doc = parentBits.nextSetBit(childDoc + 1);
  }
}
```

Why the next id in parent bitset after child doc id is the parent the child?
The is explained in the javadoc of `ToParentBlockJoinQuery`:

> This query requires that you index children and parent docs as a single block, using the IndexWriter.addDocuments() or IndexWriter.updateDocuments() API. 
> In each block, the child documents must appear first, ending with the parent document. At search time you provide a Filter identifying the parents, however this Filter must provide an BitSet per sub-reader.


Using the following documents as example. When writing document, first write child then write parent but use single
`addDocuments` call instead of calling `addDocument` in a for loop. Documents got sequential increasing id.

```text
0: { color: blue, size: small }
1: { color: green, size: medium }
2: { name: wolf, docType: shirt } // parent
-------- block ------------------
3: { color: blue, size: small }
4: { name: dog, docType: shirt } // parent
-------- block ------------------
```

The parent filter is a (cached) query `docType = shirt`, it would return matched doc `2` and `4` as a bitset `[0, 0, 1, 0, 1]`.
The child query is `color = blue & size = small` that matches doc `0` and `3`. 
First child is `0`, the next set (non-zero) bit in parents is `2`.

```text
docId:   0 1 2 3 4  
parents: 0 0 1 0 1
         ^   ^
matched child parent 
```

Iterator then move on to next child doc `3`, the next set bit after `3` is `4`. The search result is `2` and `4`.

### Get matched children instead of parent 

One thing to be aware of is `ToParentBlockJoinQuery` returns the doc id of parents and does NOT include ids of matched children
(although that's how we get the parent in the first place). To get the children, you need to do another join for EACH matched parent using `ParentChildrenBlockJoinQuery`.

```java
public class LuceneIndexTimeJoinTest {
    public void testSearchNestedMatch() throws IOException {
        TopDocs topDocs = indexSearcher.search(fullQuery, 10);
        System.out.println("name=wolf & color=blue & size=small hit on nested " + topDocs.totalHits.value); // 0
        for (ScoreDoc scoreDoc : topDocs.scoreDocs) {
          Document doc = indexSearcher.doc(scoreDoc.doc);
          System.out.println("parent doc=" + scoreDoc.doc + " name=" + doc.get("name"));
  
          // Get the actual child docs that matches under this parent doc
          ParentChildrenBlockJoinQuery childrenQuery = new ParentChildrenBlockJoinQuery(parentsFilter,
                  childQuery, scoreDoc.doc);
          TopDocs matchingChildren = indexSearcher.search(childrenQuery, 10);
          for (ScoreDoc child : matchingChildren.scoreDocs) {
            Document childDoc = indexSearcher.doc(child.doc);
            System.out.println("child doc=" + child.doc + " color=" + childDoc.get("color") + " size=" + childDoc.get("size"));
          }
        }
        // NOTE: parent doc id is larger than child, it is actually increase from 0, see makeShirts
        // name=wolf & color=blue & size=small hit on nested 1
        // parent doc=3 name=wolf
        // child doc=0 color=blue size=small
    }
}
```

## Elasticsearch's nested logic

TBH I didn't speed too much time on reading ES's code after I found the unit test from lucene join module,
which is much easier to understand...

The overall flow of ES is first run query (on multiple nodes' multiple shards), then collect the matched result
after the collector node does some transformation on search result.

- [NestedQueryBuilder](https://github.com/elastic/elasticsearch/blob/ddbd7a8263975f52b9244ffa808b29ca226505d4/server/src/main/java/org/elasticsearch/index/query/NestedQueryBuilder.java#L54)
  generates the lucene query, uses `ParentChildrenBlockJoinQuery`.
- [ESToParentBlockJoinQuery](https://github.com/elastic/elasticsearch/blob/0350307fb1c48a5604dc5d11ce63c03437b0a357/server/src/main/java/org/elasticsearch/index/search/ESToParentBlockJoinQuery.java#L25)
  wraps`ToParentBlockJoinQuery` to save the nested path.
- [NestedAggregator](https://github.com/elastic/elasticsearch/blob/ddbd7a8263975f52b9244ffa808b29ca226505d4/server/src/main/java/org/elasticsearch/search/aggregations/bucket/nested/NestedAggregator.java#L41)
  collects the matched document.


## Conclusion

- `nested` saves parent and child as seperated document but still in same Lucene index file (Segment). 
- Application need to insert extra field (with a constant value e.g. `docType: shirt`) to mark a parent document as parent.
  This extra field is indexed (does not need to be stored) for getting all parents as a bitset.
- The order of parent children allow getting parent id from child id without saving parent id in child document,
  this order requires writing documents to index writer using the 'batch' `addDocuments` method.

## Appendix

### Example Code

- Blog's code [dyweb/blog-code/2022-12-21-elasticsearch-lucene-index-time-join-nested-object](https://github.com/dyweb/blog-code/blob/main/2022-12-21-elasticsearch-lucene-index-time-join-nested-object/src/test/java/lucenejoin/LuceneIndexTimeJoinTest.java)
- Lucene [unit test](https://github.com/apache/lucene/blob/47f8c1baa2e8d25fd60c886ec7ce09a81ee7d668/lucene/join/src/test/org/apache/lucene/search/join/TestBlockJoin.java#L96)

### Block Join

- [Searching relational content with Lucene's BlockJoinQuery](https://blog.mikemccandless.com/2012/01/searching-relational-content-with.html) 2012 when first introduced
- [lucene join解决父子关系索引](https://www.cnblogs.com/LBSer/p/4417074.html) 2015, in Chinese, good example but sample code uses deprecated classes.
- Solr
  - [Nested objects in Solr](https://yonik.com/solr-nested-objects/) 2016
  - [How to use Block Join to improve search efficiency with nested documents in Solr](https://blog.griddynamics.com/how-to-use-block-join-to-improve-search-efficiency-with-nested-documents-in-solr/)

### Nested vs Parent Child

- [Elasticsearch Nested vs Parent Child](https://stackoverflow.com/questions/49941244/elastic-search-parent-child-vs-nested-document) SO question
- [Chapter 42. Parent-Child Relationship](https://learning.oreilly.com/library/view/elasticsearch-the-definitive/9781449358532/part06ch03.html#parent-child-mapping) of ES definitive guide

> The parent-child relationship is similar in nature to the nested model: both allow you to associate one entity with another. 
> The difference is that, with nested objects, all entities live within the same document while, with parent-child, 
> the parent and children are completely separate documents

### Things we didn't cover

There are some topic I want to cover but does not have time:

- The performance of index time join vs query time join.
- How to model your document and query so the join is efficient, e.g. there is also `ToChildBlockJoinQuery`
- How other search index library are solving this problem, there are many new libraries in Go and Rust. 

## License

- This article is licensed under [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/).
- Please contact <marketing@dongyue.io> for commercial use.
