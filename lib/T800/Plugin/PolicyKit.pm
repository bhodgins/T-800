package T800::Plugin::PolicyKit;

use Moose;
use MooseX::Params::Validate qw(validated_list);

use YAML::Tiny;
use Getopt::Long qw(GetOptionsFromString);

with 'T800::Role::Plugin';
with 'T800::Role::Initialization';
with 'T800::Role::PluginCommands';

with 'Universa::Role::Configuration' => {
    class      => 'T800::Plugin::PolicyKit::Config',
    configfile => 'policykit.yml',
};

sub BUILD {}
with 'T800::Role::IRCHandler';

my @arguables = (
    'x',
    );

sub _cmd_test {
    my $self = shift;

    print "HELLO!\n";
}

sub t800_preinit {
    my $self = shift;

    $self->name('policykit');
}

my %filtered_events = (
    'PublicReceiver' => 'on_irc_public',
    # TODO
);

sub on_irc_public {
    my $self = shift;
    my ($who, $where, $what) = @_;

    my $nick = (split '!', $who)[0];
    my $channel = $where->[0];

    # TODO: Plugin oriented commands:
    if ($what =~ /^\!policykit (.*)/) {
	print "COMMAND\n";
	my ($ret, $opts) = GetOptionsFromString($1, @arguables);
	use Data::Dumper;
	print Dumper $opts;
	print Dumper $ret;
    }
}

sub t800_init {
    my $self = shift;

    $self->add_command('test' => '_cmd_test');
    $self->add_command('_default' => '_cmd_default');
}

sub _cmd_default {
    my $self = shift;

    #$self->irc->yield( privmsg => $channel => "PolicyKit is not current unavailable\n");
}

sub t800_postinit {
    my $self = shift;

    my $policykit = $self->core->plugin_named('policykit')
	or die "Can't find PolicyKit, but PolicyKit is loaded\n";

    # Here we will remove the function that dispatches events, then
    # replace it with a new one for policy checking:
    $self->core->meta->make_mutable; # Evil mode
    $self->core->meta->remove_method('plugin_dispatch');

    $self->core->meta->add_method('plugin_dispatch' => sub {
	my ($self, $role, $call, $plugin, $args) = validated_list(
	    \@_,
	    role    => { isa => 'Str' },
	    call    => { isa => 'Str' },
	    plugins => { isa => 'ArrayRef[Str]|Undef', optional => 1 },
	    args    => { isa => 'ArrayRef[Any]',       optional => 1 },
	    );

	# Event policy matches check to ensure acces to events:
	return unless $policykit->event_policy_match($role, $call, $args);

	foreach my $plugin ($self->plugins_with($role)) {
	    # Plugin policy matches check to ensure access to plugins:
	    if ($policykit->plugin_policy_match(ref($plugin), $role, $call, $args)) {
		$plugin->$call(@{ $args }) if $plugin->can($call);
	    }
	}
				  });

    $self->core->meta->make_immutable;
}

# Check policy for given event:
sub event_policy_match {
    my ($self, $args) = @_;

    # TODO
    return $self->config->default_event_policy,
}

sub plugin_policy_match {
    my ($self, $args) = @_;

    # TODO
    return $self->config->default_plugin_policy,
}

__PACKAGE__->meta->make_immutable;

package T800::Plugin::PolicyKit::Config;

use Moose;
with 'MooseX::SimpleConfig';

has 'default_event_policy'  => ( isa => 'Bool', is => 'ro', default => 1 );
has 'default_plugin_policy' => ( isa => 'Bool', is => 'ro', default => 1 );

# TODO

__PACKAGE__->meta->make_immutable;

__DATA__
---
# PolicyKit Configuration:
#
# The default policy is boolean and should be either 1 or 0:
# A default policy of 1 means that by default, the event is allowed.
# A default policy of 0 means that by default, the event is disallowed.
default_event_policy:  1
default_plugin_policy: 1
...
