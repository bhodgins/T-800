package T800::Plugin::PluggableCommands;

use Moose;

with 'T800::Role::Plugin';
with 'T800::Role::PublicReceiver';


with 'Universa::Role::Configuration' => {
    configfile => 'pluggablecommands.yml',
    class      => 'T800::Plugin::PluggableCommands::Config',
};

sub on_irc_public {
    my $self = shift;
    my ($who, $where, $what) = @_;

    #my ($focus, $message) = split ' ', $what, 2;

    my @attention = (
	$self->config->trigger,
	$self->core->config->nick . ': ',
	$self->core->config->nick . ', ',
	);

    if ( grep { $what =~ /^$_/ } @attention) {

	print "I am being summoned!\n";
    }
}

__PACKAGE__->meta->make_immutable;

package T800::Plugin::PluggableCommands::Config;

use Moose;
with 'MooseX::SimpleConfig';

has 'trigger' => (isa => 'Str', is => 'ro', default => '!');


__PACKAGE__->meta->make_immutable;

__DATA__
---
# T800::Plugin::PluggableCommands configuration:
#
# By setting a trigger, the bot has an alternative way of detecting any incoming
# commands given by the user:
trigger: "!"
...
