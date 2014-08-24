# sh-realpath

*A portable, pure shell implementation of realpath*

Copy the functions in [realpath.sh](realpath.sh) into your shell script to
avoid introducing a dependency on either `realpath` or `readlink -f`, since:

* `realpath` does not come installed by default
* `readlink -f` **is not portable** to OS-X ([relevant man page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/Manpages/man1/readlink.1.html))

## Usage

    $ source ./realpath.sh
    $ realpath /proc/self
    /proc/2772

Or we can get tricky:

    $ cd /tmp
    $ mkdir -p somedir/targetdir somedir/anotherdir
    $ ln -s somedir somedirlink
    $ ln -s somedir/anotherdir/../anotherlink somelink
    $ ln -s targetdir/targetpath somedir/anotherlink
    $ realpath .///somedirlink/././anotherdir/../../somelink
    /tmp/somedir/targetdir/targetpath

## API

Note: unlike `realpath(1)`, these functions take no options; **do not** use `--` to escape any arguments

Function                          | Description
----------------------------------|--------------
<pre>realpath PATH</pre>          | Resolve all symlinks to `PATH`, then output the canonicalized result
<pre>resolve_symlinks PATH</pre>  | If `PATH` is a symlink, follow it as many times as possible; output the path of the first non-symlink found
<pre>canonicalize_path PATH</pre> | Output absolute path that `PATH` refers to, resolving any relative directories (`.`, `..`) in `PATH` and any symlinks in `PATH`'s ancestor directories

## readlink(1) Portability

**sh-realpath** has a hard dependency on the `readlink` command.

It should be noted that `readlink(1)` is not included in the [POSIX
Standard](https://shellhaters.heroku.com/posix).  However, it is
included in GNU coreutils, FreeBSD, OS-X, and probably elsewhere, so it is
reasonably portable.

If for some reason you need to support systems that do not have the `readlink`
command installed, one workaround is to define a shell function called `readlink`
that wraps the output of `ls -l`.  For implementation hints, see [this
post](http://unix.stackexchange.com/a/76517/49971) by Gilles.  If there is
demand for it, I can include a workaround in **sh-realpath**.
