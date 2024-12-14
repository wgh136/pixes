import subprocess
import os
import httpx

file = open('pubspec.yaml', 'r')
content = file.read()
file.close()

subprocess.run(["flutter", "build", "windows"], shell=True)

version = str.split(str.split(content, 'version: ')[1], '+')[0]

subprocess.run(["tar", "-a", "-c", "-f", f"build/windows/pixes-{version}-windows.zip", "-C", "build/windows/x64/runner/Release", "*"]
               , shell=True)

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

if not os.path.exists("windows/ChineseSimplified.isl"):
    # download ChineseSimplified.isl
    url = "https://raw.githubusercontent.com/kira-96/Inno-Setup-Chinese-Simplified-Translation/refs/heads/main/ChineseSimplified.isl"
    response = httpx.get(url)
    with open('windows/ChineseSimplified.isl', 'wb') as file:
        file.write(response.content)

subprocess.run(["iscc", "windows/build.iss"], shell=True)

with open('windows/build.iss', 'w') as file:
    file.write(issContent)