### Manpages

If a man page is available for a given command using the #show_help
method will automatically find the manpage and display it.

    sample = File.dirname(__FILE__) + '/samples'

    load(sample + '/bin/hello')

    manpage = Hello.cli.manpage

    manpage.assert == sample + '/man/hello.1'

