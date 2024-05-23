import subprocess
import os

os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

fontUse = '''
  fonts:
    - family: font
      fonts:
        - asset: assets/SourceHanSansSC-Regular.otf
'''

file = open('pubspec.yaml', 'r')
content = file.read()
file.close()
file = open('pubspec.yaml', 'a')
file.write(fontUse)
file.close()

subprocess.run(["flutter", "build", "windows"], shell=True)

file = open('pubspec.yaml', 'w')
file.write(content)

if os.path.exists("build/app-windows.zip"):
    os.remove("build/app-windows.zip")

subprocess.run(["tar", "-a", "-c", "-f", "build/windows/x64/app-windows.zip", "-C", "build/windows/x64/runner/Release", "."]
               , shell=True)

version = str.split(str.split(content, 'version: ')[1], '+')[0]
issContent = ""
file = open('windows/build.iss', 'r')
issContent = file.read()
newContent = issContent
newContent = newContent.replace("{{version}}", version)
newContent = newContent.replace("{{root_path}}", os.getcwd())
file.close()
file = open('windows/build.iss', 'w')
file.write(newContent)
file.close()

subprocess.run(["iscc", "windows/build.iss"], shell=True)

with open('windows/build.iss', 'w') as file:
  file.write(issContent)