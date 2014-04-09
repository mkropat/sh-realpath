# sh-realpath

*A portable, pure shell implementation of realpath*

Copy the functions in [realpath.sh](realpath.sh) into your shell script to
avoid introducing a dependency on either `realpath` or `readlink -f`, since:

* `realpath` does not come installed by default
* `readlink -f` **is not portable** to OS-X ([relevant man page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/Manpages/man1/readlink.1.html))

## Usage:

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

Note: unlike `realpath(1)`, these functions take no options.  Any arguments
**should not** be escaped with `--`.

Function                 | Description
-------------------------|--------------
`realpath PATH`          | Resolve all symlinks to `PATH`, then output the canonicalized result
`resolve_symlinks PATH`  | Follow symlink that `PATH` points to; repat as many time as necessary to find a non-symlink, then output it
`canonicalize_path PATH` | Output absolute path that `PATH` refers to, resolving any relative directories (`.`, `..`) in `PATH` and any symlinks in `PATH`'s parent directories

## readlink(1) Portability

**sh-realpath** has a hard dependency on the `readlink` command.

It should be noted that `readlink(1)` is not included in the [POSIX
Standard](https://shellhaters.heroku.com/posix).  However, the command is
included in GNU coreutils, FreeBSD, OS-X, and probably elsewhere, so it is
reasonably portable.

If for some reason you need to support systems that do not have the `readlink`
command, one workaround is to define a shell function to replace it using the
`ls` command.  For implementation hints, see [this
post](http://unix.stackexchange.com/a/76517/49971) by Gilles.  If there is
demand for it, I can include a workaround in **sh-realpath**.
