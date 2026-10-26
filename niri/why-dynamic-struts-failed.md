# Why dynamic struts didn't work

Read this before trying again. It was tried for a couple of days on niri 26.04 and retired.

## The idea

Struts are the empty strips at the left and right edges of the screen. A strip of about
36px lets the neighbouring column peek in, which hints that more windows are off-screen.
The goal: show the strips only when the windows on a workspace overflow the screen, and
use the full width (strips = 0) when everything fits.

The implementation was a small script that watched niri's event stream, wrote the struts to
an included `struts.kdl`, and let niri live-reload the config. The code is in git history
(commit `fc1f349` and what followed; the final version was never committed).

## The root problem: niri doesn't re-scroll when struts change

Niri keeps a scroll position per workspace (the "view offset"), and it only recomputes it
when something moves: focus changes, a window opens or closes, a column is resized.
Changing the struts changes the usable area, but the view is left where it was.

What you see after the struts change:

- Windows sit a few dozen px away from where they should be.
- The window that should be hugging the left edge isn't, and no neighbour peeks in.
- It fixes itself as soon as focus moves to another column, which is why it looks random.

A second effect: a workspace that fits and then goes through "struts on, then struts off"
(because you visited an overflowing workspace in between) comes back about 36px off
its left edge. Niri adjusts each workspace's stored position when the usable area changes,
and the round trip doesn't return it to where it started. This happens even if the struts
are changed *before* switching to that workspace.

Because the struts are one setting for the whole screen, not per workspace, every switch
between a fitting and an overflowing workspace triggers this.

## Everything that was tried

Working:

- Only change struts on overflow, never depending on which window is focused. (Struts that
  depended on focus resized the windows on every focus change: constant jitter.)
- Never turn struts off when a window closes. Otherwise the leftover columns widen and jump.
- To fix the stale view after turning struts on: move focus to a neighbour column and back.
  This works but flashes briefly (about 0.5s including a wait for niri to reload).
- To avoid the stale view when turning struts off on a focus change: run the focus keybinds
  through a wrapper that drops the struts first, waits ~0.2s, then moves focus. This worked,
  but only for focus changes that go through your keybinds (mouse clicks and anything else
  bypass it).

Tried and didn't work:

- `focus-column` on the already-focused column: niri skips it as a no-op.
- `focus-column-right` pressed on the last column: no-op.
- `set-column-width +0`, `set-window-width +0`: no-ops.
- `center-column`, `center-visible-columns`: re-fit, but change the look. The latter only
  centers fully visible columns, so with a partly off-screen neighbour it centers just one.
- Opening and closing the overview.
- Changing the struts before a workspace switch (the "wrap the switch" idea).
- Window rule `open-focused false` to make new windows not scroll the view. Windows spawned
  from niri still took focus.

There is no niri action that aligns a column to the right edge, scrolls the view by an offset,
or forces a re-fit without changing focus.

## What would be needed to make it work

Any one of these:

1. **Niri re-fitting the view on a config reload or a working-area change.** An upstream change
   to niri; there's nothing to do from the config side.
2. **Sticky struts.** Turn them on if *any* workspace on the screen overflows, off only when none
   do. Struts then rarely change, so there's no stale view and no switching jolt. The cost: a
   workspace that fits shows the strips too whenever another workspace overflows. This is the
   most practical idea and was never built.
3. **A way to intercept new windows before they are placed.** Not possible from niri's IPC; it
   only reports windows after the layout has moved. Wrapping spawn keybinds would only cover
   windows you launch through them. It would miss `Ctrl+N` in Firefox, app dialogs, links
   opened by other apps and launcher launches.
4. **Accept the focus bounce.** Re-fit with a focus bounce after every struts change. It works
   but flashes on window opens and workspace switches, which is why it was dropped.

## What was left instead

A fixed 15px left strut in `config.kdl` and nothing on the right. Earlier fixed 12px/14px struts on both sides were tried; with the 10px `gaps` they gave only a 2-4px sliver of the neighbouring column (the peek is the strut minus the gap) and cost width on both sides.
