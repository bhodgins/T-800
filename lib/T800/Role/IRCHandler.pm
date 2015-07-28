package T800::Role::IRCHandler;

use Moose::Role;


has 'irc'   => (
    isa     => 'Object',
    is      => 'rw',
    lazy    => 1,
    builder => '_build_irc',
    );

sub _build_irc { shift->core->irc }

1;
