package T800::Plugin::Test;

use Moose;
with 'T800::Role::Plugin';
with 'T800::Role::PublicReceiver';

sub BUILD {
    my $self = shift;

    $self->name('Example plugin');
}

sub on_irc_public {
    my $self = shift;

    print "received dispatch\n";
    
    use Data::Dumper;
    print Dumper @_;
}

__PACKAGE__->meta->make_immutable;
