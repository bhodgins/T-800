package T800::Plugin::PluginUtil;

use Moose;

with 'T800::Role::Plugin';
with 'T800::Role::PluginCommands';
with 'T800::Role::Initialization';
with 'T800::Role::IRCHandler';


sub t800_init {
    my $self = shift;

    $self->name('pluginutil');
    $self->add_command('list' => 'list_plugins');
}

sub list_plugins {
    my ($self, $who, $where, $what) = @_;
    my $channel = $where->[0];
    my @plugin_list = ();

    push @plugin_list, $_->name
	foreach (@{ $self->core->_plugins });

    $self->irc->yield(
	'privmsg',
	$channel,
	"Currently loaded plugins: @{[join(', ', @plugin_list)]}",
	);
}

__PACKAGE__->meta->make_immutable;
