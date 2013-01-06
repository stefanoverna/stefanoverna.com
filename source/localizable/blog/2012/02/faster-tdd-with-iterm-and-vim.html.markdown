---
title: Faster TDD with iTerm and vim
date: 2012/02/06
---

A couple of weeks ago [Josh Davey][] released [turbux][], a great vim plugin that aims to keep your TDD feedback loop faster and less prone to unnecessary context-switches through the use of split sessions and [tmux][].

Before you continue reading this post, [check out the announcement post on his blog][post], so you know what we're talking about.

## iTerm anyone?

Anything that can speed up our TDD loop has to be taken very seriously, so I tried to port the same concepts to my personal development habits.

In my day-to-day work I make use of [iTerm 2][iterm], a great replacement to the default Mac terminal application. iTerm provides both split and tab sessions; furthermore, it supports the use of AppleScript to automate many aspects of its behavior.

I asked myself whether I really needed to add an "extra layer" to my usual stack — that is, tmux — or rather if I could achieve the same result without it. Turns out it was not the case.

## How to communicate with iTerm

Man, I hate AppleScript. Approximately 90% of the entire time spent on this small project was just to learn the minimum necessary to write this:

    [@language="bash"]
    #! /usr/bin/osascript
    tell application "iTerm"
      tell the current terminal
        tell (first session Whose name contains "foo")
          text write ("echo bar" as text)
        end tell
      end tell
    end tell

This code searches in the current iTerm window for a session named "foo", and sends the command `echo bar` to it. As you might have guessed, we just built a bridge between vim and an iTerm session.

## Welcome iTermux!

Next step was to fork the turbux plugin, rename it into [itermux][] (how original, right?) and replace its `Send_to_Tmux()` function with a parametrized version of the snippet mentioned above:

    [@language="vim"]
    function! Send_to_iTerm(command)
      let app = 'iTerm'
      if exists("g:itermux_app_name") && g:itermux_app_name != ''
        let app = g:itermux_app_name
      endif
      let session = 'iTermux'
      if exists("g:itermux_session_name") && g:itermux_session_name != ''
        let session = g:itermux_session_name
      endif

      let commands =  [ '-e "on run argv"',
                      \ '-e "tell application \"' . app . '\""',
                      \ '-e "tell the current terminal"',
                      \ '-e "tell (first session whose name contains \"' . session . '\")"',
                      \ '-e "set AppleScript''s text item delimiters to \" \""',
                      \ '-e "write text (argv as text)"',
                      \ '-e "end tell"',
                      \ '-e "end tell"',
                      \ '-e "end tell"',
                      \ '-e "end run"' ]

      let complete_command = "osascript " . join(commands, ' ') . " " . a:command
      system(complete_command)
    endfunction

As you can see, I've made it possible to change the name of the iTerm app and the name you want to give to the iTerm session dedicated to testing, i.e.:

    [@language="vim"]
    let g:itermux_session_name = 'testing'
    let g:itermux_app_name = 'iTerm2'

## Demo Time

I've prepared a [small video][video] to show how cool it is the final result. I've been using this setup for two weeks now, and it's been so rewarding.

<p><iframe src="http://player.vimeo.com/video/36213322?title=0&amp;byline=0&amp;portrait=0" width="600" height="600" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe></p>

## Feedbacks appreciated!

[Download it][itermux], install it, and let us know what you think of it!

[Josh Davey]: http://twitter.com/joshuadavey
[post]: http://joshuadavey.com/post/15619414829/faster-tdd-feedback-with-tmux-tslime-vim-and
[turbux]: https://github.com/jgdavey/vim-turbux
[tmux]: http://tmux.sourceforge.net/
[iterm]: http://www.iterm2.com/
[video]: http://vimeo.com/welaika/itermux
[itermux]: https://github.com/welaika/vim-itermux
