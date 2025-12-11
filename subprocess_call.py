import subprocess

command_string = 'appium --allow-insecure=adb_shell'
## call appium adb insecure shell
subprocess.call(f'C:\Windows\System32\WindowsPowerShell\\v1.0\powershell.exe {command_string}', shell=True) # type: ignore