#!/usr/bin/env python3
"""Capture original emulator PNGs, UI XML and ordered walkthrough metadata.

Run using the repository Python environment. Commands are passed as one JSON
array, e.g. '[{"op":"inspect"}]'. Captures never modify screenshot pixels.
"""
import hashlib
import json
import re
import shlex
import subprocess
import sys
import time
import requests
from datetime import datetime
from pathlib import Path
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[1] / "android-sgac2-2026-09-07"
SERIAL = "emulator-5554"
SESSION_FILE = Path("/private/tmp/myica-walkthrough-session.json")


def adb(*args, binary=False):
    p = subprocess.run(["adb", "-s", SERIAL, *args], capture_output=True, timeout=40)
    if p.returncode:
        raise RuntimeError(p.stderr.decode(errors="replace"))
    return p.stdout if binary else p.stdout.decode(errors="replace")


def source():
    if SESSION_FILE.exists():
        sid = json.loads(SESSION_FILE.read_text())["sessionId"]
        response = requests.get(f"http://127.0.0.1:4727/session/{sid}/source", timeout=30)
        response.raise_for_status()
        return response.json()["value"]
    adb("shell", "uiautomator", "dump", "/sdcard/myica_walkthrough.xml")
    raw = adb("exec-out", "cat", "/sdcard/myica_walkthrough.xml")
    return raw[raw.index("<?xml"):]


def nodes(raw):
    return [n for n in ET.fromstring(raw).iter() if n.get("bounds")]


def describe(raw):
    result = []
    for n in nodes(raw):
        a = n.attrib
        bounds = list(map(int, re.findall(r"\d+", a.get("bounds", ""))))
        if len(bounds) != 4 or bounds[2] <= bounds[0] or bounds[3] <= bounds[1]:
            continue
        if a.get("text") or a.get("content-desc") or a.get("class", "").endswith("EditText"):
            result.append({k: a[k] for k in ("text", "content-desc", "resource-id", "bounds", "checked") if a.get(k) and a.get(k) != "false"})
    modal_indices = [i for i, row in enumerate(result) if row.get("content-desc") == "Close modal"]
    if modal_indices:
        result = result[modal_indices[-1]:]
    for row in result:
        for key in ("text", "content-desc"):
            if len(row.get(key, "")) > 220:
                row[key] = row[key][:217] + "..."
    return result


def capture(c):
    directory = ROOT / c["category"]
    (directory / "screenshots").mkdir(parents=True, exist_ok=True)
    (directory / "sources").mkdir(exist_ok=True)
    manifest = directory / "manifest.json"
    records = json.loads(manifest.read_text()) if manifest.exists() else []
    slug = re.sub(r"[^a-z0-9]+", "-", c["title"].lower()).strip("-")
    stem = f"{len(records)+1:03d}-{slug}"
    raw = source()
    if c.get("web"):
        for _ in range(15):
            webviews = [n for n in nodes(raw) if n.get("class") == "android.webkit.WebView"]
            if any(sum(bool(child.get("text") or child.get("content-desc")) for child in webview.iter()) >= 8 for webview in webviews):
                break
            time.sleep(1)
            raw = source()
    for _ in range(8):
        if not any(n.get("text") == "Loading..." for n in nodes(raw)):
            break
        time.sleep(1)
        raw = source()
    png = adb("exec-out", "screencap", "-p", binary=True)
    if not png.startswith(b"\x89PNG\r\n\x1a\n"):
        raise RuntimeError("Device did not return a PNG")
    (directory / "screenshots" / f"{stem}.png").write_bytes(png)
    (directory / "sources" / f"{stem}.xml").write_text(raw)
    record = {"step": len(records)+1, "title": c["title"], "action": c.get("action", ""),
              "observation": c.get("observation", ""), "status": c.get("status", "Captured"),
              "flow": c.get("flow", c["category"]), "captured_at": datetime.now().astimezone().isoformat(),
              "screenshot": f"screenshots/{stem}.png", "source": f"sources/{stem}.xml",
              "sha256": hashlib.sha256(png).hexdigest()}
    records.append(record)
    manifest.write_text(json.dumps(records, indent=2, ensure_ascii=False)+"\n")
    print(json.dumps({"captured": str(directory / record["screenshot"]), "screen": describe(raw)}, ensure_ascii=False), flush=True)


def run(c):
    op = c["op"]
    if op == "connect":
        response = requests.post("http://127.0.0.1:4727/session", json={"capabilities":{"alwaysMatch":{
            "platformName":"Android", "appium:automationName":"UiAutomator2", "appium:udid":SERIAL,
            "appium:deviceName":"Pixel_7_Pro", "appium:noReset":True, "appium:newCommandTimeout":7200,
            "appium:settings[waitForIdleTimeout]":500, "appium:settings[waitForSelectorTimeout]":500}}}, timeout=120)
        response.raise_for_status()
        value = response.json()["value"]
        SESSION_FILE.write_text(json.dumps({"sessionId":value["sessionId"]}))
        print("Dedicated walkthrough session connected", flush=True)
    elif op == "inspect":
        raw = source()
        ROOT.mkdir(parents=True, exist_ok=True)
        (ROOT / "current-screen.xml").write_text(raw)
        print(json.dumps(describe(raw), ensure_ascii=False), flush=True)
    elif op == "capture":
        capture(c)
    elif op == "tap":
        attr = {"id": "resource-id", "text": "text", "desc": "content-desc"}[c.get("by", "text")]
        matches = []
        for _ in range(6):
            raw = source()
            matches = [n for n in nodes(raw) if (c["value"] in n.get(attr, "") if c.get("contains") else n.get(attr) == c["value"])]
            matches = [n for n in matches if (lambda b: len(b)==4 and b[2]>b[0] and b[3]>b[1])(list(map(int,re.findall(r"\d+",n.get("bounds","")))))]
            if matches:
                break
            time.sleep(0.5)
        if not matches:
            raise RuntimeError(f"No visible element {attr}={c['value']!r}")
        n = matches[c.get("index", 0)]
        x1, y1, x2, y2 = map(int, re.findall(r"\d+", n.get("bounds")))
        adb("shell", "input", "tap", str((x1+x2)//2), str((y1+y2)//2))
        print(json.dumps({"tapped": {k:n.get(k) for k in ["text","content-desc","resource-id","bounds"]}}), flush=True)
        time.sleep(c.get("wait", 0.65))
    elif op == "xy":
        adb("shell", "input", "tap", str(c["x"]), str(c["y"]))
        time.sleep(c.get("wait", 0.65))
    elif op == "input":
        adb("shell", "input", "text", shlex.quote(c["value"].replace(" ", "%s")))
        time.sleep(c.get("wait", 0.4))
    elif op == "clear":
        adb("shell", "input", "keyevent", "KEYCODE_MOVE_END")
        adb("shell", "input", "keyevent", "--longpress", "KEYCODE_DEL")
        for _ in range(c.get("length", 40)):
            adb("shell", "input", "keyevent", "KEYCODE_DEL")
    elif op == "slow_input":
        for char in c["value"]:
            adb("shell", "input", "text", shlex.quote(char))
            time.sleep(0.2)
    elif op == "key":
        adb("shell", "input", "keyevent", c["value"])
        time.sleep(c.get("wait", 0.65))
    elif op == "swipe":
        points = c.get("points", [720, 2450, 720, 850, 450])
        adb("shell", "input", "swipe", *map(str, points))
        time.sleep(0.7)
    elif op == "launch":
        adb("shell", "am", "start", "-n", "sg.gov.ica.mobile.app/sg.gov.ica.mobile.app.MainActivity")
        time.sleep(3)
    elif op == "restart":
        adb("shell", "am", "force-stop", "sg.gov.ica.mobile.app")
        run({"op":"launch"})
    else:
        raise ValueError(op)


if __name__ == "__main__":
    for command in json.loads(sys.argv[1]):
        run(command)
