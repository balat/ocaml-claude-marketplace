# Ocsigen Toolkit widgets

Client-server widgets usable from shared sections. Module names are those of Eliom 13
(`Ot.Spinner`); Eliom 12 and earlier use `Ot_spinner`. The demo files are those of the
Ocsigen Start template (`os_template`).

## Contents

- Layout and navigation
- Asynchronous content
- Inputs and pickers
- Gestures and motion
- DOM helpers

## Layout and navigation

| Module | Purpose | Demo |
|---|---|---|
| `Ot.Drawer` | side drawer menu for mobile and web layouts | `myapp_drawer.eliom` in the template |
| `Ot.Carousel` | swipeable carousel with tabs, bullets and ribbon, also usable as a tabbed view | `demo_carousel1`, `demo_carousel2`, `demo_carousel3` |
| `Ot.Page_transition` | animated page transitions using screenshots of the leaving page | `demo_pagetransition` |
| `Ot.Popup` | modal popups, confirmation dialogs, closable overlays | `demo_popup` |
| `Ot.Tongue` | panel sliding from the bottom edge with intermediate stops, exposing its position as a signal | `demo_tongue` |
| `Ot.Sticky` | detect and emulate `position: sticky` | |
| `Ot.Tip` | tooltips and onboarding tips (with Ocsigen Start's `Os.Tips`) | `demo_tips` |

## Asynchronous content

| Module | Purpose | Demo |
|---|---|---|
| `Ot.Spinner` | render a placeholder while a promise (RPC, query) resolves, then swap in the content; keeps client-side page rendering from stalling on the slowest call | `demo_spinner` |
| `Ot.Pulltorefresh` | pull-to-refresh gesture on a scrollable container | `demo_pulltorefresh` |
| `Ot.Picture_uploader` | image upload with preview and cropping, with its typed service (`Ot.Picture_uploader.mk_service`) | template avatar upload |

## Inputs and pickers

| Module | Purpose | Demo |
|---|---|---|
| `Ot.Calendar` | calendar and date picker | `demo_calendar` |
| `Ot.Time_picker` | clock-style time picker | `demo_timepicker` |
| `Ot.Color_picker` | colour picker | |
| `Ot.Range` | range selection | |
| `Ot.Toggle` | binary toggle switch | |
| `Ot.Form` | reactive form inputs: `reactive_input`, `debounced_input`, `checkbox`, `radio_buttons`, `disableable_button`, ... | `demo_forms` |
| `Ot.Buttons` | dropdown buttons | |

## Gestures and motion

| Module | Purpose |
|---|---|
| `Ot.Swipe` | bind swipe gestures on an element (`Ot.Swipe.bind`) |
| `Ot.Noderesize` | event when an element's size changes |
| `Ot.Size` | screen, document and element sizes, as values and as React signals |

## DOM helpers

| Module | Purpose |
|---|---|
| `Ot.Nodeready` | `nodeready node` resolves once the node is inserted in the document; use before measuring or focusing a freshly rendered element |
| `Ot.Lib` | `onloads`, `onresizes`, `window_scrolls`, `click_outside`, `in_ancestors` and similar helpers |
| `Ot.Style` | interface to `getComputedStyle` |
| `Ot.Icons` | `<i>` icon elements styled by the toolkit's CSS |
