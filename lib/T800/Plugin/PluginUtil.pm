package T800::Plugin::PluginUtil;

use Moose;
use Module::Refresh;
no warnings 'redefine';

with 'T800::Role::Plugin';
with 'T800::Role::PluginCommands';
with 'T800::Role::Initialization';
with 'T800::Role::IRCHandler';


sub BUILD {
    my $self = shift;

    $self->name('pluginutil');
    $self->add_command('list' => 'list_plugins');
    $self->add_command('reload' => 'reload_plugins');
    Module::Refresh->new;
    print "testing another refresh\n";
}

sub plugin_names {
    my $self = shift;

    my $plugins = [];
    push @{ $plugins }, $_->name foreach @{ $self->core->_plugins };
    $plugins;
}

sub list_plugins {
    my ($self, $who, $where, $what) = @_;
    my $channel = $where->[0];

    $self->irc->yield(
	'privmsg',
	$channel,
	"Currently loaded plugins: " . join(', ', @{ $self->plugin_names }));
}

sub reload_plugins {
    my ($self, $who, $where, $what) = @_;
    my $channel = $where->[0];

    my @package_names = ();
    push @package_names, ref($_) foreach @{ $self->core->_plugins };

    use Data::Dumper;
    print Dumper \@package_names;

    $self->core->_plugins([]);
    Module::Refresh->refresh;
    $self->core->_plugins($self->core->_build_plugins);

    $self->irc->yield('privmsg', $channel, "Plugins have been reloaded:");
    $self->irc->yield('privmsg', $channel, join( ', ', @{ $self->plugin_names }));
}

__PACKAGE__->meta->make_immutable;
