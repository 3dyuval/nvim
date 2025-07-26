#!/usr/bin/env lua

print("=== MINIMAL SCRIPT TEST ===")
print("Sending commands via script...")

os.execute('kitten @ send-text --match "title:Basic Test" "$(printf \'\\x1b\')"')
os.execute("sleep 0.1")
os.execute('kitten @ send-text --match "title:Basic Test" ":"')
os.execute("sleep 0.1")
os.execute('kitten @ send-text --match "title:Basic Test" "echo script test"')
os.execute("sleep 0.1")
os.execute('kitten @ send-text --match "title:Basic Test" "$(printf \'\\r\')"')

print("Script commands sent.")

