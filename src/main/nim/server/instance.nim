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

import sequtils,
       times,
       json,
       oids


type Instance* = ref object
  id* : string
  group* : string
  created* : Time
  modified* : Time
  meta* : JsonNode


proc newInstance* (group: string, time: Time = getTime(), meta: JsonNode = nil): Instance =
  result = Instance(
    id: $oids.genOid(),
    group: group,
    created: time,
    modified: time
  )
  if not meta.isNil:
    result.meta = meta


proc toJson* (instance: Instance): JsonNode =
  result = %* {
    "id": instance.id,
    "group": instance.group,
    "created": $instance.created,
    "modified": $instance.modified
  }

  if not instance.meta.isNil:
    result["meta"] = instance.meta


proc toJson* (instances: seq[Instance]): JsonNode =
  let js = instances.map do (it: Instance) -> JsonNode: it.toJson()
  return %*js


proc toJsonString* (instance: Instance): string =
  result = $instance.toJson()


proc toJsonString* (instances: seq[Instance]): string =
  result = $instances.toJson()
