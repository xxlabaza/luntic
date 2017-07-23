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
       settings,
       strutils,
       server/server


const
  BANNER = "banner.txt".staticRead
  WELCOME_REST = prop"welcome.rest"
  WELCOME_DASHBOARD = prop"welcome.dashboard"


when isMainModule:

  let options = settings.parseArguments()

  echo BANNER
  if options.dashboard > 0:
    echo WELCOME_DASHBOARD.format(options.address, options.port, options.pathPrefix, options.dashboard)
  else:
    echo WELCOME_REST.format(options.address, options.port, options.pathPrefix)

  server.start(options)
