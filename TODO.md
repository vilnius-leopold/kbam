TODO
----
- [x] merge office modifications
- [x] add some docs
- [x] find solution for nested queries (nested query string insertion --> hashtag --> no escape?!) --> Kbam class functions? --> empty after .slq call?
- [x] add lincens --> is MIT the best solution?
- [x] add alias for get: fetch
- [x] query + execute
- [x] group, having
- [x] multiple queries, single connect
- [x] insert
- [x] update
- [x] finish implementing nested where
	- [ ] refractor and double check syntax, redundancies
- [x] add verbose / debug mode / output
	- [x] added error, warning, log 
- [x] make first (alpha) release
- [ ] add entire docs
- [ ] Instance separtion when using same connection class --> count problems
- [ ] finish implementing nested queries
- [ ] query hooks? insert raw sql in between query?!
- [ ] separate statement compose?! --> e.g. only where clause --> usage?
- [ ] make all implementations and APIs consistent (update and insert)
- [ ] what about unit-testing! --> check it out!
	- [ ] set up test db
	- [ ] add test queries, kbam <==> raw sql testing
- [ ] check security
- [ ] kbam class functions for query string composition
- [ ] reformat query format --> inverted query debug
- [ ] distinguish public/private class/instance methods
- [ ] general clean up / restructure
- [x] try / use https://github.com/sonota/anbt-sql-formatter for sql clean-up ==> SUCKS