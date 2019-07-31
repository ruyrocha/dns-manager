# DNS Manager API

The purpose of this API is to present a brief and custom report for DNS records.

It's built with Rails using Grape, and tested with RSpec.

## The end-points

There are two basic end-points: one dedicated to create records, and another to fetch those records.

### POST /api/v1/dns_records

This end-point - `/api/v1/dns_records` - accepts a POST request with an IP address and a list of hostnames, e.g:

```shell
curl --request POST \
  --url http://localhost:3000/api/v1/dns_records \
  --header 'content-type: application/json' \
  --data '{
	"ip": "1.1.1.9",
	"hostnames": ["foo.com", "bar.com", "baz.com"]
}'
```

And this is the response:
```
{
  "id": 24,
  "type": "A",
  "value": "1.1.1.9",
  "domains": 3
}
```

*NOTE*: In general, we're storing A records for domain names and IPv4 addresses only.

### GET api/v1/dns_records

This end-point is intended to fetch the records. Here is the parameters list:

 * page: required Integer page number
 * include: optional String list of hostnames to fetch DNS records
 * exclude: optional String list of hostnames to exclude
 
E.g:
```
curl --request GET \
  --url 'http://localhost:3000/api/v1/dns_records?page=1&include=ipsum.com%2Cdolor.com&exclude=sit.com' \
  --header 'content-type: application/json'
```

The request above returns:
```
{
  "total": 2,
  "page": 1,
  "data": {
    "matches": [
      {
        "record_id": 17,
        "ip_address": "1.1.1.1"
      },
      {
        "record_id": 19,
        "ip_address": "3.3.3.3"
      }
    ],
    "non_matches": [
      {
        "hostname": "amet.com",
        "matching_dns_records": 2
      },
      {
        "hostname": "lorem.com",
        "matching_dns_records": 1
      }
    ]
  }
}
```

When the parameters `include` and `exclude` are omitted, it shows all records:

```
{
  "total": 14,
  "page": 1,
  "data": [
    {
      "id": "1",
      "type": "dns_record",
      "attributes": {
        "id": 1,
        "hostname": "lorem.com",
        "ip_address": "1.1.1.1"
      }
    },
    {
      "id": "2",
      "type": "dns_record",
      "attributes": {
        "id": 2,
        "hostname": "ipsum.com",
        "ip_address": "1.1.1.1"
      }
    },
    {
      "id": "3",
      "type": "dns_record",
      "attributes": {
        "id": 3,
        "hostname": "dolor.com",
        "ip_address": "1.1.1.1"
      }
    },
    {
      "id": "4",
      "type": "dns_record",
      "attributes": {
        "id": 4,
        "hostname": "amet.com",
        "ip_address": "1.1.1.1"
      }
    },
    {
      "id": "5",
      "type": "dns_record",
      "attributes": {
        "id": 5,
        "hostname": "ipsum.com",
        "ip_address": "2.2.2.2"
      }
    }
  ]
}
```

The current set returns 5 records at most and it's possible to navigate through pages by changing the `page` parameter.

## Running the app

Assuming you have **`Docker` and `docker-compose` installed**, clone this repo locally, enter into it, build the image and setup the database, e.g:

```shell
➜  rails git clone https://github.com/ruyrocha/dns-manager.git                                
➜  rails cd dns-manager 
➜  dns-manager git:(feature/manage-dns-records) ✗ docker-compose build
postgres uses an image, skipping
Building app
Step 1/11 : FROM ruby:2.6.3-buster
...
Successfully built 6f12bc74f4ca
Successfully tagged dns-manager_app:latest
➜  dns-manager git:(feature/manage-dns-records) ✗ docker-compose run --rm app rails db:setup
Starting dns-manager_postgres_1 ... done
Database 'dns-manager_development' already exists
Database 'dns-manager_test' already exists
-- enable_extension("plpgsql")
   -> 0.0229s
-- create_table("dns_records", {:force=>:cascade})
   -> 0.1787s
-- create_table("domains", {:force=>:cascade})
   -> 0.0145s
-- create_table("domains_records", {:id=>false, :force=>:cascade})
   -> 0.0096s
-- create_table("records", {:force=>:cascade})
   -> 0.0228s
-- enable_extension("plpgsql")
   -> 0.0134s
-- create_table("dns_records", {:force=>:cascade})
   -> 0.0157s
-- create_table("domains", {:force=>:cascade})
   -> 0.0116s
-- create_table("domains_records", {:id=>false, :force=>:cascade})
   -> 0.0108s
-- create_table("records", {:force=>:cascade})
   -> 0.0155s
 --> Assigned 1.1.1.1 to lorem.com, ipsum.com, dolor.com, amet.com.
 --> Assigned 2.2.2.2 to ipsum.com.
 --> Assigned 3.3.3.3 to ipsum.com, dolor.com, amet.com.
 --> Assigned 4.4.4.4 to ipsum.com, dolor.com, sit.com, amet.com.
 --> Assigned 5.5.5.5 to dolor.com, sit.com.
```

### RSpec

There are some tests. To run then, please set the `RAILS_ENV` environment variable to `test` and execute `rspec` as follows:

```
➜  dns-manager git:(feature/manage-dns-records) ✗ docker-compose run --rm -e RAILS_ENV=test app rspec -f d spec
Starting dns-manager_postgres_1 ... done

DnsRecords::Api
  GET /api/v1/dns_records
    failure
      shows errors
    no filter
      should respond with a success status code (2xx)
      includes the total number of records
      includes the page number
      includes the DNS records, domain and IP addresses
    filtering
      should respond with a success status code (2xx)
      includes the total number of records
      includes an array with matching records
      includes non-matching records

HomeController
  GET #index
    returns http success
    shows the right content

DnsRecord
  add some examples to (or delete) /usr/src/app/spec/models/dns_record_spec.rb (PENDING: Not yet implemented)

Domain
  should validate that :name cannot be empty/falsy
  should validate that :name is case-sensitively unique
  should have many dns_records
  should have many records through dns_records

Record
  should validate that :value cannot be empty/falsy
  should have many dns_records
  should have many domains through dns_records

Pending: (Failures listed here are expected and do not affect your suite's status)

  1) DnsRecord add some examples to (or delete) /usr/src/app/spec/models/dns_record_spec.rb
     # Not yet implemented
     # ./spec/models/dns_record_spec.rb:4


Finished in 1.78 seconds (files took 4.44 seconds to load)
19 examples, 0 failures, 1 pending
```

### Running the web server

You can run the Puma web server by setting the bind address to `0`, and then the app will be accessible through **http://localhost:3000**, e.g:

```shell
➜  dns-manager git:(feature/manage-dns-records) ✗ docker-compose run --rm --service-ports app bundle exec rails server -b 0
Starting dns-manager_postgres_1 ... done
=> Booting Puma
=> Rails 5.2.3 application starting in development 
=> Run `rails server -h` for more startup options
Puma starting in single mode...
* Version 3.12.1 (ruby 2.6.3-p62), codename: Llamas in Pajamas
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://0:3000
Use Ctrl-C to stop
```

And in another shell the app will be ready to accept and serve HTTP connections:

```shell
➜  dns-manager git:(feature/manage-dns-records) ✗ http :3000
HTTP/1.1 200 OK
Cache-Control: max-age=0, private, must-revalidate
Content-Type: application/json; charset=utf-8
ETag: W/"e2df310e68823ee66859397337d6150a"
Transfer-Encoding: chunked
X-Request-Id: e45b815a-73d7-4666-88a0-51729ef3afcf
X-Runtime: 0.160265

{
    "message": "Hello."
}
```

In the example above I'm using HTTPie, but feel free to use a tool like Insomnia, Postman or cURL.