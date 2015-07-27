package T800::Role::IRCHandler;

use Moose::Role;


has 'irc' => (
    isa   => 'Object',
    is    => 'rw',
    );

after 'BUILD' => sub {
    my $self = shift;

    $self->irc($self->core->irc);
};

1;
