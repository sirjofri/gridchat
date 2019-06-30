gridchat
========

This gridchat application is an extension to the hubfs chat of the [plan 9
public grid project](http://wiki.9gridchan.org/Hubfs_chat/index.html).

It has the following features:

- It has a GUI!
- You can start it directly on your inferno `emu` command line. It
  autoconnects to hubfs chat.
- You can set and change your nick (type + hit enter to send a proper JOIN
  notification to the chat).
- type your message and hit enter (or press that big button) to send the
  message.
- it is entirely written in inferno limbo, the binary should run on all
  inferno dis machines.
- you can scroll with keys (inside the message entry box, hit keys up/down)
- you can enter additional commands (see below)

Furthermore it works on mobile inferno installations like [the one
of bhgv](https://github.com/bhgv/Inferno-OS_Android). You may need to adjust
font and scaling.

Please note that **this is an unofficial application. It's created by a user
of hubfs chat, not by the creators or maintainers of hubfs chat.**

Commands
--------

- `/j[oin] <chat>` (Not implemented yet).
- `/c[onfig]` print current configuration.
- `/aj [0|1]` or `/autoj[ump] [0|1]` prevents scrolling after messages. Good
  for reading the history. Without the optional argument the feature is
  toggled.
- `/part [message]` prints a part message. This does _not_ leave the chat!

License
=======

Copyright (c) 2019 Joel Fridolin Meyer (sirjofri)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
