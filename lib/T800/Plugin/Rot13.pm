package T800::Plugin::Rot13;

use Moose;

with 'T800::Role::Plugin';
with 'T800::Role::PluginCommands';
with 'T800::Role::IRCHandler';
with 'T800::Role::Initialization';


sub BUILD {
    my $self = shift;

    $self->name('rot13');
    $self->add_command('_default' => 'rot13');
}

sub rot13 {
    my ($self, $who, $where, $what) = @_;
    my $nickname = (split '!', $who)[0];
    my $channel  = $where->[0];

    $what =~ tr[a-zA-Z][n-za-mN-ZA-M];
    $self->irc->yield( privmsg => $channel => "$nickname: $what");
}

__PACKAGE__->meta->make_immutable;
