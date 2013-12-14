K'bam!
======

## Description
K'bam! is MySQL query string builder featuring statement chaining, nesting and sanatization.  
K'bam is still in developement but you can test it already. I'd be happy about your feedback.

### What it does

it turns this 
```ruby
	Kbam.new.from('posts')
		.select('title, author, date, text')
		.limit(10)
		.order('date') 
		.where('author = ?', 'john')
```
into this
```sql
SELECT title, author, date, text 
FROM posts 
WHERE author = 'john' 
ORDER BY date ASC 
LIMIT 10 
```

## For whom is K'bam!?
K'bam! is for those that feel comfortable with raw SQL statements, but don't want to go into the effort of sanatizing every variable and want to enjoy the convenience of random (order) statement chaining.

##Features
- random (order) statement chaining
- variable sanatization
- you are not forced to use any defined database structure as required by many ORMs
- K'bam! is fast and does't constrain you.
- K'bam! has no uneccassary overhead and provides full access and suport for MySQL through the mysql2 apdater.
- nested queries
- K'bam! has rich syntax and alias functions - use it as you like

## Usage
```ruby
# your database credentials
db_credentials = {
	:host     => 'localhost',
	:database => 'db_name',
	:username => 'root',
	:password => 'Kbam_roX!'
}

#Let K'bam! connect to the database
Kbam.connect(db_credentials)

# compose your query
comment_query = Kbam.new.from(:comments)
	.order(:created, :desc)
	.where(:user_name, 'leo')
	.limit(10)

# fetch the comments
comments = comment_query.get
# you can also ommit .get
# and just run .each, it will do the same

# count comments 
total_comments = comment_query.total
count_comments = comment_query.count

# print the result
comments.each do |comment|
	puts comment
end

```


## Examples

#### Nested where
```ruby
nested_where = Kbam.new.where(:user_name, 'Olympia').and(:id >= 120)

Kbam.new.from(:comments)
	.where("user_name = ?", 'john')
	.or(nested_where)

#=> SELECT * FROM comments
# WHERE `user_name` = 'john' OR (`user_name` = 'Olympia' AND `id` >= 120)
```

#### Subquery
```ruby
sub_query = Kbam.new.from(:comments).select(:user_name, :id, :created)

Kbam.new.from(sub_query.as("sub_table"))

#=> SELECT * FROM (
# SELECT user_name, id, created FROM comments LIMIT 1000 
# ) AS sub_table
```

#### Syntax sugar (still experimental)
```ruby
# you can use >= <= < > in where clauses
# by default sugar is turned off
# to turn it on just type:
Kbam.sugar_please!

# query with sugar ;)
Kbam.new.from(:comments).where(:user_name, 'Olympia').and(:id >= 120)

#=> SELECT * FROM comments WHERE `user_name` = 'Olympia' AND `id` >= 120
```

## Functions

### Composing Functions

#### select

```ruby
# can take array, single and multiple arguments
.select("fullname AS name", ["age", "birth"])

# or chain it
.select("fullname AS name").select(["age", "birth"])

#=> SELECT fullname AS name, age, birth

# if empty or omitted
#=> SELECT *

```


#### where

```ruby
string = "user_name = ?" # or also: "user_name = ? AND id = ?"
vars = "john"            # can take array, single and multiple arguments

.where(string, vars)

#=> WHERE ... AND user_name = 'john'
```
Aliases  
`.and`

#### or_where

```ruby

.or_where(string, vars)

#=> WHERE ... OR user_name = 'john'
```
Aliases  
`.or`  
`.where_or`

#### limit

```ruby

.limit(10)

#=> LIMIT 10

# default limit 1000

```
#### offset

```ruby

.offset(50)

#=> OFFSET 50
```

### Retrieving Functions

#### get

```ruby
# retrieves posts
posts = Kbam.new.from("posts").get
#=> 10

# you can also do
.get(:hash), .get(:array), .get(:json)
# hash is default
```
Aliases  
`.fetch`

#### each

```ruby
# no need to call get before each
Kbam.new.from("posts").each do |post|
	puts post
end
#=> 10
```

#### count

```ruby
# counts only posts in current result set
Kbam.new.from("posts").limit(10).count
#=> 10
```
Aliases  
`.length`

#### total

```ruby
# counts all posts irrespective of the current resultset
Kbam.new.from("posts").limit(10).total
#=> 327
```

### Helper Functions

#### escape

```ruby
# escapes string
Kbam.escape(dirty_string)
```
Aliases  
`.esc`

## The reason to build K'bam!
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


##License

The MIT License (MIT)  
  
Copyright (c) 2013 Leopold Burdyl-Strohmann  
  
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:  
  
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.  
  
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.