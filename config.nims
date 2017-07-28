
import strutils

mode = ScriptMode.Verbose

let
  binaryName    = "luntic"
  mainFileName  = "main"
  version       = "1.1.0"
  buildFolder               = thisDir() & '/' & "build"
  buildSourcesMainFolder    = buildFolder & "/sources/main"
  buildSourcesTestFolder    = buildFolder & "/sources/test"
  buildCacheFolder          = buildFolder & "/cache"
  buildTargetFolder         = buildFolder & "/target"
  buildDockerFolder         = buildFolder & "/docker"
  buildResourcesMainFolder  = buildFolder & "/resources/main"
  buildResourcesTestFolder  = buildFolder & "/resources/test"
  buildBinaryFile           = buildTargetFolder & "/" & binaryName
  sourcesFolder               = thisDir() & '/' & "src"
  sourcesMainFolder           = sourcesFolder & "/main"
  sourcesMainNimFolder        = sourcesMainFolder & "/nim"
  sourcesMainResourcesFolder  = sourcesMainFolder & "/resources"
  sourcesTestFolder           = sourcesFolder & "/test"
  sourcesTestNimFolder        = sourcesTestFolder & "/nim"
  sourcesTestResourcesFolder  = sourcesTestFolder & "/resources"
  sourcesMainFile             = buildSourcesMainFolder & "/" & mainFileName



template dependsOn (tasks: untyped) =
  for taskName in astToStr(tasks).split({',', ' '}):
    exec "nim " & taskName


proc build_create () =
  for folder in @[buildSourcesMainFolder, buildCacheFolder, buildTargetFolder]:
    if not dirExists folder:
      mkdir folder
  if dirExists sourcesMainResourcesFolder:
    mkdir buildResourcesMainFolder


proc build_copy () =
  build_create()
  if dirExists sourcesMainNimFolder:
    exec "cp -r $1/* $2".format(sourcesMainNimFolder, buildSourcesMainFolder)
  if dirExists(sourcesMainResourcesFolder) and listFiles(sourcesMainResourcesFolder).len > 0:
    exec "cp -r $1/* $2".format(sourcesMainResourcesFolder, buildResourcesMainFolder)


proc test_copy () =
  build_copy()
  if dirExists(sourcesTestNimFolder) and listFiles(sourcesTestNimFolder).len > 0:
    if not dirExists buildSourcesTestFolder:
      mkdir buildSourcesTestFolder
    exec "cp -r $1/* $2".format(sourcesTestNimFolder, buildSourcesTestFolder)
  if dirExists(sourcesTestResourcesFolder) and listFiles(sourcesTestResourcesFolder).len > 0:
    if not dirExists buildResourcesTestFolder:
      mkdir buildResourcesTestFolder
    exec "cp -r $1/* $2".format(sourcesTestResourcesFolder, buildResourcesTestFolder)


proc folders (dir: string): seq[string] =
  result = newSeq[string]()
  result.add(dir)
  for child in listDirs(dir):
    result.add(folders(child))


proc findTestFiles (): seq[string] =
  result = newSeq[string]()
  for folder in folders(buildSourcesTestFolder):
    for file in listFiles(folder):
      if file.endsWith("_test.nim"):
        result.add(file)


proc addAllBuildPaths () =
  switch "path", buildSourcesMainFolder
  if existsDir buildResourcesMainFolder:
    switch "path", buildResourcesMainFolder

  for folder in folders(buildSourcesMainFolder):
    switch "path", folder


proc collectPaths (folder: string): string =
  result = ""
  for child in folders(folder):
    result &= " --path:" & child


task clean, "cleans the project":
  if dirExists buildFolder:
    rmdir buildFolder
  else:
    echo "Nothing to clean"


task test, "tests the project":
  dependsOn clean
  test_copy()

  var command = "nim compile"
  command &= collectPaths(buildSourcesMainFolder)
  command &= collectPaths(buildResourcesMainFolder)
  command &= collectPaths(buildSourcesTestFolder)
  command &= collectPaths(buildResourcesTestFolder)

  command &= " --nimcache:" & buildCacheFolder
  command &= " --out:" & buildTargetFolder & "/test"
  command &= " --verbosity:0"
  command &= " --run "

  for file in findTestFiles():
    exec command & file
  rmFile buildTargetFolder & "/test"


task build, "builds the project":
  if paramCount() == 2 and paramStr(2) == "release":
    dependsOn test
    switch "define", "release"
  else:
    dependsOn clean
    build_copy()

  --verbosity:1
  switch "out", buildBinaryFile
  switch "nimcache", buildCacheFolder

  addAllBuildPaths()
  setCommand "compile", sourcesMainFile


task init, "initialize a project":
  for folder in @[sourcesMainNimFolder, sourcesMainResourcesFolder, sourcesTestNimFolder, sourcesTestResourcesFolder]:
    mkdir folder
  exec "echo 'echo \"Hello world\"' > $1/$2.nim".format(sourcesMainNimFolder, mainFileName)


task docker, "builds the project within specific docker container":
  dependsOn clean
  build_copy()

  exec "mkdir -p $1".format(buildDockerFolder)

  exec """docker run \
--rm \
-v '$1:/tmp/src' \
-v '$2:/tmp/target' \
xxlabaza/nim:0.17.0 \
compile --define:release \
        --symbolFiles:off \
        --nimcache:/tmp/src/cache \
        --path:/tmp/src/sources/main \
        --path:/tmp/src/resources/main \
        --out:/tmp/target/$3 \
        /tmp/src/sources/main/$4""".format(buildFolder, buildDockerFolder, binaryName, mainFileName)

  exec "docker build --force-rm=true --tag xxlabaza/luntic:$1 .".format(version)


task run, "runs the project":
  dependsOn build

  var command = buildBinaryFile
  for parameterIndex in 2..paramCount():
    command &= ' ' & paramStr(parameterIndex)

  exec command
  setCommand "nop"
