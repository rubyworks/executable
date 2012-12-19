### Manpages

If a man page is available for a given command using the #show_help
method will automatically find the manpage and display it.

    sample = File.dirname(__FILE__) + '/samples'

    manpage = `ruby #{sample}/bin/hello --manpage`.strip

    manpage.assert == sample + '/man/hello.1'

Note: Would rather use #load for this, but without a `.rb` on
the `hello` file, it doesn't seem possible.

