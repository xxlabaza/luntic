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
       strutils,
       options,
       tables


proc handle* (rc: RequestContext, groups: TableRef[string, seq[Instance]]): Future[void] =
  if rc.group.isNone or rc.instanceId.isNone:
    return rc.respond(400, "Group or ID was not set")

  let
    group = rc.group.get()
    instanceId = rc.instanceId.get()

  if not groups.hasKey(group):
    let msg = "There is no such group - '$1'".format(group)
    return rc.respond(404, msg)

  var
    instances = groups[group]
    index = -1

  for i in 0..instances.high:
    if instances[i].id == instanceId:
      index = i
      break

  if index == -1:
    let msg = "There is no such ID - '$1' in group '$2'".format(instanceId, group)
    return rc.respond(404, msg)
  elif instances.len == 0:
    groups.del(group)
  else:
    groups[group].del(index)

  return rc.respond(204)
