#!/usr/bin/env python3
"""Print 7-day snow outlook as JSON. Location from Noctalia's cache; data: Open-Meteo."""
import json, os, sys, urllib.request

loc = json.load(open(os.path.expanduser("~/.cache/noctalia/location.json")))
url = ("https://api.open-meteo.com/v1/forecast?latitude=%s&longitude=%s"
       "&current=temperature_2m,apparent_temperature,wind_speed_10m&hourly=temperature_2m,snowfall,precipitation_probability&daily=snowfall_sum,weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset"
       "&wind_speed_unit=mph&precipitation_unit=inch&forecast_days=7&timezone=auto"
       % (loc["latitude"], loc["longitude"]))
r = json.load(urllib.request.urlopen(url, timeout=15))
d = r["daily"]
now_c = r["current"]["temperature_2m"]
SNOW_CODES = {71, 73, 75, 77, 85, 86}
# One rule everywhere: snow needs enough chance AND (a little snow OR a snow weather code).
MIN_POP = 30        # % chance of precipitation
DAY_MIN_IN = 0.02   # forecast inches for a day
HOUR_MIN_IN = 0.01  # forecast inches for one hour
days = []
for t, s, c, hi, lo, p in zip(d["time"], d["snowfall_sum"], d["weather_code"], d["temperature_2m_max"], d["temperature_2m_min"], d["precipitation_probability_max"]):
    s = s or 0
    days.append({"date": t, "snow": (p or 0) >= MIN_POP and (s >= DAY_MIN_IN or c in SNOW_CODES), "inches": round(s, 1), "hi": round(hi), "lo": round(lo), "pct": p or 0})
sf = r["hourly"]["snowfall"]
hp = r["hourly"]["precipitation_probability"]
# an hour counts only if it passes the chance test too; others are zeroed
sf = [(x or 0) if (x or 0) >= HOUR_MIN_IN and (hp[k] or 0) >= MIN_POP else 0 for k, x in enumerate(sf)]
for i, day in enumerate(days):
    v = sf[24 * i:24 * i + 24]
    on = [k for k, x in enumerate(v) if x > 0]
    if on and day["snow"]:
        day.update({"from": on[0], "to": on[-1] + 1, "peak": v.index(max(v))})
pop = [x or 0 for x in r["hourly"]["precipitation_probability"][:24]]
FAKE = os.path.expanduser("~/.cache/noctalia/snow-fake")  # touch to enable demo data, rm to disable
fake_now = None
if os.path.exists(FAKE):
    prof = [0, .02, .05, .12, .2, .14, .06, .02]  # 1pm-8pm
    sf = [0.0] * 24
    for k, x in enumerate(prof): sf[13 + k] = x
    for i, (inch, f, t, pk) in {0: (0.6, 13, 21, 17), 1: (1.4, 9, 18, 13), 3: (5.2, 18, 24, 21)}.items():
        days[i].update({"snow": True, "inches": inch, "pct": 85, "from": f, "to": t, "peak": pk})
    days[2].update({"snow": False, "inches": 0, "from": None, "to": None, "peak": None})
    pop = [10] * 24
    for k, x in enumerate([30, 45, 60, 75, 90, 80, 55, 30]): pop[13 + k] = x
    fake_now = 16
def hr(x): return round(int(x[11:13]) + int(x[14:16]) / 60, 2)
sun = {"sunrise": hr(d["sunrise"][0]), "sunset": hr(d["sunset"][0])}
h = r["hourly"]["temperature_2m"]
periods = [{"name": n, "c": round(h[i]), "f": round(h[i] * 9 / 5 + 32)} for n, i in (("Morning", 8), ("Afternoon", 14), ("Evening", 21))]
json.dump({"pop_hourly": pop, "snow_hourly": [round(x or 0, 2) for x in sf[:24]], "now_hour": fake_now if fake_now is not None else int(r["current"]["time"][11:13]), "periods": periods, "hourly": [round(x, 1) for x in h[:24]], "place": loc.get("name", ""), "now_c": round(now_c), "now_f": round(now_c * 9 / 5 + 32), "feels_c": round(r["current"]["apparent_temperature"]), "wind": round(r["current"]["wind_speed_10m"]), "days": days, **sun}, sys.stdout)
