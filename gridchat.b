implement gridchat;

include "sys.m";
	sys: Sys;
	sprint: import sys;
include "arg.m";
include "draw.m";
include "sh.m";
	sh: Sh;
include "dial.m";
	dial: Dial;
include "tk.m";
	tk: Tk;
include "tkclient.m";
	tkclient: Tkclient;
include "keyboard.m";

t: ref Tk->Toplevel;
wmctl: chan of string;

gridaddress := "tcp!chat.9gridchan.org!9997";
mountpoint := "/n/chat";
channel := "chat";
filename := "/tmp/test";
nick := "nickname";
verbose := 0;
dowarn := 0;

gridchat: module
{
	init: fn(ctxt: ref Draw->Context, args: list of string);
};

tkcmds := array[] of {
	"frame .fr",
	"text .out -width 450 -height 500 -state disabled",
	"entry .nick -width 100",
	"bind .nick <Key-\n> {send cmd changenick}",
	"entry .in -width 300",
	"bind .in <Key-\n> {send cmd send}",
	"frame .sendline",
	"button .btn -width 45 -text {Send} -command {send cmd send}",
	"pack .nick .in .btn -in .sendline -side left -fill x",
	"pack .out .sendline -in .fr",
	"pack .fr",
	"focus .in",
};

init(ctxt: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	sh = load Sh Sh->PATH;
	dial = load Dial Dial->PATH;
	tk = load Tk Tk->PATH;
	tkclient = load Tkclient Tkclient->PATH;
	tkclient->init();
	if (ctxt == nil)
		ctxt = tkclient->makedrawcontext();
	if (ctxt == nil)
		fail("no window context");

	(t, wmctl) = tkclient->toplevel(ctxt, "", "gridchat", Tkclient->Appl);
	tkcmdchan := chan of string;
	tk->namechan(t, tkcmdchan, "cmd");
	for (i := 0; i < len tkcmds; i++)
		tkcmd(tkcmds[i]);

	mountgridchat(ctxt);
	preinit(args);

	tkclient->onscreen(t, nil);
	tkclient->startinput(t, "kbd"::"ptr"::nil);

	fd := sys->open(filename, sys->OREAD);
	if (fd == nil)
		fail(sprint("cannot open file %s", filename));
	spawn read_chat(fd);

	for (;;) alt {
	s := <-t.ctxt.kbd =>
		tk->keyboard(t, s);
	s := <-t.ctxt.ptr =>
		tk->pointer(t, *s);
	s := <-t.ctxt.ctl or
	s  = <-t.wreq or
	s  = <-wmctl =>
		tkclient->wmctl(t, s);
	s := <-tkcmdchan =>
		evalcmd(s);
	}
}

preinit(args: list of string)
{
	arg := load Arg Arg->PATH;
	arg->init(args);
	arg->setusage(arg->progname()+" [-v] [-n nick] [-c channel]");
	while ((c := arg->opt()) != 0)
		case c {
			'n' =>
				nick = arg->earg();
			'c' =>
				channel = arg->earg();
			'v' =>
				verbose = 1;
		}

	filename = sprint("%s/%s", mountpoint, channel);

	if (sys->open(filename, sys->ORDWR) == nil)
		fail(sprint("error opening file %s for reading and writing", filename));

	tkcmd(".nick delete 0 end");
	tkcmd(sprint(".nick insert 0 %s", nick));
	if (nick != "nickname")
		writemsg(sprint("JOIN %s to chat\n", nick));
}

evalcmd(s: string)
{
	case s {
	"send" =>
		nname := tkcmd(".nick get");
		msg := tkcmd(".in get");
		if (msg == nil || msg == "")
			return;
		if (nname == nil || nname == "" || nname == "nickname") {
			sysnotice("please change your nick");
			break;
		}
		writemsg(sprint("%s :  %s\n", nname, msg));
		tkcmd(".in delete 0 end");
	"changenick" =>
		nname := tkcmd(".nick get");
		tkcmd("focus .in");
		if (nname == nil || nname == "" || nname == "nickname" || nname == nick)
			break;
		if (nick != "nickname") {
			writemsg(sprint("NICK> %s is now called %s\n", nick, nname));
			break;
		}
		nick = nname;
		writemsg(sprint("JOIN %s to chat\n", nick));
	}
}

sysnotice(s: string)
{
	msg := sprint("---> NOTE: %s <---\n", s);
	tkcmd(sprint(".out insert end {%s}", msg));
	if (verbose)
		sys->fprint(sys->fildes(2), "sysnotice: %s\n", msg);
}

writemsg(s: string)
{
	fd := sys->open(filename, sys->OWRITE);
	if (fd == nil)
		fail(sprint("error writing file %s", filename));
	sys->seek(fd, big 0, sys->SEEKEND);
	sys->fprint(fd, "%s", s);
	if (verbose)
		sys->fprint(sys->fildes(2), "wrote message\n");
	tkcmd(".out see end");
}

read_chat(fd: ref Sys->FD)
{
	buf := array[Sys->ATOMICIO] of byte;
	dowarn = 0;
	while (( n := sys->read(fd, buf, len buf)) > 0)
		tkcmd(sprint(".out insert end {%s}; .out see end", string buf[:n]));
	if (n < 0)
		fail(sprint("cannot read from file %s", filename));
	dowarn = 1;
}

tkcmd(s: string): string
{
	r := tk->cmd(t, s);
	if (dowarn && r != nil && r[0] == '!')
		warn(sprint("tkcmd: %q: %s", s, r));
	return r;
}

warn(s: string)
{
	sys->fprint(sys->fildes(2), "%s\n", s);
}

fail(s: string)
{
	warn(s);
	raise "fail: " + s;
}


mountgridchat(ctxt: ref Draw->Context)
{
	rtn := sh->system(ctxt, "ndb/cs");
	if (rtn != nil || rtn != "")
		fail(sprint("cannot start ndb/cs:\n%s", rtn));
	if (verbose)
		sys->fprint(sys->fildes(2), "started ndb/cs\n");
	dest := dial->netmkaddr(gridaddress, "net", "styx");
	c := dial->dial(dest, nil);
	if (c == nil)
		fail(sprint("can't dial %s: %r", dest));
	if (verbose)
		sys->fprint(sys->fildes(2), "connected with %s\n", gridaddress);

	if (sys->mount(c.dfd, nil, mountpoint, sys->MCREATE | sys->MREPL, nil) < 0)
		fail("can't mount gridchat filesystem");
	if (verbose)
		sys->fprint(sys->fildes(2), "mounted %s\n", mountpoint);
}