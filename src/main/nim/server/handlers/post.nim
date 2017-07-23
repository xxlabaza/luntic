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

import asyncdispatch,
       ../instance,
       ../context,
       options,
       tables


proc handle* (rc: RequestContext, groups: TableRef[string, seq[Instance]]): Future[void] =
  if rc.group.isNone or rc.instanceId.isSome:
    return rc.respond(400, "Group was not set or ID was")

  let
    group = rc.group.get()
    instance = newInstance(group, rc.time, rc.body.get(nil))

  if not groups.hasKey(group):
    groups[group] = newSeq[Instance]()
  groups[group].add(instance)

  var location = rc.pathPrefix
  if location[location.high] != '/':
    location &= '/'
  location &= group & '/' & instance.id

  return rc.respond(201, instance.toJsonString(), [
    ("Location", location),
    ("Content-Type", "application/json")
  ])
