package T800::Config;

use Moose;
with 'MooseX::SimpleConfig';

has 'nick'     => (isa => 'Str', is => 'ro', default => "T-800_$$");
has 'ircname'  => (isa => 'Str', is => 'ro', default => 'T-800 IRC Bot');
has 'host'     => (isa => 'Str', is => 'ro', required => 1);

has 'password' => (isa => 'Str|Undef', is => 'ro');
has 'ssl'      => (isa => 'Bool',      is => 'ro', default => 0);
has 'port'     => (isa => 'Int',       is => 'ro', default => 6667); 

has 'channels' => (isa => 'ArrayRef[Str]', is => 'ro', required => 1);
has 'plugins'  => (isa => 'ArrayRef[Str]|Undef', is => 'ro');

__PACKAGE__->meta->make_immutable;

__DATA__
---
# configuration file for T-800
nick: T-800
host: irc.freenode.net

channels:
  - "##9600-baud.net"
...
