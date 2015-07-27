package T800::Role::PluginCommands;

use Moose::Role;
use MooseX::Params::Validate;

use Carp qw(carp);

has '_commands' => (
    isa         => 'HashRef[Code]|Undef',
    is          => 'ro',
    builder     => '_build_commands',
    );


sub add_command {
    my ($self, $command, $callback) = pos_validated_list(
	\@_,
	{ does => 'T800::Role::PluginCommands' },
	{ isa  => 'Str'                        },
	{ isa  => 'Str'                        }
	);

    return carp 'Cannott call add_command without a valid callback name'
	unless $self->can($callback);

    $self->_commands->{$command} = $callback
}

sub on_command {
    my ($self, $who, $where, $what) = @_;;

    use Data::Dumper;
    print Dumper @_[1 .. $#_];

    return unless $what;
    my ($command, $rest) = split ' ', $what, 2;
    if ( exists($self->_commands->{$command}) ) {
	my $cb = $self->_commands->{$command};

	print "FOO: $cb\n";
	$self->$cb($who, $where, $rest) if $self->can($cb);
    }

    else {
	if ( exists($self->_commands->{'_default'}) ) {
	    my $cb = $self->_commands->{'_default'};
	    $self->$cb($who, $where, $what) if $self->can($cb);
	}
    }
}

sub _build_commands { {} }

1;
