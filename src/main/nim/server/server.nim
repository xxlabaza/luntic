#
# Copyright 2017 Artem Labazin <xxlabaza@gmail.com>.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import asynchttpserver,
       asyncdispatch,
       strutils,
       sequtils,
       tables,
       times,
       uri,
       ../settings,
       context,
       instance,
       handlers/post,
       handlers/get,
       handlers/put,
       handlers/delete


const
  INDEX_PAGE = "html/index.html".staticRead
  GROUP_PAGE = "html/group.html".staticRead
  ABOUT_PAGE = "html/about.html".staticRead
  STYLE_CSS = "html/style.css".staticRead


var
  groups {.threadvar.} : TableRef[string, seq[Instance]]
  pathPrefix {.threadvar.} : string
  debug {.threadvar.} : bool
  heartbeat {.threadvar.} : int


proc log (request: Request) =
  var reqMethod = $request.reqMethod
  for i in reqMethod.len..<6:
    reqMethod &= ' '
  if request.body.isNilOrEmpty:
    echo "$1 -- $2 $3".format(getTime(), reqMethod, request.url.path)
  else:
    echo "$1 -- $2 $3  $4".format(getTime(), reqMethod, request.url.path, request.body)
  for key, value in request.headers.table.pairs():
    echo "  $1: $2".format(key, $value)


proc restCallback (request: Request) {.async.} =
  if debug:
    log(request)

  if not request.url.path.startsWith(pathPrefix):
    await request.respond(Http400, "Only root path ($1) request allowed".format(pathPrefix))
  else:
    let rc = initRequestContext(pathPrefix, heartbeat, request)
    case request.reqMethod:
    of HttpPost:
      await post.handle(rc, groups)
    of HttpGet:
      await get.handle(rc, groups)
    of HttpPut:
      await put.handle(rc, groups)
    of HttpDelete:
      await delete.handle(rc, groups)
    else:
      await request.respond(Http405, "Awailable methods: GET, POST, PUT, DELETE")


proc staticCallback (request: Request) {.async.} =
  let path = request.url.path

  if path.startsWith("/api"):
    var apiRequest = request
    if path != "/api":
      apiRequest.url.path = path["/api".len..path.high]
    else:
      apiRequest.url.path = pathPrefix
    await restCallback(apiRequest)
    return

  if request.reqMethod != HttpGet:
    await request.respond(Http405, "Awailable methods: GET")
    return

  var content:string
  case path:
  of "/":
    content = INDEX_PAGE
  of "/group":
    content = GROUP_PAGE
  of "/about":
    content = ABOUT_PAGE
  of "/style.css":
    let headers = newHttpHeaders([("Content-Type", "text/css")])
    await request.respond(Http200, STYLE_CSS, headers)
    return
  else:
    await request.respond(Http404, "")
    return

  let headers = newHttpHeaders([
    ("Content-Type", "text/html"),
    ("Set-Cookie", "pathPrefix=" & pathPrefix)
  ])
  await request.respond(Http200, content, headers)


proc scheduler (timeout: int) {.async.} =
  let interval = seconds(timeout)
  while true:
    await sleepAsync(timeout * 1_000)
    let time = getTime()
    if debug:
      echo "$1 -- REMOVER STARTED".format(time)
    for key in groups.keys():
      groups[key].keepItIf(it.modified > (time - interval))
      if groups[key].len == 0:
        groups.del(key)


proc start* (settings: Settings) =
  groups = newTable[string, seq[Instance]]()
  pathPrefix = settings.pathPrefix
  debug = settings.debug
  heartbeat = settings.heartbeat

  let heartbeat = settings.heartbeat
  if heartbeat > 0:
    asyncCheck scheduler(heartbeat)

  if settings.dashboard > 0:
    asyncCheck newAsyncHttpServer().serve(Port(settings.dashboard), staticCallback, settings.address)

  waitFor newAsyncHttpServer().serve(Port(settings.port), restCallback, settings.address)
