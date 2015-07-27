package T800::Role::Plugin;

use Moose::Role;


has 'name' => (
    isa    => 'Str',
    is     => 'rw',
    );

has 'core'   => (
    isa      => 'T800',
    is       => 'ro',
    required => 1,
    );

1;
