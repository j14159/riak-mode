riak-mode
=========

Browse Riak through emacs (but only if you like doing things the wrong way)

#Why Would You Do Such A Thing
Mostly **_sheer perversity_**.

I wanted to learn elisp and how to write a major mode for a few other things to come later.  This seemed like a simple place to start that would also save me cutting and pasting to curl, etc when debugging stuff that writes to Riak.

Generally speaking, this does everything to Riak that you're not supposed to do (e.g. list all buckets, list all keys in a bucket).  It's set to use port 8098 (typical HTTP port for Riak) in a var that you should be able to override (see source).  Upon start, it will ask you to provide a Riak node against which to perpetrate its horrors.

#How Do I Use It?
You probably shouldn't.

But in case you want to, stick `riak-mode.el` somewhere in your emacs load path, run `M-x package-install emacs-web`  and do the following:

`M-: (require 'riak-mode)`

`M-x riak-mode`

"b" will pull a list of buckets from the node, use the return key on a bucket name to list its keys and return on a key to get the contents of it slapped into the riak-mode output buffer.

#Warnings
This is my first attempt at anything in elisp and as such, should be considered Bad Code.  I might get around to cleaning it up but since everything this does is inadvisable, I'll probably let it languish.

If you run this against a production Riak cluster it will probably Have A Sad leading to it Not Behaving The Way You Want.  Should this degraded situation occur, own your on head be it.  I warned you not to use this.

