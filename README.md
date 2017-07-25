
# Luntic

A lightweight REST in-memory discovery service.

Features:

* periodical task for removing expired records;

* simple dashboard in web browser.

The service was inspired by [Eureka](https://github.com/Netflix/eureka) web service and it uses for registration and locating services in your environment.

It uses REST JSON-based API for simple integration.

## Contents

- [Getting Started](#getting-started)
- [API](#api)
  - [Registering new service](#registering-new-service)
  - [Retrieve a service(s)](#retrieve-services)
  - [Update service](#update-service)
  - [Remove service](#remove-service)
- [Development](#development)
  - [Prerequisites](#prerequisites)
  - [Building](#building)
  - [Running the tests](#running-the-tests)
- [Built With](#built-with)
- [Changelog](#changelog)
- [Contributing](#contributing)
- [Versioning](#versioning)
- [Authors](#authors)
- [License](#license)

## Getting Started

Start the Luntic discovery server:

```bash
$> luntic

    __                  __   _
   / /   __  __ ____   / /_ (_)_____
  / /   / / / // __ \ / __// // ___/
 / /___/ /_/ // / / // /_ / // /__
/_____/\__,_//_/ /_/ \__//_/ \___/

I was born!

v1.0.1
Copyright (c) by Artem Labazin

REST requests are serviced on: http://localhost:8080/

```

If you need to launch Luntic on different port, with specific path prefix, debug access logs or public net address, you are able to set it:

```bash
$> luntic --debug --port=9999 --path-prefix=/register 0.0.0.0

    __                  __   _
   / /   __  __ ____   / /_ (_)_____
  / /   / / / // __ \ / __// // ___/
 / /___/ /_/ // / / // /_ / // /__
/_____/\__,_//_/ /_/ \__//_/ \___/

I was born!

v1.0.1
Copyright (c) by Artem Labazin

REST requests are serviced on: http://0.0.0.0:9999/register

2017-07-22T03:20:45+03:00 -- POST   /register/popa
2017-07-22T03:21:12+03:00 -- GET    /register
2017-07-22T03:21:28+03:00 -- DELETE /register/popa/59729a5d8b7df47200000001

```

We could also start a simple web browser dashboard on separate port:

```bash
$> luntic --dashboard:9876

    __                  __   _
   / /   __  __ ____   / /_ (_)_____
  / /   / / / // __ \ / __// // ___/
 / /___/ /_/ // / / // /_ / // /__
/_____/\__,_//_/ /_/ \__//_/ \___/

I was born!

v1.0.1
Copyright (c) by Artem Labazin

REST requests are serviced on: http://localhost:8080/
Dashboard is available on: http://localhost:9876/

```

Open the link [http://localhost:9876](http://localhost:9876) in your web browser and you could see something like this:

![home page](https://github.com/xxlabaza/luntic/blob/master/images/home.png?raw=true)

And see group info:

![group info](https://github.com/xxlabaza/luntic/blob/master/images/group.png?raw=true)

Also there is a API page:

![api page](https://github.com/xxlabaza/luntic/blob/master/images/api.png?raw=true)

To see all available switches and keys, type the following:

```bash
$> luntic --help

Usage:  luntic [OPTIONS] [LISTENING_ADDRESS]

A lightweight REST in-memory discovery service

Options:
    -p:PORT --port=PORT   sets listening port
                          default: 8080
    --path-prefix=PATH    sets server's endpoints path prefix
                          default: '/'
    --heartbeat=SECONDS   sets heartbeat service cleaner in seconds,
                          if it set to 0 - turn off heartbeat scheduler
                          default: 0s
    --dashboard=PORT      setups a simple web browser-oriented dashboard
                          for services monitoring
                          default: turned off
    -d --debug            turn on debug mode
    -v --version          prints program's version
    -h --help             prints this help menu

```

After starting Luntic server you could register your first app via REST API.
I am using [HTTPie](https://httpie.org) for request calls, but you can do it with cURL or [Postman](https://www.getpostman.com).

Registering a new app, which has *popa* group name:

```bash
$> http -v POST :8080/popa
POST /popa HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 0
Host: localhost:8080
User-Agent: HTTPie/0.9.9


HTTP/1.1 201 Created
Content-Length: 124
content-type: application/json
location: /popa/597298af0937867200000001
x-expired-time: 0

{
    "created": "2017-07-22T03:13:35+03:00",
    "group": "popa",
    "id": "597298af0937867200000001",
    "modified": "2017-07-22T03:13:35+03:00"
}

```

As we can see, we have created a new record in **popa** application group. The server have generated the instance id **597298af0937867200000001**, creation time and last modified time fields.

We are also able to attach our own JSON object to a record in **meta** field during its creation:

```bash
$> http -v POST :8080/popa one=1 two=2
POST /popa HTTP/1.1
Accept: application/json, */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 24
Content-Type: application/json
Host: localhost:8080
User-Agent: HTTPie/0.9.9

{
    "one": "1",
    "two": "2"
}

HTTP/1.1 201 Created
Content-Length: 154
content-type: application/json
location: /popa/5972a20d5b31ed7400000001
x-expired-time: 0

{
    "created": "2017-07-22T03:53:33+03:00",
    "group": "popa",
    "id": "5972a20d5b31ed7400000001",
    "meta": {
        "one": "1",
        "two": "2"
    },
    "modified": "2017-07-22T03:53:33+03:00"
}

```

To get a just created record - we need to use a path from **Location** header in creation reponse:

```bash
$> http -v :8080/popa/5972a2e54396247500000001
GET /popa/5972a2e54396247500000001 HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Host: localhost:8080
User-Agent: HTTPie/0.9.9


HTTP/1.1 200 OK
Content-Length: 154
content-type: application/json

{
    "created": "2017-07-22T03:53:33+03:00",
    "group": "popa",
    "id": "5972a20d5b31ed7400000001",
    "meta": {
        "one": "1",
        "two": "2"
    },
    "modified": "2017-07-22T03:53:33+03:00"
}

```

Also, we could get all available records within one group name:

```bash
$> http -v :8080/popa
GET /popa HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Host: localhost:8080
User-Agent: HTTPie/0.9.9


HTTP/1.1 200 OK
Content-Length: 282
content-type: application/json

[
    {
        "created": "2017-07-22T03:13:35+03:00",
        "group": "popa",
        "id": "597298af0937867200000001",
        "modified": "2017-07-22T03:13:35+03:00"
    },
    {
        "created": "2017-07-22T03:53:33+03:00",
        "group": "popa",
        "id": "5972a20d5b31ed7400000001",
        "meta": {
            "one": "1",
            "two": "2"
        },
        "modified": "2017-07-22T03:53:33+03:00"
    }
]

```

Or, we can get all data in one object - **group** -> **instances**:

```bash
$> http -v :8080/
GET / HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Host: localhost:8080
User-Agent: HTTPie/0.9.9


HTTP/1.1 200 OK
Content-Length: 426
content-type: application/json

{
    "popa": [
        {
            "created": "2017-07-22T03:13:35+03:00",
            "group": "popa",
            "id": "597298af0937867200000001",
            "modified": "2017-07-22T03:13:35+03:00"
        },
        {
            "created": "2017-07-22T03:53:33+03:00",
            "group": "popa",
            "id": "5972a20d5b31ed7400000001",
            "meta": {
                "one": "1",
                "two": "2"
            },
            "modified": "2017-07-22T03:53:33+03:00"
        }
    ],
    "zuul": [
        {
            "created": "2017-07-22T04:03:26+03:00",
            "group": "zuul",
            "id": "5972a45e4396247500000003",
            "modified": "2017-07-22T04:03:26+03:00"
        }
    ]
}
```

To update last **modified** time you could type this:

```bash
$> http -v PUT :8080/popa/5972a20d5b31ed7400000001
PUT /popa/5972a20d5b31ed7400000001 HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 0
Host: localhost:8080
User-Agent: HTTPie/0.9.9


HTTP/1.1 200 OK
Content-Length: 154
content-type: application/json

{
    "created": "2017-07-22T03:53:33+03:00",
    "group": "popa",
    "id": "5972a20d5b31ed7400000001",
    "meta": {
        "one": "1",
        "two": "2"
    },
    "modified": "2017-07-22T04:10:42+03:00"
}

```

Why do we want to update last modified time? Luntic can be started with **--heartbeat=SECONDS** switch, which enables scheduled task for periodical removing expired instances in groups. So, with this switch you need to update modified time, otherwise it removes. By default this scheduled task is disabled.

With **PUT** method you could also change **meta** field:

```bash
$> http -v PUT :8080/popa/5972a20d5b31ed7400000001 greeting="Hello world" one=1 two=2
PUT /popa/5972a20d5b31ed7400000001 HTTP/1.1
Accept: application/json, */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 51
Content-Type: application/json
Host: localhost:8080
User-Agent: HTTPie/0.9.9

{
    "greeting": "Hello world",
    "one": "1",
    "two": "2"
}

HTTP/1.1 200 OK
Content-Length: 179
content-type: application/json

{
    "created": "2017-07-22T03:53:33+03:00",
    "group": "popa",
    "id": "5972a20d5b31ed7400000001",
    "meta": {
        "greeting": "Hello world",
        "one": "1",
        "two": "2"
    },
    "modified": "2017-07-22T04:12:16+03:00"
}

```

And at last, we want to remove the record:

```bash
$> http -v DELETE :8080/popa/5972a20d5b31ed7400000001
DELETE /popa/5972a20d5b31ed7400000001 HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 0
Host: localhost:8080
User-Agent: HTTPie/0.9.9


HTTP/1.1 204 No Content
Content-Length: 0

```

## API

### Registering new service

Creates new record.

* **Request**

  **POST** [/pathPrefix]/{group}

  `pathPrefix` - common path prefix, which was set (default value - **/**) at the start of Luntic program;

  `group` - name of the registering application group.

  Examples:

  * POST /popa - we didn't set `pathPrefix` (it is optional) at start time and set `group` in this request as **popa**;

  * POST /api/popa - we set `pathPrefix` at start time and use it in the request (**api**), also we set `group` (**popa**).

  Also, you could send a `JSON` object with a request. It will be attached to server generated instance in `meta` field.

* **Success Response:**

  As a result of the request we get a response:

  **Code:** 201

  **Headers:**

    * Location: [/pathPrefix]/{group}/{instanceId}

    * X-Expired-Time: <int_seconds_or_zero_if_disabled>

  **Content type:** application/json

  **JSON fields:**

  | Field name   | Optional | Description                                                 |
  | ------------ | -------- | ----------------------------------------------------------- |
  | **id**       | no       | generated record id                                         |
  | **group**    | no       | the group name you set                                      |
  | **created**  | no       | the time you registered                                     |
  | **modified** | no       | the time you last accessed the record                       |
  | **meta**     | yes      | if you send `JSON` in request, we get it back in that field |

  > **IMPORTANT:** Take a look at `X-Expired-Time` header - if it is not `0` value, your record expires after that amount of second. To prevent removing your instance record - make a `PUT` request within this timeout.

* **Error Response:**

  **400** - in case of incorrect group set (absent or contains */* sign)

* **Examples:**

  ```bash
  $> http -v POST :8080/popa

  POST /popa HTTP/1.1
  Accept: */*
  Accept-Encoding: gzip, deflate
  Connection: keep-alive
  Content-Length: 0
  Host: localhost:8080


  HTTP/1.1 201 Created
  Content-Length: 124
  Content-Type: application/json
  Location: /popa/597298af0937867200000001

  {
      "created": "2017-07-22T03:13:35+03:00",
      "group": "popa",
      "id": "597298af0937867200000001",
      "modified": "2017-07-22T03:13:35+03:00"
  }

  ```

  ```bash
  $> http -v POST :8080/popa one=1 two=2

  POST /popa HTTP/1.1
  Accept: application/json, */*
  Accept-Encoding: gzip, deflate
  Connection: keep-alive
  Content-Length: 24
  Content-Type: application/json
  Host: localhost:8080

  {
      "one": "1",
      "two": "2"
  }


  HTTP/1.1 201 Created
  Content-Length: 154
  Content-Type: application/json
  Location: /popa/5972a20d5b31ed7400000001

  {
      "created": "2017-07-22T03:53:33+03:00",
      "group": "popa",
      "id": "5972a20d5b31ed7400000001",
      "meta": {
          "one": "1",
          "two": "2"
      },
      "modified": "2017-07-22T03:53:33+03:00"
  }

  ```

### Retrieve services

Returns all or specific records on the server.

* **Request**

  Get all `groups` and records:

  **GET** [/pathPrefix]/

  Get all `group's` records:

  **GET** [/pathPrefix]/{group}

  Get only specific record:

  **GET** [/pathPrefix]/{group}/{instanceId}

  `pathPrefix` - common path prefix, which was set (default value - **/**) at the start of Luntic program;

  `group` - name of the registered application group.

  `instanceId` - service instance id.

* **Success Response:**

  As a result of the request we get a response:

  **Code:** 200

  **Content type:** application/json

  **Content fields:**

  | Field name   | Optional | Description                                                 |
  | ------------ | -------- | ----------------------------------------------------------- |
  | **id**       | no       | generated record id                                         |
  | **group**    | no       | the group name you set                                      |
  | **created**  | no       | the time you registered time                                |
  | **modified** | no       | the time you last accessed the record                       |
  | **meta**     | yes      | if you send `JSON` in request, we get it back in that field |

* **Error Response:**

  **404** - in case of nonexistent `group` or `instanceId`.

* **Examples:**

  Get all records in the services:

  ```bash
  $> http -v :8080/
  / HTTP/1.1
  Accept: */*
  Accept-Encoding: gzip, deflate
  Connection: keep-alive
  Host: localhost:8080
  User-Agent: HTTPie/0.9.9


  HTTP/1.1 200 OK
  Content-Length: 397
  content-type: application/json

  {
      "popa": [
          {
              "created": "2017-07-23T03:41:51+03:00",
              "group": "popa",
              "id": "5973f0cfead3c64a00000001",
              "modified": "2017-07-23T03:41:51+03:00"
          },
          {
              "created": "2017-07-23T03:41:52+03:00",
              "group": "popa",
              "id": "5973f0d0ead3c64a00000002",
              "modified": "2017-07-23T03:41:52+03:00"
          }
      ],
      "zuul": [
          {
              "created": "2017-07-23T03:41:57+03:00",
              "group": "zuul",
              "id": "5973f0d5ead3c64a00000003",
              "modified": "2017-07-23T03:41:57+03:00"
          }
      ]
  }
  ```

  Get all records by *group* name:

  ```bash
  $> http -v :8080/popa
  GET /popa HTTP/1.1
  Accept: */*
  Accept-Encoding: gzip, deflate
  Connection: keep-alive
  Host: localhost:8080
  User-Agent: HTTPie/0.9.9


  HTTP/1.1 200 OK
  Content-Length: 253
  content-type: application/json

  [
      {
          "created": "2017-07-23T03:41:51+03:00",
          "group": "popa",
          "id": "5973f0cfead3c64a00000001",
          "modified": "2017-07-23T03:41:51+03:00"
      },
      {
          "created": "2017-07-23T03:41:52+03:00",
          "group": "popa",
          "id": "5973f0d0ead3c64a00000002",
          "modified": "2017-07-23T03:41:52+03:00"
      }
  ]
  ```

  Get record by its *group* and *instanceId*:

  ```bash
  $> http -v :8080/popa/5973f0cfead3c64a00000001
  GET /popa/5973f0cfead3c64a00000001 HTTP/1.1
  Accept: */*
  Accept-Encoding: gzip, deflate
  Connection: keep-alive
  Host: localhost:8080
  User-Agent: HTTPie/0.9.9


  HTTP/1.1 200 OK
  Content-Length: 125
  content-type: application/json

  {
      "created": "2017-07-23T03:41:51+03:00",
      "group": "popa",
      "id": "5973f0cfead3c64a00000001",
      "modified": "2017-07-23T03:41:51+03:00"
  }
  ```

### Update service

This request, first of all, updates `modified` time field of the updating record.

* **Request**

  **PUT** [/pathPrefix]/{group}/{instanceId}

  `pathPrefix` - common path prefix, which was set (default value - **/**) at the start of Luntic program;

  `group` - name of the registered application group.

  `instanceId` - service instance id for updating.

  Also, you could send a `JSON` object with a request. It will be attached to server generated instance in `meta` field.

* **Success Response:**

  As a result of the request we get a response:

  **Code:** 200

  **Content type:** JSON

  **Content fields:**

  | Field name   | Optional | Description                                                 |
  | ------------ | -------- | ----------------------------------------------------------- |
  | **id**       | no       | generated record id                                         |
  | **group**    | no       | the group name you set                                      |
  | **created**  | no       | the time you registered time                                |
  | **modified** | no       | the time you last accessed the record                       |
  | **meta**     | yes      | if you send `JSON` in request, we get it back in that field |

* **Error Response:**

  **400** - if not `group` or `instanceId` are present;

  **404** - in case of nonexistent `group` or `instanceId`.

* **Examples:**

  Regular *modified* time update:

  ```bash
  http -v PUT :8080/popa/5973f0cfead3c64a00000001
  PUT /popa/5973f0cfead3c64a00000001 HTTP/1.1
  Accept: */*
  Accept-Encoding: gzip, deflate
  Connection: keep-alive
  Content-Length: 0
  Host: localhost:8080
  User-Agent: HTTPie/0.9.9


  HTTP/1.1 200 OK
  Content-Length: 125
  content-type: application/json

  {
      "created": "2017-07-23T03:41:51+03:00",
      "group": "popa",
      "id": "5973f0cfead3c64a00000001",
      "modified": "2017-07-23T03:46:22+03:00"
  }
  ```

  Update with attaching new *meta* field value:

  ```bash
  http -v PUT :8080/popa/5973f0cfead3c64a00000001 name=Artem
  PUT /popa/5973f0cfead3c64a00000001 HTTP/1.1
  Accept: application/json, */*
  Accept-Encoding: gzip, deflate
  Connection: keep-alive
  Content-Length: 17
  Content-Type: application/json
  Host: localhost:8080
  User-Agent: HTTPie/0.9.9

  {
      "name": "Artem"
  }

  HTTP/1.1 200 OK
  Content-Length: 149
  content-type: application/json

  {
      "created": "2017-07-23T03:41:51+03:00",
      "group": "popa",
      "id": "5973f0cfead3c64a00000001",
      "meta": {
          "name": "Artem"
      },
      "modified": "2017-07-23T03:47:28+03:00"
  }
  ```

### Remove service

Deletes the service from the services.

* **Request**

  **DELETE** [/pathPrefix]/{group}/{instanceId}

  `pathPrefix` - common path prefix, which was set (default value - **/**) at the start of Luntic program;

  `group` - name of the registered application group.

  `instanceId` - service instance id for removing.

* **Success Response:**

  As a result of the request we get a response:

  **Code:** 204

  **No Content**

* **Error Response:**

  **400** - if not `group` or `instanceId` are present;

  **404** - in case of nonexistent `group` or `instanceId`.

* **Examples:**

  ```bash
  $> http -v DELETE :8080/popa/5972a20d5b31ed7400000001
  DELETE /app/popa/5973e2c95d89804600000007 HTTP/1.1
  Accept: */*
  Accept-Encoding: gzip, deflate
  Connection: keep-alive
  Content-Length: 0
  Host: localhost:8080


  HTTP/1.1 204 No Content
  Content-Length: 0
  ```

## Development

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

For building the project you need only a [Nim](https://nim-lang.org) compiler ([Windows](https://nim-lang.org/install_windows.html) or [OSX/Unix](https://nim-lang.org/install_unix.html)).

> **IMPORTANT:** Luntic requires Nim version **0.17.0**

And, of course, you need to clone Luntic from GitHub:

```bash
$> git clone https://github.com/xxlabaza/luntic
$> cd luntic
```

### Building

For building routine automation, I am using [config.nims](./config.nims) file. It contains all needed tasks described in **Nim** language.

To build the Luntic project, do the following:

```bash
$> nim build
...
Hint: operation successful (52249 lines compiled; 4.124 sec total; 106.934MiB peakmem; Debug Build) [SuccessX]
```

If you need to build a release (less output binnary file size):

```bash
$> nim build release
```

To check, what everything is fine, type the nex command:

```bash
$> build/target/luntic -v
v1.0.1
```

### Running the tests

To run the project's test, do the following:

```bash
$> nim test
...
[OK] Parsing request parts
```

Also, if you build a release, the tests launch automatically.

## Built With

* [Nim](https://nim-lang.org) - is a systems and applications programming language

## Changelog

To see what has changed in recent versions of Luntic, see the [changelog](./CHANGELOG.md) file.

## Contributing

Please read [contributing](./CONTRIBUTING.md) file for details on my code of conduct, and the process for submitting pull requests to me.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/xxlabaza/luntic/tags).

## Authors

* **Artem Labazin** - the main creator and developer

## License

This project is licensed under the Apache License 2.0 License - see the [license](./LICENSE) file for details
