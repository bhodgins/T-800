package T800::Plugin::PolicyKit;

use Moose;

with 'T800::Role::Plugin';
with 'T800::Role::Initialization';

with 'Universa::Role::Configuration' => {
    class      => 'T800:Plugin::PolicyKit::Config',
    configfile => 'policykit.yml',
};

package T800::Plugin::PolicyKit::Config;

use Moose;
with 'MooseX::SimpleConfig';


sub t800_preinit {

    print "TEST PREINIT PHASE\n";
}

sub t800_postinit {
    my $self = shift;

    print "Testing\n";

    # Here we will remove the function that dispatches events, then
    # replace it with a new one for policy checking:
    $self->core->remove_method('plugin_dispatch');

    # TODO
}

__PACKAGE__->meta->make_immutable;
