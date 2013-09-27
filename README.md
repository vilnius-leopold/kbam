K'bam!
======

### Description
K'bam! is MySQL query string builder, featuring statement chaining and ?-escaping.

### What it does

it turns this 
``` 
	Kbam.new.from('posts')
		.select('title, author, date, text')
		.limit(10)
		.order('date') 
		.where('author = ?', 'john')
```
into this
``` 
SELECT title, author, date, text FROM posts WHERE author = 'john' ORDER BY date ASC LIMIT 10 
```

### For whom is K'bam!?
K'bam! is for those that feel comfortable with raw SQL statements, but don't want to go into the effort of sanatizing every variable and want to enjoy the convenience of random (order) statement chaining.

###Features
- random (order) statement chaining
- variable sanatization
- you are not forced to use any defined database structure as required by many ORMs
- K'bam! is fast and does't constrain you.
- K'bam! has no uneccassary overhead and provides full access and suport for MySQL through the mysql2 apdater.
- nested queries



#### Nested queries
```
	nested_where = Kbam.new.where('user_name = ?', 'Olympia').and('id = ?', 120)

	comment_query = Kbam.new.from(:comments)
		.limit(10)
		.order(:created)
		.where('user_name = ?', 'john').or(nested_where)
	
	#=> SELECT * FROM comments WHERE user_name = 'john' OR (user_name = 'Olympia' AND id = 120) ORDER BY `created` ASC LIMIT 10

	#Isn't that f***ing awesome!?

```
### Functions

#### where

```
	string = "user_name = ?" # or also: "user_name = ? AND id = ?"
	vars = "john" # can take array, single and multiple arguments

	.where(string, vars)
	
	#=> WHERE user_name = 'john'
```
Aliases  
		.and(string, vars)



### The reason to build K'bam!
I tried Datamapper, ActiveRecord and Sequel when working on a project. The database requirements for this project were rather simple, but for some reason all these ORMs had trouble with the one or the other MySQL / Databse feature. Either they didn't support the following or to achieve it, it needed a big work around that would have been extremely simple in raw MySQL. And on top - they where often slow.
- using String as a primary key
- multiple join tables
- joining tables not on primary key 'id' and foreign key 'other_table_id'
- ordering by field of a join table
- using conditions for a join table
- nested where statement like WHERE a AND (b OR c)
- using a MySQL function in a SELECT or WHERE statement
- renaming fields (using AS)
- counting entire dataset (using SQL_CALC_FOUND_ROWS)
- nested select statements SELECT ... FROM (SELECT ... FROM ...) AS t 
