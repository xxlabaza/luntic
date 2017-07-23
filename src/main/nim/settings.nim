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

import properties,
       parseopt2,
       strutils


type Settings* = object of RootObj
  port* : int
  pathPrefix* : string
  address* : string
  heartbeat* : int
  debug*: bool
  dashboard*: int


const
  VERSION = prop"version"
  USAGE = prop"usage"
  DEFAUL_PORT = prop"default.port"
  DEFAUL_PATH_PREFIX = prop"default.pathPrefix"
  DEFAUL_ADDRESS = prop"default.address"
  DEFAUL_HEARTBEAT = prop"default.heartbeat"


proc parseArguments* (): Settings =
  result = Settings(
    port: parseInt(DEFAUL_PORT),
    pathPrefix: DEFAUL_PATH_PREFIX,
    address: DEFAUL_ADDRESS,
    heartbeat: parseInt(DEFAUL_HEARTBEAT),
    debug: false,
    dashboard: -1
  )

  for kind, key, value in getopt():
    case kind:
    of cmdArgument:
      result.address = key
    of cmdLongOption, cmdShortOption:
      case key:
      of "p", "port":
        result.port = parseInt(value)
      of "path-prefix":
        result.pathPrefix = value
      of "heartbeat":
        result.heartbeat = parseInt(value)
      of "dashboard":
        result.dashboard = parseInt(value)
      of "d", "debug":
        result.debug = true
      of "h", "help":
        echo USAGE
        quit QuitSuccess
      of "v", "version":
        echo VERSION
        quit QuitSuccess
      else:
        echo "Nope"
        quit QuitFailure
    of cmdEnd:
      assert(false) # cannot happen
