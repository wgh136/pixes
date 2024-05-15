import subprocess
import os

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

subprocess.run(["iscc", "build/windows/build.iss"], shell=True)