package T800::Plugin::PolicyKit;

use Moose;
use MooseX::Params::Validate qw(pos_validated_list);

use YAML::Tiny;

with 'T800::Role::Plugin';
with 'T800::Role::Initialization';

with 'Universa::Role::Configuration' => {
    class      => 'T800::Plugin::PolicyKit::Config',
    configfile => 'policykit.yml',
};

sub t800_preinit {
    my $self = shift;

    $self->name('policykit');
}

my %filtered_events = (
    'PublicReceiver' => 'on_irc_public',
    # TODO
);

sub t800_postinit {
    my $self = shift;

    my $policykit = $self->core->plugin_named('policykit')
	or die "Can't find PolicyKit, but PolicyKit is loaded\n";

    # Here we will remove the function that dispatches events, then
    # replace it with a new one for policy checking:
    $self->core->meta->make_mutable; # Evil mode
    $self->core->meta->remove_method('plugin_dispatch');

    $self->core->meta->add_method('plugin_dispatch' => sub {
	my ($self, $role, $call, @args) = pos_validated_list(
	    \@_,
	    { does => 'T800' },
	    { isa  => 'Str' },
	    { isa  => 'Str' },
	    MX_PARAMS_VALIDATE_ALLOW_EXTRA => 1,
	    );

	# Event policy matches check to ensure acces to events:
	if ($filtered_events{$role} eq $call) {
	    return unless $policykit->event_policy_match(\@args);
	}

	foreach my $plugin ($self->plugins_with($role)) {
	    # Plugin policy matches check to ensure access to plugins:
	    if ($policykit->plugin_policy_match(ref($plugin), \@args)) {
		$plugin->$call(@args) if $plugin->can($call);
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
