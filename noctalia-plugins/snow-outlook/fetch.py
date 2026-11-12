#!/usr/bin/env python3
"""Print 7-day snow outlook as JSON. Location from Noctalia's cache; data: Open-Meteo."""
import json, os, sys, urllib.request

loc = json.load(open(os.path.expanduser("~/.cache/noctalia/location.json")))
url = ("https://api.open-meteo.com/v1/forecast?latitude=%s&longitude=%s"
       "&current=temperature_2m,apparent_temperature,wind_speed_10m&hourly=temperature_2m&daily=snowfall_sum,weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset"
       "&wind_speed_unit=mph&precipitation_unit=inch&forecast_days=7&timezone=auto"
       % (loc["latitude"], loc["longitude"]))
r = json.load(urllib.request.urlopen(url, timeout=15))
d = r["daily"]
now_c = r["current"]["temperature_2m"]
SNOW_CODES = {71, 73, 75, 77, 85, 86}
days = []
for t, s, c, hi, lo, p in zip(d["time"], d["snowfall_sum"], d["weather_code"], d["temperature_2m_max"], d["temperature_2m_min"], d["precipitation_probability_max"]):
    s = s or 0
    days.append({"date": t, "snow": s >= 0.05 or c in SNOW_CODES, "inches": round(s, 1), "hi": round(hi), "lo": round(lo), "pct": p or 0})
def hr(x): return round(int(x[11:13]) + int(x[14:16]) / 60, 2)
sun = {"sunrise": hr(d["sunrise"][0]), "sunset": hr(d["sunset"][0])}
h = r["hourly"]["temperature_2m"]
periods = [{"name": n, "c": round(h[i]), "f": round(h[i] * 9 / 5 + 32)} for n, i in (("Morning", 8), ("Afternoon", 14), ("Evening", 21))]
json.dump({"periods": periods, "hourly": [round(x, 1) for x in h[:24]], "place": loc.get("name", ""), "now_c": round(now_c), "now_f": round(now_c * 9 / 5 + 32), "feels_c": round(r["current"]["apparent_temperature"]), "wind": round(r["current"]["wind_speed_10m"]), "days": days, **sun}, sys.stdout)
