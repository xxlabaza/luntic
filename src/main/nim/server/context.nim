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
       sequtils,
       strutils,
       options,
       tables,
       times,
       json


type RequestContext* = object
  pathPrefix* : string
  group* : Option[string]
  instanceId* : Option[string]
  body* : Option[JsonNode]
  request* : Request
  time* : Time


proc parsePath* (pathPrefix: string, request: Request): (Option[string], Option[string]) =
  let emptyTuple = (none(string), none(string))

  let path = request.url.path
  if path.isNilOrEmpty:
    return emptyTuple

  let contextPath = path.substr(pathPrefix.len)
  if contextPath.isNilOrEmpty:
    return emptyTuple

  let tokens = contextPath.split('/')
      .filter do (it: string) -> bool : not it.isNilOrEmpty

  if tokens.len == 1:
    return (some(tokens[0]), none(string))
  elif tokens.len > 2:
    let msg = "the request '$1' contains incorrect path parts: $2".format(contextPath, tokens)
    raise newException(Exception, msg)
  else:
    return (some(tokens[0]), some(tokens[1]))


proc parseBody* (request: Request): Option[JsonNode] =
  let jsonText = request.body
  if jsonText.isNilOrEmpty:
    return none(JsonNode)

  var json:JsonNode = nil
  try:
    json = parseJson(jsonText)
  except:
    return none(JsonNode)
  return some(json)


proc initRequestContext* (pathPrefix: string, request: Request): RequestContext =
  let (group, instanceId) = parsePath(pathPrefix, request)
  result = RequestContext(
    pathPrefix: pathPrefix,
    group: group,
    instanceId: instanceId,
    body: parseBody(request),
    request: request,
    time: getTime()
  )


proc respond* (rc: RequestContext; status: int; content: string = ""; headers: openarray[tuple[key: string, val: string]] = []): Future[void] =
  let code = HttpCode(status)
  let httpHeaders = newHttpHeaders(headers)
  return respond(rc.request, code, content, httpHeaders)



when isMainModule:

  import uri

  proc createRequest (str: string): Request =
    let url = Uri(path: str)
    return Request(url: url)

  proc checkMe (str: string) =
    echo "Incoming path: $1".format(str)
    try:
      let request = createRequest(str)
      echo "\t" & $parsePath("/api", request)
    except:
      echo "\tError"

  checkMe("/api/popa/123")
  checkMe("/api/popa")
  checkMe("/api/popa/")
  checkMe("/api/popa/123/")
  checkMe("/api/popa/123/wow")
  checkMe("/api/")
  checkMe("/api")
