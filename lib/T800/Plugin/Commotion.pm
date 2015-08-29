package T800::Plugin::Commotion;

use Moose;

with 'T800::Role::Plugin';
with 'T800::Role::MessageReceiver';
with 'T800::Role::Initialization';

sub BUILD {
    my $self = shift;

    $self->name('commotion');
}

sub on_privmsg {
    my ($self, $who, $where, $what) = @_;
    my ($nick, $channel) = ((split '!', $who)[0], $where->[0]);

    # Print a little message that tells us what's going on:
    print "$channel <$nick> $what\n";
}

__PACKAGE__->meta->make_immutable;
