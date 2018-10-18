### Bed-and-Breakfast Voting System

#### The System

The system consists of a rabbitMQ server and two application components:

* Vote Monitor.  This is a headless service that listens for Vote messages posted
through a rabbitMQ queue, and which POSTs a vote for each such message to...

* B&B Voting API Server.  This is an API-only Rails application that provides access to
two resources:

  - You can create a Vote for a named Bed-and-Breakfast.  The "vote" is a numerical value.
It can be a positive or negative integer (or zero, although a zero-vote doesn't accomplish anything useful).

  - You can obtain a list of B&Bs that have been voted upon, each with the total votes from its voters.

Here're are some things the system does *not* provide:

* It has no pre-existing set of B&Bs.  It only knows about B&Bs for which at least one vote has
been cast.

* It provides no view of the per-voter votes for each B&B.  I provides only the total number of
votes for each B&B.

* The list of B&Bs is ordered by name of the B&B.  This wasn't stated anywhere in the requirement,
and in real life one would imagine that the GET should accept URL parameters to filter and/or to
sort the results.

The exercise does not suggest that this is part of a larger, transactional system of services (e.g.,
a B&B Travel Resource Database), nor does it say that it isn't part of such a larger system.  In the
absence of this, the code has no provision for detecting/reporting errors, nor for recovering from them,
as would be necessary in a larger system.  This is discussed in more details (see below).
### Testing

Start several terminal windows plus a Web browser, as follows (assuming that the root directory of the repo is "atl"):

##### Terminal 1: Start the API Rails Server as follows, in atl/api
```bash
$ cd api
$ bundle exec rails s
```
##### Browser: Open a browser and point it to the API Rails Server
```URL
http://localhost:3000/bed_and_breakfasts.json
```
Unless you already have Bnb records in the API database, you will see only an empty array in the browser.
As yet, there are no B&Bs on which to report.
##### Terminal 2: Start the Message Processing Loop, in atl/message_processor
```bash
$ cd message_processor
$ ruby monitor.rb
```
##### Terminal 3: Open an IRB session, also in atl/message_processor
```ruby
$ cd message_processor
$ irb
> require_relative "test_driver"
> driver = TestDriver.new
```
You can now pump vote-messages into the message processor using the driver.  For example:
```ruby
> driver.push("Blessing Inn", 2, "Johnny", "Quest")
```
As soon as push a message like this, you ought to be able to refresh the browser window to see the updated
totals.

Note that each user can contribute only one number of votes.  In other words, if several users have voted on the
same B&B, and if the total of all of those votes is (say) 105, then, if one of the same users re-POSTs votes
for that B&B their original votes will be subtracted and their new votes will be added.
### Developer Notes: Testing
#### Vote Monitor Testing
There is only a unit test for the vote monitor (which, after all, is a simple, single method).
You may notice that I stubbed the calls to rabbitMQ, in the spirit of reducing run-time as well as
to avoid even the possibility of corrupting the live, shared rabbitMQ server (although that could
perhaps be accomplished through containerization or by some kind of per-environment ENV configuration
of *vhosts* and TCP sockets).

#### API Server Testing
There are two acceptance tests, coded as RSpec *request specs*:

* List of Beds and Breakfasts.  This exercises the GET of the list of voted-for B&Bs.
* Posting Votes.  This exercises the POST of votes.

It is due to the simplistic scenario of this exercise that each of these corresponds to a single
Controller entry-point (which may have begged the question, why aren't these functional tests)? Acceptance
tests correspond to what the system is supposed "to do" from the point of view of a product manager,
which may or may not correspond to a list of particular controller entry points.

One may notice that the acceptance test for the list of B&Bs includes a scenario in which there are only
zero votes for one of the B&Bs.  This would be odd in real life, because a B&B can't exist until
someone has voted for it, and, all who have voted for it would have had to vote "zero".

There are unit tests for the two controllers (Bnbs and Votes), and for the two models (Bnb and Vote).

There are test-data factories for Bnb and Votes composed such that every factoried instance is
valid.
### Developer Notes: Code Design
#### It Doesn't Use the JSON API Specification
If it did, it could support filtering and querying for the GET of B&Bs.  But, the overall format
of the response body would be require an additional { data: <array of objects>, ... } wrapper.
In real life, one would prefer to use the JSON API specification, perhaps.

#### There is No Voter Table
I didn't make a table in the server to hold Voter information, because I assume that there would be
some other services managing the identity of the voters. All that is required to process a
vote-message is for us to assume that the first and last names are well-formed (no trailing spaces,
for example), and that they can be used easily as a combined primary key to a voter's identity
(so that the number of votes can be maintained per voter per B&B by the server).  None of this
would be helped, particularly, by having a Voter table, nor would it seem to be the business
of the vote-manager micro-service to ensure any of it.

It's an interesting question that is perhaps out of the scope of this exercise:  how should a downstream
service such as vote-manager ensure that the data it is given (by midstream services) is trustable?
A system of micro-services is a kind of  distributed, transactional system. Each service is like
a node in such a distributed system, and has the same needs as such a node would have:

* The service must assume some degree of trust about the data it is given, and must have the means
to do further refinement on that data pertinent to its particular service specialty.

* The service must be able initiate a roll-back or retry of the transaction in which it is called.

Neither of these is addressed in the code, currently, because I have no idea what other services may be
involved in handling the overall transactions (which may include, say, user authentication or B&B
filtering for sets of users), nor do I know how transactions are initiated upstream (perhaps, users
up-vote through browsers, after drilling into a geographic region?). If the system is no more than
what seems required for the voting, then, it might after all be reasonable for the vote-manager to
cast the first and last names as some kind of primary key to a Voter record--or, we can postulate a
second micro-service to manage Voter identity to which vote-manager can delegate, or, which we can
assume to have been called upstream from the vote-manager (in which case, I'd expect a Voter ID rather
than a first and last name in the enqueued vote).
#### Are Vote Resources Nested Within B&Bs?
At first, I imagined the Votes Controller as presenting the nested votes for a B&B (except that we provide
only a #create action, in this system). But, that would imply
a URL of the form, "/bnb/:some-kind-of-key/votes," which implies that the B&B records exist prior to any
of their votes.  And, in this sytem, that's not how things work.  Instead, a B&B is almost a side-effect
of creating a vote.  If anything, the URL ought to present things the other way:  a vote ought to
include sufficient information to record its B&B--which is how it works, currently.  It happens that
the only distinguishing attribute of a B&B is its name, which is why we can manage it this way.
#### Use of Default vhost and TCP socket, in rabbitMQ
As coded, everything that uses rabbitMQ does so using the default *vhost* and TCP socket.
This is probably a bad idea in any real-life situation.  If nothing else, we'd want to prevent
development and/or testing work from corrupting the queues in production.  Then, too, although
we've named the queue that we use in a way that seems reasonably safe from overlap with other
applications, we'd probably want more assurance that we could not interfere with other production
applications.

Using containers, it may be possible to rely (at least, within each container) on the Docker defaults.
