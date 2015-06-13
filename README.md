# wwiki
(wip) getting data from the cities gem, weather and wikipedia api using sinatra and mashape

## Installation

```bash
# get json data for every city in the US (required by Cities gem).
wget https://s3-us-west-2.amazonaws.com/cities-gem/cities.tar.gz

# extract cities from tar file
tar -xzf cities.tar.gz

# rename cities to data
mv cities data

# add key from mashape to keystore
touch keystore

# install dependencies
bundle install

# run server on port 8080
ruby server.rb
```
