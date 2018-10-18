### Bed And Breakfast Server

#### Getting The List of B&Bs, With Total Vote Counts
```ruby
GET server_url/bed_and_breakfasts.json
```
returns an array of Bed-and-Breakfast objects each containing the name
of an inn and the current number of "up" votes for that inn.

The array is encoded as a JSON object.  For example:

```json
[
    { "name" : "Allard Inn", "number_of_votes" : 12 },
    { "name" : "Betty Bed and Breakfast", "number_of_votes" : 0 },
]
```
Other than the server being offline, or some other operational failure, the only possible
response status is this:

* 200 (Ok)

The body of the response will be in *json*, no matter what the content of the Accept header (and, in fact,
you can omit the ".json" suffix from the URL).

#### Voting for a B&B, or Updating a Person's Count of Votes
To update the count of votes issued by a person for one of the inns:

```ruby
POST server_url/votes?bed_and_breakfast_name="Allard%20Inn&first_name=Herman&last_name=Melville"
```
If this is the first vote for the named B&B, a record for that B&B will be added to the database.
Otherwise, the vote-count will be added to the votes for the existing B&B.

Each time a person POSTs a number of votes for an inn, their previous vote-count for that inn is replaced with their new count.

```json
{ "name" : "Allard Inn", "number_of_votes" : 13 }
```
The status code of the response is one of the following:
* 201 (Created)
* 422 (Unprocessable Entity): an invalid request (missing B&B name, or, non-integer vote count, etc.)

#### Development Testing Tips

To start the server:

```bash
bundle exec rails s
```

To emulate a person casting 7 votes for a B&B called Blessing Inn:

```bash
curl -v -d "bnb_name=Blessing%20Inn&first_name=Billy&last_name=Bones&vote=7" http://localhost:3000/votes
```

You can *curl* to get the list of B&Bs, too, or, just use a browser.
