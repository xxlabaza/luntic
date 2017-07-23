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

import unittest, tables, options, uri, asynchttpserver, context

proc createRequest (str: string): Request =
  return Request(url: Uri(path: str))

test "Parsing request parts":
  let toCheck = {
    "/api/popa": ("/api", "popa", ""),
    "/api/popa/": ("/api", "popa", ""),
    "/api/popa/123": ("/api", "popa", "123"),
    "/api/popa/123/": ("/api", "popa", "123"),
    "/api/popa/123/wow": ("/api", "", ""),
    "/api/": ("/api", "", ""),
    "/api": ("/api", "", ""),
    "/popa": ("/", "popa", "")
  }.toTable

  for key, value in toCheck.pairs():
    let request = createRequest(key)
    try:
      let (group, id) = parsePath(value[0], request)
      check(value[1] == group.get())
      if id.isSome:
        check(value[2] == id.get())
      else:
        check(value[2] == "")
    except:
      check(("", "") == (value[1], value[2]))
