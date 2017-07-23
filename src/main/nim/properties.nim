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

import tables,
       strutils,
       parseutils


type IllegalPropertyException = object of Exception

let content {.compileTime.} = "text.properties".staticRead


proc parseValue (map: Table[string, string], str: string): string =
  result = ""

  var index = 0
  while index < str.len:
    var before = ""
    index += str.parseUntil(before, "${", index)
    result &= before

    if index >= str.len:
      break
    index += 2

    var key = ""
    index += str.parseUntil(key, {'}', '\0'}, index)
    if not map.hasKey(key):
      let message = "Illegal property '$1' in string '$2'".format(key, str)
      raise newException(IllegalPropertyException, message)
    result &= map[key]

    index += 1


proc parseSingleLine (line: string): (string, string) =
  let tokens = line.split({ ':', '=' }, 1)
  if tokens.len != 2:
    let message = "Property '$1' is invalid".format(line)
    raise newException(IllegalPropertyException, message)

  let key = tokens[0].strip()

  var value = tokens[1].strip()
  if value.startsWith("'") and value.endsWith("'"):
    value = value[1..(value.high - 1)]
  elif value.startsWith("\"") and value.endsWith("\""):
    value = value[1..(value.high - 1)]

  return (key, value)


proc parseProperties (): Table[string, string] {.compileTime.} =
  result = initTable[string, string]()

  var multiLineKey:string = nil
  for line in content.splitLines:
    let trimmedLine = line.strip(false)
    if trimmedLine.len == 0 or trimmedLine.startsWith("#"):
      if not multiLineKey.isNilOrEmpty:
        multiLineKey = nil
      continue

    if multiLineKey.isNilOrEmpty:
      let parsedLine = parseSingleLine(trimmedLine)
      var value = parsedLine[1]
      if trimmedLine.endsWith('\\'):
        value = value.replace("\\", "\n")
        multiLineKey = parsedLine[0]
      result[parsedLine[0]] = result.parseValue(value)
    else:
      let value = trimmedLine.replace("\\", "\n")
      result[multiLineKey] &= result.parseValue(value)
      if not trimmedLine.endsWith('\\'):
        multiLineKey = nil


let properties {.compileTime.} = parseProperties()


proc prop* (path: string): string {.compileTime.} =
  return properties[path]
